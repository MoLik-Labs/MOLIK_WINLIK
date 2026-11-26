# Cài đặt & chạy lần đầu

MOLIK WINLIK không cần cài đặt và không cần Internet khi tối ưu.

## Cách chuẩn (offline) — 3 bước

1. **Tải** ZIP của repo từ GitHub (nút `Code → Download ZIP`) và giải nén vào một thư mục bất kỳ, ví dụ `D:\MOLIK_WINLIK`.
2. **Double-click `MOLIK_WINLIK.bat`** → bấm **Yes** khi Windows hỏi quyền Administrator.
3. Giao diện tick-chọn mở ra: dùng `↑`/`↓` di chuyển, `SPACE` tick tweak, `ENTER` áp dụng.

Chỉ cần giữ `MOLIK_WINLIK.bat` và `MolikWinlik-Portable.ps1` cùng thư mục là mang sang máy khác chạy tiếp được (USB cũng được).

## Các cách chạy khác

| Cách | Lệnh | Khi nào dùng |
|---|---|---|
| GUI cửa sổ | `MOLIK_WINLIK.bat -Gui` | Thích dùng chuột, kiểu winutil |
| Menu số | `MOLIK_WINLIK.bat -Menu` | Terminal không hỗ trợ phím trực tiếp |
| Online | `MOLIK_WINLIK.bat -Update` hoặc `irm .../win.ps1 | iex` | Muốn bản mới nhất / bản cũ bị lỗi cần thay |
| Headless | `MOLIK_WINLIK.bat -Mode HardcoreGaming -Apply -Yes` | Script, tự động hóa |

## Trước khi áp lần đầu

- Tool **tự tạo backup** (Restore Point + Registry/BCD) trước khi áp — cứ yên tâm.
- Chạy thử `MOLIK_WINLIK.bat -SelfTest` (chỉ đọc) để chắc chắn môi trường khỏe.
- Chưa rõ máy mình hợp Mode nào: `MOLIK_WINLIK.bat -Smart -Plan` — tool đọc phần cứng và in kế hoạch kèm lý do, chưa áp gì cả.

## Gỡ / quay lại như cũ

- Hoàn tác phiên gần nhất: `MOLIK_WINLIK.bat -UndoLast`
- Khôi phục mặc định toàn bộ: `MOLIK_WINLIK.bat -RestoreDefaults`
- Xóa tool: xóa thư mục đã giải nén. Backup nằm ở `C:\MOLIK_WINLIK_Backups\` — xóa luôn nếu không cần.
