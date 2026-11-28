// MOLIK WINLIK — trang tài liệu chính thức (Astro Starlight)
// Site: https://molik-labs.github.io/MOLIK_WINLIK/  (GitHub Pages, deploy qua Actions)
// Theme: sáng = Forest, tối = Catppuccin Mocha (xem src/styles/custom.css)
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://molik-labs.github.io',
  base: '/MOLIK_WINLIK',
  // Chỉ phục vụ chạy thử local (npm run dev) qua host preview; bản build tĩnh không dùng.
  vite: { server: { allowedHosts: true } },
  integrations: [
    starlight({
      title: 'MOLIK WINLIK',
      description:
        'MOLIK WINLIK by @nggkhaiz — bộ tối ưu Windows sâu: 200 tweak hoàn tác được, 11 Mode, GUI kiểu winutil, TUI tick-chọn, Cleanup Center, kênh online kiểm chứng SHA256.',
      logo: { src: './src/assets/logo.svg', alt: 'MOLIK WINLIK' },
      favicon: '/favicon.svg',
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/MoLik-Labs/MOLIK_WINLIK' },
      ],
      editLink: {
        baseUrl: 'https://github.com/MoLik-Labs/MOLIK_WINLIK/edit/main/docs/',
      },
      lastUpdated: true,
      customCss: ['./src/styles/custom.css'],
      locales: {
        root: { label: 'Tiếng Việt', lang: 'vi' },
      },
      head: [
        { tag: 'meta', attrs: { name: 'theme-color', content: '#22713c' } },
        { tag: 'meta', attrs: { property: 'og:type', content: 'website' } },
        {
          tag: 'meta',
          attrs: {
            property: 'og:title',
            content: 'MOLIK WINLIK — Tối ưu Windows sâu, an toàn, hoàn tác được',
          },
        },
        {
          tag: 'meta',
          attrs: {
            property: 'og:description',
            content: '200 tweak · 11 Mode · GUI winutil-style · Backup/hoàn tác toàn diện · Online kiểm chứng SHA256.',
          },
        },
        {
          tag: 'meta',
          attrs: {
            property: 'og:image',
            content: 'https://molik-labs.github.io/MOLIK_WINLIK/logo.svg',
          },
        },
      ],
      sidebar: [
        {
          label: '🚀 Bắt đầu',
          items: [
            { label: 'Cài đặt & chạy lần đầu', slug: 'guide/getting-started' },
            { label: 'Tải xuống & các bản phân phối', slug: 'guide/download' },
            { label: '🌐 Bản Online (cập nhật an toàn)', slug: 'guide/online' },
          ],
        },
        {
          label: '⚙️ Sử dụng',
          items: [
            { label: '11 Mode theo nhu cầu', slug: 'guide/modes' },
            { label: 'Preset theo tình huống', slug: 'guide/presets' },
            { label: 'Giao diện: GUI / TUI / CLI', slug: 'guide/interfaces' },
            { label: 'Cleanup Center (dọn rác)', slug: 'guide/cleanup' },
          ],
        },
        {
          label: '🛡️ An toàn & hỗ trợ',
          items: [
            { label: 'An toàn, Backup & Hoàn tác', slug: 'guide/safety' },
            { label: 'Khắc phục sự cố', slug: 'guide/troubleshooting' },
            { label: 'Hỏi đáp (FAQ)', slug: 'guide/faq' },
          ],
        },
        {
          label: '📚 Tham chiếu',
          items: [
            { label: 'Tham chiếu lệnh CLI', slug: 'guide/cli-reference' },
            { label: 'Cho nhà phát triển', slug: 'guide/developers' },
            { label: 'ADR-001: Kiến trúc engine', slug: 'adr-001-engine-language' },
          ],
        },
      ],
    }),
  ],
});
