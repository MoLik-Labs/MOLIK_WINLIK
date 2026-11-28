---
title: "Cho nhà phát triển"
description: "Kiến trúc engine PowerShell, quy tắc kênh online, audit tĩnh, build Portable và phát triển trang tài liệu Starlight này."
---

## Kiến trúc

- **Engine**: PowerShell 5.1+ (quyết định tại [ADR-001](../../adr-001-engine-language)) — `MolikWinlik.ps1` là launcher, 18 module engine trong `Optimizer/` được inline thành bản 1-file `MolikWinlik-Portable.ps1` bằng `Optimizer/Build-Portable.ps1`. Không sửa tay file Portable.
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

## Kênh online (quy tắc bất biến)

- Code được phép chạm mạng chỉ nằm ở: `win.ps1`, `MOLIK_WINLIK-Online.bat`, `Optimizer/Core/OnlineUpdate.ps1` — audit **FAIL** nếu Portable chứa bất kỳ code tải/chạy từ mạng nào.
- Mọi đường tải đều phải: đối chiếu SHA256 trước → kiểm tra cú pháp → sao lưu `.bak` → mới thay. Không bao giờ ghi đè file đang chạy (dùng tiến trình phụ).
- Thêm lệnh online mới phải có mặt ở: launcher (switch + dispatch), `docs/guide/online.md`, `docs/guide/cli-reference.md`.

## Web tài liệu này

Trang docs dùng **Astro Starlight** trong `docs/`, deploy bằng GitHub Pages qua `.github/workflows/pages.yml`:

```bash
cd docs
npm install
npm run dev      # chạy thử local (mặc định http://localhost:4321/MOLIK_WINLIK/)
npm run build    # kiểm tra build ra docs/dist
```

- Nội dung: `docs/src/content/docs/` (Markdown/MDX, bắt buộc frontmatter `title` + `description`); trang chủ là `index.mdx` dạng splash.
- Điều hướng: sidebar khai báo bằng `slug` trong `docs/astro.config.mjs`; link nội bộ trong bài dùng đường dẫn tương đối (`../online`, `./guide/online/`) để tự khớp `base`.
- Theme: **sáng = Forest, tối = Catppuccin Mocha** — chỉnh tại `docs/src/styles/custom.css` qua biến `--sl-color-*` của Starlight.
- Tìm kiếm Pagefind và sitemap do Starlight tự sinh khi build.
- Trang tương tác dùng component native của Starlight (`Tabs`, `Steps`, `CardGrid` trong file `.mdx`) — ưu tiên chúng thay vì tự chế HTML/CSS.
- Hosting: GitHub Pages phải đặt **Settings → Pages → Source: GitHub Actions** thì workflow mới deploy được bản Starlight; nếu để legacy (branch `/`) web sẽ hiện README thay vì docs.
- Hosting 2 lớp: workflow Actions đã sẵn sàng, đồng thời bản build được **xuất bản ra gốc repo** (`python3 docs/scripts/publish_root_site.py` sau khi build) để Pages legacy (main /) phục vụ ngay — audit kiểm tra lớp gốc này tồn tại và khớp `docs/dist`. Khi nào tiện, bật thêm **Settings → Pages → Source: GitHub Actions** thì workflow tự lo hoàn toàn.
- **Kiểm tra docs như code** (học theo triết lý checks của Nimbus): sau khi build, chạy `python3 docs/scripts/check_site.py` — nó lint nguồn (frontmatter, code fence phải có nhãn, heading không nhảy cấp) và crawl bản build (mọi link/asset/neo phải tồn tại, mỗi trang đúng 1 h1 + title + description + lang). Yêu cầu **0 lỗi** trước khi commit; audit tổng của repo cũng canh lớp gốc Pages.
- Sau khi sửa docs, luôn build lại + chạy kiểm tra link nội bộ trước khi commit (mọi `href`/`src`/neo trong `docs/dist` phải trỏ tới file/ID tồn tại — ID neo của Starlight giữ nguyên dấu tiếng Việt).
