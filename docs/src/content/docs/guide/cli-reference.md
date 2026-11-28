---
title: "Tham chiếu lệnh CLI"
description: "Toàn bộ lệnh MOLIK_WINLIK.bat: giao diện, áp dụng, dọn dẹp, hoàn tác, chẩn đoán và kênh online."
---

Mọi lệnh đều gọi qua `MOLIK_WINLIK.bat ...` (tự xin quyền Admin khi cần). Lệnh chỉ đọc **không** bật hộp UAC.

## Chạy & giao diện

| Lệnh | Tác dụng |
|---|---|
| `MOLIK_WINLIK.bat` | Mở TUI tick-chọn (mặc định) |
| `MOLIK_WINLIK.bat -Gui` | Mở GUI cửa sổ kiểu winutil (4 tab) |
| `MOLIK_WINLIK.bat -Menu` | Menu số cho terminal không hỗ trợ phím trực tiếp |
| `MOLIK_WINLIK.bat -Version` | Xem phiên bản, quy mô catalog |

## Áp dụng tối ưu

| Lệnh | Tác dụng |
|---|---|
| `-Mode <Khóa> -Plan` | Xem kế hoạch của Mode (chưa áp) — khóa xem ở [11 Mode](../modes) |
| `-Mode <Khóa> -Apply -Yes` | Áp cả Mode |
| `-Preset <tên> -Plan` / `-Apply -Yes` | Áp [Preset](../presets) theo tình huống |
| `-ApplyIds GAM01,GPU01 -Yes` | Áp từng tweak theo ID |
| `-Smart -Plan` | Smart Advisor đọc phần cứng, khuyên Mode kèm lý do (chưa áp) |
| `-ListModes` / `-ListPresets` / `-ListTweaks -Search "timer"` | Tra cứu Mode / Preset / catalog |
| `-Status GAM01,GPU01` | Kiểm tra tweak đã áp hay chưa |
| `-ListApps` / `-InstallApps "VLC,7-Zip"` / `-AppsMenu` | Danh sách & cài app bằng winget (239 app) |
| `-PurgeRAM` / `-BoostEmulators` | Xả RAM standby / boost tiến trình giả lập |

## Dọn dẹp & sửa chữa

| Lệnh | Tác dụng |
|---|---|
| `-Cleanup` | [Cleanup Center](../cleanup): dọn cache/temp qua vùng cách ly (hoàn lại được) |
| `-DeepCleanup` | Dọn sâu bằng cleanmgr + DISM của Windows |
| `-RestoreCleanup` | Hoàn lại toàn bộ lần Cleanup gần nhất về chỗ cũ |
| `-RepairWindows` | Sửa Windows bằng DISM RestoreHealth + SFC chính chủ |

## Backup, hoàn tác & chẩn đoán

| Lệnh | Tác dụng |
|---|---|
| `-UndoLast -Yes` | Hoàn tác phiên áp dụng gần nhất |
| `-RestoreIds GAM01,GPU01` | Khôi phục từng tweak về giá trị gốc |
| `-RestoreDefaults -Yes` | Khôi phục **toàn bộ** về mặc định |
| `-ListBackups` / `-BackupOnly` / `-RestoreBackup` | Xem / tạo / nạp backup hệ thống |
| `-Doctor` | Chẩn đoán phần cứng & trạng thái (chỉ đọc) |
| `-SelfTest` | Tự kiểm tra toàn diện tool (chỉ đọc) |
| `-Benchmark -BenchmarkLabel Before` | Đo hiệu năng trước/sau, `-CompareBenchmarks` để so sánh |
| `-ExportReport` | Xuất Dashboard HTML + JSON của máy |

## Kênh online (tùy chọn)

| Lệnh | Tác dụng |
|---|---|
| `-CheckUpdate` | Kiểm tra có bản mới không (không thay gì) — chi tiết [Bản Online](../online) |
| `-Update` | Cập nhật khi có bản mới (kiểm chứng SHA256, backup .bak) |
| `-Repair` | Ép thay bản sạch kể cả cùng phiên bản |
