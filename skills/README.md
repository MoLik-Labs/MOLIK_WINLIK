# MOLIK WINLIK — Agent Skills

Bộ skill nội bộ cho dự án MOLIK WINLIK, viết theo chuẩn **Agent Skills**
(frontmatter `name` + `description` trong `SKILL.md`, thư mục riêng cho từng
skill, script/tài nguyên đóng gói kèm). Cấu trúc học từ
[anthropics/skills](https://github.com/anthropics/skills) (skill-creator,
frontend-design, webapp-testing, doc-coauthoring) rồi **viết lại hoàn toàn**
cho ngữ cảnh Windows tweaking của dự án này — không copy nguyên văn skill
thương mại nào; nguồn cảm hứng và giấy phép gốc xem `THIRD_PARTY_NOTICES.md`
ở repo anthropics/skills (Apache-2.0 cho phần lớn skill).

## Cách dùng

- **Claude Code / Arena Agent**: đặt (hoặc trỏ) thư mục `skills/` này vào nơi
  agent nạp skill (ví dụ copy/symlink từng thư mục con vào `.claude/skills/`).
  Agent sẽ tự đọc `description` để quyết định khi nào dùng skill.
- **Người bảo trì**: đọc `SKILL.md` của skill liên quan trước khi sửa code —
  đó là checklist + quy tắc bất biến của dự án, kèm lệnh kiểm chứng.
- **CI / máy thường**: chạy trực tiếp script đóng gói, không cần agent:
  `python3 skills/molik-deep-debug/scripts/audit_molik.py --root .`

## Danh sách skill

| Skill | Khi nào dùng |
|---|---|
| `molik-deep-debug` | Debug logic/code sâu: chạy audit tĩnh, săn lỗi Apply/Restore/Check không đối xứng, trùng khóa registry, dữ liệu vendor bẩn. Có `scripts/audit_molik.py` + `evals/`. |
| `molik-security-audit` | Rà soát bảo mật: offline purity, UAC/quoting injection, scheduled task persistence, Defender exclusions, khôi phục an toàn. |
| `molik-perf-optimizer` | Tối ưu hiệu năng tool (khởi động, TUI render, benchmark) mà không đổi hành vi; quy tắc đo trước/sau. |
| `molik-tui-design` | Giữ TUI tối giản kiểu công cụ thật (htop/lazygit): layout cố định, không trang trí thừa, không "AI slop". |
| `molik-windows-tweaks` | Kiến thức miền: viết/sửa tweak sao cho reversible, có Check thật, đúng pha Plan Engine, đúng mức Risk. |
| `molik-release-qa` | Đóng đợt phát hành: bump version đồng bộ, build Portable, đối chiếu SHA256, PR → merge → xóa branch. |

## Skills vendor bên ngoài

`skills/external/` chứa skill vendor nguyên văn (MIT/Apache-2.0) từ
superpowers, samber/cc-skills-golang, spf13/go-skills,
mohitmishra786/low-level-dev-skills, pbakaus/impeccable,
leonxlnx/taste-skill, nextlevelbuilder/ui-ux-pro-max-skill và
vercel-labs/agent-skills — chi tiết ở `skills/external/SOURCES.md`.
`AGENTS.md` ở gốc repo chỉ thị mọi phiên agent mới nạp bộ skills này.

## Quy tắc viết skill mới (rút từ skill-creator)

1. `name`: kebab-case, không chứa từ khóa bị cấm (`claude`, `anthropic`).
2. `description`: nói rõ skill làm gì **và khi nào kích hoạt**, tối đa 1024 ký tự.
3. Thân `SKILL.md`: quy trình + checklist + lệnh kiểm chứng cụ thể, ngắn gọn;
   chi tiết dài để vào file tham chiếu/script trong cùng thư mục.
4. Mọi khẳng định "đã kiểm tra" phải có lệnh chạy được đính kèm (script đóng
   gói ưu tiên hơn hướng dẫn đọc tay).
5. Sau khi sửa skill: chạy lại audit + evals mẫu trong `evals/` (nếu có).
