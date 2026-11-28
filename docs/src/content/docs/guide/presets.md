---
title: "Preset theo tình huống"
description: "8 Preset tinh gọn cho từng hoàn cảnh: safe-daily cho máy người thân, farm-safe-247, esports-fps, god-safe..."
---

**Mode** là gói lớn theo nhu cầu; **Preset** là gói tinh hơn cho từng hoàn cảnh cụ thể — vẫn giải ra từ catalog thật nên luôn an toàn và hoàn tác được như mọi tweak khác.

```powershell
MOLIK_WINLIK.bat -ListPresets                  # xem tất cả preset
MOLIK_WINLIK.bat -Preset safe-daily -Plan       # xem trước kế hoạch (chưa áp)
MOLIK_WINLIK.bat -Preset safe-daily -Apply -Yes # áp dụng
```

Trong giao diện: tab **Presets** của GUI, hoặc phím `X` ở Menu số.

| Preset | Mode nền | Dành cho |
|---|---|---|
| `safe-daily` | BatterySaver (chỉ tweak **Safe**) | ✅ **Máy người thân / dùng hằng ngày** — gọn, mát, ổn định, rủi ro gần như bằng không |
| `farm-safe-247` | EmulatorFarm (bỏ Extreme) | Treo farm 24/7 mà máy vẫn dùng việc khác — ổn định lâu dài |
| `farm-max` | EmulatorFarm (+ Extreme chọn lọc) | Dàn farm chuyên dụng cắm điện cố định, đã có backup |
| `esports-fps` | HardcoreGaming (bỏ tweak gây nóng) | Thi đấu FPS dài — frame-time ổn định thay vì ép nhiệt |
| `streamer-workstation` | Workstation (+ latency tweak) | Stream/record/render — giữ mitigations, mượt capture |
| `potato-plus` | LowSpec (+ debloat dịch vụ) | Máy rất yếu cần nhẹ tối đa |
| `privacy-max` | MOLIK Standard (+ Privacy sâu) | Riêng tư tối đa mà không đụng hiệu năng |
| `god-safe` | GodMode (bỏ toàn bộ Extreme) | "Quét sạch an toàn" — mọi tweak trừ nhóm rủi ro Extreme |

:::tip Chưa biết chọn gì?
Cứ bắt đầu bằng `safe-daily`. Ưng rồi hãy lên Mode mạnh hơn — mọi thứ đều hoàn tác được bằng `-UndoLast`.
:::
