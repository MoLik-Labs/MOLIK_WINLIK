# Khắc phục sự cố

## Không mở được / báo cần Administrator

Chạy bằng `MOLIK_WINLIK.bat` (tự xin quyền UAC). Nếu đã bấm nhầm **No** ở hộp UAC, tool dừng hẳn theo thiết kế — mở lại và bấm **Yes**, hoặc chuột phải → *Run as administrator*.

## Tiếng Việt hiển thị lỗi ô vuông/mã lạ

Bạn đang mở nhầm cách chạy. Hãy chạy qua `MOLIK_WINLIK.bat` hoặc `powershell -ExecutionPolicy Bypass -File` — đừng mở file .ps1 bằng cách double-click trực tiếp. Tool đã dùng UTF-8 có BOM chuẩn cho PowerShell 5.1.

## GUI không mở

Tool tự fallback về TUI/Menu nên cứ dùng tiếp. GUI cần PowerShell chạy STA; mở thủ công bằng:

```powershell
powershell -STA -File MolikWinlik.ps1 -Gui
```

## Máy chậm hơn / có tweak không hợp

1. `MOLIK_WINLIK.bat -Doctor` — xem cảnh báo (chờ restart, VBS tranh VT-x, ổ gần đầy...).
2. Restart máy một lần — nhiều tweak (HAGS, BCD, pagefile) chỉ có hiệu lực sau restart.
3. Vẫn không ổn: `MOLIK_WINLIK.bat -UndoLast` để hoàn tác phiên gần nhất, hoặc `-RestoreDefaults`.

## Bản đang dùng bị lỗi / nghi hỏng file

`MOLIK_WINLIK.bat -Repair` — tải bản sạch, kiểm chứng SHA256, sao lưu bản cũ rồi thay thế (chi tiết: [Bản Online](/guide/online)). Lỗi riêng của kênh online (hash lệch, tải 3 lần thất bại, antivirus soi file tải) xem bảng xử lý ở [trang Bản Online](/guide/online#loi-thuong-gap-o-kenh-online). Không có mạng thì tải ZIP mới từ GitHub và giải nén đè (backup của bạn ở `C:\MOLIK_WINLIK_Backups\` không bị đụng).

## Kiểm tra sức khỏe tổng thể

```powershell
MOLIK_WINLIK.bat -SelfTest   # kiểm tra cú pháp, catalog, dữ liệu, encoding... (chỉ đọc)
MOLIK_WINLIK.bat -Doctor     # chẩn đoán phần cứng & trạng thái tweak
MOLIK_WINLIK.bat -ExportReport  # xuất Dashboard HTML gửi kèm khi cần hỗ trợ
```

Gửi kèm file log (`C:\MOLIK_WINLIK_Backups\Logs\`) và Dashboard HTML khi báo lỗi sẽ giúp chẩn đoán nhanh nhất.
