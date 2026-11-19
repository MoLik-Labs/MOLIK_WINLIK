# ADR-001: Giữ PowerShell làm engine — không viết lại toàn bộ bằng Rust/Go

- Trạng thái: **Đã chốt** (đợt v5.0.0)
- Bối cảnh: Có đề xuất viết lại toàn bộ MOLIK WINLIK bằng Rust hoặc Go để
  "hiệu suất tốt và lâu dài". ADR này ghi lại đánh giá kỹ thuật để các đợt
  sau không phải tranh luận lại từ đầu.

## Đánh giá

| Tiêu chí | PowerShell (hiện tại) | Rust/Go rewrite |
|---|---|---|
| Tốc độ áp tweak | Nút thắt là ghi registry/BCD/CIM — I/O của Windows, không phụ thuộc ngôn ngữ gọi | Không nhanh hơn đáng kể; vẫn phải gọi cùng Win32/COM/WMI API |
| Minh bạch & an toàn | Người dùng đọc được 100% hành vi trong `.ps1` trước khi chạy Admin — đây là tính năng bảo mật cốt lõi của tool tối ưu hệ thống | Binary khó kiểm chứng, dễ bị AV/Defender gắn cờ hơn, mất niềm tin "đọc trước khi chạy" |
| Bề mặt API | Registry, DISM, bcdedit, powercfg, Scheduled Task, COM (WScript.Shell), CIM/WMI — PowerShell là lớp native mỏng nhất | Phải bọc lại từng API (winreg/COM interop), 196 tweak × Apply/Restore/Check viết lại từ đầu, rủi ro lệch hành vi rất lớn |
| Khả năng kiểm chứng của dự án | `-SelfTest` chạy CheckScript thật trên máy người dùng | Phải xây lại toàn bộ hạ tầng test; trong môi trường phát triển hiện tại không có sẵn toolchain Rust/Go lẫn máy Windows để đối chứng hành vi |
| Bảo trì dữ liệu vendor | Dữ liệu WinUtil dạng `.ps1` nạp trực tiếp | Phải thêm lớp đóng gói dữ liệu (JSON/nhúng) + công cụ chuyển đổi |

## Quyết định

1. **Engine giữ nguyên PowerShell 5.1+** (tương thích mọi Windows 10/11
   không cần cài thêm runtime — chính là "hiệu quả lâu dài" thực tế nhất
   cho tool loại này).
2. Hiệu năng được tối ưu ở đúng nút thắt đã đo: khởi động lười (bỏ snapshot
   phần cứng cho lệnh chỉ-đọc), render TUI bằng Console API trực tiếp,
   benchmark không tự làm chậm chính nó, memoize phát hiện giả lập/Mode.
3. Phần việc cần chạy đa nền tảng (audit tĩnh cho CI/sandbox) viết bằng
   **Python stdlib** trong `skills/molik-deep-debug/scripts/` — chạy được ở
   mọi nơi, không phụ thuộc Windows.
4. Mở lại quyết định này chỉ khi có nhu cầu cụ thể mà PowerShell không đáp
   ứng được (ví dụ daemon nền cần binary độc lập không phụ thuộc
   powershell.exe) — khi đó viết **helper nhỏ** bằng Go (single binary,
   không cgo) cho đúng phần đó, engine tweak vẫn giữ PowerShell.
