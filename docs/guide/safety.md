# An toàn, Backup & Hoàn tác

## Trước khi áp

- Tự tạo **System Restore Point** và xuất các nhánh Registry quan trọng + BCD vào `C:\MOLIK_WINLIK_Backups\Backup_<thời gian>\`.
- **Plan Engine** phân tích trước: bổ sung tweak phụ thuộc, loại tweak mâu thuẫn/bị thay thế, sắp xếp thứ tự áp an toàn (nền trước — kernel/BCD cuối cùng), cảnh báo theo ngữ cảnh (laptop, RAM ít...).
- Tweak **Extreme** phải gõ xác nhận riêng.

## Sau khi áp

- Mỗi tweak được **kiểm chứng lại trạng thái thật** (`verified` / `unverified` trong log tại `C:\MOLIK_WINLIK_Backups\Logs\`).
- Phiên bị ngắt giữa chừng (mất điện, treo máy) để lại marker — lần mở sau **Doctor sẽ cảnh báo** và hướng dẫn hoàn tác.

## Hoàn tác

| Cách | Lệnh |
|---|---|
| Phiên gần nhất | `MOLIK_WINLIK.bat -UndoLast` (chạy Restore từng tweak theo thứ tự ngược) |
| Từng tweak | `-RestoreIds GAM01,GPU01` |
| Toàn bộ về mặc định | `MOLIK_WINLIK.bat -RestoreDefaults` |
| Nạp lại Registry từ backup | `MOLIK_WINLIK.bat -RestoreBackup` (BCD chỉ hướng dẫn nạp tay để tránh rủi ro boot) |
| Bản tool bị lỗi | `MOLIK_WINLIK.bat -Repair` (thay bản sạch có kiểm chứng hash) |

Chẩn đoán bất cứ lúc nào bằng `MOLIK_WINLIK.bat -Doctor` — hoàn toàn chỉ đọc.
