---
name: molik-deep-debug
description: Deep-debug MOLIK WINLIK PowerShell codebase: run the bundled static audit, hunt Apply/Restore/Check asymmetry, duplicate IDs, registry-target conflicts, stale reboot lists, vendor-data rot, encoding and version drift. Use whenever debugging logic/code in Optimizer/, MolikWinlik.ps1, TweaksCatalog.ps1, or before claiming a bug-fix release is clean.
---

# MOLIK WINLIK — Deep Debug

## Nguyên tắc

- Audit bằng script trước, đọc tay sau. Mọi kết luận "không có lỗi X" phải
  chỉ được tên lệnh đã chạy.
- Parser tĩnh chỉ thấy được một phần catalog (biến `$Path` không literal) —
  không bao giờ kết luận "không xung đột" chỉ từ parser; kiểm chứng runtime
  thuộc về `-SelfTest` trên Windows thật.
- SelfTest là CHỈ ĐỌC tuyệt đối: không gọi Undo/Restore thật để "probe".

## Quy trình

1. Chạy audit tĩnh (mọi nền tảng, không cần Windows):
   `python3 skills/molik-deep-debug/scripts/audit_molik.py --root .`
   FAIL nào cũng phải sửa ở nguồn, không sửa audit để cho qua.
2. Nếu audit PASS mà vẫn nghi ngờ: rà bằng mắt các khối `Add-Cmd` đa-khóa
   (parser không thấy), đối chiếu từng cặp Apply/Restore:
   - Restore phải trả về **trạng thái gốc thật**: giá trị gốc vốn không tồn
     tại thì `Remove-ItemProperty`, không ghi đè giá trị khác.
   - Check phải kiểm tra **kết quả thật** (đọc lại registry/trạng thái),
     không chỉ "Apply không ném lỗi".
3. Kiểm tra các danh sách tham chiếu chéo: reboot-required IDs tồn tại,
   không trùng; khóa Mode của mọi tweak thuộc 6 Mode hợp lệ; Preset giải ra
   danh sách không rỗng và tôn trọng `ExcludeRisks`.
4. Encoding: file `.ps1` chứa tiếng Việt bắt buộc UTF-8 có BOM (PS 5.1
   `-File`); sửa file bằng script ngoài dễ làm mất BOM — kiểm tra lại sau
   mỗi lần sửa hàng loạt.
5. Sau khi sửa engine: build lại Portable (`Optimizer/Build-Portable.ps1`
   trên Windows, hoặc quy trình tương đương), đối chiếu `.sha256`, chạy lại
   audit cho tới khi 0 FAIL.

## Bẫy đã từng gặp (đừng lặp lại)

- DWORD `4294967295` phải viết `-1` trong PowerShell.
- Tweak trùng tuyệt đối giữa native và WinUtil vendor chỉ lộ khi audit chéo
  hai nguồn theo khóa đích `Path\Name`.
- Restore "viết lại đúng giá trị vừa áp" là no-op trá hình.
- Ultimate Performance bị nhân bản mỗi lần áp nếu không kiểm tra scheme đã
  tồn tại trước khi `powercfg -duplicatescheme`.
