<#
	.SYNOPSIS
	MOLIK WINLIK - Online bootstrapper (KÊNH ONLINE TÙY CHỌN, kiểm chứng SHA256)

	.DESCRIPTION
	Cách chạy online (luôn lấy bản mới nhất từ repo chính thức):

	  irm https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1 | iex

	Hoặc tải file này về rồi chạy kèm tham số chuyển tiếp cho Portable:

	  powershell -ExecutionPolicy Bypass -File .\win.ps1 -Gui
	  powershell -ExecutionPolicy Bypass -File .\win.ps1 -Mode HardcoreGaming -Apply -Yes

	Quy trình an toàn:
	1. Tải file .sha256 (rất nhỏ) từ repo chính thức trước.
	2. Nếu bản cache ở %LOCALAPPDATA%\MOLIK_WINLIK đã khớp SHA256 đó thì
	   dùng luôn (khởi động nhanh, không tải lại 390KB).
	3. Nếu chưa có/khác hash: tải Portable (tối đa 3 lần thử), KIỂM CHỨNG
	   SHA256 + kiểm tra cú pháp PowerShell, sao lưu bản cache cũ thành
	   .bak-<thời gian> rồi mới thay.
	4. Tự xin quyền Administrator và chạy file LOCAL đã kiểm chứng.
	Bản offline (MOLIK_WINLIK.bat cạnh MolikWinlik-Portable.ps1) vẫn là
	cách chạy chuẩn — kênh này chỉ để tiện lấy bản mới / trải nghiệm nhanh.
#>
param(
	[switch]$Force,
	[switch]$NoLaunch,
	[Parameter(ValueFromRemainingArguments = $true)][string[]]$MolikArgs
)

$ErrorActionPreference = "Stop"
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$repo = "MoLik-Labs/MOLIK_WINLIK"
$base = "https://raw.githubusercontent.com/$repo/main"
$dir = Join-Path $env:LOCALAPPDATA "MOLIK_WINLIK"
New-Item -Path $dir -ItemType Directory -Force | Out-Null
$file = Join-Path $dir "MolikWinlik-Portable.ps1"
$hashTmp = Join-Path $dir "latest.sha256"

function Get-MolikOnlineFile
{
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
			if ($i -lt 3) { Write-Host "  [i] Tải lần $i lỗi ($($_.Exception.Message)) — thử lại sau 2 giây..." -ForegroundColor Yellow; Start-Sleep -Seconds 2 }
		}
	}
	throw "Không tải được $Uri sau 3 lần thử: $($lastError.Exception.Message)"
}

Write-Host ""
Write-Host "  MOLIK WINLIK (online) — nguồn chính thức: github.com/$repo" -ForegroundColor Cyan
Write-Host "  Đang kiểm tra bản mới nhất (đọc SHA256 trước)..." -ForegroundColor Gray
Get-MolikOnlineFile -Uri "$base/MolikWinlik-Portable.ps1.sha256" -OutFile $hashTmp | Out-Null
$expected = ((Get-Content $hashTmp -Raw).Trim() -split '\s+')[0].ToLower()

$needDownload = $Force -or -not (Test-Path $file)
if (-not $needDownload)
{
	$cachedHash = (Get-FileHash -Path $file -Algorithm SHA256).Hash.ToLower()
	if ($cachedHash -eq $expected)
	{
		Write-Host "  [✓] Bản đã tải trước đó vẫn là mới nhất (SHA256 khớp) — dùng luôn, không tải lại." -ForegroundColor Green
	}
	else { $needDownload = $true }
}

if ($needDownload)
{
	$stage = Join-Path $dir "MolikWinlik-Portable.ps1.download"
	Write-Host "  Đang tải MolikWinlik-Portable.ps1 ..." -ForegroundColor Cyan
	Get-MolikOnlineFile -Uri "$base/MolikWinlik-Portable.ps1" -OutFile $stage | Out-Null

	$actual = (Get-FileHash -Path $stage -Algorithm SHA256).Hash.ToLower()
	if ($expected -ne $actual)
	{
		Remove-Item $stage -Force -ErrorAction SilentlyContinue
		throw "SHA256 KHÔNG KHỚP (mong đợi $expected, nhận $actual) — đã hủy vì an toàn, bản hiện tại không bị đụng vào."
	}
	Write-Host "  [✓] SHA256 khớp: $actual" -ForegroundColor Green

	# Kiem tra cu phap truoc khi chay: file loi parse thi khong bao gio duoc thay
	$tokens = $null; $parseErrors = $null
	[void][System.Management.Automation.Language.Parser]::ParseFile($stage, [ref]$tokens, [ref]$parseErrors)
	if ($parseErrors -and $parseErrors.Count -gt 0)
	{
		Remove-Item $stage -Force -ErrorAction SilentlyContinue
		throw "File tải về có $($parseErrors.Count) lỗi cú pháp — đã hủy vì an toàn."
	}
	$sizeKB = [Math]::Round((Get-Item $stage).Length / 1024)
	$newText = Get-Content $stage -Raw
	$newVersion = if ($newText -match 'MolikWinlikVersion = "([0-9.]+)"') { $Matches[1] } else { "?" }
	if ((Get-Item $stage).Length -lt 102400 -or $newVersion -eq "?")
	{
		Remove-Item $stage -Force -ErrorAction SilentlyContinue
		throw "File tải về không giống bản MOLIK WINLIK hợp lệ (dung lượng/phiên bản bất thường) — đã hủy."
	}
	if (Test-Path $file)
	{
		$bak = "$file.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
		Copy-Item $file $bak -Force -ErrorAction SilentlyContinue
		Write-Host "  Đã sao lưu bản cache cũ: $bak" -ForegroundColor DarkGray
	}
	Move-Item $stage $file -Force
	Write-Host "  [✓] Đã sẵn sàng MOLIK WINLIK v$newVersion (${sizeKB} KB) tại $file" -ForegroundColor Green
}

if ($NoLaunch)
{
	Write-Host "  [i] -NoLaunch: chỉ tải & kiểm chứng xong, không chạy." -ForegroundColor DarkGray
	return
}

$isAdmin = $false
try { $isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch {}
$forward = @()
if ($MolikArgs) { $forward = @($MolikArgs) }
if ($isAdmin)
{
	& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $file @forward
}
else
{
	$argLine = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$file`"") + $forward
	Start-Process -FilePath "powershell.exe" -ArgumentList $argLine -Verb RunAs
}
