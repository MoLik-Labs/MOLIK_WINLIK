# Hỏi đáp (FAQ)

## MOLIK WINLIK có phải phần mềm cài đặt không?
Không. Đây là bộ script PowerShell chạy trực tiếp: giải nén → double-click `MOLIK_WINLIK.bat`. Không cài service/driver nền, gỡ bằng cách xóa thư mục.

## Có cần Internet không?
Không — khi tối ưu, core chạy **offline 100%**. Internet chỉ cần khi bạn chủ động dùng [kênh online](/guide/online) (chạy ngay/cập nhật) hoặc cài app bằng winget.

## Dùng bản online có an toàn không?
Có kiểm chứng bắt buộc: `win.ps1` tải bản Portable từ repo chính thức, **đối chiếu SHA256** (lệch là hủy), kiểm tra cú pháp PowerShell, sao lưu bản cũ rồi mới chạy file local. Dù vậy, nếu muốn chắc chắn tuyệt đối, hãy dùng [bản offline](/guide/download) và tự đối chiếu hash.

## Áp tweak xong máy lạ hơn thì sao?
Restart máy một lần (nhiều tweak chỉ có hiệu lực sau restart). Vẫn không ổn: `MOLIK_WINLIK.bat -UndoLast` hoàn tác phiên gần nhất, hoặc `-RestoreDefaults` về mặc định toàn bộ. Xem thêm [Khắc phục sự cố](/guide/troubleshooting).

## Tool có tự backup không?
Có — trước mỗi phiên áp: System Restore Point + xuất Registry/BCD vào `C:\MOLIK_WINLIK_Backups\`. Cleanup cũng không xóa hẳn mà chuyển vào vùng cách ly để `-RestoreCleanup` hoàn lại được.

## Máy yếu nên chọn gì?
Preset `safe-daily` hoặc Mode `LowSpec`/`BatterySaver`. Chạy `MOLIK_WINLIK.bat -Smart -Plan` để tool tự đọc tầng máy (Low/Medium/High) và khuyên kèm lý do — xem [bảng Mode theo tầng máy](/guide/modes#may-yeu-trung-binh-manh).

## Khác gì winutil của Chris Titus Tech?
Cùng triết lý tick-chọn dễ dùng, nhưng MOLIK WINLIK đi sâu hơn cho Windows gaming/farm: catalog 200 tweak (gồm cả BCD/kernel/timer), 11 Mode + 8 Preset, Plan Engine, Smart Advisor theo phần cứng, benchmark trước–sau và hệ backup/hoàn tác nhiều lớp. 28 tweak + 239 app được vendor từ winutil (MIT, ghi credit rõ ràng).

## Bản Portable khác bản đầy đủ thế nào?
Portable = 1 file chứa toàn bộ engine để mang đi chạy ngay (offline tuyệt đối, không tự tải). Bản đầy đủ (kèm `Optimizer/`) thêm: tự cập nhật `-Update`/`-Repair`, bộ skills phát triển, và khả năng sửa nguồn rồi build lại Portable.

## Windows báo SmartScreen khi chạy file tải về?
Vì file script tải từ Internet chưa có chữ ký số thương mại. Chọn *More info → Run anyway* chỉ khi bạn tải từ repo chính thức và (tốt nhất) đã đối chiếu SHA256. Đây cũng là lý do dự án luôn giữ đường offline minh bạch để bạn đọc code trước.

## Cập nhật thế nào cho an toàn nhất?
`MOLIK_WINLIK.bat -CheckUpdate` để xem có bản mới, rồi `-Update`. Mọi lần thay đều qua kiểm chứng hash + backup `.bak` — bản đang chạy không bao giờ bị ghi đè trực tiếp.
