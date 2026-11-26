---
name: molik-security-audit
description: Security-audit MOLIK WINLIK: offline purity (no download/exec at runtime), UAC elevation and argument-quoting safety in MOLIK_WINLIK.bat and the launcher, scheduled-task persistence, Defender exclusions, backup/restore safety. Use when touching launchers, elevation, tasks, exclusions, winget installs, or before any release that claims "secure".
---

# MOLIK WINLIK — Security Audit

## Bất biến bảo mật của dự án

1. **Core offline 100%**: Portable không `Invoke-RestMethod`/`Invoke-WebRequest`/
   `DownloadString`/`iex` ngoài các dòng guard của chính bộ kiểm tra. Ngoại
   lệ duy nhất đã biết: winget/choco cài app do người dùng chủ động chọn,
   với `--id` exact-match từ dữ liệu vendor cố định.
   Kênh online tùy chọn DUY NHẤT: `win.ps1`, `MOLIK_WINLIK-Online.bat`,
   `Optimizer/Core/OnlineUpdate.ps1` — bắt buộc kiểm chứng SHA256 (lệch = hủy),
   sao lưu `.bak` trước khi thay, không inline vào Portable (audit kiểm tra).
2. **Minh bạch nguồn**: toàn bộ hành vi nằm trong `.ps1` đọc được. Đây là lý
   do dự án không đóng thành binary mờ (xem `docs/ADR-001-...`).
3. Mọi tweak Extreme phải: có cảnh báo, cần xác nhận riêng, reversible.

## Checklist rà soát

- [ ] `.bat` launcher: đối số người dùng (`%*`) không bao giờ lọt nguyên
      văn vào chuỗi lệnh PowerShell; dấu `'` phải được escape thành `''`
      trước khi nhúng. Đường dẫn `%~f0`/`%CORE%` luôn trong nháy kép.
- [ ] Launcher `.ps1`: hủy UAC = dừng hẳn, không chạy tiếp thiếu quyền.
      Elevation mở cửa sổ mới rồi `return`, không `exit` trần.
- [ ] Scheduled Task (EXT03/EXT38-daemon/RAM cleaner): action chỉ trỏ file
      script local của tool, argument không chứa dữ liệu người dùng chưa
      escape; task Restore phải gỡ đúng task đã tạo.
- [ ] Defender exclusions (EMU05): chỉ path/process giả lập đã phát hiện,
      Restore gỡ đủ cả exclusion path lẫn process.
- [ ] Backup/Restore: chỉ nạp `.reg` từ thư mục `Backup_*` của chính tool;
      BCD không tự `/import` (rủi ro boot) — chỉ hướng dẫn thủ công.
- [ ] Profile JSON nạp từ đĩa: ID lạ bị lọc theo catalog, không thực thi
      nội dung profile như code.
- [ ] Dữ liệu vendor (WinUtil): chỉ registry entries, kiểm tra trùng khóa
      đích với native ở mỗi lần đổi dữ liệu (SelfTest trên Windows +
      `audit_molik.py`).
- [ ] Không ghi secret/token vào log/report; HTML report chỉ chứa thông số
      phần cứng, và mọi giá trị đều `HtmlEncode`.

## Kiểm chứng

```
python3 skills/molik-deep-debug/scripts/audit_molik.py --root .
MOLIK_WINLIK.bat -SelfTest   (trên Windows: mục OFFLINE guard + encoding)
```
