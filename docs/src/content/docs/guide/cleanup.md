---
title: "Cleanup Center — dọn cache & temp rác"
description: "Dọn cache/temp bằng cơ chế an toàn của MOLIK WINLIK: vùng cách ly hoàn lại được, cleanmgr & DISM chính chủ Windows."
---

```powershell
MOLIK_WINLIK.bat -Cleanup       # dọn thường
MOLIK_WINLIK.bat -DeepCleanup   # dọn sâu bằng công cụ Windows
```

Cũng có trong TUI (phím `C`), Menu (phím `Z`) và GUI (tab System).

## Dọn những gì

- Temp người dùng (`%TEMP%`) và Temp Windows — chỉ file cũ hơn 1 ngày
- Thumbnail/icon cache, DirectX shader cache (Windows tự dựng lại)
- Windows Error Reporting, crash dumps người dùng
- Windows Update download cache (dừng/chạy lại dịch vụ đúng quy trình)
- Delivery Optimization cache, Recycle Bin, DNS cache
- Chế độ sâu: **Disk Cleanup** (`cleanmgr /autoclean`) và **DISM** `/StartComponentCleanup` — công cụ có sẵn của Windows

## Hoàn lại sau khi dọn (vùng cách ly)

Mặc định Cleanup **không xóa hẳn**: mọi thứ được chuyển vào
`C:\MOLIK_WINLIK_Backups\Quarantine\Cleanup_<thời gian>` kèm
`manifest.json` ghi đường dẫn gốc.

```powershell
MOLIK_WINLIK.bat -RestoreCleanup   # đưa mọi thứ về chỗ cũ
```

Vùng cách ly quá 30 ngày mới tự xóa (có thông báo trước trong log).
Muốn xóa hẳn ngay từ đầu: chạy `Invoke-MolikCleanup -Permanent` trong
PowerShell. Recycle Bin chỉ được dọn ở chế độ Deep và luôn có cảnh báo,
vì thùng rác chính là lớp hoàn tác cuối của Windows.

## Cam kết an toàn

- Chỉ xóa **nội dung bên trong** các thư mục cache/temp đích — không xóa thư mục gốc, không đụng Documents/Downloads/dữ liệu cá nhân.
- File đang bị khóa tự bỏ qua; mỗi mục độc lập, lỗi một mục không ảnh hưởng mục khác.
- Báo cáo rõ **số MB giải phóng theo từng mục** sau khi dọn.
- Cần dọn thử trước khi tối ưu thật? Tweak `SYS08` trong catalog là bản rút gọn một lần; Cleanup Center là tính năng đầy đủ kèm đo lường.

Máy yếu ổ gần đầy thường giải phóng được vài GB — một trong những cách "tăng tốc" an toàn nhất trước khi đụng tweak sâu.
