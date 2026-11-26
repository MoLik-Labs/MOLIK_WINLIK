# Online, Update & Repair

Bản chuẩn của MOLIK WINLIK là **offline**. Kênh online là tùy chọn, dành cho hai việc: lấy bản mới nhất và thay lại bản sạch khi bản đang dùng bị lỗi.

## Tự cập nhật / thay bản lỗi

```powershell
MOLIK_WINLIK.bat -Update   # có bản mới mới thay
MOLIK_WINLIK.bat -Repair   # ép thay bản sạch kể cả cùng version
```

Quy trình an toàn bắt buộc:

1. Tải `MolikWinlik-Portable.ps1` và `MolikWinlik-Portable.ps1.sha256` từ repo chính thức.
2. **Đối chiếu SHA256** — lệch hash là hủy ngay, giữ nguyên bản hiện tại.
3. Sao lưu bản hiện tại thành `*.bak-<thời gian>` rồi mới thay.
4. Nếu bản Portable đang chạy, một tiến trình phụ sẽ thay file sau khi bạn đóng cửa sổ — không bao giờ ghi đè file đang chạy.

## Chạy online luôn (không cần tải ZIP)

```powershell
irm https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1 | iex
```

`win.ps1` cũng tải + kiểm chứng SHA256 vào `%LOCALAPPDATA%\MOLIK_WINLIK` rồi mới chạy file local đã kiểm chứng. Hoặc double-click `MOLIK_WINLIK-Online.bat`.

::: warning Lưu ý
Kênh online cần Internet và có thể bị một số antivirus soi kỹ hơn (hành vi tải file là bình thường với mọi trình cập nhật). Khi cần chắc chắn tuyệt đối, hãy dùng bản offline: tải ZIP, giải nén, `MOLIK_WINLIK.bat`.
:::
