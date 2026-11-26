<#
	.SYNOPSIS
	MOLIK WINLIK - Window GUI (winutil-style, WinForms, offline)

	.DESCRIPTION
	Giao dien cua so kieu winutil: tab Tweaks (tick chon + Mode + tim kiem),
	Apps (tick cai bang winget), Presets, System (thong tin + Backup/Undo/
	Benchmark/Report). Chay: MOLIK_WINLIK.bat -Gui
	Khung WinForms/.NET co san trong Windows - khong tai gi, khong can cai.
	Neu host khong o che do STA hoac loi khoi tao, ham tra $false de
	launcher tu fallback ve TUI/Menu nhu cu (khong bao gio crash cung).
#>

function Show-MolikWinlikGui
{
	[CmdletBinding()]
	param($Catalog, $Snapshot, [string]$InitialMode = "EmulatorFarm")

	if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA')
	{
		Write-Host "  [!] GUI can PowerShell chay STA - hay chay truc tiep: powershell -STA -File MolikWinlik.ps1 -Gui" -ForegroundColor Yellow
		return $false
	}
	try
	{
		Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
		Add-Type -AssemblyName System.Drawing -ErrorAction Stop
		[System.Windows.Forms.Application]::EnableVisualStyles()
	}
	catch
	{
		Write-Host "  [!] Không khởi tạo được WinForms ($($_.Exception.Message)) - dùng TUI thay thế." -ForegroundColor Yellow
		return $false
	}

	try
	{
		$form = New-Object System.Windows.Forms.Form
		$form.Text = "MOLIK WINLIK v$(Get-MolikUiVersion) by @nggkhaiz - Offline Optimizer"
		$form.Size = New-Object System.Drawing.Size(1020, 720)
		$form.StartPosition = "CenterScreen"
		$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

		$tabs = New-Object System.Windows.Forms.TabControl
		$tabs.Dock = "Fill"
		$form.Controls.Add($tabs)

		$logBox = New-Object System.Windows.Forms.TextBox
		$logBox.Multiline = $true
		$logBox.ScrollBars = "Vertical"
		$logBox.ReadOnly = $true
		$logBox.Dock = "Bottom"
		$logBox.Height = 110
		$logBox.Font = New-Object System.Drawing.Font("Consolas", 8.5)
		$form.Controls.Add($logBox)

		$progress = New-Object System.Windows.Forms.ProgressBar
		$progress.Dock = "Bottom"
		$progress.Height = 14
		$form.Controls.Add($progress)

		$appendLog = {
			param([string]$Text)
			$logBox.AppendText("[$(Get-Date -Format 'HH:mm:ss')] $Text`r`n")
		}

		# ── Tab Tweaks ────────────────────────────────────────────────────
		$tabTweaks = New-Object System.Windows.Forms.TabPage("Tweaks")
		$tabs.TabPages.Add($tabTweaks) | Out-Null
		$topPanel = New-Object System.Windows.Forms.Panel
		$topPanel.Dock = "Top"; $topPanel.Height = 40
		$tabTweaks.Controls.Add($topPanel)

		$modeCombo = New-Object System.Windows.Forms.ComboBox
		$modeCombo.DropDownStyle = "DropDownList"
		$modeCombo.Location = New-Object System.Drawing.Point(8, 8)
		$modeCombo.Width = 180
		foreach ($m in (Get-SophiaOptimizationModes)) { [void]$modeCombo.Items.Add($m.Key) }
		$modeCombo.SelectedItem = $InitialMode
		$topPanel.Controls.Add($modeCombo)

		$searchBox = New-Object System.Windows.Forms.TextBox
		$searchBox.Location = New-Object System.Drawing.Point(196, 9)
		$searchBox.Width = 200
		$topPanel.Controls.Add($searchBox)

		$tweakList = New-Object System.Windows.Forms.CheckedListBox
		$tweakList.Dock = "Fill"
		$tweakList.CheckOnClick = $true
		$tabTweaks.Controls.Add($tweakList)
		$tweakList.BringToFront()
		$tweakItems = [System.Collections.ArrayList]::new()

		$refreshTweaks = {
			$tweakList.Items.Clear(); $tweakItems.Clear()
			$term = $searchBox.Text.Trim().ToLower()
			foreach ($t in $Catalog)
			{
				if ($term -and -not ($t.Name.ToLower().Contains($term) -or $t.Id.ToLower().Contains($term) -or $t.Category.ToLower().Contains($term))) { continue }
				[void]$tweakItems.Add($t)
				[void]$tweakList.Items.Add(("[{0}] [{1}] {2} - {3}" -f $t.Id, $t.Risk, $t.Name, (Format-MolikCategoryName $t.Category)))
			}
		}
		$searchBox.Add_TextChanged({ & $refreshTweaks })

		$btnApplyMode = New-Object System.Windows.Forms.Button
		$btnApplyMode.Text = "Tick theo Mode"
		$btnApplyMode.Location = New-Object System.Drawing.Point(404, 7)
		$btnApplyMode.Width = 110
		$topPanel.Controls.Add($btnApplyMode)
		$btnApplyMode.Add_Click({
			$ids = @(Get-SophiaModeTweakIds -ModeKey $modeCombo.SelectedItem -Catalog $Catalog)
			for ($i = 0; $i -lt $tweakItems.Count; $i++) { $tweakList.SetItemChecked($i, ($ids -contains $tweakItems[$i].Id)) }
			& $appendLog "Đã tick $($ids.Count) tweak của Mode $($modeCombo.SelectedItem)."
		})

		$invokeGuiApply = {
			param([string[]]$Ids, [string]$Verb)
			if (-not $Ids -or $Ids.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Chưa tick tweak nào.") | Out-Null; return }
			$confirm = [System.Windows.Forms.MessageBox]::Show("$Verb $($Ids.Count) tweak?", "MOLIK WINLIK", "YesNo", "Question")
			if ($confirm -ne "Yes") { return }
			try
			{
				if ($Verb -eq "Áp dụng" -and (Get-Command New-SophiaSystemBackup -ErrorAction SilentlyContinue)) { New-SophiaSystemBackup -Label "Before GUI apply" | Out-Null }
				$ordered = @($Catalog | Where-Object { $Ids -contains $_.Id })
				if (Get-Command Get-SophiaOptimizationPlan -ErrorAction SilentlyContinue)
				{
					try { $ordered = @((Get-SophiaOptimizationPlan -Catalog $Catalog -SelectedIds $Ids -Snapshot $Snapshot).Items | ForEach-Object { $_.Tweak }) } catch {}
				}
				$progress.Maximum = $ordered.Count; $progress.Value = 0
				$okN = 0; $failN = 0
				foreach ($t in $ordered)
				{
					try
					{
						if ($Verb -eq "Áp dụng") { & $t.ApplyScript; $v = $false; try { $v = [bool](& $t.CheckScript) } catch {}; & $appendLog ("OK {0} {1}{2}" -f $t.Id, $t.Name, $(if ($v) { " [verified]" } else { " [unverified]" })) }
						else { & $t.RestoreScript; & $appendLog "RESTORED $($t.Id) $($t.Name)" }
						$okN++
					}
					catch { & $appendLog "FAIL $($t.Id): $($_.Exception.Message)"; $failN++ }
					$progress.Value++
					[System.Windows.Forms.Application]::DoEvents()
				}
				& $appendLog "Hoàn tất ($Verb): $okN OK / $failN FAIL. Nhiều tweak cần RESTART mới có hiệu lực."
			}
			catch { & $appendLog "LỖI $Verb : $($_.Exception.Message)" }
		}

		$btnApply = New-Object System.Windows.Forms.Button
		$btnApply.Text = "ÁP DỤNG đã tick"
		$btnApply.Location = New-Object System.Drawing.Point(522, 7)
		$btnApply.Width = 120
		$topPanel.Controls.Add($btnApply)
		$btnApply.Add_Click({
			$ids = @(); for ($i = 0; $i -lt $tweakItems.Count; $i++) { if ($tweakList.GetItemChecked($i)) { $ids += $tweakItems[$i].Id } }
			& $invokeGuiApply $ids "Áp dụng"
		})

		$btnRestore = New-Object System.Windows.Forms.Button
		$btnRestore.Text = "Khôi phục đã tick"
		$btnRestore.Location = New-Object System.Drawing.Point(650, 7)
		$btnRestore.Width = 120
		$topPanel.Controls.Add($btnRestore)
		$btnRestore.Add_Click({
			$ids = @(); for ($i = 0; $i -lt $tweakItems.Count; $i++) { if ($tweakList.GetItemChecked($i)) { $ids += $tweakItems[$i].Id } }
			& $invokeGuiApply $ids "Khôi phục"
		})

		# ── Tab Apps ──────────────────────────────────────────────────────
		$tabApps = New-Object System.Windows.Forms.TabPage("Apps (winget)")
		$tabs.TabPages.Add($tabApps) | Out-Null
		$appList = New-Object System.Windows.Forms.CheckedListBox
		$appList.Dock = "Fill"; $appList.CheckOnClick = $true
		$tabApps.Controls.Add($appList)
		$appItems = [System.Collections.ArrayList]::new()
		if (Get-Command Get-SophiaAppsCatalog -ErrorAction SilentlyContinue)
		{
			foreach ($a in (Get-SophiaAppsCatalog)) { [void]$appItems.Add($a); [void]$appList.Items.Add("$($a.Name) ($($a.Winget))") }
		}
		$btnInstall = New-Object System.Windows.Forms.Button
		$btnInstall.Text = "Cài app đã tick"
		$btnInstall.Dock = "Top"; $btnInstall.Height = 32
		$tabApps.Controls.Add($btnInstall)
		$btnInstall.Add_Click({
			$names = @(); for ($i = 0; $i -lt $appItems.Count; $i++) { if ($appList.GetItemChecked($i)) { $names += $appItems[$i].Name } }
			if ($names.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Chưa tick app nào.") | Out-Null; return }
			& $appendLog "Đang cài $($names.Count) app qua winget..."
			try { Install-SophiaApps -Queries $names; & $appendLog "Cài app xong (xem chi tiết trong cửa sổ console nếu có)." }
			catch { & $appendLog "LỖI cài app: $($_.Exception.Message)" }
		})

		# ── Tab Presets ───────────────────────────────────────────────────
		$tabPresets = New-Object System.Windows.Forms.TabPage("Presets")
		$tabs.TabPages.Add($tabPresets) | Out-Null
		$presetList = New-Object System.Windows.Forms.ListBox
		$presetList.Dock = "Fill"
		$tabPresets.Controls.Add($presetList)
		$presetItems = [System.Collections.ArrayList]::new()
		if (Get-Command Get-MolikPresets -ErrorAction SilentlyContinue)
		{
			foreach ($pr in (Get-MolikPresets)) { [void]$presetItems.Add($pr); [void]$presetList.Items.Add("$($pr.Icon) $($pr.Title) - $($pr.Description)") }
		}
		$btnPreset = New-Object System.Windows.Forms.Button
		$btnPreset.Text = "Áp dụng Preset đã chọn"
		$btnPreset.Dock = "Top"; $btnPreset.Height = 32
		$tabPresets.Controls.Add($btnPreset)
		$btnPreset.Add_Click({
			if ($presetList.SelectedIndex -lt 0) { [System.Windows.Forms.MessageBox]::Show("Chưa chọn Preset.") | Out-Null; return }
			$ids = @(Resolve-MolikPreset -Preset $presetItems[$presetList.SelectedIndex] -Catalog $Catalog)
			& $invokeGuiApply $ids "Áp dụng"
		})

		# ── Tab System ────────────────────────────────────────────────────
		$tabSys = New-Object System.Windows.Forms.TabPage("System")
		$tabs.TabPages.Add($tabSys) | Out-Null
		$sysText = New-Object System.Windows.Forms.TextBox
		$sysText.Multiline = $true; $sysText.ReadOnly = $true; $sysText.Dock = "Fill"
		$sysText.Font = New-Object System.Drawing.Font("Consolas", 9)
		$tabSys.Controls.Add($sysText)
		if ($Snapshot)
		{
			$sysText.Text = (@(
				"OS        : $($Snapshot.OSName) (Build $($Snapshot.OSBuild).$($Snapshot.OSUBR))"
				"CPU       : $($Snapshot.CPUName) ($($Snapshot.CPUThreads) luồng)"
				"RAM       : $($Snapshot.RAMTotalGB) GB (trống $($Snapshot.RAMFreeGB) GB)"
				"GPU       : $($Snapshot.GPUName) ($($Snapshot.GPUVendor))"
				"Ổ hệ thống: $($Snapshot.SystemDriveType), trống $($Snapshot.SystemDriveFreeGB) GB"
				"Power Plan: $($Snapshot.ActivePowerPlan)"
				"Admin     : $($Snapshot.IsAdmin) | PendingReboot: $($Snapshot.PendingReboot) | Laptop: $($Snapshot.IsLaptop)"
				"Giả lập   : $(if ($Snapshot.InstalledEmulators) { $Snapshot.InstalledEmulators -join ', ' } else { 'không phát hiện' })"
			) -join "`r`n")
		}
		$sysPanel = New-Object System.Windows.Forms.Panel
		$sysPanel.Dock = "Top"; $sysPanel.Height = 40
		$tabSys.Controls.Add($sysPanel)
		$mkBtn = {
			param([string]$Text, [int]$X, [scriptblock]$OnClick)
			$b = New-Object System.Windows.Forms.Button
			$b.Text = $Text; $b.Location = New-Object System.Drawing.Point($X, 7); $b.Width = 130
			$b.Add_Click($OnClick)
			$sysPanel.Controls.Add($b)
		}
		& $mkBtn "Backup ngay" 8 { try { $p = New-SophiaSystemBackup; & $appendLog "Đã backup: $p" } catch { & $appendLog "LỖI backup: $($_.Exception.Message)" } }
		& $mkBtn "Hoàn tác phiên" 146 { if ([System.Windows.Forms.MessageBox]::Show("Hoàn tác phiên áp dụng gần nhất?", "MOLIK WINLIK", "YesNo", "Question") -eq "Yes") { try { Restore-MolikLastSession -Catalog $Catalog -Force | Out-Null; & $appendLog "Đã hoàn tác phiên gần nhất - hãy RESTART." } catch { & $appendLog "LỖI hoàn tác: $($_.Exception.Message)" } } }
		& $mkBtn "Benchmark" 284 { try { $r = Invoke-SophiaBenchmark -Label "GUI"; & $appendLog "Benchmark xong: CPU Score $($r.CpuScore)" } catch { & $appendLog "LỖI benchmark: $($_.Exception.Message)" } }
		& $mkBtn "Xuất báo cáo HTML" 422 { try { $hp = Export-MolikHtmlReport -Snapshot $Snapshot -Catalog $Catalog; & $appendLog "Đã xuất: $hp" } catch { & $appendLog "LỖI report: $($_.Exception.Message)" } }

		& $refreshTweaks
		& $appendLog "MOLIK WINLIK GUI sẵn sàng: $($Catalog.Count) tweak. Tick rồi bấm ÁP DỤNG."
		[void]$form.ShowDialog()
		return $true
	}
	catch
	{
		Write-Host "  [!] GUI lỗi ($($_.Exception.Message)) - dùng TUI thay thế." -ForegroundColor Yellow
		return $false
	}
}
