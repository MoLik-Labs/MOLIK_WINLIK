<#
	.SYNOPSIS
	MOLIK WINLIK - Cleanup Center (don cache/temp rac bang cong cu Windows)

	.DESCRIPTION
	Dọn an toàn: Temp người dùng & Windows, cache thumbnail/icon, DirectX
	shader cache, Windows Error Reporting, Delivery Optimization, Windows
	Update download cache, Recycle Bin, DNS cache. Chế độ -Deep dùng thêm
	công cụ có sẵn của Windows: cleanmgr /autoclean và DISM StartComponentCleanup.
	Nguyên tắc an toàn: chỉ xóa nội dung bên trong thư mục đích (không xóa
	thư mục gốc), file đang khóa bị bỏ qua, mỗi mục bọc try/catch riêng,
	báo cáo MB đã giải phóng theo từng mục. -WhatIf chỉ in kế hoạch.
#>

function Get-MolikFolderSizeMB
{
	param([string]$Path)
	if (-not (Test-Path $Path)) { return 0.0 }
	try
	{
		$sum = (Get-ChildItem -Path $Path -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
		if ($null -eq $sum) { return 0.0 }
		return [Math]::Round($sum / 1048576, 1)
	}
	catch { return 0.0 }
}

function Clear-MolikFolderContents
{
	# Xoa noi dung (file/thu muc con) trong $Path, chi file sua truoc
	# $OlderThanDays ngay (0 = tat ca). Tra ve so MB da xoa (uoc luong).
	param([string]$Path, [int]$OlderThanDays = 1, [switch]$WhatIf)
	if (-not (Test-Path $Path)) { return 0.0 }
	$before = Get-MolikFolderSizeMB -Path $Path
	if ($WhatIf) { return $before }
	$cutoff = (Get-Date).AddDays(-$OlderThanDays)
	try
	{
		Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue | ForEach-Object {
			if ($OlderThanDays -le 0 -or $_.LastWriteTime -lt $cutoff)
			{
				Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
			}
		}
	}
	catch {}
	$after = Get-MolikFolderSizeMB -Path $Path
	return [Math]::Round([Math]::Max(0, $before - $after), 1)
}

function Invoke-MolikCleanup
{
	[CmdletBinding()]
	param([switch]$Deep, [switch]$WhatIf)

	Write-Host ""
	Write-Host "  MOLIK WINLIK — CLEANUP CENTER (dọn cache/temp an toàn)" -ForegroundColor White
	if ($WhatIf) { Write-Host "  [WHATIF] Chỉ xem kế hoạch, không xóa gì." -ForegroundColor Yellow }

	$results = @()
	$addResult = { param($Name, $MB) $script:cleanupTotal += $MB; $results += [PSCustomObject]@{ Item = $Name; MB = $MB } }
	$script:cleanupTotal = 0.0

	$sections = @(
		@{ Name = "Temp người dùng (%TEMP%)";        Path = $env:TEMP; Days = 1 }
		@{ Name = "Temp Windows (C:\Windows\Temp)";  Path = "$env:SystemRoot\Temp"; Days = 1 }
		@{ Name = "DirectX Shader Cache";            Path = "$env:LOCALAPPDATA\D3DSCache"; Days = 0 }
		@{ Name = "Windows Error Reporting";         Path = "$env:LOCALAPPDATA\Microsoft\Windows\WER"; Days = 0 }
		@{ Name = "Crash dumps người dùng";          Path = "$env:LOCALAPPDATA\CrashDumps"; Days = 0 }
	)
	foreach ($s in $sections)
	{
		try { $freed = Clear-MolikFolderContents -Path $s.Path -OlderThanDays $s.Days -WhatIf:$WhatIf; & $addResult $s.Name $freed } catch { & $addResult $s.Name 0 }
	}

	# Thumbnail / icon cache (chi file cache, Explorer tu dung lai)
	try
	{
		$explorerCache = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
		$mb = 0.0
		if ((Test-Path $explorerCache) -and -not $WhatIf)
		{
			$beforeT = Get-MolikFolderSizeMB -Path $explorerCache
			Get-ChildItem -Path $explorerCache -Filter "*cache_*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
			$mb = [Math]::Round([Math]::Max(0, $beforeT - (Get-MolikFolderSizeMB -Path $explorerCache)), 1)
		}
		& $addResult "Thumbnail/Icon cache" $mb
	}
	catch { & $addResult "Thumbnail/Icon cache" 0 }

	# Windows Update download cache: dung dich vu -> xoa -> chay lai
	try
	{
		$wuPath = "$env:SystemRoot\SoftwareDistribution\Download"
		$wuFreed = 0.0
		if (-not $WhatIf)
		{
			Stop-Service -Name @("wuauserv", "bits") -Force -ErrorAction SilentlyContinue
			$wuFreed = Clear-MolikFolderContents -Path $wuPath -OlderThanDays 0
			Start-Service -Name @("bits", "wuauserv") -ErrorAction SilentlyContinue
		}
		else { $wuFreed = Get-MolikFolderSizeMB -Path $wuPath }
		& $addResult "Windows Update cache" $wuFreed
	}
	catch { & $addResult "Windows Update cache" 0 }

	# Delivery Optimization cache (cmdlet co san tren Windows 10/11 moi)
	try
	{
		if (-not $WhatIf -and (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue))
		{
			Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue | Out-Null
		}
		& $addResult "Delivery Optimization cache" 0
	}
	catch {}

	# Recycle Bin + DNS cache: cong cu nen cua Windows, an toan tuyet doi
	if (-not $WhatIf)
	{
		try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } catch {}
		try { & "$env:SystemRoot\System32\ipconfig.exe" /flushdns 2>$null | Out-Null } catch {}
	}

	if ($Deep -and -not $WhatIf)
	{
		Write-Host "  [Deep] Đang chạy Disk Cleanup của Windows (cleanmgr /autoclean)..." -ForegroundColor Cyan
		try { Start-Process -FilePath "$env:SystemRoot\System32\cleanmgr.exe" -ArgumentList "/autoclean" -Wait -ErrorAction SilentlyContinue } catch {}
		$isAdmin = $false
		try { $isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch {}
		if ($isAdmin)
		{
			Write-Host "  [Deep] DISM StartComponentCleanup (dọn kho component, hơi lâu)..." -ForegroundColor Cyan
			try { Start-Process -FilePath "$env:SystemRoot\System32\Dism.exe" -ArgumentList "/Online", "/Cleanup-Image", "/StartComponentCleanup" -Wait -NoNewWindow -ErrorAction SilentlyContinue } catch {}
		}
		else { Write-Host "  [Deep] Bỏ qua DISM (cần Admin)." -ForegroundColor Yellow }
	}

	Write-Host ""
	$results | ForEach-Object { Write-Host ("    {0,-38} {1,8} MB" -f $_.Item, $_.MB) -ForegroundColor Gray }
	Write-Host ("  Tổng giải phóng (ước tính): {0} MB" -f $script:cleanupTotal) -ForegroundColor Green
	Write-Host "  Chỉ cache/temp đã được dọn — không đụng Documents/Downloads/dữ liệu cá nhân." -ForegroundColor DarkGray
	return [PSCustomObject]@{ TotalFreedMB = $script:cleanupTotal; Items = $results; Deep = [bool]$Deep }
}
