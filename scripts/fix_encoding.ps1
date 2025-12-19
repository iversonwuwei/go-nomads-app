# Flutter 项目文件编码修复脚本
# 将所有 .dart 文件转换为 UTF-8 无 BOM 编码

param(
    [string]$Path = "lib",
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flutter 文件编码检查与修复工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$files = Get-ChildItem -Path $Path -Filter "*.dart" -Recurse
$totalFiles = $files.Count
$fixedFiles = 0
$errorFiles = @()

Write-Host "正在扫描 $totalFiles 个 Dart 文件..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $files) {
    try {
        # 读取文件原始字节
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        
        # 检查是否有 BOM
        $hasBom = $false
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            $hasBom = $true
        }
        
        # 尝试以 UTF-8 解码
        $utf8 = [System.Text.Encoding]::UTF8
        $content = $utf8.GetString($bytes)
        
        # 检查是否包含乱码特征（连续问号或替换字符）
        $hasGarbage = $content -match '\?{4,}' -or $content -match '\uFFFD'
        
        # 如果有 BOM 或乱码，需要修复
        if ($hasBom -or $hasGarbage) {
            Write-Host "发现问题: $($file.FullName)" -ForegroundColor Red
            
            if ($hasBom) {
                Write-Host "  - 包含 UTF-8 BOM" -ForegroundColor Yellow
            }
            if ($hasGarbage) {
                Write-Host "  - 可能包含乱码字符" -ForegroundColor Yellow
            }
            
            if (-not $DryRun) {
                # 移除 BOM 并重新保存
                if ($hasBom) {
                    $contentWithoutBom = $utf8.GetString($bytes, 3, $bytes.Length - 3)
                    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
                    [System.IO.File]::WriteAllText($file.FullName, $contentWithoutBom, $utf8NoBom)
                    Write-Host "  √ 已移除 BOM" -ForegroundColor Green
                }
            }
            
            $fixedFiles++
        }
    }
    catch {
        $errorFiles += $file.FullName
        Write-Host "错误处理文件: $($file.FullName)" -ForegroundColor Red
        Write-Host "  错误: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "扫描完成!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "总文件数: $totalFiles" -ForegroundColor White
Write-Host "问题文件: $fixedFiles" -ForegroundColor $(if ($fixedFiles -gt 0) { "Yellow" } else { "Green" })
Write-Host "处理错误: $($errorFiles.Count)" -ForegroundColor $(if ($errorFiles.Count -gt 0) { "Red" } else { "Green" })

if ($DryRun) {
    Write-Host ""
    Write-Host "注意: 这是预览模式，未做任何修改。" -ForegroundColor Yellow
    Write-Host "移除 -DryRun 参数以执行实际修复。" -ForegroundColor Yellow
}

Write-Host ""
