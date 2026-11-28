# MOLIK WINLIK

**Bộ tối ưu Windows sâu, chạy offline 100%, có giao diện đồ họa kiểu winutil + TUI tick-chọn + CLI đầy đủ.**

`MOLIK WINLIK by @nggkhaiz` — 200 tweak hệ thống (172 native + 28 WinUtil vendored), 11 Mode theo nhu cầu, backup/khôi phục toàn diện, benchmark trước–sau, và mọi tweak đều **hoàn tác được**.

> 🇻🇳 Tiếng Việt là ngôn ngữ chính của dự án. English summary at the bottom.

---

## Bắt đầu trong 10 giây (không cần Internet)

1. Tải ZIP của repo này, giải nén vào một thư mục bất kỳ.
2. Double-click **`MOLIK_WINLIK.bat`** → bấm **Yes** khi Windows hỏi quyền Administrator.
3. Giao diện tick-chọn mở ra. Tick tweak → `ENTER` để áp dụng. Xong.

Không cài đặt, không tải thêm gì khi chạy, không `irm | iex`. Muốn giao diện cửa sổ: `MOLIK_WINLIK.bat -Gui`.

## Giao diện

| Giao diện | Lệnh | Phù hợp |
|---|---|---|
| **GUI (winutil-style)** | `MOLIK_WINLIK.bat -Gui` | 4 tab Tweaks / Apps / Presets / System, chuột + tick chọn, log & tiến trình trực tiếp. Tự fallback TUI nếu không mở được |
| **TUI tick-chọn** | `MOLIK_WINLIK.bat` | Bàn phím: `↑↓` chọn, `SPACE` tick, `ENTER` áp dụng, `1-9`/`M` đổi Mode, `/` tìm, `?` trợ giúp — tối giản kiểu htop |
| **Menu số** | `MOLIK_WINLIK.bat -Menu` | Host không hỗ trợ phím trực tiếp (ISE, output redirect...) |
| **Headless CLI** | xem bảng dưới | Script/automation, chạy không tương tác |

## 11 Mode tối ưu

| Mode (khóa) | Tweak | Dành cho |
|---|---:|---|
| 🖥️ Treo Giả Lập 24/7 (`EmulatorFarm`) | 109 | Farm multi-instance LDPlayer/MuMu/Nox/BlueStacks: tắt VBS/Hyper-V tranh VT-x, dọn RAM tự động, pagefile cố định |
| 🎮 Hardcore Gaming (`HardcoreGaming`) | 78 | FPS/esports low-latency: HAGS, MPO/Game DVR off, timer & BCD latency, Nagle off, chuột 1:1, Ultimate Performance |
| 🎬 Workstation (`Workstation`) | 21 | Render/compile/đa nhiệm nặng — mạnh nhưng giữ ổn định & mitigations |
| 🥔 Low-Spec (`LowSpec`) | 48 | Máy yếu RAM ≤ 8GB, ổ chậm: gọn tiến trình nền, giảm tải hệ thống |
| 🛡️ MOLIK Standard (`SophiaStandard`) | 51 | Privacy + gọn gàng an toàn, không đụng kernel/BCD |
| 🔒 Privacy Max (`PrivacyMax`) | 57 | Riêng tư cực hạn: toàn nhóm Privacy + WinUtil, trần rủi ro Moderate |
| 🧹 Debloat Max (`DebloatMax`) | 54 | Dọn sạch services/ứng dụng nền/Explorer tối đa |
| 💻 Developer (`Developer`) | 78 | Môi trường lập trình sạch, ổn định khi build/test |
| 🎥 Creator / Streamer (`Creator`) | 76 | GPU + Network cho stream/quay/dựng: encode mượt, mạng ổn định |
| 🔋 Battery / Laptop (`BatterySaver`) | 63 | Chỉ tweak Safe: mát máy, tiết kiệm pin, không khóa xung |
| 👑 God Mode (`GodMode`) | 200 | Toàn bộ catalog kể cả Extreme — chỉ khi đã backup và hiểu rõ đánh đổi |

5 Mode cuối là **Mode ảo**: hợp từ Mode nền + nhóm tweak + trần rủi ro, nên luôn khớp catalog thật. Ngoài Mode còn có **7 Preset** tình huống (`-ListPresets`), **Smart Advisor** tự khuyên theo phần cứng (phím `G`), và **Plan Engine** sắp xếp thứ tự áp an toàn + cảnh báo mâu thuẫn trước khi chạm vào hệ thống.

## CLI headless

```powershell
MOLIK_WINLIK.bat -Mode HardcoreGaming -Apply -Yes   # áp cả Mode
MOLIK_WINLIK.bat -Preset <tên> -Apply -Yes          # áp Preset
MOLIK_WINLIK.bat -ApplyIds GAM01,GPU01 -Yes         # áp theo ID
MOLIK_WINLIK.bat -Smart -Plan                       # xem kế hoạch Smart Advisor khuyên
MOLIK_WINLIK.bat -ListTweaks -Search "timer"        # tra cứu catalog
MOLIK_WINLIK.bat -Benchmark -BenchmarkLabel Before  # đo trước / After rồi -CompareBenchmarks
MOLIK_WINLIK.bat -Doctor                            # chẩn đoán hệ thống (chỉ đọc)
MOLIK_WINLIK.bat -SelfTest                          # tự kiểm tra toàn diện (chỉ đọc)
MOLIK_WINLIK.bat -UndoLast -Yes                     # hoàn tác phiên áp dụng gần nhất
MOLIK_WINLIK.bat -ExportReport                      # xuất Dashboard HTML + JSON
MOLIK_WINLIK.bat -Gui                               # giao diện cửa sổ
```

## Máy yếu / trung bình / mạnh — chọn Mode theo tầng máy

Tool tự phân tầng phần cứng (**Low / Medium / High** từ RAM, số luồng CPU, loại ổ, GPU — xem `-Doctor`):

| Tầng máy | Nhận biết | Mode khuyên dùng |
|---|---|---|
| **Low (yếu)** | RAM ≤ 8GB, ≤ 4 luồng, hoặc ổ HDD | `LowSpec`, `BatterySaver` — gọn, mát, ổn định |
| **Medium (trung bình)** | Còn lại | `Workstation`, `Creator`, `DebloatMax` — cân bằng |
| **High (mạnh)** | RAM ≥ 16GB, ≥ 12 luồng, SSD/NVMe | `HardcoreGaming`, `EmulatorFarm`, `Developer` — bung hết |

Không chắc máy mình tầng nào? Chạy `MOLIK_WINLIK.bat -Smart -Plan` — Smart Advisor tự đọc tầng máy và khuyên Mode kèm lý do.

## Dọn cache & temp rác (Cleanup Center)

`MOLIK_WINLIK.bat -Cleanup` — dọn an toàn bằng cơ chế của Windows: Temp người dùng & Windows, thumbnail/icon cache, DirectX shader cache, báo lỗi WER, Windows Update cache, Delivery Optimization, Recycle Bin, DNS cache; báo rõ đã giải phóng bao nhiêu MB. `-DeepCleanup` dùng thêm **Disk Cleanup (`cleanmgr /autoclean`)** và **DISM StartComponentCleanup** có sẵn của Windows. Trong TUI bấm `C`, trong Menu bấm `Z`, trong GUI có nút ở tab System. Chỉ đụng cache/temp — không bao giờ chạm dữ liệu cá nhân.

## Online & tự thay bản mới khi lỗi (tùy chọn)

Bản chuẩn vẫn là **offline**. Kênh online phục vụ: chạy ngay không cần tải ZIP, kiểm tra/cập nhật bản mới, và thay bản sạch khi bản đang dùng bị lỗi:

```powershell
irm https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1 | iex   # chạy bản online ngay
MOLIK_WINLIK.bat -CheckUpdate   # chỉ kiểm tra có bản mới không (không thay gì)
MOLIK_WINLIK.bat -Update        # tải bản mới, kiểm chứng SHA256 rồi thay (tự sao lưu .bak)
MOLIK_WINLIK.bat -Repair        # ép thay lại bản sạch kể cả khi cùng version
```

Mọi đường online đều theo cùng quy trình: **đối chiếu SHA256 với file `.sha256` chính thức → kiểm tra cú pháp → sao lưu `.bak` → mới thay/chạy** — lệch hash là hủy ngay và giữ nguyên bản hiện tại. `win.ps1` còn dùng lại bản cache đã kiểm chứng cho những lần mở sau (khởi động nhanh), tải tối đa 3 lần thử. Cũng có `MOLIK_WINLIK-Online.bat` để double-click và chuyển tham số (ví dụ `-Gui`).

📚 **Tài liệu đầy đủ (web)**: https://molik-labs.github.io/MOLIK_WINLIK/ — hướng dẫn từng bước, bảng 11 Mode/8 Preset, tham chiếu CLI, FAQ (nguồn trong `docs/`, VitePress).

## An toàn & khôi phục

- **Tự backup trước khi áp**: System Restore Point + xuất registry/BCD vào `C:\MOLIK_WINLIK_Backups\`.
- **Mọi tweak đều có Restore** trả về đúng trạng thái gốc; áp xong tool **tự kiểm chứng** trạng thái thật (`verified`/`unverified` trong log).
- `-UndoLast` hoàn tác cả phiên gần nhất; phiên bị ngắt giữa chừng (mất điện...) được Doctor cảnh báo ở lần mở sau.
- **Cleanup không xóa hẳn**: mặc định chuyển vào vùng cách ly kèm manifest — `-RestoreCleanup` hoàn lại toàn bộ; `-RepairWindows` sửa Windows bằng DISM + SFC chính chủ khi máy lỗi.
- Tweak rủi ro **Extreme** phải xác nhận riêng và được Plan Engine xếp áp cuối cùng, ngay trước khi restart.
- **Minh bạch**: toàn bộ hành vi nằm trong file `.ps1` đọc được — không binary mờ, không tải code khi chạy.

## Cho nhà phát triển

- Kiến trúc & quyết định kỹ thuật: `docs/ADR-001-engine-language.md` (vì sao engine là PowerShell, Go/Rust chỉ cho helper phụ trợ).
- Bộ **Agent Skills** của dự án: `skills/` (6 skill nội bộ + skills vendor từ superpowers/golang/low-level/design) — `AGENTS.md` ở gốc repo hướng dẫn mọi phiên agent nạp chúng. Audit tĩnh đa nền tảng: `python3 skills/molik-deep-debug/scripts/audit_molik.py --root .`
- Build bản 1-file: `Optimizer\Build-Portable.ps1` → `MolikWinlik-Portable.ps1` + `.sha256`. Không sửa tay file Portable.
- Nhật ký thay đổi: `CHANGELOG-MOLIK.md`. Tài liệu engine: `Optimizer/README.md`.

## Nguồn gốc & giấy phép

Xây trên [Sophia Script for Windows](https://github.com/farag2/Sophia-Script-for-Windows) (thư mục `src/` giữ nguyên 100%) và dữ liệu tweak/app của [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil) (MIT, vendor offline tại `Optimizer/Data/`, xem `LICENSE-winutil.txt`). Phần MOLIK WINLIK phát hành theo cùng tinh thần mã nguồn mở — đọc code trước khi chạy Admin là quyền của bạn.

---

### English summary

MOLIK WINLIK is a fully-offline Windows deep-optimization toolkit: 200 reversible tweaks, 11 need-based modes, a winutil-style window GUI plus a minimal keyboard TUI and a full headless CLI, automatic registry/BCD backup before applying, post-apply verification, one-click undo of the last session, and before/after benchmarks. Double-click `MOLIK_WINLIK.bat` (it self-elevates) — no downloads at runtime, ever.
