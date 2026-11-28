import DefaultTheme from 'vitepress/theme'
import './custom.css'
import InstallBox from './components/InstallBox.vue'

/** @type {import('vitepress').Theme} */
export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    // Khối chọn cách cài đặt (tab Online / Offline / Cập nhật) dùng ở trang chủ & trang hướng dẫn
    app.component('InstallBox', InstallBox)
  },
}
