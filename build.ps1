# AkashChat API Go 构建脚本
# 用于Windows环境下的项目构建和打包

param(
    [string]$Target = "build",
    [string]$Version = "v1.0.0",
    [switch]$Help
)

# 设置变量
$BinaryName = "akashchat-api-go"
$BuildTime = Get-Date -Format "yyyyMMdd_HHmmss"
$CommitHash = if (Get-Command git -ErrorAction SilentlyContinue) {
    git rev-parse --short HEAD 2>$null
} else {
    "unknown"
}

# 显示帮助信息
function Show-Help {
    Write-Host "AkashChat API Go 构建脚本" -ForegroundColor Green
    Write-Host "使用方法: .\build.ps1 [目标] [选项]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "目标:" -ForegroundColor Cyan
    Write-Host "  build         - 构建当前平台版本 (默认)"
    Write-Host "  build-linux   - 构建 Linux amd64 版本"
    Write-Host "  build-debug   - 构建 Linux amd64 调试版本"
    Write-Host "  clean         - 清理构建文件"
    Write-Host "  package       - 创建发布包"
    Write-Host "  deps          - 安装依赖"
    Write-Host "  test          - 运行测试"
    Write-Host "  run           - 运行应用程序"
    Write-Host "  docker-build  - 构建 Docker 镜像"
    Write-Host ""
    Write-Host "选项:" -ForegroundColor Cyan
    Write-Host "  -Version      - 版本号 (默认: v1.0.0)"
    Write-Host "  -Help         - 显示帮助信息"
    Write-Host ""
    Write-Host "示例:" -ForegroundColor Yellow
    Write-Host "  .\build.ps1 build-linux -Version v1.0.1"
    Write-Host "  .\build.ps1 clean"
    Write-Host "  .\build.ps1 package -Version v2.0.0"
}

# 构建当前平台版本
function Build-Current {
    Write-Host "构建当前平台版本..." -ForegroundColor Green
    $ldflags = "-s -w -X main.Version=$Version -X main.BuildTime=$BuildTime -X main.CommitHash=$CommitHash"
    go build -ldflags "$ldflags" -o "$BinaryName.exe" ./cmd/server
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 构建成功: $BinaryName.exe" -ForegroundColor Green
    } else {
        Write-Host "✗ 构建失败" -ForegroundColor Red
        exit 1
    }
}

# 构建 Linux amd64 版本
function Build-Linux {
    Write-Host "构建 Linux amd64 版本..." -ForegroundColor Green
    $env:CGO_ENABLED = "0"
    $env:GOOS = "linux"
    $env:GOARCH = "amd64"
    $ldflags = "-s -w -X main.Version=$Version -X main.BuildTime=$BuildTime -X main.CommitHash=$CommitHash"
    go build -ldflags "$ldflags" -o "$BinaryName-linux-amd64" ./cmd/server
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 构建成功: $BinaryName-linux-amd64" -ForegroundColor Green
    } else {
        Write-Host "✗ 构建失败" -ForegroundColor Red
        exit 1
    }
    # 恢复环境变量
    Remove-Item Env:CGO_ENABLED -ErrorAction SilentlyContinue
    Remove-Item Env:GOOS -ErrorAction SilentlyContinue
    Remove-Item Env:GOARCH -ErrorAction SilentlyContinue
}

# 构建 Linux amd64 调试版本
function Build-LinuxDebug {
    Write-Host "构建 Linux amd64 调试版本..." -ForegroundColor Green
    $env:CGO_ENABLED = "0"
    $env:GOOS = "linux"
    $env:GOARCH = "amd64"
    go build -o "$BinaryName-linux-amd64-debug" ./cmd/server
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 构建成功: $BinaryName-linux-amd64-debug" -ForegroundColor Green
    } else {
        Write-Host "✗ 构建失败" -ForegroundColor Red
        exit 1
    }
    Remove-Item Env:CGO_ENABLED -ErrorAction SilentlyContinue
    Remove-Item Env:GOOS -ErrorAction SilentlyContinue
    Remove-Item Env:GOARCH -ErrorAction SilentlyContinue
}

# 清理构建文件
function Clean-Build {
    Write-Host "清理构建文件..." -ForegroundColor Yellow
    $files = @("$BinaryName.exe", "$BinaryName-linux-amd64", "$BinaryName-linux-amd64-debug")
    foreach ($file in $files) {
        if (Test-Path $file) {
            Remove-Item $file -Force
            Write-Host "✓ 已删除: $file" -ForegroundColor Green
        }
    }
    if (Test-Path "release") {
        Remove-Item "release" -Recurse -Force
        Write-Host "✓ 已删除: release 目录" -ForegroundColor Green
    }
}

# 创建发布包
function Create-Package {
    Write-Host "创建发布包..." -ForegroundColor Green

    # 首先构建Linux版本
    Build-Linux

    # 创建release目录
    New-Item -ItemType Directory -Path "release" -Force | Out-Null

    # 复制文件
    Copy-Item "$BinaryName-linux-amd64" "release\" -Force
    if (Test-Path "README.md") {
        Copy-Item "README.md" "release\" -Force
    }
    if (Test-Path "LICENSE") {
        Copy-Item "LICENSE" "release\" -Force
    }
    if (Test-Path "config") {
        Copy-Item "config" "release\" -Recurse -Force
    }

    # 创建压缩包
    $packagePath = "release\$BinaryName-$Version-linux-amd64.tar.gz"
    if (Get-Command tar -ErrorAction SilentlyContinue) {
        # 使用系统tar命令
        Set-Location "release"
        tar -czf "../$packagePath" *
        Set-Location ".."
    } else {
        Write-Host "警告: 未找到tar命令，请手动压缩release目录" -ForegroundColor Yellow
        return
    }

    Write-Host "✓ 发布包已创建: $packagePath" -ForegroundColor Green
}

# 安装依赖
function Install-Deps {
    Write-Host "安装依赖..." -ForegroundColor Green
    go mod download
    go mod tidy
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 依赖安装完成" -ForegroundColor Green
    } else {
        Write-Host "✗ 依赖安装失败" -ForegroundColor Red
        exit 1
    }
}

# 运行测试
function Run-Tests {
    Write-Host "运行测试..." -ForegroundColor Green
    go test -v ./...
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 所有测试通过" -ForegroundColor Green
    } else {
        Write-Host "✗ 测试失败" -ForegroundColor Red
        exit 1
    }
}

# 运行应用程序
function Run-App {
    Write-Host "运行应用程序..." -ForegroundColor Green
    go run ./cmd/server
}

# 构建 Docker 镜像
function Build-Docker {
    Write-Host "构建 Docker 镜像..." -ForegroundColor Green
    docker build -t "akashchat-api-go:$Version" .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker 镜像构建成功: akashchat-api-go:$Version" -ForegroundColor Green
    } else {
        Write-Host "✗ Docker 镜像构建失败" -ForegroundColor Red
        exit 1
    }
}

# 主逻辑
if ($Help) {
    Show-Help
    exit 0
}

Write-Host "AkashChat API Go 构建脚本" -ForegroundColor Green
Write-Host "版本: $Version" -ForegroundColor Cyan
Write-Host "构建时间: $BuildTime" -ForegroundColor Cyan
Write-Host "提交哈希: $CommitHash" -ForegroundColor Cyan
Write-Host "目标: $Target" -ForegroundColor Cyan
Write-Host ""

switch ($Target.ToLower()) {
    "build" { Build-Current }
    "build-linux" { Build-Linux }
    "build-debug" { Build-LinuxDebug }
    "clean" { Clean-Build }
    "package" { Create-Package }
    "deps" { Install-Deps }
    "test" { Run-Tests }
    "run" { Run-App }
    "docker-build" { Build-Docker }
    default {
        Write-Host "未知目标: $Target" -ForegroundColor Red
        Write-Host "使用 -Help 查看可用目标" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "✓ 完成!" -ForegroundColor Green
