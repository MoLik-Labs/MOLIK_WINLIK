<#
	.SYNOPSIS
	MOLIK WINLIK - HTML Dashboard Report Engine (offline, 1 file HTML doc lap)

	.DESCRIPTION
	Xuat bao cao he thong + trang thai toi uu dang HTML tu chua (CSS nhung san)
	de mo bang trinh duyet, gui cho ky thuat vien hoac luu ho so may:
	  .\MolikWinlik.ps1 -ExportReport     (sinh ca JSON lan HTML)
	Trong giao dien tick-chon: phim H. Trong Menu don gian: phim H.
	Khong can Internet, khong tai tai nguyen ngoai.
#>

function Get-MolikAppliedStatus
{
	[CmdletBinding()]
	param([Parameter(Mandatory)]$Catalog, [string[]]$Ids)

	$targets = @($Catalog)
	if ($Ids -and $Ids.Count -gt 0) { $targets = @($Catalog | Where-Object { $Ids -contains $_.Id }) }
	$status = @{}
	foreach ($t in $targets)
	{
		try { $status[$t.Id] = [bool](& $t.CheckScript) } catch { $status[$t.Id] = $false }
	}
	return $status
}

function Export-MolikHtmlReport
{
	[CmdletBinding()]
	param(
		$Snapshot,
		[Parameter(Mandatory)]$Catalog,
		[string]$Path = "",
		[switch]$SkipStatus
	)

	if (-not $Path)
	{
		$dir = "$env:SystemDrive\MOLIK_WINLIK_Backups\Reports"
		New-Item -Path $dir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
		$Path = Join-Path $dir ("MolikWinlik-Report-{0}.html" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
	}

	$enc = { param($v) if ($null -eq $v) { return "" } return [System.Net.WebUtility]::HtmlEncode([string]$v) }
	$ver = if ($Global:MolikWinlikVersion) { $Global:MolikWinlikVersion } else { "5.7.0" }
	$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

	$status = @{}
	$appliedCount = -1
	if (-not $SkipStatus)
	{
		$status = Get-MolikAppliedStatus -Catalog $Catalog
		$appliedCount = @($status.Keys | Where-Object { $status[$_] }).Count
	}

	$osName = & $enc $Snapshot.OSName
	$cpu = & $enc $Snapshot.CPUName
	$gpu = & $enc $Snapshot.GPUName
	$ram = & $enc $Snapshot.RAMTotalGB
	$drive = & $enc $Snapshot.SystemDriveType
	$admin = if ($Snapshot.IsAdmin) { "Administrator" } else { "Standard User" }
	$emu = if ($Snapshot.InstalledEmulators) { & $enc ($Snapshot.InstalledEmulators -join ", ") } else { "—" }
	$reboot = if ($Snapshot.PendingReboot) { '<span class="badge ext">PENDING REBOOT</span>' } else { '<span class="badge safe">OK</span>' }
	$appliedText = if ($appliedCount -ge 0) { "$appliedCount / $($Catalog.Count)" } else { "— (bỏ qua kiểm tra)" }

	$modeRows = ""
	foreach ($m in (Get-SophiaOptimizationModes))
	{
		$mIds = @(Get-SophiaModeTweakIds -ModeKey $m.Key -Catalog $Catalog)
		$impact = "—"
		try
		{
			if (Get-Command Get-SophiaOptimizationPlan -ErrorAction SilentlyContinue)
			{
				$plan = Get-SophiaOptimizationPlan -Catalog $Catalog -SelectedIds $mIds
				$impact = "$($plan.ImpactScore) ($($plan.Level))"
			}
		} catch {}
		$modeRows += "<tr><td>$(& $enc $m.Icon) $(& $enc $m.Name)</td><td>$(& $enc $m.Sub)</td><td>$($mIds.Count)</td><td>$impact</td></tr>`n"
	}

	$tweakRows = ""
	foreach ($t in $Catalog)
	{
		$riskClass = "safe"
		if ($t.Risk -eq "Extreme") { $riskClass = "ext" } elseif ($t.Risk -eq "Moderate") { $riskClass = "mod" }
		$applied = "—"
		if ($status.ContainsKey($t.Id)) { $applied = if ($status[$t.Id]) { "● Đã áp" } else { "○ Chưa" } }
		$tweakRows += "<tr><td><code>$(& $enc $t.Id)</code></td><td>$(& $enc $t.Name)</td><td>$(& $enc $t.Category)</td><td><span class=`"badge $riskClass`">$(& $enc $t.Risk)</span></td><td>$applied</td></tr>`n"
	}

	$html = @"
<!DOCTYPE html>
<html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>MOLIK WINLIK Report - $osName</title>
<style>
 :root{--bg:#0b0e14;--panel:#12161f;--line:#232a38;--text:#e8edf5;--muted:#93a0b4;--accent:#e5537a;--accent2:#4f9cf9;--ok:#2ea043;--warn:#b07d10;--bad:#d64545}
 *{box-sizing:border-box}html{color-scheme:dark}
 body{font-family:'Segoe UI',system-ui,-apple-system,sans-serif;background:var(--bg);color:var(--text);margin:0;padding:28px 20px 40px;line-height:1.5}
 main{max-width:1060px;margin:0 auto}
 header h1{font-size:26px;letter-spacing:.2px;margin:0}header h1 .accent{color:var(--accent)}
 .sub{color:var(--muted);font-size:13px}
 h2{font-size:17px;color:var(--text);border-bottom:1px solid var(--line);padding-bottom:6px;margin:30px 0 10px}
 .cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:10px;margin:18px 0}
 .card{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:12px 14px;font-size:12px;color:var(--muted)}
 .card b{font-size:16px;color:var(--text);display:block;margin-top:3px;overflow-wrap:anywhere}
 .tablewrap{overflow-x:auto;border:1px solid var(--line);border-radius:8px}
 table{border-collapse:collapse;width:100%;margin:0} th,td{padding:7px 10px;text-align:left;font-size:13.5px;border-bottom:1px solid var(--line)}
 thead th{position:sticky;top:0;background:#171c28;color:var(--text)} tbody tr:hover{background:#141926}
 code{color:#f0a35e;font-family:Consolas,monospace;font-size:12.5px}
 .badge{padding:1px 8px;border-radius:20px;font-size:11.5px;font-weight:600;white-space:nowrap}
 .safe{background:var(--ok);color:#fff}.mod{background:var(--warn);color:#fff}.ext{background:var(--bad);color:#fff}
 footer{color:var(--muted);font-size:12.5px;margin-top:28px;border-top:1px solid var(--line);padding-top:12px}
 @media (max-width:640px){body{padding:18px 12px 30px}header h1{font-size:21px}}
 @media (prefers-reduced-motion:reduce){*{transition:none!important;animation:none!important}}
 @media print{body{background:#fff;color:#000}.card,thead th{background:#fff}h2,.card b{color:#000}}
</style></head><body>
<header><h1><span class="accent">MOLIK WINLIK</span> <span class="sub">v$ver — by @nggkhaiz</span></h1>
<div class="sub">Báo cáo hệ thống &amp; tối ưu — tạo lúc $now (offline)</div></header>
<main>
<div class="cards">
 <div class="card">Hệ điều hành<b>$osName</b></div>
 <div class="card">CPU<b>$cpu</b></div>
 <div class="card">RAM (GB)<b>$ram</b></div>
 <div class="card">GPU<b>$gpu</b></div>
 <div class="card">Ổ hệ thống<b>$drive</b></div>
 <div class="card">Quyền chạy<b>$admin</b></div>
 <div class="card">Tweak đã áp dụng<b>$appliedText</b></div>
 <div class="card">Chờ restart<b>$reboot</b></div>
</div>
<p>🖥️ Giả lập phát hiện: <b>$emu</b></p>
<h2>🎛️ $((Get-SophiaOptimizationModes).Count) Mode tối ưu</h2>
<table><tr><th>Mode</th><th>Mô tả</th><th>Số tweak</th><th>Impact Score</th></tr>
$modeRows</table>
<h2>🧩 Toàn bộ catalog ($($Catalog.Count) tweak)</h2>
<table><tr><th>ID</th><th>Tên tweak</th><th>Nhóm</th><th>Rủi ro</th><th>Trạng thái</th></tr>
$tweakRows</table>
</main>
<footer>MOLIK WINLIK by @nggkhaiz — Báo cáo tĩnh, không chứa dữ liệu cá nhân ngoài thông số phần cứng trên. Backup: C:\MOLIK_WINLIK_Backups\</footer>
</body></html>
"@

	$html | Set-Content -Path $Path -Encoding UTF8 -Force
	Write-Host "  [✓] Đã xuất báo cáo HTML Dashboard: $Path" -ForegroundColor Green
	Write-Host "      Mở bằng trình duyệt để xem (offline, gửi kèm khi cần hỗ trợ)." -ForegroundColor Gray
	return $Path
}

function Show-MolikSystemDoctor
{
	# Chan doan nhanh sau toi uu: tong hop Snapshot + trang thai tweak da ap
	# thanh danh sach PASS / CANH BAO doc ngay tren terminal (khong can Admin
	# cho phan lon kiem tra; lenh -Doctor chay khong UAC).
	[CmdletBinding()]
	param($Snapshot, [Parameter(Mandatory)]$Catalog)

	Write-Host ""
	Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
	Write-Host "  ║  🩺 MOLIK WINLIK DOCTOR — chẩn đoán hệ thống (chỉ đọc)              ║" -ForegroundColor Cyan
	Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
	if (-not $Snapshot)
	{
		Write-Host "  [X] Không đọc được Snapshot phần cứng — không chẩn đoán được." -ForegroundColor Red
		return
	}
	Write-Host ("  {0} | Build {1}.{2} | {3} | {4} luồng | RAM {5}GB (trống {6}GB) | {7} trống {8}GB" -f $Snapshot.OSName, $Snapshot.OSBuild, $Snapshot.OSUBR, $Snapshot.CPUName, $Snapshot.CPUThreads, $Snapshot.RAMTotalGB, $Snapshot.RAMFreeGB, $Snapshot.SystemDriveType, $Snapshot.SystemDriveFreeGB) -ForegroundColor Gray
	Write-Host ("  Phân tầng máy: {0} (Low=yếu · Medium=trung bình · High=mạnh) — Smart Advisor (phím G / -Smart) chọn Mode theo tầng này." -f $(if ($Snapshot.PerformanceTier) { $Snapshot.PerformanceTier } else { "Medium" })) -ForegroundColor DarkGray
	Write-Host ("  GPU: {0} ({1}) | WDDM {2} | Power Plan: {3} | Tiến trình: {4} | Giả lập: {5}" -f $Snapshot.GPUName, $Snapshot.GPUVendor, $Snapshot.WDDMVersion, $Snapshot.ActivePowerPlan, $Snapshot.ProcessCount, $(if ($Snapshot.InstalledEmulators) { $Snapshot.InstalledEmulators -join ", " } else { "không phát hiện" })) -ForegroundColor Gray
	Write-Host ""

	function DoctorLine([bool]$Ok, [string]$OkText, [string]$WarnText)
	{
		if ($Ok) { Write-Host "  [✓] $OkText" -ForegroundColor Green } else { Write-Host "  [!] $WarnText" -ForegroundColor Yellow }
	}

	DoctorLine (-not $Snapshot.PendingReboot) "Không có cập nhật/file nào đang chờ restart." "Đang CHỜ RESTART (CBS/Windows Update/PendingFileRename) — hãy restart trước khi tối ưu tiếp."
	$sessionMarkerPath = "$env:SystemDrive\MOLIK_WINLIK_Backups\Logs\session_in_progress.json"
	if (Test-Path $sessionMarkerPath)
	{
		Write-Host "  [!] Một phiên áp dụng trước có dấu hiệu bị ngắt giữa chừng (mất điện/tắt máy giữa lúc áp). Xem thư mục Logs và cân nhắc chạy -UndoLast để hoàn tác phiên gần nhất." -ForegroundColor Red
	}
	$lastResultPath = "$env:SystemDrive\MOLIK_WINLIK_Backups\Logs\last_session_result.json"
	if (Test-Path $lastResultPath)
	{
		try
		{
			$lr = Get-Content $lastResultPath -Raw | ConvertFrom-Json
			Write-Host ("  Phiên áp gần nhất ({0}): {1} OK / {2} FAIL ({3} verified)." -f $lr.FinishedAt, $lr.OK, $lr.Fail, $lr.Verified) -ForegroundColor Gray
		} catch {}
	}
	DoctorLine ($Snapshot.VTxEnabled) "VT-x/AMD-V đã bật trong BIOS (giả lập chạy được full tốc)." "VT-x CHƯA bật trong BIOS — giả lập sẽ rất chậm dù đã tweak Windows."
	DoctorLine (-not $Snapshot.VBSRunning -and -not $Snapshot.HVCIEnabled) "VBS/HVCI đang tắt — VT-x không bị tranh (tốt cho farm/giả lập)." "VBS/HVCI đang BẬT: tranh VT-x với giả lập (dùng EMU01/EMU04 nếu là máy farm chuyên dụng)."
	DoctorLine ($Snapshot.HAGSEnabled) "HAGS (GPU01) đã bật — GPU tự lập lịch, giảm latency." "HAGS chưa bật — tick GPU01 nếu GPU hỗ trợ (WDDM >= 2.7)."
	DoctorLine ($Snapshot.MPODisabled) "MPO đã tắt (OverlayTestMode=5) — giảm stutter khi nhiều cửa sổ/game." "MPO đang bật mặc định — một số máy bị flicker/stutter sẽ cần tắt MPO trong Catalog GPU."
	if ($Snapshot.InstalledEmulators -and $Snapshot.InstalledEmulators.Count -gt 0 -and $Snapshot.HypervisorLaunchType -eq "Off")
	{
		Write-Host "  [✓] Hypervisor launch đã Off — giả lập native (LD/MuMu/Nox) dùng VT-x trực tiếp." -ForegroundColor Green
	}
	elseif ($Snapshot.InstalledEmulators -and $Snapshot.InstalledEmulators.Count -gt 0)
	{
		Write-Host "  [!] Có giả lập nhưng Hypervisor vẫn '$($Snapshot.HypervisorLaunchType)' — EMU02/EMU03 giúp farm ổn định hơn (đọc kỹ mô tả trước khi tick)." -ForegroundColor Yellow
	}
	if ($Snapshot.SystemDriveFreeGB -gt 0 -and $Snapshot.SystemDriveFreeGB -lt 15)
	{
		Write-Host "  [!] Ổ hệ thống chỉ còn $($Snapshot.SystemDriveFreeGB)GB trống — Pagefile/Update dễ lỗi, hãy dọn ổ." -ForegroundColor Yellow
	}
	if ($Snapshot.IsLaptop)
	{
		Write-Host "  [i] Máy laptop: tránh các tweak khóa xung/idle (EXT07/EXT08/CPU03) khi không cắm điện cố định." -ForegroundColor DarkGray
	}

	Write-Host ""
	Write-Host "  Đang quét trạng thái $($Catalog.Count) tweak (chỉ đọc)..." -ForegroundColor Cyan
	$map = Get-MolikAppliedStatus -Catalog $Catalog
	$applied = @($Catalog | Where-Object { $map[$_.Id] })
	$extremeOn = @($applied | Where-Object { $_.Risk -eq "Extreme" })
	Write-Host ("  Đã áp dụng: {0}/{1} tweak | Extreme đang bật: {2}" -f $applied.Count, $Catalog.Count, $extremeOn.Count) -ForegroundColor Cyan
	if ($extremeOn.Count -gt 0)
	{
		Write-Host "  Các tweak Extreme đang có hiệu lực (đánh đổi bảo mật/ổn định — đảm bảo bạn chủ động chọn):" -ForegroundColor Yellow
		$extremeOn | ForEach-Object { Write-Host "      - [$($_.Id)] $($_.Name)" -ForegroundColor DarkYellow }
	}
	Write-Host "  Mẹo: -Status xem toàn bộ danh sách | -UndoLast hoàn tác phiên áp dụng gần nhất | -ExportReport xuất Dashboard HTML." -ForegroundColor DarkGray
}
