---
title: "An toàn, Backup & Hoàn tác"
description: "Backup Restore Point + Registry/BCD, kiểm chứng sau khi áp, UndoLast/RestoreDefaults và sửa Windows bằng DISM + SFC."
---

## Trước khi áp

- Tự tạo **System Restore Point** và xuất các nhánh Registry quan trọng + BCD vào `C:\MOLIK_WINLIK_Backups\Backup_<thời gian>\`.
- **Plan Engine** phân tích trước: bổ sung tweak phụ thuộc, loại tweak mâu thuẫn/bị thay thế, sắp xếp thứ tự áp an toàn (nền trước — kernel/BCD cuối cùng), cảnh báo theo ngữ cảnh (laptop, RAM ít...).
- Tweak **Extreme** phải gõ xác nhận riêng.

## Sau khi áp

- Mỗi tweak được **kiểm chứng lại trạng thái thật** (`verified` / `unverified` trong log tại `C:\MOLIK_WINLIK_Backups\Logs\`).
- Phiên bị ngắt giữa chừng (mất điện, treo máy) để lại marker — lần mở sau **Doctor sẽ cảnh báo** và hướng dẫn hoàn tác.

## Sửa chữa Windows khi máy lỗi

```powershell
MOLIK_WINLIK.bat -RepairWindows   # DISM RestoreHealth + SFC /scannow
```

Đây là công cụ chính chủ của Microsoft — nên chạy khi máy có dấu hiệu lỗi
file hệ thống, update lỗi lặp lại, hoặc sau khi gỡ phần mềm làm hỏng Windows.
Tool cũng tự cảnh báo **chờ restart** và **ổ gần đầy** trước mỗi phiên áp
(preflight), và ghi kết quả phiên gần nhất để `-Doctor` hiển thị.

## Hoàn tác

| Cách | Lệnh |
|---|---|
| Phiên gần nhất | `MOLIK_WINLIK.bat -UndoLast` (chạy Restore từng tweak theo thứ tự ngược) |
| Từng tweak | `-RestoreIds GAM01,GPU01` |
| Toàn bộ về mặc định | `MOLIK_WINLIK.bat -RestoreDefaults` |
| Nạp lại Registry từ backup | `MOLIK_WINLIK.bat -RestoreBackup` (BCD chỉ hướng dẫn nạp tay để tránh rủi ro boot) |
| Bản tool bị lỗi | `MOLIK_WINLIK.bat -Repair` (thay bản sạch có kiểm chứng hash) |

Chẩn đoán bất cứ lúc nào bằng `MOLIK_WINLIK.bat -Doctor` — hoàn toàn chỉ đọc.
