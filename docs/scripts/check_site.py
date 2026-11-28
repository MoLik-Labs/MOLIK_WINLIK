#!/usr/bin/env python3
"""MOLIK WINLIK docs checker — debug rõ ràng cho web tài liệu (phong cách
"docs lint" của Nimbus: Links / Headings / Code blocks / Metadata).

Hai lớp kiểm tra, chỉ dùng Python stdlib:
  A) NGUỒN (docs/src/content/docs): frontmatter title+description, fence
     code phải có nhãn ngôn ngữ, thứ tự heading không nhảy cấp.
  B) BẢN BUILD (docs/dist): mọi href/src nội bộ phải trỏ tới file thật,
     neo (#...) phải tồn tại, mỗi trang đúng 1 <h1>, có <title> + meta
     description + lang="vi", <img> có alt. Nếu có bản xuất bản ở gốc
     repo (GitHub Pages legacy) thì phải khớp byte với docs/dist.

Cách dùng:
  cd docs && npm run build && python3 scripts/check_site.py
Thoát mã 1 nếu có bất kỳ lỗi nào; in báo cáo theo nhóm để sửa dứt điểm.
"""
import pathlib
import re
import sys
from html.parser import HTMLParser
from urllib.parse import urlparse, unquote

DOCS = pathlib.Path(__file__).resolve().parents[1]
ROOT = DOCS.parent
SRC = DOCS / "src" / "content" / "docs"
DIST = DOCS / "dist"
BASE = "/MOLIK_WINLIK"

problems: list[str] = []
notes: list[str] = []


# ---------------------------------------------------------------- A) nguồn
def check_sources() -> None:
    files = sorted(SRC.rglob("*.md")) + sorted(SRC.rglob("*.mdx"))
    if not files:
        problems.append("NGUỒN: không thấy file nội dung nào trong src/content/docs")
        return
    for f in files:
        rel = f.relative_to(SRC)
        text = f.read_text(encoding="utf-8")
        if not text.startswith("---"):
            problems.append(f"NGUỒN {rel}: thiếu frontmatter")
            continue
        fm = text.split("---", 2)[1]
        if "title:" not in fm:
            problems.append(f"NGUỒN {rel}: frontmatter thiếu title")
        if "description:" not in fm:
            problems.append(f"NGUỒN {rel}: frontmatter thiếu description")
        # Fence: mo fence ma khong co nhan ngon ngu la loi (dong fence thi khong tinh)
        in_fence = False
        prev_heading = 1  # title trang dong vai tro h1
        for i, line in enumerate(text.split("\n"), 1):
            if line.startswith("```"):
                if not in_fence and line.strip() == "```":
                    problems.append(f"NGUỒN {rel}:{i}: code fence mở mà không có nhãn ngôn ngữ (vd ```powershell)")
                in_fence = not in_fence
                continue
            if in_fence:
                continue
            m = re.match(r"^(#{2,6})\s", line)
            if m:
                lvl = len(m.group(1))
                if lvl > prev_heading + 1:
                    problems.append(f"NGUỒN {rel}:{i}: heading nhảy cấp h{prev_heading} -> h{lvl}")
                prev_heading = lvl
    notes.append(f"NGUỒN: đã lint {len(files)} file md/mdx")


# ---------------------------------------------------------------- B) build
class PageParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.refs: list[tuple[str, str]] = []
        self.ids: set[str] = set()
        self.h1 = 0
        self.title = ""
        self._in_title = False
        self.meta_desc = False
        self.lang = ""
        self.img_no_alt: list[str] = []
        self.heading_levels: list[int] = []

    def handle_starttag(self, tag, attrs):
        d = dict(attrs)
        if tag == "html":
            self.lang = d.get("lang", "")
        if "id" in d:
            self.ids.add(d["id"])
        if tag in ("h1", "h2", "h3", "h4", "h5", "h6"):
            self.heading_levels.append(int(tag[1]))
            if tag == "h1":
                self.h1 += 1
        if tag == "title":
            self._in_title = True
        if tag == "meta" and d.get("name") == "description" and d.get("content"):
            self.meta_desc = True
        if tag == "img" and not d.get("alt"):
            self.img_no_alt.append(d.get("src", "?")[:60])
        for a in ("href", "src"):
            if a in d:
                self.refs.append((a, d[a]))

    def handle_endtag(self, tag):
        if tag == "title":
            self._in_title = False

    def handle_data(self, data):
        if self._in_title:
            self.title += data


def url_to_file(url_path: str):
    if url_path.startswith(BASE):
        url_path = url_path[len(BASE):]
    if not url_path.startswith("/"):
        return None
    path = unquote(url_path)
    cand = DIST / path.lstrip("/")
    if path.endswith("/") or not cand.suffix:
        cand = cand / "index.html"
    return cand


def check_dist() -> None:
    if not (DIST / "index.html").exists():
        problems.append("BUILD: chưa có docs/dist — chạy `cd docs && npm run build` trước")
        return
    pages: dict[str, PageParser] = {}
    for html in DIST.rglob("*.html"):
        p = PageParser()
        p.feed(html.read_text(encoding="utf-8", errors="replace"))
        pages["/" + str(html.relative_to(DIST))] = p

    for rel, p in sorted(pages.items()):
        if p.h1 != 1:
            problems.append(f"BUILD {rel}: có {p.h1} thẻ <h1> (phải đúng 1)")
        if not p.title.strip():
            problems.append(f"BUILD {rel}: thiếu <title>")
        if not p.meta_desc:
            problems.append(f"BUILD {rel}: thiếu meta description")
        if p.lang != "vi":
            problems.append(f"BUILD {rel}: lang='{p.lang}' (kỳ vọng 'vi')")
        for src in p.img_no_alt:
            problems.append(f"BUILD {rel}: <img> thiếu alt: {src}")
        prev = 0
        for lvl in p.heading_levels:
            if prev and lvl > prev + 1:
                problems.append(f"BUILD {rel}: heading nhảy cấp h{prev} -> h{lvl} trong HTML")
            prev = lvl

    checked = 0
    for rel, parser in sorted(pages.items()):
        page_url = BASE + (rel[: -len("index.html")] if rel.endswith("index.html") else rel)
        for attr, ref in parser.refs:
            if not ref or ref.startswith(("http://", "https://", "mailto:", "data:", "javascript:")):
                continue
            u = urlparse(ref)
            frag = unquote(u.fragment)
            if u.path in ("", "/") and frag:
                target_file, target_parser = DIST / rel.lstrip("/"), parser
            elif u.path.startswith("/"):
                target_file, target_parser = url_to_file(u.path), None
            else:
                joined = page_url.rstrip("/") + "/" + u.path if not u.path.startswith("..") else page_url + u.path
                parts: list[str] = []
                for seg in joined.split("/"):
                    if seg == "..":
                        if parts:
                            parts.pop()
                    elif seg not in ("", "."):
                        parts.append(seg)
                target_file = url_to_file("/" + "/".join(parts) + ("/" if u.path.endswith("/") else ""))
                target_parser = None
            checked += 1
            if target_file is None or not target_file.exists():
                problems.append(f"LINK {rel}: {attr}={ref} -> thiếu file {target_file}")
                continue
            if frag:
                if target_parser is None:
                    target_parser = PageParser()
                    target_parser.feed(target_file.read_text(encoding="utf-8", errors="replace"))
                if frag not in target_parser.ids:
                    problems.append(f"NEO {rel}: {attr}={ref} -> không có id #{frag} trong {target_file.relative_to(DIST)}")
    notes.append(f"BUILD: {len(pages)} trang, {checked} link/asset nội bộ đã kiểm")

    # Ban xuat ban o goc repo (Pages legacy) phai khop ban build
    root_index = ROOT / "index.html"
    if root_index.exists():
        def _norm(data: bytes) -> bytes:
            # Starlight nhung moc lastUpdated (theo git/mtime) vao HTML - bo qua
            # rieng gia tri thoi gian khi so khop, phan con lai phai giong het.
            s = re.sub(rb'datetime="[^"]*"', b'datetime="X"', data)
            return re.sub(rb'(datetime="X">)[^<]*', rb'\1X', s)
        if _norm(root_index.read_bytes()) != _norm((DIST / "index.html").read_bytes()):
            problems.append("ROOT: index.html ở gốc repo lệch docs/dist — chạy lại docs/scripts/publish_root_site.py")
        else:
            notes.append("ROOT: bản Pages ở gốc repo khớp docs/dist")
    if not (DIST / "llms.txt").exists():
        problems.append("BUILD: thiếu llms.txt trong dist (khai báo ở docs/public/llms.txt)")


def main() -> int:
    check_sources()
    check_dist()
    print("== MOLIK WINLIK DOCS CHECK ==")
    for n in notes:
        print("  [i]", n)
    if problems:
        print(f"\n  {len(problems)} LỖI:")
        for x in problems:
            print("   -", x)
        return 1
    print("\n  OK: 0 lỗi (links / headings / code blocks / metadata / root sync)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
