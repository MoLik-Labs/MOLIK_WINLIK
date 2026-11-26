<#
	.SYNOPSIS
	MOLIK WINLIK - Online bootstrapper (KÊNH ONLINE TÙY CHỌN)

	.DESCRIPTION
	Cách chạy online (luôn lấy bản mới nhất, có kiểm chứng SHA256):

	  irm https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1 | iex

	Script này tải MolikWinlik-Portable.ps1 + .sha256 từ repo chính thức
	về %LOCALAPPDATA%\MOLIK_WINLIK, đối chiếu SHA256 (lệch là dừng ngay),
	tự xin quyền Administrator rồi chạy file LOCAL đã kiểm chứng.
	Bản offline (MOLIK_WINLIK.bat cạnh file Portable) vẫn là cách chạy
	chuẩn được khuyến nghị — kênh này chỉ để tiện cập nhật/trải nghiệm nhanh.
#>
$ErrorActionPreference = "Stop"
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$repo = "MoLik-Labs/MOLIK_WINLIK"
$base = "https://raw.githubusercontent.com/$repo/main"
$dir = Join-Path $env:LOCALAPPDATA "MOLIK_WINLIK"
New-Item -Path $dir -ItemType Directory -Force | Out-Null
$file = Join-Path $dir "MolikWinlik-Portable.ps1"
$hashTmp = Join-Path $dir "latest.sha256"

Write-Host "MOLIK WINLIK (online): dang tai ban moi nhat tu GitHub..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "$base/MolikWinlik-Portable.ps1" -OutFile $file -UseBasicParsing
Invoke-WebRequest -Uri "$base/MolikWinlik-Portable.ps1.sha256" -OutFile $hashTmp -UseBasicParsing

$expected = ((Get-Content $hashTmp -Raw).Trim() -split '\s+')[0].ToLower()
$actual = (Get-FileHash -Path $file -Algorithm SHA256).Hash.ToLower()
if ($expected -ne $actual)
{
	Remove-Item $file -Force -ErrorAction SilentlyContinue
	throw "SHA256 khong khop (mong doi $expected, nhan $actual) - da huy vi an toan."
}
Write-Host "[OK] SHA256 khop: $actual" -ForegroundColor Green

$isAdmin = $false
try { $isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch {}
if ($isAdmin)
{
	& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $file
}
else
{
	Start-Process -FilePath "powershell.exe" -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$file`"") -Verb RunAs
}
