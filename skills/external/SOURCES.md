# Nguồn skills bên ngoài (vendored)

Các skill dưới đây được **vendor nguyên văn file `SKILL.md`** (và thư mục
nhẹ đi kèm nếu có) từ các repo công khai, theo giấy phép MIT/Apache-2.0 của
từng repo. Phần assets/scripts nặng không vendor — cần thì xem upstream.
Mọi đợt làm việc đều được phép (và khuyến khích) dùng các skill này.

| Thư mục | Upstream | Giấy phép | Dùng cho |
|---|---|---|---|
| `superpowers/` | [obra/superpowers](https://github.com/obra/superpowers) (marketplace: [obra/superpowers-marketplace](https://github.com/obra/superpowers-marketplace)) | MIT | systematic-debugging, verification-before-completion, writing-plans, TDD, finishing-a-development-branch |
| `golang/` (samber) | [samber/cc-skills-golang](https://github.com/samber/cc-skills-golang) | MIT | golang-performance, error-handling, concurrency, cli |
| `golang/spf13-go` | [spf13/go-skills](https://github.com/spf13/go-skills) | MIT | Go idioms (khi viết helper Go theo ADR-001) |
| `low-level/` | [mohitmishra786/low-level-dev-skills](https://github.com/mohitmishra786/low-level-dev-skills) | MIT | flamegraphs, hardware-counters, concurrency-debugging, core-dumps |
| `design/impeccable` | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | Apache-2.0 | polish/QA thiết kế frontend |
| `design/taste-skill` | [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) | MIT | gu thiết kế, tránh output generic |
| `design/ui-ux-pro-max` | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | MIT | hệ thống thiết kế UI/UX |
| `design/web-design-guidelines` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | (repo upstream) | audit giao diện web/HTML theo Web Interface Guidelines |

Skill nội bộ của dự án (ưu tiên cao hơn khi xung đột): 6 skill `molik-*` ở
thư mục cha. Quy tắc nạp skill mỗi phiên: xem `AGENTS.md` ở gốc repo.
