# MOLIK WINLIK — Changelog

Tool tối ưu Windows offline của fork này (nằm ngoài module upstream `src/`).
Chạy: double-click `MOLIK_WINLIK.bat`. Chi tiết kỹ thuật: `Optimizer/README.md`.

## v5.8.0 — Hoàn thiện web docs: sửa mọi lỗi link/neo & host trực tiếp

- **Crawl kiểm chứng toàn site**: 607 link/asset/neo nội bộ được kiểm tra
  tự động — sửa 6 lỗi thật (5 neo tiếng Việt bị lệch do Starlight giữ dấu
  trong ID heading, 1 link ADR sai cấp thư mục). Kết quả: 0 lỗi.
- **Host trực tiếp bằng GitHub Pages**: bản Starlight build được xuất bản
  ra gốc repo (kèm `.nojekyll`) để chế độ Pages legacy (main /) đang bật
  phục vụ ngay — không còn cảnh web chỉ hiện README và trang con 404.
  Thêm `docs/scripts/publish_root_site.py` + audit tự canh tính đồng bộ;
  workflow Actions vẫn sẵn sàng khi chuyển Source sau này.

## v5.7.0 — Starlight tối ưu trải nghiệm đọc & sẵn sàng host GitHub Pages

- Trang **Bản Online** và **Cài đặt lần đầu** chuyển sang MDX dùng
  component native của Starlight: `Tabs` (3 cách chạy online, đồng bộ
  lựa chọn giữa các khối), `Steps` (quy trình kiểm chứng 7 bước, 3 bước
  cài offline) — đọc nhanh, ít cuộn, đúng chuẩn docs hiện đại.
- Sidebar thêm huy hiệu "Mới" cho trang Online; khối code dùng theme
  **Catppuccin Latte/Mocha** đồng bộ với theme sáng/tối của site.
- Ghi rõ trong tài liệu dev: pipeline GitHub Pages (workflow đã chạy
  xanh) chỉ còn chờ bật **Settings → Pages → Source: GitHub Actions**
  một lần; nếu để legacy, web sẽ hiện README thay vì docs Starlight.

## v5.6.0 — Web docs chuyển sang Astro Starlight

- **Chuyển nền tảng docs từ VitePress sang Astro Starlight** (framework
  docs chuyên nghiệp của hệ Astro): tìm kiếm Pagefind tích hợp sẵn,
  sidebar/mục lục chuẩn, hiệu năng build nhanh, sẵn sàng mở rộng i18n.
- Toàn bộ 13 trang hướng dẫn + ADR được migrate với frontmatter
  title/description chuẩn SEO; trang chủ dạng splash với hero, khối số
  liệu, component chọn cách cài (tab Online/Offline/Cập nhật, nút Copy)
  và lưới tính năng CardGrid của Starlight.
- Theme giữ bản sắc: **sáng = Forest, tối = Catppuccin Mocha** qua biến
  `--sl-color-*`; workflow Pages build từ `docs/` (Astro) ra `docs/dist`.

## v5.5.0 — Bản Online hoàn thiện & Web docs chuyên nghiệp

- **Online v2** (`win.ps1`): đọc `.sha256` trước và dùng lại cache đã
  kiểm chứng (mở nhanh lần sau), tải tối đa 3 lần thử, kiểm tra cú pháp
  PowerShell + định dạng trước khi thay, sao lưu bản cache cũ, chuyển
  tiếp tham số cho Portable (`-Gui`, `-Mode ...`), `-Force`/`-NoLaunch`.
- **Cập nhật an toàn hơn**: thêm `-CheckUpdate` (chỉ kiểm tra, không
  Admin); `-Update`/`-Repair` dùng chung bộ tải có retry + kiểm tra
  cú pháp bản mới trước khi thay.
- **Web docs VitePress chuyên nghiệp**: logo/favicon + ảnh TUI, trang
  chủ có khối số liệu và **component chọn cách cài (tab Online/Offline/
  Cập nhật, nút Copy)**, sitemap, tìm kiếm tiếng Việt; thêm trang Bản
  Online (chủ lực), Tải xuống, Preset, Tham chiếu CLI, FAQ — tổng 13
  trang hướng dẫn. Theme sáng Forest / tối Catppuccin Mocha giữ nguyên.

## v5.4.0 — Ổn định & an toàn toàn diện

- **Xóa gì cũng hoàn lại được**: Cleanup mặc định CHUYỂN vào vùng cách ly
  `Quarantine\Cleanup_<time>` + manifest thay vì xóa hẳn —
  `-RestoreCleanup` đưa mọi thứ về đúng chỗ cũ; vùng cách ly >30 ngày mới
  tự xóa (có thông báo). Recycle Bin chỉ dọn ở -Deep kèm cảnh báo.
- **Windows Repair**: `-RepairWindows` chạy DISM RestoreHealth + SFC
  chính chủ của Windows khi máy có dấu hiệu lỗi hệ thống.
- **Ổn định khi áp**: Preflight cảnh báo chờ-restart & ổ gần đầy trước
  khi chạm hệ thống; kết quả phiên lưu `last_session_result.json` để
  Doctor hiển thị; launcher có crash-trap ghi log `crash_*.log` thay vì
  chết cứng khó hiểu.
- **Dễ dùng như winutil**: GUI thêm nút Quét trạng thái ([ĐÃ ÁP]/[chưa]
  ngay trong danh sách); Preset mới `safe-daily` (chỉ tweak Safe) cho
  máy người thân.

## v5.3.0 — Online/Update-Repair, Cleanup Center, tầng máy & Web docs

- **Kênh online tùy chọn** (core vẫn offline 100%): `win.ps1`,
  `MOLIK_WINLIK-Online.bat`, và `-Update`/`-Repair` trong launcher —
  tải bản mới từ GitHub, **kiểm chứng SHA256** (lệch = hủy), sao lưu
  `.bak` rồi thay thế an toàn kể cả khi bản Portable đang chạy.
- **Cleanup Center** (`-Cleanup`/`-DeepCleanup`, TUI `C`, Menu `Z`, GUI):
  dọn Temp/thumbnail/shader/WER/Update cache/Recycle Bin/DNS, đo MB
  giải phóng; bản sâu dùng cleanmgr + DISM có sẵn của Windows.
- **Phân tầng máy Low/Medium/High** trong Snapshot: Smart Advisor và
  Doctor chọn/giải thích Mode theo tầng — máy yếu về LowSpec ổn định.
- **Dọn repo**: xóa `img/`, README dịch upstream và CHANGELOG upstream
  thừa; README gốc bổ sung mục tầng máy, Cleanup, Online/Repair.
- **Web docs VitePress + GitHub Pages** (`docs/`, workflow pages.yml):
  hướng dẫn đầy đủ; theme sáng **Forest**, tối **Catppuccin Mocha**.

## v5.2.0 — 11 Mode, 200 tweak & README chuyên nghiệp

- **5 Mode ảo mới** (PrivacyMax 57, DebloatMax 54, Developer 78,
  Creator 76, BatterySaver 63): hợp từ Mode nền + nhóm Category + trần
  rủi ro trong `Get-SophiaModeTweakIds` — dùng chung cho TUI/GUI/CLI/
  Preset, không phải gán lại 200 tweak. Tổng **11 Mode**.
- **Vendor winutil mới nhất (70c23c8)**: thêm WU26 Hibernate-off,
  WU27 Dark Theme, WU28 Razer auto-install block, WU29 Taskbar centered
  sau khi audit chéo khóa đích với native + 24 WU cũ → tròn **200 tweak**
  (172 native + 28... gồm 28 tweak WinUtil (WU01–WU29, trừ WU05 đã gỡ)).
- TUI: phím số 1–9 chuyển Mode nhanh; Menu số chọn Mode bằng số bất kỳ
  (TUI/RAM/Boost chuyển sang phím I/P/E để không đụng số Mode).
- **README gốc viết lại hoàn toàn** (chuyên nghiệp, song ngữ tóm tắt),
  Optimizer README cập nhật đủ 11 Mode + số đếm tự động từ catalog.

## v5.1.0 — GUI winutil-style, kho skills mở rộng & dashboard mới

- **GUI cửa sổ kiểu winutil** (`MOLIK_WINLIK.bat -Gui`): 4 tab
  Tweaks/Apps/Presets/System, tick chọn + chọn Mode + tìm kiếm, cài app
  winget, backup/hoàn tác/benchmark/xuất báo cáo, log + thanh tiến trình.
  Lỗi khởi tạo (không STA...) tự fallback về TUI/Menu — không crash.
- **Kho skills mở rộng**: vendor thêm superpowers (systematic-debugging,
  verification, plans, TDD), golang (samber + spf13), low-level profiling,
  design (impeccable, taste, ui-ux-pro-max, web-design-guidelines) vào
  `skills/external/` kèm `SOURCES.md`; thêm `AGENTS.md`/`CLAUDE.md` ở gốc
  để mọi phiên chat/agent mới tự nạp skills của dự án.
- **Dashboard HTML thiết kế lại**: lưới thẻ responsive, bảng cuộn ngang +
  header dính, semantic header/main/footer, hỗ trợ in ấn & giảm chuyển
  động — vẫn offline 100%, không tài nguyên ngoài.
- Engine áp dụng: có tweak FAIL sẽ chỉ thẳng tới `-UndoLast`/phím U.
- Audit tĩnh thêm 2 kiểm tra: parity danh sách engine (launcher ↔ builder)
  và frontmatter toàn bộ 24 SKILL.md. Tổng 13/13 PASS.

## v5.0.0 — Skills, bảo mật & hiệu năng

- **Bộ Agent Skills nội bộ** (`skills/`): 6 skill theo chuẩn Agent Skills
  (học từ anthropics/skills, viết lại cho dự án) — deep-debug, security-audit,
  perf-optimizer, tui-design, windows-tweaks, release-qa — kèm công cụ audit
  tĩnh chạy đa nền tảng `audit_molik.py`. Từ nay debug có checklist + lệnh
  kiểm chứng đóng gói sẵn, dùng lại được ở mọi đợt sau.
- **Bảo mật**: `MOLIK_WINLIK.bat` escape dấu `'` trong đối số trước khi nhúng
  vào lệnh nâng quyền UAC (trước đây đối số chứa `'` bẻ vỡ chuỗi lệnh);
  fallback Chocolatey không còn gọi với ID rỗng (app chỉ có winget báo rõ).
- **Hiệu năng khởi động**: lệnh chỉ-đọc (`-ListTweaks`, `-Version`,
  `-ListModes`...) bỏ qua toàn bộ quét phần cứng/CIM — mở gần như tức thì.
  TUI vẽ bằng Console API trực tiếp thay `Write-Host` (hết chậm/nhấp nháy
  mỗi phím), danh sách tweak theo Mode và kết quả quét giả lập được nhớ
  trong phiên.
- **Đúng đắn**: gỡ ID `RAM03` trùng trong danh sách cần-restart (audit bắt
  được); Benchmark tái sử dụng một đối tượng SHA256 thay vì tạo 4000 lần/job
  làm sai chính số đo. SelfTest thêm kiểm tra trùng reboot-ID và lệch
  version Portable.
- **Kiến trúc**: ghi `docs/ADR-001` — đánh giá Rust/Go rewrite và lý do giữ
  PowerShell (nút thắt là I/O registry của Windows, minh bạch nguồn là tính
  năng bảo mật); Python lo phần audit đa nền tảng.

## v4.2.0 — Debug PRO

- Audit chéo dữ liệu WinUtil ↔ catalog native: gỡ **WU05** (trùng tuyệt đối
  EXT72), sửa restore vô nghĩa của WU14 → còn **196 tweak** không trùng lặp.
  SelfTest tự kiểm tra trùng khóa đích giữa hai nguồn + dữ liệu app.
- Hủy UAC giữa chừng: tool dừng và hướng dẫn rõ, không chạy tiếp thiếu quyền.
- `-ListTweaks -Search` không sập khi nhập ký tự đặc biệt (regex → Contains).
- Chọn GPU chính theo AdapterRAM lớn nhất (máy hybrid iGPU+dGPU hết báo sai).
- Benchmark đa luồng chỉ nhận job đã hoàn thành khi đo.

## v4.1.0 — Debug sâu & hoàn thiện cực hạn

- **Audit engine cực hạn** (ExtremeEngine/RAM Daemon/WinUtil): Restore của
  Unhide Power Settings nay xóa giá trị đúng trạng thái gốc; fsutil 8dot3
  khôi phục về mặc định hệ thống (2); dừng Timer Daemon chỉ khớp đúng
  tiến trình `MolikTimer.ps1`.
- **Không còn nhân bản Power Plan**: GAM01/EXT07 chỉ tạo Ultimate
  Performance khi chưa tồn tại (trước đây mỗi lần áp lại nhân thêm 1 bản).
- **Restore đối xứng nốt**: EMU03 bật lại đủ 3 tính năng Hyper-V đã tắt;
  EMU05 gỡ đủ exclusion đường dẫn + tiến trình đã thêm.
- **Phát hiện giả lập toàn diện**: các tweak theo exe (EXT05/EXT06) dùng
  luôn kết quả quét toàn ổ đĩa + registry của HardwareDetector.
- **Marker phiên đang chạy**: nếu mất điện/tắt máy giữa lúc áp dụng,
  Doctor lần sau cảnh báo ngay và hướng dẫn `-UndoLast`.
- Danh sách tweak cần restart đầy đủ hơn (RAM03/EXT25/EXT79/EXT80/EXT83);
  SelfTest kiểm tra thêm ID cần-restart tồn tại + khóa Mode hợp lệ.

## v4.0.0 — Bản hoàn thiện

- Đồng bộ version 4.0.0 toàn hệ thống; bản Portable khi build lại tự lấy
  version từ launcher (không còn lệch banner).
- `-ExportReport` ghi vào `C:\MOLIK_WINLIK_Backups\Reports` (không rải file
  vào thư mục repo nữa).
- `-RestoreDefaults -Yes` chạy thẳng không dừng chờ ENTER.
- Menu đơn giản có thêm phím `K` — Doctor.
- Metadata backup ghi kèm phiên bản tool.

## v3.3.0 — DEEPER

- Áp dụng xong **tự kiểm chứng**: mỗi tweak được chạy lại CheckScript, kết
  quả tách `verified` / `unverified` / FAIL (cả trong log phiên).
- Audit sâu catalog: sửa Restore thiếu đối xứng (SYS01/SYS02/EXT14/EXT15/
  EXT78), RAM04, lỗi tràn DWORD âm thầm ở GAM08/RAM09 (4294967295 → -1),
  GPU05 chỉ áp lên GPU NVIDIA thật.
- Check thật cho NET01/NET04/NET05/RAM08/EXT05/EXT06/EXT36/EXT45/EXT69.
- Tweak mới EXT85 (DoSvc), EXT86 (DPS/SRUM) — **197 tweak**.
- SelfTest: kiểm tra xung đột registry (cùng khóa, khác giá trị đích).

## v3.2.0 — TUI tối giản

- Viết lại giao diện tick-chọn: 3 dòng header, 1 dòng/tweak cột thẳng hàng,
  panel chi tiết cố định ở đáy, 1 dòng phím tắt. Bỏ hộp viền/emoji thừa.
- Menu đơn giản và header Plan gọn cùng phong cách.

## v3.1.0 — Hoàn tác & chẩn đoán

- `-UndoLast` / phím `U`: hoàn tác đúng phiên áp dụng gần nhất theo log.
- `-Doctor`: chẩn đoán chỉ đọc (VT-x, VBS/HVCI, chờ restart, HAGS/MPO...).
- `-ListBackups` / `-ListProfiles`; sửa lỗi Restore chọn nhầm thư mục
  `Logs/Profiles` làm backup mới nhất.
- TUI hết rác khung hình cũ; Plan Engine nhận Snapshot ở mọi đường áp dụng.

## v3.0.0 — Đa năng & giao diện chuyên nghiệp

- 7 Presets theo kịch bản (`-Preset`), báo cáo **HTML Dashboard**
  (`-ExportReport`, phím `H`), CLI headless đầy đủ (`-ApplyIds`,
  `-RestoreIds`, `-Status`, `-BackupOnly`, `-Version`...).
- Tweak mới EXT81–EXT84 + PRI11 — 195 tweak; EMU12 dừng thật service
  WSearch. Sửa lỗi TUI sập ngay khung đầu (thiếu khởi tạo trạng thái).

## v2.x — Offline hoàn toàn

- Bỏ hẳn đường chạy online (`irm | iex`): entry point chuẩn là
  `MOLIK_WINLIK.bat` → file local `MolikWinlik-Portable.ps1`, tự xin Admin.
- Đổi tên tool thành **MOLIK WINLIK by @nggkhaiz**; tên `Sophia-*` chỉ còn
  là shim tương thích. Encoding chuẩn UTF-8 có BOM cho PowerShell 5.1.

## v1.x — Nền tảng

- Engine tick-chọn `[✓]/[ ]`, 6 Mode (Farm/Gaming/Workstation/LowSpec/
  Standard/GodMode), catalog tweak sâu (BCD/MSI/timer/GPU/network),
  Plan Engine, Smart Advisor, Benchmark before/after, backup/restore,
  tích hợp dữ liệu winutil offline (25 tweak + 239 app, MIT).
