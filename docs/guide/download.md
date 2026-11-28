# Tải xuống & các bản phân phối

## Bạn nhận được gì từ GitHub?

Vào repo [MoLik-Labs/MOLIK_WINLIK](https://github.com/MoLik-Labs/MOLIK_WINLIK) → nút **Code → Download ZIP** → giải nén. Chỉ cần quan tâm các file sau:

| File / thư mục | Vai trò |
|---|---|
| `MOLIK_WINLIK.bat` | **File chạy chính (offline)** — double-click, tự xin quyền Admin |
| `MolikWinlik-Portable.ps1` | Toàn bộ tool trong 1 file PowerShell (do `MOLIK_WINLIK.bat` gọi) |
| `MolikWinlik-Portable.ps1.sha256` | Dấu vân tay SHA256 của bản Portable — để kiểm chứng file không bị sửa |
| `MOLIK_WINLIK-Online.bat` | Launcher bản online (tải bản mới nhất có kiểm chứng rồi chạy) |
| `win.ps1` | Script bootstrap của kênh online (nhỏ, đọc được toàn bộ) |
| `MolikWinlik.ps1` + `Optimizer/` | Bản nguồn đầy đủ cho nhà phát triển / chạy `-Update`, `-SelfTest` sâu |
| `docs/` | Chính trang tài liệu bạn đang đọc (VitePress) |

Chỉ cần giữ `MOLIK_WINLIK.bat` + `MolikWinlik-Portable.ps1` cùng thư mục là mang sang máy khác (kể cả USB) chạy tiếp được.

## Yêu cầu hệ thống

- Windows 10 hoặc Windows 11 (64-bit khuyến nghị)
- PowerShell 5.1 (có sẵn trong Windows) hoặc PowerShell 7
- Quyền Administrator khi áp dụng tweak (tool tự xin qua UAC)
- Internet: **không cần** khi tối ưu; chỉ cần khi dùng kênh online / cài app bằng winget

## Kiểm chứng SHA256 thủ công

Muốn tự chắc chắn file Portable nguyên vẹn trước khi chạy Admin:

```powershell
Get-FileHash .\MolikWinlik-Portable.ps1 -Algorithm SHA256
Get-Content .\MolikWinlik-Portable.ps1.sha256
```

Hai dãy hex phải giống hệt nhau. Kênh [online](/guide/online) làm bước này tự động mỗi lần tải.

## Cập nhật bản offline

- Cách tự động: `MOLIK_WINLIK.bat -CheckUpdate` rồi `-Update` (xem [Bản Online](/guide/online#cap-nhat-va-sua-ban-loi)).
- Cách thủ công: tải ZIP mới, giải nén đè lên thư mục cũ. Dữ liệu của bạn nằm ở `C:\MOLIK_WINLIK_Backups\` (backup, profile, log, báo cáo) — không nằm trong thư mục tool nên không mất.

## Gỡ cài đặt

Xóa thư mục đã giải nén là xong — tool không cài service/driver nền nào để "ở lại". Nếu muốn sạch hoàn toàn, xóa thêm `C:\MOLIK_WINLIK_Backups\` sau khi đã chắc chắn không cần hoàn tác nữa. Trước khi gỡ mà đã áp tweak, nên chạy `MOLIK_WINLIK.bat -RestoreDefaults` để đưa Windows về mặc định.
