import { defineConfig } from 'vitepress'

// MOLIK WINLIK docs - https://molik-labs.github.io/MOLIK_WINLIK/
export default defineConfig({
  lang: 'vi-VN',
  title: 'MOLIK WINLIK',
  description: 'Bộ tối ưu Windows sâu, offline 100% — GUI kiểu winutil, TUI tick-chọn, 200 tweak, 11 Mode.',
  base: '/MOLIK_WINLIK/',
  cleanUrls: true,
  lastUpdated: true,
  themeConfig: {
    logo: undefined,
    siteTitle: 'MOLIK WINLIK',
    nav: [
      { text: 'Hướng dẫn', link: '/guide/getting-started' },
      { text: '11 Mode', link: '/guide/modes' },
      { text: 'Tính năng', link: '/guide/interfaces' },
      { text: 'Phát triển', link: '/guide/developers' },
      { text: 'GitHub', link: 'https://github.com/MoLik-Labs/MOLIK_WINLIK' },
    ],
    sidebar: [
      {
        text: 'Bắt đầu',
        items: [
          { text: 'Cài đặt & chạy lần đầu', link: '/guide/getting-started' },
          { text: 'Giao diện: GUI / TUI / CLI', link: '/guide/interfaces' },
          { text: '11 Mode theo nhu cầu', link: '/guide/modes' },
        ],
      },
      {
        text: 'Tính năng',
        items: [
          { text: 'Cleanup Center (dọn rác)', link: '/guide/cleanup' },
          { text: 'Online, Update & Repair', link: '/guide/online-update' },
          { text: 'An toàn, Backup & Hoàn tác', link: '/guide/safety' },
        ],
      },
      {
        text: 'Hỗ trợ',
        items: [
          { text: 'Khắc phục sự cố', link: '/guide/troubleshooting' },
          { text: 'Cho nhà phát triển', link: '/guide/developers' },
          { text: 'ADR-001: Kiến trúc engine', link: '/ADR-001-engine-language' },
        ],
      },
    ],
    search: { provider: 'local' },
    footer: {
      message: 'MOLIK WINLIK by @nggkhaiz — dựa trên Sophia Script (farag2) & dữ liệu winutil (Chris Titus Tech, MIT).',
      copyright: 'Chạy offline 100% — không tải code khi tối ưu.',
    },
    outline: { label: 'Trong trang này' },
    lastUpdatedText: 'Cập nhật lần cuối',
    docFooter: { prev: 'Trang trước', next: 'Trang sau' },
  },
})
