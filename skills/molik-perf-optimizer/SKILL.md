---
name: molik-perf-optimizer
description: Optimize MOLIK WINLIK performance (startup time, TUI render cost, snapshot/benchmark cost) without changing behavior or the minimal TUI layout. Use when the tool feels slow to start, the tick-select UI flickers, SelfTest/Doctor scans feel heavy, or before/after making performance claims.
---

# MOLIK WINLIK — Performance Optimizer

## Nút thắt thật (đo được, đừng đoán)

1. **Khởi động**: `Get-SophiaSystemSnapshot` chạy nhiều CIM query +
   `Find-InstalledEmulators` quét ổ đĩa/registry. Lệnh chỉ-đọc
   (`-ListTweaks`, `-Version`, `-ListModes`...) không cần snapshot —
   phải đi đường tắt (lazy snapshot), chỉ tính khi tính năng cần.
2. **TUI render**: vòng lặp phím vẽ lại toàn khung. `Write-Host` qua
   pipeline rất chậm; dùng `[Console]::Write/WriteLine` trực tiếp, giữ
   nguyên layout/màu. Không đổi layout khi tối ưu hiệu năng.
3. **Benchmark tự đo**: tạo `SHA256` mới trong vòng lặp là tự làm chậm số
   đo của chính mình — tạo một lần, tái sử dụng, `Dispose` đúng.
4. Quét trạng thái 196 CheckScript là I/O registry — chấp nhận chậm, nhưng
   chỉ chạy khi người dùng yêu cầu (phím V / Doctor / Report), không chạy
   ngầm mỗi khung hình.

## Quy tắc

- Đo trước/sau bằng `-Benchmark` (Before/After) hoặc stopwatch quanh đoạn
  sửa; không tuyên bố "nhanh hơn" khi chưa có số.
- Memoize thứ bất biến trong phiên: kết quả phát hiện giả lập, danh sách
  tweak theo Mode. Catalog không đổi trong lúc chạy.
- Không đánh đổi đúng đắn lấy tốc độ: bỏ snapshot ở lệnh cần snapshot là
  bug, không phải tối ưu.
- Ngôn ngữ không phải nút thắt: tweak là ghi registry/CIM (I/O-bound).
  Viết lại Rust/Go không làm registry nhanh hơn — xem ADR-001.
