# 🎮 The NPC's Day Off

**"The NPC's Day Off"** adalah game 2D Top-Down Adventure bernuansa komedi meta di mana seorang NPC RPG akhirnya tersadar bahwa dirinya hanyalah sekumpulan baris kode dan pixel. Muak diabaikan pemain, menunggu quest tanpa henti, dan diperlakukan seperti pajangan latar belakang, dia memutuskan mengambil hari libur dan kabur dari game!

---

## ✨ Fitur & Peningkatan Terbaru

### 1. 🎨 Visual Pixel Art & Suasana Desa RPG
- **Player Sprite**: Karakter NPC dengan ekspresi lelah/bosan (*-_-*), lengkap dengan animasi *idle bobbing*, *walk wobble*, dan partikel debu langkah.
- **Ground & Pathway**: Tekstur rumput seamless dengan bunga liar serta jalan setapak (*cobblestone path*).
- **Dekorasi Lengkap**: Rumah Kepala Desa, Kedai Penginapan, Pohon Oak rindang, Pohon Cemara, serta Bebatuan berlumut.
- **Escape Gate**: Gerbang desa dengan rune sihir yang berubah visual dari terkunci (pintu kayu besi) menjadi portal berputar saat ketiga fragmen memori terkumpul, dilengkapi aura partikel.
- **NPC Tambahan**: Pak Tani (*Farmer*) dan Warga Desa (*Villager*) yang berkeliaran (*wandering*) dengan dialog sarkastik mereka masing-masing.

### 2. 🧩 Mekanik Puzzle & Collectible
- **3 Memory Fragments**: Pecahan ingatan NPC yang tersebar di map (dekat rumah, pohon, dan batu).
- **Interaksi Objek Lingkungan**: Dekati pohon, rumah, atau batu dan tekan **[E]** untuk mendengar keluhan/monolog meta NPC tentang objek tersebut.
- **Gerbang Terkunci**: Gerbang keluar desa membutuhkan ketiga fragmen untuk terbuka. Mencoba keluar sebelum lengkap akan memicu dialog petunjuk.

### 3. 💬 Sistem Dialog & UI Modern
- **25 Dialog Komedi Meta**: Monolog pembuka, interaksi lingkungan, NPC sekitar, progres memori, hingga ending twist!
- **Typewriter Effect**: Teks muncul huruf-per-huruf dengan efek suara ketik (*audio blip*).
- **Fast-Forward & Skip**: Tekan **[E / Klik]** saat mengetik untuk langsung menampilkan teks penuh, atau **[ESC]** untuk menutup.
- **Avatar Portrait**: Kotak dialog dilengkapi portrait wajah NPC pembicara.
- **Item Counter & Toast Notifications**: Indikator slot pecahan memori di pojok kanan atas dan pop-up banner notifikasi.
- **Pause Menu**: Tekan **[ESC]** saat bermain untuk membuka menu Jeda (*Resume, Restart, Quit*).

### 4. 🎵 Audio & Game Juice
- **Sound Effects (SFX)**: Suara langkah kaki bervariasi (*footstep*), lenting kristal (*collect chime*), dialog typewriter blip, unlock portal, dan *escape victory fanfare*.
- **Ambient BGM**: Musik latar yang tenang dan menyejukkan.
- **Efek Kamera & Layar**: Camera shake saat event penting, fade in/out transisi layar, serta flash putih kemenangan saat berhasil kabur.

---

## 📁 Struktur Folder Proyek

```text
res://
├── assets/
│   ├── audio/
│   │   ├── bgm_calm.wav             # Musik latar desa yang tenang
│   │   ├── sfx_collect.wav          # Suara pengambilan Memory Fragment
│   │   ├── sfx_dialog.wav           # Suara ketik dialog typewriter
│   │   ├── sfx_escape.wav           # Suara kemenangan (Escape Fanfare)
│   │   ├── sfx_footstep.wav         # Suara langkah kaki karakter
│   │   └── sfx_gate_unlock.wav      # Suara portal gerbang terbuka
│   └── sprites/
│       ├── gate_closed.png          # Gerbang terkunci
│       ├── gate_open.png            # Gerbang terbuka bercahaya
│       ├── ground_grass.png         # Tekstur rumput desa
│       ├── ground_path.png          # Tekstur jalan setapak
│       ├── house.png                # Bangunan rumah RPG
│       ├── item_icon.png            # Icon UI Memory Fragment
│       ├── memory_fragment.png      # Kristal pecahan memori
│       ├── npc_farmer.png           # Sprite Pak Tani
│       ├── npc_villager.png         # Sprite Warga Desa
│       ├── player_idle.png          # Karakter utama NPC bosan
│       ├── player_walk.png          # Frame jalan
│       ├── portrait_npc.png         # Portrait avatar NPC untuk dialog
│       ├── rock.png                 # Batu berlumut
│       ├── tree.png                 # Pohon oak besar
│       └── tree_small.png           # Pohon kecil
├── data/
│   └── dialogs.json                 # Database 25 dialog JSON
├── scenes/
│   └── main.tscn                    # Scene utama terintegrasi penuh
├── scripts/
│   ├── dialog_system.gd             # Typewriter dialog & portrait controller
│   ├── escape_gate.gd               # Logika gerbang keluar & unlock check
│   ├── game_manager.gd              # Autoload GameManager (State, Items, Audio cues)
│   ├── interactable_object.gd       # Script objek interaktif (Pohon, Rumah, Batu)
│   ├── item.gd                      # Script collectible Memory Fragment
│   ├── main.gd                      # Controller level, HUD, Toast, & Pause Menu
│   ├── npc_wanderer.gd              # Script AI wandering NPC tambahan
│   └── player.gd                    # Player movement, dust particles, & footstep
├── project.godot                    # Konfigurasi Godot 4 (Autoload & Main Scene)
└── README.md
```

---

## 🕹️ Kontrol Permainan

| Tombol / Input | Aksi |
| :--- | :--- |
| **W, A, S, D** / **Tombol Panah** | Menggerakkan karakter NPC (Smooth Movement) |
| **E** | Interaksi (Ambil Item / Periksa Pohon/Rumah / Bicara dengan NPC / Buka Gerbang) |
| **Spasi / Enter / Klik Kiri** | Lanjut dialog / Fast-forward teks dialog |
| **ESC** | Lewati dialog (saat dialog) / Buka Pause Menu (saat bermain) |

---

## 🚀 Cara Menjalankan di Godot 4.x

1. Buka folder proyek ini di **Godot Engine 4 (versi 4.3 atau 4.7)**.
2. Tekan **F5** (atau klik tombol **Play** di pojok kanan atas).
3. Anda akan disambut monolog pembuka NPC. Kumpulkan ketiga **Memory Fragments** di sekitar desa untuk membuka gerbang dan kabur!
