# Giao diện: GUI / TUI / CLI

## GUI cửa sổ (kiểu winutil)

```powershell
MOLIK_WINLIK.bat -Gui
```

4 tab: **Tweaks** (tick chọn, chọn theo Mode, tìm kiếm trực tiếp), **Apps** (tick cài bằng winget), **Presets**, **System** (thông tin máy, Backup, Hoàn tác, Benchmark, Dọn rác, Xuất báo cáo). Có log theo thời gian thực và thanh tiến trình; trước khi áp luôn tự backup. Nếu máy không mở được GUI (thiếu STA/WinForms), tool tự chuyển về TUI/Menu — không bao giờ crash cứng.

## TUI tick-chọn (mặc định)

| Phím | Tác dụng |
|---|---|
| `↑` `↓` / `K` `J` | Di chuyển |
| `SPACE` | Tick / bỏ tick |
| `ENTER` | Áp dụng các tweak đã tick |
| `1`–`9`, `M` | Chuyển Mode |
| `/` | Tìm tweak |
| `F` | Lọc (đã chọn / Extreme / chưa áp) |
| `V` | Quét trạng thái đã áp (dấu ●) |
| `G` | Smart Advisor tự tick theo máy |
| `C` | Cleanup Center (dọn cache/temp) |
| `P` / `E` | Purge RAM / Boost giả lập |
| `B` / `U` / `R` | Backup / Hoàn tác phiên / Khôi phục mặc định |
| `H` | Xuất Dashboard HTML |
| `?` / `Q` | Trợ giúp / Thoát |

## Menu số & Headless CLI

`MOLIK_WINLIK.bat -Menu` cho terminal không hỗ trợ phím trực tiếp. Chạy tự động hoàn toàn bằng CLI:

```powershell
MOLIK_WINLIK.bat -Mode PrivacyMax -Apply -Yes
MOLIK_WINLIK.bat -ApplyIds GAM01,GPU01 -Yes
MOLIK_WINLIK.bat -ListTweaks -Search "timer"
MOLIK_WINLIK.bat -Benchmark -BenchmarkLabel Before
MOLIK_WINLIK.bat -Doctor          # chẩn đoán chỉ đọc
MOLIK_WINLIK.bat -SelfTest        # tự kiểm tra chỉ đọc
MOLIK_WINLIK.bat -UndoLast -Yes   # hoàn tác phiên gần nhất
```
