---
title: "Cài đặt & chạy lần đầu"
description: "Hai đường vào MOLIK WINLIK: online chạy ngay trong 10 giây, hoặc offline chuẩn 3 bước — cùng một bản Portable đã kiểm chứng SHA256."
---

MOLIK WINLIK không cần cài đặt. Có hai đường vào — **online để thử ngay** và **offline để dùng lâu dài**; cả hai đều dẫn tới cùng một bản Portable đã kiểm chứng.

## Cách 1 — Online: chạy ngay trong 10 giây

Mở PowerShell và dán một dòng:

```powershell
irm https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1 | iex
```

`win.ps1` sẽ tải bản mới nhất về `%LOCALAPPDATA%\MOLIK_WINLIK`, **kiểm chứng SHA256 + cú pháp**, xin quyền Admin rồi chạy file local. Những lần sau, nếu bản cache vẫn mới nhất thì mở gần như tức thì. Chi tiết & các biến thể: [Bản Online](../online).

## Cách 2 — Offline (chuẩn, khuyến nghị lâu dài): 3 bước

1. **Tải** ZIP của repo từ [GitHub](https://github.com/MoLik-Labs/MOLIK_WINLIK) (nút `Code → Download ZIP`) và giải nén vào một thư mục bất kỳ, ví dụ `D:\MOLIK_WINLIK` — xem [giải thích từng file](../download).
2. **Double-click `MOLIK_WINLIK.bat`** → bấm **Yes** khi Windows hỏi quyền Administrator.
3. Giao diện tick-chọn mở ra: dùng `↑`/`↓` di chuyển, `SPACE` tick tweak, `ENTER` áp dụng.

Chỉ cần giữ `MOLIK_WINLIK.bat` và `MolikWinlik-Portable.ps1` cùng thư mục là mang sang máy khác chạy tiếp được (USB cũng được).

## Các cách chạy khác

| Cách | Lệnh | Khi nào dùng |
|---|---|---|
| GUI cửa sổ | `MOLIK_WINLIK.bat -Gui` | Thích dùng chuột, kiểu winutil |
| Menu số | `MOLIK_WINLIK.bat -Menu` | Terminal không hỗ trợ phím trực tiếp |
| Kiểm tra bản mới | `MOLIK_WINLIK.bat -CheckUpdate` | Xem có bản mới không (chỉ kiểm tra) |
| Cập nhật / sửa bản lỗi | `MOLIK_WINLIK.bat -Update` / `-Repair` | Bản mới nhất, hoặc bản đang dùng bị lỗi cần thay sạch |
| Headless | `MOLIK_WINLIK.bat -Mode HardcoreGaming -Apply -Yes` | Script, tự động hóa — xem [Tham chiếu CLI](../cli-reference) |

## Trước khi áp lần đầu

- Tool **tự tạo backup** (Restore Point + Registry/BCD) trước khi áp — cứ yên tâm.
- Chạy thử `MOLIK_WINLIK.bat -SelfTest` (chỉ đọc) để chắc chắn môi trường khỏe.
- Chưa rõ máy mình hợp Mode nào: `MOLIK_WINLIK.bat -Smart -Plan` — tool đọc phần cứng và in kế hoạch kèm lý do, chưa áp gì cả.
- Muốn tuyệt đối an toàn cho lần đầu: dùng [Preset `safe-daily`](../presets) (chỉ tweak mức Safe).

## Gỡ / quay lại như cũ

- Hoàn tác phiên gần nhất: `MOLIK_WINLIK.bat -UndoLast`
- Khôi phục mặc định toàn bộ: `MOLIK_WINLIK.bat -RestoreDefaults`
- Xóa tool: xóa thư mục đã giải nén. Backup nằm ở `C:\MOLIK_WINLIK_Backups\` — xóa luôn nếu không cần.
