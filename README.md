# pma-voice-radius

Resource visual radius voice proximity untuk **pma-voice**. Menampilkan lingkaran
merah transparan + teks (mis. `WHISPER • 3M`) di sekitar player setiap kali voice
range diganti, lalu otomatis hilang setelah beberapa detik.

Resource ini **tidak mengubah file pma-voice sama sekali**. Ia hanya membaca
statebag `proximity` yang memang sudah di-broadcast oleh pma-voice setiap kali
voice range berubah (scroll/F11 cycle, export `overrideProximityRange`,
`clearProximityOverride`, atau saat pertama connect ke mumble).

## Instalasi

1. Copy folder `pma-voice-radius` ke folder `resources` server kamu.
2. Di `server.cfg`, pastikan **pma-voice di-start lebih dulu**, baru resource ini:

   ```cfg
   ensure pma-voice
   ensure pma-voice-radius
   ```

3. Restart server / restart resource:

   ```
   restart pma-voice-radius
   ```

Tidak ada langkah tambahan lain — resource langsung aktif begitu server jalan.

## Konfigurasi (`config.lua`)

| Setting | Fungsi |
|---|---|
| `Config.DisplayDuration` | Durasi (ms) lingkaran & teks tampil sebelum hilang otomatis |
| `Config.ShowOnInitialConnect` | `true`/`false` — tampilkan lingkaran saat pertama connect mumble, atau hanya saat range benar-benar diganti |
| `Config.CircleColor` | Warna dasar lingkaran (default merah, `r=255,g=0,b=0`) |
| `Config.FillAlpha` | Transparansi area dalam lingkaran (0–255, kecil = makin transparan) |
| `Config.DrawFill` | Aktif/nonaktifkan fill area dalam radius |
| `Config.OutlineAlpha` | Transparansi garis tepi lingkaran |
| `Config.OutlineThickness` | Ketebalan garis outline (1 = tipis) |
| `Config.OutlineThicknessOffset` | Jarak antar layer garis saat `OutlineThickness > 1` |
| `Config.CircleSegments` | Jumlah segmen garis lingkaran (lebih tinggi = lebih halus, sedikit lebih berat) |
| `Config.GroundZOffset` | Offset ketinggian dari tanah (hindari z-fighting) |
| `Config.ShowText` | Aktif/nonaktifkan teks mode+jarak di atas player |
| `Config.TextZOffset` | Ketinggian teks di atas player |
| `Config.TextScale` / `Config.TextFont` | Ukuran & font teks |
| `Config.TextFormat` | Format teks, `%s` = nama mode, `%d` = jarak radius |
| `Config.TextUppercase` | Nama mode huruf besar semua atau tidak |
| `Config.TextColor` | Warna teks |

## Catatan teknis

- Nama mode & jarak radius diambil langsung dari data yang dikirim pma-voice
  (statebag `proximity`), bukan hardcode — jadi otomatis mengikuti
  `Cfg.voiceModes` di pma-voice, termasuk saat radius di-override manual
  (akan muncul sebagai `CUSTOM`).
- Loop render hanya aktif (tick tiap frame) selama lingkaran sedang tampil;
  di luar itu thread idle dengan `Wait(500)`, jadi tidak membebani client.
- Titik-titik lingkaran (trig) di-cache dan hanya dihitung ulang kalau
  `Config.CircleSegments` berubah — bukan setiap frame.
