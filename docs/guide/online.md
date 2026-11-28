# 🌐 Bản Online — chạy ngay, cập nhật & sửa bản lỗi an toàn

Bản chuẩn của MOLIK WINLIK vẫn là **offline** (tải ZIP một lần, chạy mãi). **Kênh online là tùy chọn** phục vụ ba việc: chạy ngay không cần tải ZIP, kiểm tra/cập nhật bản mới, và **thay lại bản sạch khi bản đang dùng bị lỗi** — mọi bước đều có kiểm chứng SHA256.

::: tip Tóm tắt 10 giây
```powershell
irm https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1 | iex
```
Lệnh này **không chạy code lạ trực tiếp**: `win.ps1` tải bản Portable về máy, đối chiếu SHA256 với file `.sha256` chính thức, kiểm tra cú pháp, rồi mới chạy **file local đã kiểm chứng** với quyền Admin.
:::

## Ba cách dùng bản online

| Cách | Lệnh / thao tác | Hợp khi |
|---|---|---|
| **A. Một dòng lệnh** | `irm https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1 \| iex` | Muốn chạy ngay trên máy bất kỳ có Internet |
| **B. File Online.bat** | Double-click `MOLIK_WINLIK-Online.bat` (có trong repo) | Thích double-click, muốn chuyển tham số như `-Gui` |
| **C. Tải win.ps1 về chạy** | `powershell -ExecutionPolicy Bypass -File .\win.ps1 -Gui` | Muốn đọc script bootstrap trước khi chạy, hoặc chuyển tham số đầy đủ |

Cả ba cách đều dùng chung một quy trình kiểm chứng bên dưới — khác nhau chỉ ở cách khởi động.

## Quy trình kiểm chứng — vì sao an toàn?

`win.ps1` (kích thước nhỏ, đọc được toàn bộ trên GitHub) thực hiện đúng thứ tự:

1. **Lấy dấu vân tay trước** — tải file `MolikWinlik-Portable.ps1.sha256` (vài chục byte) từ repo chính thức `MoLik-Labs/MOLIK_WINLIK`.
2. **Dùng lại cache nếu còn mới** — nếu bản đã tải ở `%LOCALAPPDATA%\MOLIK_WINLIK\` khớp SHA256 thì dùng luôn, không tải lại ~390 KB (mở nhanh những lần sau). `-Force` để ép tải lại.
3. **Tải có thử lại** — tải Portable tối đa 3 lần (mạng chập chờn không làm hỏng phiên), timeout rõ ràng.
4. **Đối chiếu SHA256** — lệch hash là **hủy ngay**, xóa file tải dở, không đụng bản hiện tại.
5. **Kiểm tra cú pháp & định dạng** — file phải parse sạch bằng parser PowerShell, dung lượng hợp lý và có version marker của MOLIK WINLIK.
6. **Sao lưu rồi mới thay** — bản cache cũ thành `*.bak-<thời gian>` trước khi ghi bản mới.
7. **Chạy file local** — tự xin quyền Administrator và chạy file đã kiểm chứng, chuyển tiếp mọi tham số bạn truyền (ví dụ `-Gui`, `-Mode ...`).

::: warning Antivirus soi kênh online là bình thường
Mọi trình cập nhật tải file thực thi đều có thể bị antivirus để ý hơn bản offline. Nếu cần chắc chắn tuyệt đối, dùng [bản offline](/guide/download) — tải ZIP từ GitHub, giải nén, đọc code nếu muốn, rồi double-click `MOLIK_WINLIK.bat`.
:::

## Cập nhật và sửa bản lỗi

Khi đã có MOLIK WINLIK trên máy (bản đầy đủ kèm thư mục `Optimizer/`):

```powershell
MOLIK_WINLIK.bat -CheckUpdate   # chỉ kiểm tra: bạn đang ở bản mới nhất chưa? (không thay gì, không cần Admin)
MOLIK_WINLIK.bat -Update        # có bản mới mới thay
MOLIK_WINLIK.bat -Repair        # ép thay bản sạch kể cả cùng phiên bản — dùng khi nghi file bị lỗi/hỏng
```

Quy trình `-Update` / `-Repair`:

1. Tải bản mới + `.sha256` từ repo chính thức (tối đa 3 lần thử mỗi file).
2. **SHA256 lệch → hủy**, giữ nguyên bản hiện tại.
3. Kiểm tra cú pháp PowerShell của bản mới — lỗi parse thì hủy.
4. Sao lưu bản hiện tại thành `MolikWinlik-Portable.ps1.bak-<thời gian>`.
5. Thay thế an toàn: nếu bản Portable **đang chạy**, một tiến trình phụ sẽ thay file sau khi bạn đóng cửa sổ — không bao giờ ghi đè file đang chạy.

::: info Đang chạy bằng bản Portable lẻ (chỉ 2 file .bat + .ps1)?
Bản Portable lẻ cố ý **không chứa code tải** (offline tuyệt đối). Khi đó `-Update` sẽ hướng dẫn hai cách: chạy `MOLIK_WINLIK-Online.bat`, hoặc tải ZIP mới từ GitHub giải nén đè — backup của bạn ở `C:\MOLIK_WINLIK_Backups\` không bị đụng vào.
:::

## Truyền tham số qua bản online

```powershell
# Qua file win.ps1 đã tải về:
powershell -ExecutionPolicy Bypass -File .\win.ps1 -Gui
powershell -ExecutionPolicy Bypass -File .\win.ps1 -Mode HardcoreGaming -Apply -Yes
powershell -ExecutionPolicy Bypass -File .\win.ps1 -Force        # ép tải lại bản mới nhất
powershell -ExecutionPolicy Bypass -File .\win.ps1 -NoLaunch     # chỉ tải & kiểm chứng, không chạy

# Qua Online.bat:
MOLIK_WINLIK-Online.bat -Gui
MOLIK_WINLIK-Online.bat -Doctor
```

## Lỗi thường gặp ở kênh online

| Hiện tượng | Nguyên nhân & cách xử lý |
|---|---|
| `SHA256 KHÔNG KHỚP` | File tải bị lỗi/hỏng giữa đường hoặc nguồn không đúng. Tool đã tự hủy — kiểm tra mạng rồi chạy lại; nếu lặp lại, dùng bản offline |
| Tải lỗi sau 3 lần thử | Mạng/proxy chặn `raw.githubusercontent.com`. Dùng [bản offline](/guide/download) hoặc đổi mạng |
| Antivirus chặn file tải | Hành vi tải chương trình bị soi là bình thường. Ưu tiên bản offline từ ZIP GitHub chính thức |
| Mở online nhưng ra bản cũ | Cache còn khớp hash cũ của repo tại thời điểm kiểm tra — chạy lại với `-Force` (`win.ps1`) hoặc `MOLIK_WINLIK.bat -Repair` |

## Online vs Offline — chọn thế nào?

| Tiêu chí | 🌐 Online | 📦 Offline |
|---|---|---|
| Cần Internet | Có (lúc tải/cập nhật) | Không |
| Luôn mới nhất | ✔ Tự lấy bản mới | Cập nhật tay bằng ZIP hoặc `-Update` |
| Kiểm chứng toàn vẹn | SHA256 + parse-check tự động | Bạn tự đối chiếu `.sha256` nếu muốn ([hướng dẫn](/guide/download#kiem-chung-sha256-thu-cong)) |
| Antivirus thân thiện | Trung bình | Cao nhất |
| Khuyên dùng cho | Thử nhanh, sửa bản lỗi, cập nhật | Dùng lâu dài, máy farm, triển khai nhiều máy |

Tiếp theo: [Cài đặt & chạy lần đầu](/guide/getting-started) hoặc [An toàn, Backup & Hoàn tác](/guide/safety).
