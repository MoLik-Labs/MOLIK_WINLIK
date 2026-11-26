<#
	.SYNOPSIS
	MOLIK WINLIK - Online Update / Repair (KÊNH ONLINE TÙY CHỌN, tách riêng)

	.DESCRIPTION
	Đây là file DUY NHẤT của dự án được phép chạm mạng, và chỉ khi người
	dùng chủ động chạy -Update / -Repair (hoặc win.ps1 / MOLIK_WINLIK-Online.bat):
	  - Tải MolikWinlik-Portable.ps1 + file .sha256 từ repo chính thức
	  - KIỂM CHỨNG SHA256: lệch hash là hủy ngay, không thay gì
	  - Sao lưu bản hiện tại thành .bak-<thời gian> trước khi thay
	  - Bản Portable đang chạy được thay bằng tiến trình phụ sau khi thoát
	Bản Portable phân phối cho người dùng KHÔNG chứa file này và vẫn
	offline 100% (SelfTest/audit kiểm tra điều đó).
#>

function Update-MolikWinlik
{
	[CmdletBinding()]
	param([switch]$Force)

	$repo = "MoLik-Labs/MOLIK_WINLIK"
	$base = "https://raw.githubusercontent.com/$repo/main"
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
		Invoke-WebRequest -Uri "$base/MolikWinlik-Portable.ps1" -OutFile $newFile -UseBasicParsing -ErrorAction Stop
		Invoke-WebRequest -Uri "$base/MolikWinlik-Portable.ps1.sha256" -OutFile $hashFile -UseBasicParsing -ErrorAction Stop

		$expected = ((Get-Content $hashFile -Raw).Trim() -split '\s+')[0].ToLower()
		$actual = (Get-FileHash -Path $newFile -Algorithm SHA256).Hash.ToLower()
		if ($expected -ne $actual)
		{
			Write-Host "  [X] SHA256 KHÔNG KHỚP (mong đợi $expected, nhận $actual) — đã hủy, giữ nguyên bản hiện tại." -ForegroundColor Red
			return $false
		}
		Write-Host "  [✓] SHA256 khớp: $actual" -ForegroundColor Green

		$newText = Get-Content $newFile -Raw
		$newVersion = if ($newText -match 'MolikWinlikVersion = "([0-9.]+)"') { $Matches[1] } else { "?" }
		$curVersion = if ($Global:MolikWinlikVersion) { $Global:MolikWinlikVersion } else { "?" }
		Write-Host "  Phiên bản: hiện tại v$curVersion → tải về v$newVersion" -ForegroundColor Cyan
		if ((-not $Force) -and ($newVersion -eq $curVersion))
		{
			Write-Host "  [✓] Bạn đang ở bản mới nhất. Dùng -Repair nếu muốn thay lại bản sạch." -ForegroundColor Green
			return $true
		}

		# File dich: ban Portable canh launcher dang chay (chuan phan phoi)
		$runDir = if ($PSCommandPath) { Split-Path $PSCommandPath -Parent } else { (Get-Location).Path }
		$target = Join-Path $runDir "MolikWinlik-Portable.ps1"
		if (-not (Test-Path $target)) { $target = $PSCommandPath }
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
