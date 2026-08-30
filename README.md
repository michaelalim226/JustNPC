# 💎 GEM HUNT ARCADE

**"Gem Hunt Arcade"** adalah game arcade 2D top-down di mana pemain harus menjelajahi map yang luas dan colorful untuk menemukan **10 permata (Gems/Diamonds)** sebelum waktu 3 menit habis. Hadapi enemy, hindari area berbahaya (rawa), dan kumpulkan semua berlian untuk menang!

---

## 🎮 Fitur Game

### 🗺️ Satu Level Besar (Mini-World)
- Map **2500×1900 piksel** yang bisa di-scroll ke segala arah.
- **Sungai Pembatas**: Sungai horizontal membelah map Utara-Selatan. Hanya bisa dilewati melalui **dua jembatan** (Barat & Timur).
- **5 zone** berbeda: Area Tengah, Desa Padat (NW), Hutan Lebat (NE), Zona Batu & Rawa (S), Sudut Terpencil (E/W).
- Kaya dekorasi: rumah berpagar, mailbox, pepohonan lebat, semak-semak, batu, kolam lumpur rawa berbahaya.

### 💎 Diamond/Gem System
| Permata | Lokasi | Skor | Kesulitan |
|-------|--------|------|-----------|
| Gem 1 | Zone A — area terbuka dekat spawn | 100 | ⭐ |
| Gem 2 | Zone A — halaman rumah depan | 100 | ⭐ |
| Gem 3 | Zone B — belakang rumah desa (NW) | 100 | ⭐⭐ |
| Gem 4 | Zone B — pekarangan pagar rumah B3 | 150 | ⭐⭐ |
| Gem 5 | Zone C — tengah hutan lebat (NE) | 150 | ⭐⭐ |
| Gem 6 | Zone C — ujung sempit hutan terhalang batu | 200 | ⭐⭐⭐ |
| Gem 7 | Zone D — dekat kolam rawa berbahaya | 200 | ⭐⭐⭐ |
| Gem 8 | Zone D — labirin bebatuan selatan | 200 | ⭐⭐⭐ |
| Gem 9 | Zone E West — sudut terpencil barat (rare!) | 300 | ⭐⭐⭐⭐ |
| Gem 10| Zone E East — sudut terpencil timur (rare!) | 300 | ⭐⭐⭐⭐ |

### 👾 Enemy System (3 Tipe)
- **Patrol Enemy (×3)**: Bergerak bolak-balik, menjaga persimpangan utama dan desa — 2 HP — +50 score
- **Chaser Enemy (×2)**: Mengejar player jika masuk radius deteksi, menjaga jembatan keluar dan labirin batu — 2 HP — +75 score  
- **Guardian Enemy (×2)**: Mengorbit permata langka di sudut terjauh, menyerang dengan charge kilat — 3 HP — +100 score

### ⚔️ Combat System
- **Tembak** ke 8 arah (arah terakhir gerak) menggunakan projectile berkilau cyan
- Cooldown tembak: 0.32 detik
- Enemy flash putih saat tertembak
- Efek kematian enemy: spin + fade + partikel ledakan oranye

### 💚 Player Health & Invulnerability
- **3 nyawa** (ditampilkan sebagai icon hati)
- Invulnerability 1.6 detik setelah terkena damage (karakter berkedip merah)
- Kena damage memicu camera shake + flash layar merah

### ⏱️ Timer & Score
- **3 menit** (180 detik) untuk mengumpulkan seluruh permata
- Warna timer dinamis: Hijau ➔ Kuning ➔ Merah berkedip (<30s)
- Bonus score dari sisa waktu: `(sisa detik) × 10`
- Floating score popup cyan (+100/150/200/300) muncul saat permata diambil

### 🏆 HUD Arcade Retro
```
┌─────────────────────────────────────────┐
│  SCORE    │  GEMS    │  TIME    │  LIFE  │
│  012500   │  05/10   │  01:42   │  ❤❤❤  │
└─────────────────────────────────────────┘
```

---

## 🕹️ Kontrol

| Tombol | Aksi |
|--------|------|
| **W / A / S / D** atau **Arrow Keys** | Gerak |
| **SPACE** atau **Klik Kiri** | Tembak projectile |
| **ESC** | Pause / Resume |

---

## 📁 Struktur Proyek

```
res://
├── assets/
│   ├── audio/
│   │   ├── bgm_calm.wav           # BGM
│   │   ├── sfx_collect.wav        # Permata diambil
│   │   ├── sfx_footstep.wav       # Langkah kaki
│   │   ├── sfx_shoot.wav          # Tembak
│   │   ├── sfx_hit.wav            # Enemy kena tembak
│   │   ├── sfx_enemy_die.wav      # Enemy mati
│   │   ├── sfx_player_hurt.wav    # Player kena damage
│   │   ├── sfx_level_complete.wav # Menang!
│   │   └── sfx_game_over.wav      # Game Over
│   └── sprites/
│       ├── gem.png                # Permata collectible cyan
│       ├── enemy_patrol.png       # Robot merah patrol
│       ├── enemy_chaser.png       # Blob ungu pengejar
│       ├── enemy_guardian.png     # Guardian emas penjaga
│       ├── projectile.png         # Bola tembakan cyan
│       ├── heart_full.png         # HUD hati penuh
│       ├── heart_empty.png        # HUD hati kosong
│       ├── bush.png               # Dekorasi semak
│       ├── fence_h.png            # Pagar kayu
│       ├── water_tile.png         # Air sungai/kolam rawa
│       ├── player_idle.png        # Karakter player
│       ├── house.png              # Bangunan
│       ├── tree.png / tree_small.png # Pohon
│       └── rock.png               # Batu
├── scenes/
│   └── main.tscn                  # Scene utama (satu level)
├── scripts/
│   ├── game_manager.gd            # State machine, timer, score, health
│   ├── player.gd                  # Movement, attack, health, camera
│   ├── projectile.gd              # Bola tembakan (spawned dinamis)
│   ├── gem.gd                     # Permata collectible
│   ├── enemy_patrol.gd            # AI patrol bolak-balik
│   ├── enemy_chaser.gd            # AI chaser state machine
│   ├── enemy_guardian.gd          # AI guardian + charge attack
│   ├── danger_zone.gd             # Kolam rawa berbahaya
│   └── main.gd                    # HUD controller + overlays
└── project.godot                  # Godot 4.7 config
```

---

## 🚀 Cara Menjalankan

1. Buka folder proyek di **Godot Engine 4.7**
2. Tunggu proses **import asset** selesai (sekitar 30 detik pertama kali)
3. Tekan **F5** atau tombol **Play**
4. Klik **START GAME** dari Main Menu
5. Jelajahi map, temukan 10 permata sebelum waktu habis!
