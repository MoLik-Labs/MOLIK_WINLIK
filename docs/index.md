---
layout: home

hero:
  name: MOLIK WINLIK
  text: Tối ưu Windows sâu, offline 100%
  tagline: 200 tweak hoàn tác được · 11 Mode theo nhu cầu · GUI kiểu winutil + TUI tick-chọn + CLI đầy đủ
  actions:
    - theme: brand
      text: Bắt đầu trong 10 giây
      link: /guide/getting-started
    - theme: alt
      text: Xem 11 Mode
      link: /guide/modes

features:
  - title: Chạy offline, minh bạch 100%
    details: Double-click MOLIK_WINLIK.bat là chạy — không tải code, không cài đặt. Toàn bộ hành vi nằm trong file .ps1 đọc được trước khi chạy Admin.
  - title: An toàn trước, hiệu năng sau
    details: Tự backup Restore Point + Registry/BCD trước khi áp, kiểm chứng trạng thái thật sau khi áp, hoàn tác cả phiên bằng -UndoLast.
  - title: Máy yếu đến máy mạnh
    details: Tool tự phân tầng Low / Medium / High và khuyên đúng Mode — máy yếu gọn mát, máy mạnh bung hết. Smart Advisor quyết theo phần cứng thật.
  - title: Dọn rác bằng công cụ Windows
    details: Cleanup Center dọn cache/temp an toàn, bản sâu dùng luôn cleanmgr & DISM có sẵn của Windows và báo số MB giải phóng.
---

## Chạy ngay

```powershell
# Offline (khuyến nghị): giải nén ZIP repo -> double-click
MOLIK_WINLIK.bat

# Giao diện cửa sổ kiểu winutil
MOLIK_WINLIK.bat -Gui

# Online tùy chọn (tải bản mới nhất, kiểm chứng SHA256 trước khi chạy)
irm https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1 | iex
```

Lần đầu dùng Windows? Đọc [Cài đặt & chạy lần đầu](/guide/getting-started) — chỉ 3 bước.
Chưa biết chọn Mode nào? Xem [bảng 11 Mode](/guide/modes) hoặc chạy `MOLIK_WINLIK.bat -Smart -Plan` để tool tự khuyên.
