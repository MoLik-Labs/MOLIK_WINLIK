---
name: molik-windows-tweaks
description: Domain rules for writing or modifying MOLIK WINLIK Windows tweaks (registry, BCD, powercfg, services, tasks): every tweak reversible, real Check script, correct Risk, correct Plan-Engine phase, mode assignment, no duplicate registry targets. Use when adding/editing tweaks in TweaksCatalog.ps1, WinUtil data, ExtremeEngine helpers, presets, or Plan Engine rules.
---

# MOLIK WINLIK — Windows Tweaks Domain Rules

## Hợp đồng của một tweak

- Đủ 4 thành phần: `ApplyScript`, `RestoreScript`, `CheckScript`, `Name`
  (+ `Id` duy nhất, `Category`, `Risk`, `Modes`).
- `RestoreScript` trả về **trạng thái gốc thật**:
  - Giá trị gốc là "không tồn tại" → `Remove-ItemProperty`.
  - Tính năng Windows (DISM/Hyper-V...) → bật lại đủ tính năng đã tắt.
  - Exclusion/service/task đã thêm → gỡ đúng thứ đã thêm, không hơn không kém.
- `CheckScript` chỉ đọc, kiểm chứng trạng thái đích thật (đọc lại giá trị),
  chạy an toàn khi thiếu phần cứng/quyền (bọc try/catch, trả `$false`).
- Không hai tweak cùng ghi một khóa `Path\Name` với giá trị đích khác nhau;
  trùng tuyệt đối (cùng giá trị) cũng phải gỡ một bên (bài học WU05~EXT72).
- DWORD giá trị `0xFFFFFFFF` viết là `-1`.

## Risk & Mode

- `Safe`: cosmetic/chuẩn upstream. `Moderate`: hiệu năng, ít đánh đổi.
  `Extreme`: đụng kernel/BCD/mitigation/Defender — bắt buộc qua Plan Engine
  phase cuối và cảnh báo riêng khi áp.
- Gán `Modes` bằng khóa hợp lệ: `EmulatorFarm`, `HardcoreGaming`,
  `Workstation`, `LowSpec`, `SophiaStandard` (hiển thị "MOLIK Standard").
  `GodMode` = toàn catalog, không gán tay.

## Plan Engine

- Tweak cần restart phải có mặt trong `Get-SophiaRebootTweakIds` (không
  trùng ID trong list).
- Phụ thuộc/cặp bắt buộc và tweak bị thay thế khai báo trong
  `Get-SophiaOptimizationPlan`, không giấu trong ApplyScript.
- Pha: nền (task/service) → registry/privacy → GPU → power → network →
  storage/pagefile → kernel/BCD cuối cùng.

## Kiểm chứng sau khi thêm/sửa tweak

```
python3 skills/molik-deep-debug/scripts/audit_molik.py --root .
MOLIK_WINLIK.bat -SelfTest        # trên Windows
MOLIK_WINLIK.bat -ListTweaks      # đếm tổng, xem phân loại
```
