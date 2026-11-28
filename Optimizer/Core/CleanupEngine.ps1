<#
	.SYNOPSIS
	MOLIK WINLIK - Cleanup & Repair Center (don rac + sua Windows an toan)

	.DESCRIPTION
	Nguyên tắc: XÓA GÌ CŨNG PHẢI HOÀN LẠI ĐƯỢC.
	- Mặc định, Cleanup KHÔNG xóa hẳn: mọi thứ được chuyển vào vùng cách ly
	  C:\MOLIK_WINLIK_Backups\Quarantine\Cleanup_<thời gian>\ kèm manifest.json
	  (đường dẫn gốc). -RestoreCleanup (hoặc Restore-MolikLastCleanup) đưa
	  mọi thứ về chỗ cũ. Vùng cách ly tự dọn sau 30 ngày (có thông báo).
	- -Permanent mới xóa hẳn. Recycle Bin CHỈ dọn ở chế độ -Deep và có cảnh
	  báo (vì thùng rác đã là lớp hoàn tác cuối của Windows).
	- -Deep dùng công cụ Windows có sẵn: cleanmgr /autoclean + DISM cleanup.
	- Invoke-MolikWindowsRepair: DISM RestoreHealth + SFC /scannow chính chủ.
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
	# Xu ly noi dung trong $Path (chi muc sua truoc $OlderThanDays ngay):
	# co $QuarantineRoot thi CHUYEN vao do + ghi manifest, khong thi xoa han.
	param([string]$Path, [int]$OlderThanDays = 1, [string]$QuarantineRoot = "", [switch]$WhatIf)
	if (-not (Test-Path $Path)) { return 0.0 }
	$before = Get-MolikFolderSizeMB -Path $Path
	if ($WhatIf) { return $before }
	$cutoff = (Get-Date).AddDays(-$OlderThanDays)
	try
	{
		Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue | ForEach-Object {
			if ($OlderThanDays -le 0 -or $_.LastWriteTime -lt $cutoff)
			{
				if ($QuarantineRoot)
				{
					$dest = Join-Path $QuarantineRoot ([Guid]::NewGuid().ToString("N") + "_" + $_.Name)
					try
					{
						Move-Item -LiteralPath $_.FullName -Destination $dest -Force -ErrorAction Stop
						$script:MolikCleanupManifest += [PSCustomObject]@{ From = $_.FullName; To = $dest }
					}
					catch {}
				}
				else
				{
					Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
				}
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
	param([switch]$Deep, [switch]$Permanent, [switch]$WhatIf)

	Write-Host ""
	Write-Host "  MOLIK WINLIK — CLEANUP CENTER (dọn cache/temp, hoàn lại được)" -ForegroundColor White
	$script:MolikCleanupManifest = @()
	$script:cleanupTotal = 0.0

	# Tu don vung cach ly qua 30 ngay (thong bao ro rang)
	$quarantineBase = "$env:SystemDrive\MOLIK_WINLIK_Backups\Quarantine"
	if ((Test-Path $quarantineBase) -and -not $WhatIf)
	{
		Get-ChildItem -Path $quarantineBase -Directory -ErrorAction SilentlyContinue |
			Where-Object { $_.Name -like "Cleanup_*" -and $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
			ForEach-Object { Write-Host "  [i] Xóa hẳn vùng cách ly cũ (>30 ngày): $($_.Name)" -ForegroundColor DarkGray; Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
	}

	$quarantineRoot = ""
	if (-not $Permanent -and -not $WhatIf)
	{
		$quarantineRoot = Join-Path $quarantineBase ("Cleanup_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
		New-Item -Path $quarantineRoot -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
		Write-Host "  Chế độ an toàn: mọi thứ được CHUYỂN vào vùng cách ly (hoàn lại bằng -RestoreCleanup), không xóa hẳn." -ForegroundColor Cyan
	}
	elseif ($Permanent) { Write-Host "  [!] Chế độ -Permanent: XÓA HẲN, không qua vùng cách ly." -ForegroundColor Yellow }

	$results = @()
	$addResult = { param($Name, $MB) $script:cleanupTotal += $MB; $results += [PSCustomObject]@{ Item = $Name; MB = $MB } }

	$sections = @(
		@{ Name = "Temp người dùng (%TEMP%)";       Path = $env:TEMP; Days = 1 }
		@{ Name = "Temp Windows (C:\Windows\Temp)"; Path = "$env:SystemRoot\Temp"; Days = 1 }
		@{ Name = "DirectX Shader Cache";           Path = "$env:LOCALAPPDATA\D3DSCache"; Days = 0 }
		@{ Name = "Windows Error Reporting";        Path = "$env:LOCALAPPDATA\Microsoft\Windows\WER"; Days = 0 }
		@{ Name = "Crash dumps người dùng";         Path = "$env:LOCALAPPDATA\CrashDumps"; Days = 0 }
	)
	foreach ($s in $sections)
	{
		try { & $addResult $s.Name (Clear-MolikFolderContents -Path $s.Path -OlderThanDays $s.Days -QuarantineRoot $quarantineRoot -WhatIf:$WhatIf) } catch { & $addResult $s.Name 0 }
	}

	# Thumbnail / icon cache (Explorer tu dung lai)
	try
	{
		$explorerCache = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
		$mbT = 0.0
		if ((Test-Path $explorerCache) -and -not $WhatIf)
		{
			$beforeT = Get-MolikFolderSizeMB -Path $explorerCache
			Get-ChildItem -Path $explorerCache -Filter "*cache_*.db" -Force -ErrorAction SilentlyContinue | ForEach-Object {
				if ($quarantineRoot)
				{
					$dest = Join-Path $quarantineRoot ([Guid]::NewGuid().ToString("N") + "_" + $_.Name)
					try { Move-Item -LiteralPath $_.FullName -Destination $dest -Force -ErrorAction Stop; $script:MolikCleanupManifest += [PSCustomObject]@{ From = $_.FullName; To = $dest } } catch {}
				}
				else { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue }
			}
			$mbT = [Math]::Round([Math]::Max(0, $beforeT - (Get-MolikFolderSizeMB -Path $explorerCache)), 1)
		}
		& $addResult "Thumbnail/Icon cache" $mbT
	}
	catch { & $addResult "Thumbnail/Icon cache" 0 }

	# Windows Update cache: dung dich vu -> xu ly -> chay lai dich vu
	try
	{
		$wuPath = "$env:SystemRoot\SoftwareDistribution\Download"
		$wuFreed = 0.0
		if (-not $WhatIf)
		{
			Stop-Service -Name @("wuauserv", "bits") -Force -ErrorAction SilentlyContinue
			$wuFreed = Clear-MolikFolderContents -Path $wuPath -OlderThanDays 0 -QuarantineRoot $quarantineRoot
			Start-Service -Name @("bits", "wuauserv") -ErrorAction SilentlyContinue
		}
		else { $wuFreed = Get-MolikFolderSizeMB -Path $wuPath }
		& $addResult "Windows Update cache" $wuFreed
	}
	catch { & $addResult "Windows Update cache" 0 }

	try
	{
		if (-not $WhatIf -and (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue))
		{
			Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue | Out-Null
		}
		& $addResult "Delivery Optimization cache" 0
	}
	catch {}

	if (-not $WhatIf)
	{
		try { & "$env:SystemRoot\System32\ipconfig.exe" /flushdns 2>$null | Out-Null } catch {}
	}

	if ($Deep -and -not $WhatIf)
	{
		Write-Host "  [Deep] Disk Cleanup của Windows (cleanmgr /autoclean)..." -ForegroundColor Cyan
		try { Start-Process -FilePath "$env:SystemRoot\System32\cleanmgr.exe" -ArgumentList "/autoclean" -Wait -ErrorAction SilentlyContinue } catch {}
		Write-Host "  [Deep] Dọn Recycle Bin (VĨNH VIỄN — thùng rác là lớp hoàn tác cuối, chỉ dọn khi bạn chọn Deep)." -ForegroundColor Yellow
		try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } catch {}
		$isAdmin = $false
		try { $isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch {}
		if ($isAdmin)
		{
			Write-Host "  [Deep] DISM StartComponentCleanup (hơi lâu)..." -ForegroundColor Cyan
			try { Start-Process -FilePath "$env:SystemRoot\System32\Dism.exe" -ArgumentList "/Online", "/Cleanup-Image", "/StartComponentCleanup" -Wait -NoNewWindow -ErrorAction SilentlyContinue } catch {}
		}
		else { Write-Host "  [Deep] Bỏ qua DISM (cần Admin)." -ForegroundColor Yellow }
	}

	# Ghi manifest de hoan tac duoc
	if ($quarantineRoot -and $script:MolikCleanupManifest.Count -gt 0)
	{
		try { $script:MolikCleanupManifest | ConvertTo-Json | Set-Content (Join-Path $quarantineRoot "manifest.json") -Encoding UTF8 -Force } catch {}
		Write-Host "  Vùng cách ly: $quarantineRoot ($($script:MolikCleanupManifest.Count) mục) — hoàn lại: MOLIK_WINLIK.bat -RestoreCleanup" -ForegroundColor Cyan
	}
	elseif ($quarantineRoot) { Remove-Item $quarantineRoot -Force -ErrorAction SilentlyContinue }

	Write-Host ""
	$results | ForEach-Object { Write-Host ("    {0,-38} {1,8} MB" -f $_.Item, $_.MB) -ForegroundColor Gray }
	Write-Host ("  Tổng đã dọn khỏi vị trí gốc: {0} MB" -f $script:cleanupTotal) -ForegroundColor Green
	Write-Host "  Chỉ cache/temp — không đụng Documents/Downloads/dữ liệu cá nhân." -ForegroundColor DarkGray
	return [PSCustomObject]@{ TotalFreedMB = $script:cleanupTotal; Items = $results; Deep = [bool]$Deep; Quarantine = $quarantineRoot }
}

function Restore-MolikLastCleanup
{
	# Hoan tac Cleanup gan nhat: doc manifest vung cach ly, dua tung muc
	# ve dung duong dan goc (muc nao da co file moi thi bo qua, khong de).
	[CmdletBinding()]
	param([switch]$Force)

	$quarantineBase = "$env:SystemDrive\MOLIK_WINLIK_Backups\Quarantine"
	$latest = Get-ChildItem -Path $quarantineBase -Directory -ErrorAction SilentlyContinue |
		Where-Object { $_.Name -like "Cleanup_*" } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
	if (-not $latest) { Write-Host "  [!] Không có vùng cách ly Cleanup nào để hoàn tác." -ForegroundColor Yellow; return $false }
	$manifestFile = Join-Path $latest.FullName "manifest.json"
	if (-not (Test-Path $manifestFile)) { Write-Host "  [!] Vùng cách ly $($latest.Name) thiếu manifest.json — không hoàn tác tự động được." -ForegroundColor Red; return $false }
	$entries = @(Get-Content $manifestFile -Raw | ConvertFrom-Json)
	Write-Host "  Hoàn tác Cleanup $($latest.Name): $($entries.Count) mục." -ForegroundColor Cyan
	if (-not $Force)
	{
		$c = Read-Host "  Đưa mọi thứ về vị trí gốc? (Y/N)"
		if ($c -notmatch '^[Yy]') { Write-Host "  Đã hủy."; return $false }
	}
	$done = 0; $skipped = 0
	foreach ($e in $entries)
	{
		try
		{
			if (-not (Test-Path $e.To)) { $skipped++; continue }
			if (Test-Path $e.From) { $skipped++; continue }
			$parent = Split-Path $e.From -Parent
			if ($parent -and -not (Test-Path $parent)) { New-Item -Path $parent -ItemType Directory -Force | Out-Null }
			Move-Item -LiteralPath $e.To -Destination $e.From -Force -ErrorAction Stop
			$done++
		}
		catch { $skipped++ }
	}
	try { Rename-Item -Path $latest.FullName -NewName ("Restored_" + $latest.Name) -ErrorAction SilentlyContinue } catch {}
	Write-Host "  Hoàn tác xong: $done mục về chỗ cũ, $skipped mục bỏ qua (đã có file mới hoặc thiếu file)." -ForegroundColor Green
	return $true
}

function Invoke-MolikWindowsRepair
{
	# Sua chua he thong bang cong cu chinh chu cua Windows (can Admin):
	# DISM RestoreHealth (sua kho component tu Windows Update/local) -> SFC.
	[CmdletBinding()]
	param()

	Write-Host ""
	Write-Host "  MOLIK WINLIK — WINDOWS REPAIR (DISM + SFC chính chủ)" -ForegroundColor White
	$isAdmin = $false
	try { $isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch {}
	if (-not $isAdmin) { Write-Host "  [X] Cần quyền Administrator — chạy MOLIK_WINLIK.bat (tự xin Admin)." -ForegroundColor Red; return $false }

	Write-Host "  [1/2] DISM /Online /Cleanup-Image /RestoreHealth (vài phút)..." -ForegroundColor Cyan
	try { Start-Process -FilePath "$env:SystemRoot\System32\Dism.exe" -ArgumentList "/Online", "/Cleanup-Image", "/RestoreHealth" -Wait -NoNewWindow -ErrorAction Stop } catch { Write-Host "  [!] DISM lỗi: $($_.Exception.Message)" -ForegroundColor Yellow }
	Write-Host "  [2/2] sfc /scannow (quét & sửa file hệ thống)..." -ForegroundColor Cyan
	try { Start-Process -FilePath "$env:SystemRoot\System32\sfc.exe" -ArgumentList "/scannow" -Wait -NoNewWindow -ErrorAction Stop } catch { Write-Host "  [!] SFC lỗi: $($_.Exception.Message)" -ForegroundColor Yellow }
	Write-Host "  [✓] Đã chạy xong DISM + SFC. Khởi động lại máy rồi chạy -Doctor để kiểm tra lại." -ForegroundColor Green
	return $true
}
