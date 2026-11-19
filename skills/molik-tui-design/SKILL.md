---
name: molik-tui-design
description: Design/keep the MOLIK WINLIK console TUI minimal and professional like real tools (htop/lazygit): fixed layout, one line per tweak, restrained color, no decorative boxes, no emoji clutter, no long help banners. Use whenever editing Optimizer/UI/InteractiveCLI.ps1 rendering, menus, headers, footers, or any user-facing console text.
---

# MOLIK WINLIK — TUI Design

Học tinh thần "restraint and self-critique" của frontend-design (anthropics/
skills) nhưng áp cho terminal thuần — người dùng đã bác bỏ giao diện rườm rà
kiểu "AI slop".

## Luật cứng

- Header tối đa 3 dòng: tên + version | tab Mode + trạng thái chọn | đường kẻ.
- Danh sách: 1 dòng/tweak, cột thẳng hàng: `> [x] ID     Tên      BADGE`.
  Badge rủi ro chỉ `EXT`/`MOD`, không màu mè thêm.
- Panel đáy cố định: 2 dòng chi tiết tweak đang chọn + 1 dòng phím tắt ngắn
  kèm vị trí trang. Trợ giúp đầy đủ chỉ hiện khi bấm `?`.
- Màu: trắng = đang chọn/tiêu điểm, xám = thường, cyan/xanh dương = điểm
  nhấn duy nhất. Một điểm nhấn thị giác cho cả màn hình là đủ.
- Không hộp trang trí `╔═╗`, không emoji trang trí trong TUI chính (giữ
  👑/emoji cho tài liệu & báo cáo HTML nếu cần), không banner hướng dẫn dài.
- Mọi khung hình phải vừa terminal nhỏ (≥60 cột): cắt chuỗi bằng helper
  truncate hiện có, không để tràn dòng gây vỡ layout.
- Menu số (`Show-SophiaSimpleMenu`) là fallback cho host không hỗ trợ
  ReadKey — giữ đồng bộ phím tắt với TUI chính.

## Khi sửa render

1. Đọc `Show-SophiaOptimizerUI` hiện tại; không thiết kế lại layout nếu
   người dùng không yêu cầu — chỉ sửa đúng điểm được nhờ.
2. Giữ cơ chế xóa phần dư của khung trước (`$lastFrameLines`) để không sót
   "rác" dưới đáy khi danh sách co lại.
3. Tự phê bình sau khi sửa: khung có còn thẳng cột ở 60/80/120 cột? Có thêm
   phần tử trang trí nào không phục vụ thao tác không? Bỏ bớt một thứ.
