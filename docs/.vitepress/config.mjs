import { defineConfig } from 'vitepress'

// MOLIK WINLIK — trang tài liệu chính thức
// Site: https://molik-labs.github.io/MOLIK_WINLIK/  (GitHub Pages, deploy qua Actions)
// Theme: sáng = Forest, tối = Catppuccin Mocha (xem theme/custom.css)
const REPO = 'https://github.com/MoLik-Labs/MOLIK_WINLIK'

export default defineConfig({
  // Chỉ ảnh hưởng khi chạy `npm run docs:dev` (cho phép mở qua host preview);
  // bản build tĩnh lên GitHub Pages không dùng cấu hình này.
  vite: { server: { allowedHosts: true } },
  lang: 'vi-VN',
  title: 'MOLIK WINLIK',
  titleTemplate: ':title · MOLIK WINLIK',
  description:
    'MOLIK WINLIK by @nggkhaiz — bộ tối ưu Windows sâu: 200 tweak hoàn tác được, 11 Mode, GUI kiểu winutil, TUI tick-chọn, Cleanup Center, kênh online kiểm chứng SHA256.',
  base: '/MOLIK_WINLIK/',
  cleanUrls: true,
  lastUpdated: true,
  sitemap: { hostname: 'https://molik-labs.github.io/MOLIK_WINLIK/' },

  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/MOLIK_WINLIK/favicon.svg' }],
    ['meta', { name: 'theme-color', content: '#2e7d46' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:title', content: 'MOLIK WINLIK — Tối ưu Windows sâu, an toàn, hoàn tác được' }],
    [
      'meta',
      {
        property: 'og:description',
        content: '200 tweak · 11 Mode · GUI winutil-style · Backup/hoàn tác toàn diện · Online kiểm chứng SHA256.',
      },
    ],
    ['meta', { property: 'og:image', content: 'https://molik-labs.github.io/MOLIK_WINLIK/logo.svg' }],
  ],

  themeConfig: {
    logo: '/logo.svg',
    siteTitle: 'MOLIK WINLIK',

    nav: [
      { text: 'Trang chủ', link: '/' },
      { text: 'Bắt đầu', link: '/guide/getting-started' },
      { text: '🌐 Bản Online', link: '/guide/online' },
      { text: '11 Mode', link: '/guide/modes' },
      {
        text: 'Tính năng',
        items: [
          { text: 'Giao diện GUI / TUI / CLI', link: '/guide/interfaces' },
          { text: 'Cleanup Center (dọn rác)', link: '/guide/cleanup' },
          { text: 'Preset theo tình huống', link: '/guide/presets' },
          { text: 'An toàn, Backup & Hoàn tác', link: '/guide/safety' },
        ],
      },
      {
        text: 'Tham chiếu',
        items: [
          { text: 'Tải xuống & các bản phân phối', link: '/guide/download' },
          { text: 'Tham chiếu lệnh CLI', link: '/guide/cli-reference' },
          { text: 'Hỏi đáp (FAQ)', link: '/guide/faq' },
          { text: 'Cho nhà phát triển', link: '/guide/developers' },
        ],
      },
    ],

    sidebar: [
      {
        text: '🚀 Bắt đầu',
        items: [
          { text: 'Giới thiệu & cài đặt lần đầu', link: '/guide/getting-started' },
          { text: 'Tải xuống & các bản phân phối', link: '/guide/download' },
          { text: '🌐 Bản Online (cập nhật an toàn)', link: '/guide/online' },
        ],
      },
      {
        text: '⚙️ Sử dụng',
        items: [
          { text: '11 Mode theo nhu cầu', link: '/guide/modes' },
          { text: 'Preset theo tình huống', link: '/guide/presets' },
          { text: 'Giao diện: GUI / TUI / CLI', link: '/guide/interfaces' },
          { text: 'Cleanup Center (dọn rác)', link: '/guide/cleanup' },
        ],
      },
      {
        text: '🛡️ An toàn & hỗ trợ',
        items: [
          { text: 'An toàn, Backup & Hoàn tác', link: '/guide/safety' },
          { text: 'Khắc phục sự cố', link: '/guide/troubleshooting' },
          { text: 'Hỏi đáp (FAQ)', link: '/guide/faq' },
        ],
      },
      {
        text: '📚 Tham chiếu',
        items: [
          { text: 'Tham chiếu lệnh CLI', link: '/guide/cli-reference' },
          { text: 'Cho nhà phát triển', link: '/guide/developers' },
          { text: 'ADR-001: Kiến trúc engine', link: '/ADR-001-engine-language' },
        ],
      },
    ],

    socialLinks: [{ icon: 'github', link: REPO }],

    editLink: {
      pattern: `${REPO}/edit/main/docs/:path`,
      text: 'Sửa trang này trên GitHub',
    },

    search: {
      provider: 'local',
      options: {
        translations: {
          button: { buttonText: 'Tìm trong tài liệu', buttonAriaLabel: 'Tìm kiếm' },
          modal: {
            noResultsText: 'Không tìm thấy kết quả cho',
            resetButtonTitle: 'Xóa tìm kiếm',
            footer: { selectText: 'chọn', navigateText: 'di chuyển', closeText: 'đóng' },
          },
        },
      },
    },

    footer: {
      message:
        'MOLIK WINLIK by @nggkhaiz · Dựa trên Sophia Script (farag2) & dữ liệu winutil (Chris Titus Tech) — đều MIT. Core tối ưu chạy offline 100%; mạng chỉ dùng khi bạn chủ động chọn kênh online.',
      copyright: 'Tài liệu này tự deploy từ thư mục docs/ bằng VitePress + GitHub Pages.',
    },

    outline: { level: [2, 3], label: 'Trong trang này' },
    lastUpdatedText: 'Cập nhật lần cuối',
    docFooter: { prev: '← Trang trước', next: 'Trang sau →' },
    returnToTopLabel: 'Về đầu trang',
    sidebarMenuLabel: 'Mục lục',
    darkModeSwitchLabel: 'Giao diện sáng/tối',
  },
})
