# Trang này đã chuyển

Nội dung **Online, Update & Repair** đã được mở rộng thành trang chính thức:

👉 **[🌐 Bản Online — chạy ngay, cập nhật & sửa bản lỗi an toàn](/guide/online)**

Tóm tắt nhanh:

```powershell
# Chạy bản online ngay (tải + kiểm chứng SHA256 rồi chạy local)
irm https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1 | iex

# Đã cài bản đầy đủ:
MOLIK_WINLIK.bat -CheckUpdate   # kiểm tra bản mới (không thay gì)
MOLIK_WINLIK.bat -Update        # cập nhật khi có bản mới
MOLIK_WINLIK.bat -Repair        # ép thay bản sạch khi bản đang dùng bị lỗi
```
