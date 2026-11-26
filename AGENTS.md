# MOLIK WINLIK — Chỉ thị cho mọi agent/phiên chat mới

Đọc file này TRƯỚC khi sửa code. Repo: MOLIK WINLIK (Windows optimizer
offline, PowerShell), branding `MOLIK WINLIK by @nggkhaiz`.

## Nạp skills (bắt buộc)

Trong `skills/` có bộ skill đã lưu sẵn cho dự án — hãy dùng chúng:

- `skills/molik-deep-debug/` — debug sâu + `scripts/audit_molik.py`
  (chạy `python3 skills/molik-deep-debug/scripts/audit_molik.py --root .`
  trước và sau mỗi đợt sửa; phải 0 FAIL).
- `skills/molik-security-audit/`, `skills/molik-perf-optimizer/`,
  `skills/molik-tui-design/`, `skills/molik-windows-tweaks/`,
  `skills/molik-release-qa/` — checklist theo từng mảng.
- `skills/external/` — skill vendor từ superpowers (systematic-debugging,
  verification-before-completion, writing-plans, TDD), golang (samber +
  spf13), low-level (profiling/debugging), design (impeccable, taste,
  ui-ux-pro-max, web-design-guidelines). Nguồn/giấy phép:
  `skills/external/SOURCES.md`.

## Bất biến không được phá

1. **Offline 100% khi chạy**: không tải code (irm/iex/DownloadString...).
   Entry point: `MOLIK_WINLIK.bat` → `MolikWinlik-Portable.ps1`.
2. `src/` upstream giữ nguyên 100%. Mọi tweak phải reversible
   (Apply/Restore/Check), không trùng khóa registry giữa các nguồn.
3. File `.ps1` có tiếng Việt phải UTF-8 **có BOM** (PowerShell 5.1).
   Không sửa tay `MolikWinlik-Portable.ps1` — sửa nguồn rồi build lại
   (`Optimizer/Build-Portable.ps1`), đối chiếu `.sha256`.
4. TUI tối giản kiểu công cụ thật (htop/lazygit): không trang trí thừa,
   không "AI slop" (xem `skills/molik-tui-design`).
5. Kiến trúc engine: PowerShell là engine chính (ADR: `docs/ADR-001`).
   Go/Rust chỉ cho helper phụ trợ khi thật cần, có benchmark chứng minh.

## Đóng đợt

Bump version đồng bộ → build Portable → audit 0 FAIL → commit → push →
PR → merge (lệnh cuối) → xóa branch đợt → xác minh Portable trên `main`
khớp SHA256. Chi tiết: `skills/molik-release-qa/SKILL.md`.
Kiểm chứng runtime Windows thuộc về người dùng (`-SelfTest`, `-Doctor`) —
không tự nhận đã chạy Windows khi ở sandbox không có PowerShell.
