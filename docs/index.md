---
layout: home
title: MOLIK WINLIK — Tối ưu Windows sâu, an toàn, hoàn tác được
hero:
  name: MOLIK WINLIK
  text: Tối ưu Windows sâu, an toàn, hoàn tác được
  tagline: by @nggkhaiz · 200 tweak · 11 Mode theo nhu cầu · GUI kiểu winutil + TUI tick-chọn + CLI đầy đủ · Core chạy offline 100%, kênh online có kiểm chứng SHA256
  image:
    src: /tui-preview.svg
    alt: Giao diện TUI tick-chọn của MOLIK WINLIK
  actions:
    - theme: brand
      text: 🌐 Dùng bản Online ngay
      link: /guide/online
    - theme: alt
      text: Cài đặt lần đầu (3 bước)
      link: /guide/getting-started
    - theme: alt
      text: Xem 11 Mode
      link: /guide/modes

features:
  - icon: 🌐
    title: Bản Online có kiểm chứng
    details: Một dòng lệnh là chạy bản mới nhất — win.ps1 tải Portable, đối chiếu SHA256, kiểm tra cú pháp, sao lưu bản cũ rồi mới chạy file local đã kiểm chứng. Cập nhật/sửa bản lỗi bằng -Update / -Repair.
  - icon: 📦
    title: Bản Offline chuẩn 100%
    details: Double-click MOLIK_WINLIK.bat là chạy — không tải code, không cài đặt. Toàn bộ hành vi nằm trong file .ps1 đọc được trước khi cấp quyền Admin. Mang USB sang máy khác chạy tiếp.
  - icon: 🛡️
    title: An toàn trước, hiệu năng sau
    details: Tự backup Restore Point + Registry/BCD trước khi áp, kiểm chứng trạng thái thật sau khi áp, hoàn tác cả phiên bằng -UndoLast. Xóa gì cũng hoàn lại được (vùng cách ly Cleanup).
  - icon: 💻
    title: Máy yếu đến máy mạnh
    details: Tool tự phân tầng Low / Medium / High và khuyên đúng Mode — máy yếu gọn mát, máy mạnh bung hết hiệu năng. Smart Advisor quyết theo phần cứng thật của bạn.
  - icon: 🖱️
    title: Dễ dùng như winutil
    details: GUI 4 tab tick bằng chuột, TUI tick-chọn bằng bàn phím, Menu số cho terminal lạ, và headless CLI đầy đủ cho script. Quét trạng thái ĐÃ ÁP/chưa ngay trong danh sách.
  - icon: 🧹
    title: Dọn rác bằng công cụ Windows
    details: Cleanup Center dọn cache/temp an toàn qua vùng cách ly (hoàn lại được), bản sâu dùng chính cleanmgr & DISM có sẵn của Windows, sửa lỗi hệ thống bằng DISM + SFC chính chủ.
---

<div class="molik-stats">
  <div class="molik-stat"><b>200</b><span>tweak hệ thống<br>(172 native + 28 WinUtil)</span></div>
  <div class="molik-stat"><b>11</b><span>Mode theo nhu cầu<br>Farm · Gaming · Low-Spec…</span></div>
  <div class="molik-stat"><b>239</b><span>ứng dụng cài qua winget<br>(dữ liệu winutil, MIT)</span></div>
  <div class="molik-stat"><b>100%</b><span>core offline<br>online là tùy chọn có kiểm chứng</span></div>
</div>

## Cài đặt trong 10 giây — chọn cách của bạn

<InstallBox />

## Chọn cách chạy trong 30 giây

| Bạn đang… | Cách khuyên dùng | Trang hướng dẫn |
|---|---|---|
| Muốn thử ngay, có Internet | **Bản Online** 1 dòng lệnh | [Bản Online](/guide/online) |
| Cần chắc chắn, không muốn tải code khi chạy | **Bản Offline** từ ZIP GitHub | [Tải xuống](/guide/download) |
| Đã dùng, muốn bản mới / bản cũ bị lỗi | `-CheckUpdate` → `-Update` / `-Repair` | [Cập nhật & sửa lỗi](/guide/online#cap-nhat-va-sua-ban-loi) |
| Máy người thân, cần an toàn tuyệt đối | Offline + Preset `safe-daily` | [Preset](/guide/presets) |
| Viết script / triển khai nhiều máy | Headless CLI | [Tham chiếu CLI](/guide/cli-reference) |

## Vì sao an toàn?

1. **Trước khi áp** — Plan Engine sắp xếp thứ tự an toàn, chặn tweak mâu thuẫn; tool tự tạo Restore Point + xuất Registry/BCD.
2. **Trong khi áp** — preflight cảnh báo máy chờ restart / ổ gần đầy; phiên bị ngắt để lại dấu vết để Doctor cảnh báo lần sau.
3. **Sau khi áp** — từng tweak được kiểm chứng trạng thái thật; không hợp thì `-UndoLast` hoàn tác cả phiên, `-RestoreDefaults` về mặc định toàn bộ.

Chi tiết: [An toàn, Backup & Hoàn tác](/guide/safety).

## Chưa biết chọn gì?

Chạy `MOLIK_WINLIK.bat -Smart -Plan` — tool đọc phần cứng (RAM, CPU, ổ, GPU), phân tầng máy và **in kế hoạch kèm lý do mà chưa áp gì cả**. Xem thêm [bảng 11 Mode](/guide/modes) hoặc để [Smart Advisor trong hướng dẫn bắt đầu](/guide/getting-started) chọn hộ.
