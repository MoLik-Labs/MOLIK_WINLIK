<#
	.SYNOPSIS
	MOLIK WINLIK - Online Update / Repair / Check (KÊNH ONLINE TÙY CHỌN, tách riêng)

	.DESCRIPTION
	Đây là file DUY NHẤT của dự án được phép chạm mạng, và chỉ khi người
	dùng chủ động chạy -CheckUpdate / -Update / -Repair (hoặc win.ps1 /
	MOLIK_WINLIK-Online.bat):
	  - Tải MolikWinlik-Portable.ps1 + file .sha256 từ repo chính thức
	    (tối đa 3 lần thử mỗi file)
	  - KIỂM CHỨNG SHA256: lệch hash là hủy ngay, không thay gì
	  - Kiểm tra cú pháp PowerShell của bản mới trước khi thay
	  - Sao lưu bản hiện tại thành .bak-<thời gian> trước khi thay
	  - Bản Portable đang chạy được thay bằng tiến trình phụ sau khi thoát
	Bản Portable phân phối cho người dùng KHÔNG chứa file này và vẫn
	offline 100% (SelfTest/audit kiểm tra điều đó).
#>

function Get-MolikOnlineBase
{
	return "https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main"
}

function Invoke-MolikDownload
{
	# Tai 1 file voi toi da 3 lan thu (mang chop chon khong lam hong phien cap nhat)
	param([string]$Uri, [string]$OutFile)
	$lastError = $null
	for ($i = 1; $i -le 3; $i++)
	{
		try
		{
			Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
			return $true
		}
		catch
		{
			$lastError = $_
			if ($i -lt 3) { Write-Host "  [i] Tải lần $i lỗi — thử lại sau 2 giây..." -ForegroundColor Yellow; Start-Sleep -Seconds 2 }
		}
	}
	throw "Không tải được sau 3 lần thử: $($lastError.Exception.Message)"
}

function Get-MolikUpdateTarget
{
	# File Portable can thay: ban canh launcher dang chay (chuan phan phoi)
	$runDir = if ($PSCommandPath) { Split-Path $PSCommandPath -Parent } else { (Get-Location).Path }
	$target = Join-Path $runDir "MolikWinlik-Portable.ps1"
	if (-not (Test-Path $target)) { $target = $PSCommandPath }
	return $target
}

function Test-MolikDownloadedPortable
{
	# Ban moi phai qua 3 cua: dung luong hop ly, co version marker,
	# va parse cu phap PowerShell khong loi.
	param([string]$Path)
	if (-not (Test-Path $Path)) { return "thiếu file" }
	if ((Get-Item $Path).Length -lt 102400) { return "dung lượng bất thường (nhỏ hơn 100 KB)" }
	$text = Get-Content $Path -Raw
	if ($text -notmatch 'MolikWinlikVersion = "([0-9.]+)"') { return "không có version marker của MOLIK WINLIK" }
	$tokens = $null; $parseErrors = $null
	[void][System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$parseErrors)
	if ($parseErrors -and $parseErrors.Count -gt 0) { return "$($parseErrors.Count) lỗi cú pháp PowerShell" }
	return ""
}

function Test-MolikUpdateAvailable
{
	# Chi KIEM TRA (khong thay gi): so SHA256 ban hien tai voi ban tren repo.
	[CmdletBinding()]
	param()

	Write-Host ""
	Write-Host "  MOLIK WINLIK — KIỂM TRA CẬP NHẬT (online)" -ForegroundColor White
	try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
	$base = Get-MolikOnlineBase
	$tmpDir = Join-Path $env:TEMP ("MolikCheck_" + [Guid]::NewGuid().ToString("N"))
	New-Item -Path $tmpDir -ItemType Directory -Force | Out-Null
	try
	{
		$hashFile = Join-Path $tmpDir "latest.sha256"
		Invoke-MolikDownload -Uri "$base/MolikWinlik-Portable.ps1.sha256" -OutFile $hashFile | Out-Null
		$remoteHash = ((Get-Content $hashFile -Raw).Trim() -split '\s+')[0].ToLower()
		$target = Get-MolikUpdateTarget
		$curVersion = if ($Global:MolikWinlikVersion) { $Global:MolikWinlikVersion } else { "?" }
		if ($target -and (Test-Path $target))
		{
			$localHash = (Get-FileHash -Path $target -Algorithm SHA256).Hash.ToLower()
			if ($localHash -eq $remoteHash)
			{
				Write-Host "  [✓] Bạn đang ở bản mới nhất (v$curVersion, SHA256 khớp repo)." -ForegroundColor Green
				return [PSCustomObject]@{ CurrentVersion = $curVersion; RemoteHash = $remoteHash; UpdateAvailable = $false }
			}
		}
		$newFile = Join-Path $tmpDir "MolikWinlik-Portable.ps1"
		Invoke-MolikDownload -Uri "$base/MolikWinlik-Portable.ps1" -OutFile $newFile | Out-Null
		$actual = (Get-FileHash -Path $newFile -Algorithm SHA256).Hash.ToLower()
		if ($actual -ne $remoteHash)
		{
			Write-Host "  [!] Không kiểm tra chắc chắn được lúc này (bản tải thử lệch hash — thử lại sau)." -ForegroundColor Yellow
			return [PSCustomObject]@{ CurrentVersion = $curVersion; RemoteHash = $remoteHash; UpdateAvailable = $null }
		}
		$newText = Get-Content $newFile -Raw
		$newVersion = if ($newText -match 'MolikWinlikVersion = "([0-9.]+)"') { $Matches[1] } else { "?" }
		Write-Host "  [↓] Có bản khác trên repo: bạn v$curVersion → repo v$newVersion." -ForegroundColor Yellow
		Write-Host "      Cập nhật an toàn: MOLIK_WINLIK.bat -Update (hoặc -Repair để thay bản sạch)." -ForegroundColor Gray
		return [PSCustomObject]@{ CurrentVersion = $curVersion; RemoteVersion = $newVersion; RemoteHash = $remoteHash; UpdateAvailable = ($newVersion -ne $curVersion) }
	}
	catch
	{
		Write-Host "  [X] Kiểm tra lỗi: $($_.Exception.Message)" -ForegroundColor Red
		return $null
	}
	finally { Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue }
}

function Update-MolikWinlik
{
	[CmdletBinding()]
	param([switch]$Force)

	$base = Get-MolikOnlineBase
	Write-Host ""
	Write-Host "  MOLIK WINLIK — ONLINE UPDATE $(if ($Force) { '(REPAIR: thay cả khi cùng version)' })" -ForegroundColor White
	Write-Host "  Nguồn duy nhất: $base" -ForegroundColor DarkGray
	try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

	$tmpDir = Join-Path $env:TEMP ("MolikUpdate_" + [Guid]::NewGuid().ToString("N"))
	New-Item -Path $tmpDir -ItemType Directory -Force | Out-Null
	try
	{
		$newFile = Join-Path $tmpDir "MolikWinlik-Portable.ps1"
		$hashFile = Join-Path $tmpDir "MolikWinlik-Portable.ps1.sha256"
		Write-Host "  Đang tải bản mới nhất..." -ForegroundColor Cyan
		Invoke-MolikDownload -Uri "$base/MolikWinlik-Portable.ps1" -OutFile $newFile | Out-Null
		Invoke-MolikDownload -Uri "$base/MolikWinlik-Portable.ps1.sha256" -OutFile $hashFile | Out-Null

		$expected = ((Get-Content $hashFile -Raw).Trim() -split '\s+')[0].ToLower()
		$actual = (Get-FileHash -Path $newFile -Algorithm SHA256).Hash.ToLower()
		if ($expected -ne $actual)
		{
			Write-Host "  [X] SHA256 KHÔNG KHỚP (mong đợi $expected, nhận $actual) — đã hủy, giữ nguyên bản hiện tại." -ForegroundColor Red
			return $false
		}
		Write-Host "  [✓] SHA256 khớp: $actual" -ForegroundColor Green

		$invalid = Test-MolikDownloadedPortable -Path $newFile
		if ($invalid)
		{
			Write-Host "  [X] Bản tải về không hợp lệ ($invalid) — đã hủy, giữ nguyên bản hiện tại." -ForegroundColor Red
			return $false
		}
		Write-Host "  [✓] Bản mới qua kiểm tra cú pháp & định dạng." -ForegroundColor Green

		$newText = Get-Content $newFile -Raw
		$newVersion = if ($newText -match 'MolikWinlikVersion = "([0-9.]+)"') { $Matches[1] } else { "?" }
		$curVersion = if ($Global:MolikWinlikVersion) { $Global:MolikWinlikVersion } else { "?" }
		Write-Host "  Phiên bản: hiện tại v$curVersion → tải về v$newVersion" -ForegroundColor Cyan
		if ((-not $Force) -and ($newVersion -eq $curVersion))
		{
			Write-Host "  [✓] Bạn đang ở bản mới nhất. Dùng -Repair nếu muốn thay lại bản sạch." -ForegroundColor Green
			return $true
		}

		$target = Get-MolikUpdateTarget
		if (-not $target) { Write-Host "  [X] Không xác định được file cần thay." -ForegroundColor Red; return $false }

		$bak = "$target.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
		Copy-Item $target $bak -Force -ErrorAction SilentlyContinue
		Write-Host "  Đã sao lưu bản cũ: $bak" -ForegroundColor DarkGray

		$isRunningPortable = ($PSCommandPath -and ((Split-Path $PSCommandPath -Leaf) -like "*Portable*") -and ((Resolve-Path $PSCommandPath).Path -eq (Resolve-Path $target).Path))
		if ($isRunningPortable)
		{
			# Khong ghi de file dang chay: tien trinh phu thay sau 3 giay
			$staged = "$target.new"
			Copy-Item $newFile $staged -Force
			$cmdLine = "timeout /t 3 /nobreak >nul & move /y `"$staged`" `"$target`" >nul"
			Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmdLine" -WindowStyle Hidden
			Write-Host "  [✓] Đã tải & kiểm chứng xong — bản v$newVersion sẽ thay thế ngay khi bạn đóng cửa sổ này. Mở lại MOLIK_WINLIK.bat để dùng bản mới." -ForegroundColor Green
		}
		else
		{
			Copy-Item $newFile $target -Force -ErrorAction Stop
			Write-Host "  [✓] Đã thay $target bằng bản v$newVersion (bản cũ ở $bak). Chạy lại MOLIK_WINLIK.bat để dùng." -ForegroundColor Green
		}
		return $true
	}
	catch
	{
		Write-Host "  [X] Update lỗi: $($_.Exception.Message)" -ForegroundColor Red
		Write-Host "      Không sao: bản hiện tại vẫn nguyên vẹn. Kiểm tra mạng rồi chạy lại -Update, hoặc tải ZIP mới từ GitHub." -ForegroundColor Yellow
		return $false
	}
	finally
	{
		Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
	}
}
