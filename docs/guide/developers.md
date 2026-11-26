# Cho nhà phát triển

## Kiến trúc

- **Engine**: PowerShell 5.1+ (quyết định tại [ADR-001](/ADR-001-engine-language)) — `MolikWinlik.ps1` là launcher, 18 module engine trong `Optimizer/` được inline thành bản 1-file `MolikWinlik-Portable.ps1` bằng `Optimizer/Build-Portable.ps1`. Không sửa tay file Portable.
- **Dữ liệu**: catalog 172 tweak native (`Optimizer/Catalog/`) + 28 tweak vendor từ [winutil](https://github.com/ChrisTitusTech/winutil) (MIT, `Optimizer/Data/`).
- `src/` là module Sophia upstream — **giữ nguyên 100%**, chỉ nạp khi có `-LoadNativeSophia`.

## Bắt buộc trước khi sửa

1. Đọc `AGENTS.md` ở gốc repo và bộ skills trong `skills/` (nội bộ `molik-*` + vendor ở `skills/external/`).
2. Chạy audit tĩnh (không cần Windows):

```bash
python3 skills/molik-deep-debug/scripts/audit_molik.py --root .
# yêu cầu: 0 FAIL (13 mục: trùng ID/hàm, xung đột registry, dữ liệu WinUtil,
# offline purity của Portable, quoting của .bat, BOM UTF-8, version đồng bộ...)
```

3. Sửa xong: bump version đồng bộ (launcher/UI/Report/builder), build lại Portable, đối chiếu `.sha256`, rồi mới commit → PR → merge → xóa branch (chi tiết: `skills/molik-release-qa/SKILL.md`).

## Web tài liệu này

VitePress trong `docs/`, deploy bằng GitHub Pages qua `.github/workflows/pages.yml`:

```bash
npm install
npm run docs:dev      # chạy thử local
npm run docs:build    # kiểm tra build
```

Theme: **sáng = Forest, tối = Catppuccin Mocha** (đổi bằng nút appearance trên thanh nav) — chỉnh tại `docs/.vitepress/theme/custom.css`. Để bật Pages: repo **Settings → Pages → Source: GitHub Actions** (làm 1 lần).
