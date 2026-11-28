<script setup>
import { ref } from 'vue'

const tabs = [
  {
    id: 'online',
    label: '🌐 Online — nhanh nhất',
    title: 'Một dòng lệnh: tải bản mới nhất, kiểm chứng SHA256 rồi chạy',
    code: 'irm https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1 | iex',
    note: 'Cần Internet. win.ps1 chỉ tải khi hash khác bản cache, luôn kiểm chứng SHA256 + cú pháp trước khi chạy file local.',
  },
  {
    id: 'offline',
    label: '📦 Offline — chuẩn, khuyến nghị',
    title: 'Tải ZIP một lần, dùng mãi không cần mạng',
    code: 'MOLIK_WINLIK.bat            # double-click, tự xin quyền Admin\nMOLIK_WINLIK.bat -Gui       # giao diện cửa sổ kiểu winutil',
    note: 'Không tải code khi chạy — toàn bộ hành vi nằm trong file .ps1 đọc được trước khi cấp quyền Admin.',
  },
  {
    id: 'update',
    label: '🔄 Đã cài — cập nhật / sửa bản lỗi',
    title: 'Kiểm tra, cập nhật, hoặc thay bản sạch khi bản đang dùng bị lỗi',
    code: 'MOLIK_WINLIK.bat -CheckUpdate   # chỉ kiểm tra, không thay gì\nMOLIK_WINLIK.bat -Update        # cập nhật khi có bản mới\nMOLIK_WINLIK.bat -Repair        # ép thay bản sạch (kèm backup .bak)',
    note: 'Mọi lần thay đều: kiểm chứng SHA256 → kiểm tra cú pháp → sao lưu bản cũ .bak-<thời gian> → mới thay.',
  },
]

const active = ref('online')
const copied = ref(false)

async function copyCode(code) {
  try {
    await navigator.clipboard.writeText(code)
  } catch {
    const ta = document.createElement('textarea')
    ta.value = code
    document.body.appendChild(ta)
    ta.select()
    document.execCommand('copy')
    document.body.removeChild(ta)
  }
  copied.value = true
  setTimeout(() => (copied.value = false), 1600)
}
</script>

<template>
  <div class="install-box">
    <div class="install-tabs" role="tablist" aria-label="Cách cài đặt MOLIK WINLIK">
      <button
        v-for="t in tabs"
        :key="t.id"
        role="tab"
        :aria-selected="active === t.id"
        :class="{ active: active === t.id }"
        @click="active = t.id"
      >
        {{ t.label }}
      </button>
    </div>

    <div v-for="t in tabs" :key="t.id" v-show="active === t.id" class="install-panel">
      <p class="install-title">{{ t.title }}</p>
      <div class="install-code">
        <pre><code>{{ t.code }}</code></pre>
        <button class="install-copy" @click="copyCode(t.code)">
          {{ copied ? '✓ Đã copy' : 'Copy' }}
        </button>
      </div>
      <p class="install-note">{{ t.note }}</p>
    </div>

    <p class="install-more">
      Chi tiết từng bước: <a href="./guide/online">Bản Online</a> ·
      <a href="./guide/download">Tải xuống</a> ·
      <a href="./guide/safety">An toàn &amp; hoàn tác</a>
    </p>
  </div>
</template>
