---
title: "11 Mode theo nhu cầu"
description: "Bảng 11 Mode tối ưu của MOLIK WINLIK và cách chọn theo tầng máy yếu / trung bình / mạnh."
---

Chọn Mode bằng phím `1`–`9` / `M` trong TUI, dropdown trong GUI, hoặc `-Mode <khóa>` trên CLI.

| Mode (khóa) | Tweak | Dành cho |
|---|---:|---|
| 🖥️ Treo Giả Lập 24/7 (`EmulatorFarm`) | 109 | Farm multi-instance LDPlayer/MuMu/Nox/BlueStacks |
| 🎮 Hardcore Gaming (`HardcoreGaming`) | 78 | FPS/esports low-latency |
| 🎬 Workstation (`Workstation`) | 21 | Render/compile/đa nhiệm nặng, giữ ổn định |
| 🥔 Low-Spec (`LowSpec`) | 48 | Máy yếu RAM ≤ 8GB, ổ chậm |
| 🛡️ MOLIK Standard (`SophiaStandard`) | 51 | Privacy + gọn gàng an toàn |
| 🔒 Privacy Max (`PrivacyMax`) | 57 | Riêng tư cực hạn, trần rủi ro Moderate |
| 🧹 Debloat Max (`DebloatMax`) | 54 | Dọn sạch services/ứng dụng nền |
| 💻 Developer (`Developer`) | 78 | Môi trường lập trình |
| 🎥 Creator / Streamer (`Creator`) | 76 | GPU + Network cho stream/quay/dựng |
| 🔋 Battery / Laptop (`BatterySaver`) | 63 | Chỉ tweak Safe — mát máy, tiết kiệm pin |
| 👑 God Mode (`GodMode`) | 200 | Toàn bộ catalog kể cả Extreme |

## Chọn Mode theo tầng máy yếu, trung bình, mạnh

Tool tự phân tầng phần cứng (**Low / Medium / High**) từ RAM, số luồng CPU, loại ổ đĩa và GPU:

- **Low (yếu)** — RAM ≤ 8GB, ≤ 4 luồng hoặc ổ HDD: dùng `LowSpec` / `BatterySaver`.
- **Medium (trung bình)**: dùng `Workstation` / `Creator` / `DebloatMax`.
- **High (mạnh)** — RAM ≥ 16GB, ≥ 12 luồng, SSD/NVMe: dùng `HardcoreGaming` / `EmulatorFarm` / `Developer`.

Chạy `MOLIK_WINLIK.bat -Doctor` để xem tầng máy của bạn, hoặc `-Smart -Plan` để Smart Advisor chọn hộ kèm lý do (chưa áp dụng gì).

## Mode "ảo" là gì?

5 Mode cuối (PrivacyMax → BatterySaver) được hợp tự động từ Mode nền + nhóm tweak + trần rủi ro, nên số lượng luôn khớp catalog thật và không bao giờ chứa tweak Extreme ngoài ý muốn. Ngoài Mode còn có **8 Preset** tình huống tinh hơn cho từng hoàn cảnh cụ thể — xem [trang Preset](../presets) (máy người thân nên bắt đầu bằng `safe-daily`).
