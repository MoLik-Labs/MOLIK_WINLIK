---
name: molik-release-qa
description: Close a MOLIK WINLIK release round: sync version bumps, rebuild the Portable single file, verify SHA256 on main after merge, update changelog/docs, open PR, merge last, delete the round branch. Use at the end of any feature/fix round or when asked to ship, release, merge, or clean up branches.
---

# MOLIK WINLIK — Release QA

## Checklist đóng đợt (theo đúng thứ tự)

1. `python3 skills/molik-deep-debug/scripts/audit_molik.py --root .` → 0 FAIL.
2. Bump version đồng bộ tại: `MolikWinlik.ps1`, `Optimizer/UI/InteractiveCLI.ps1`
   (fallback `Get-MolikUiVersion`), `Optimizer/Core/ReportEngine.ps1`
   (fallback), `Optimizer/Build-Portable.ps1` (fallback) + tài liệu
   (`README.md`, `Optimizer/README.md`, `HUONG-DAN-CHAY.txt`,
   `CHANGELOG-MOLIK.md` thêm mục mới ở đầu).
3. Build lại Portable từ source đã sửa; không sửa tay file Portable.
   Kiểm tra: số module inline, đủ hàm, đúng version, `.sha256` khớp.
4. Kiểm tra tĩnh cú pháp (tree-sitter-powershell: không file nào tăng
   error-node so với HEAD; Portable có false-positive đã biết) và
   `git status` sạch, `src/` upstream không bị đụng.
5. Commit → push branch đợt → `gh pr create` → `gh pr merge <n> --merge`
   (lệnh merge là lệnh cuối của chuỗi) → xóa branch remote.
6. Xác minh sau merge: Portable trên `origin/main` khớp SHA256 bản local,
   version trên `main` đúng, remote chỉ còn `main`.
7. Nhắc người dùng kiểm chứng runtime trên Windows thật:
   `MOLIK_WINLIK.bat -SelfTest` → `-Doctor` → áp thử một phiên xem dòng
   `verified`. Sandbox không có PowerShell — không tự nhận đã chạy Windows.

## Tài liệu

- Changelog viết theo phong cách doc-coauthoring: người đọc không có ngữ
  cảnh vẫn hiểu đợt này sửa gì, vì sao, và phải kiểm chứng gì.
- Số liệu trong README (tổng tweak, số theo Mode) phải khớp catalog thật —
  đếm bằng script, không chép tay từ đợt cũ.
