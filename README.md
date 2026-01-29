# 🎶 Mezmurbet: Digital Choir SongBook

A high-performance, dual-application ecosystem developed for the **Bahir Dar universty chrstiyan student fellowshipe Choir**. This project serves as a professional "Digital Vault" to preserve sacred musical heritage while providing a premium, distraction-free worship environment for choir members.

## ✨ Features

- **Executive Command Center:** Multi-Admin hub for total control over songs, users, and system metadata.
- **Zero-Cost Audio Hosting:** Integrated **Catbox.moe API** uploader for free melody storage, bypassing Firebase billing.
- **Dynamic Schema (No-Code):** Admins can add custom song attributes (Composer, Album, etc.) directly through the UI.
- **Smart-Sync Workroom:** Incomplete song forms are automatically detected and saved to local **SharedPreferences** to prevent data loss.
- **Interactive Lyrics Theater:** High-contrast parchment reading mode with **Smart Zoom**, **WakeLock**, and **Screenshot Protection**.
- **Professional Audio Console:** Persistent practice dock with a golden seeker, time-stamps, and **Offline Caching**.

## 🚀 Tech Stack

- **Frontend:** [Flutter](https://flutter.dev/) (Material 3)
- **Backend:** [Firebase Authentication](https://firebase.google.com/products/auth), [Cloud Firestore](https://firebase.google.com/products/firestore)
- **Audio Engine:** [just_audio](https://pub.dev/packages/just_audio)
- **Offline Storage:** [flutter_cache_manager](https://pub.dev/packages/flutter_cache_manager) & [shared_preferences](https://pub.dev/packages/shared_preferences)
- **External API:** [Catbox.moe](https://catbox.moe/) (Honest Zero-Cost Audio hosting)

## 📸 Administrative Hub (8 Pages)

| Executive Dashboard | The Master Vault | Local Workroom |
|------------|-------|-----------|
| ![Dashboard](screenshots/a1_dash.png) | ![Vault](screenshots/a2_vault.png) | ![Workroom](screenshots/a3_workroom.png) |

| Song Composer | Choir Directory | Support Inbox |
|------------|-------|-----------|
| ![Editor](screenshots/a4_editor.png) | ![Directory](screenshots/a5_directory.png) | ![Inbox](screenshots/a6_inbox.png) |

| System Hub | Leader Succession |
|------------|-------|
| ![System](screenshots/a7_system.png) | ![Roles](screenshots/a8_roles.png) |

---

## 📸 Member Application (9 Pages)

| 3D Login Portal | Spiritual Dashboard | Clustered Shelf |
|------------|-------|-----------|
| ![Login](screenshots/m1_login.png) | ![Home](screenshots/m2_dash.png) | ![Search](screenshots/m3_shelf.png) |

| Lyrics Theater | Audio Seeker Dock | Song Details |
|------------|-------|-----------|
| ![Reader](screenshots/m4_reader.png) | ![Player](screenshots/m5_player.png) | ![Details](screenshots/m6_details.png) |

| Personal Vault | Support Chat | Profile & Drawer |
|------------|-------|-----------|
| ![Favorites](screenshots/m7_fav.png) | ![Chat](screenshots/m8_chat.png) | ![Profile](screenshots/m9_profile.png) |

---
