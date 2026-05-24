# Device Lineup

8 devices, 8 install guides, 8 slots in `DeviceGrid.astro`. **Don't add, don't remove** — the grid layout depends on exactly 8, and the 8 types cover ~98% of IPTV device queries in DataForSEO.

## The 8 canonical devices

| Slot | Device | URL slug | App/player used | Primary keyword template |
|---|---|---|---|---|
| 1 | **Smart TV** (Samsung/LG/Tizen/webOS) | `/devices/smart-tv/` | Smart IPTV, IPTV Smarters Pro | `iptv smart tv {country}` |
| 2 | **Amazon Firestick** | `/devices/firestick/` | IPTV Smarters Pro (sideloaded via Downloader) | `iptv firestick {country}` |
| 3 | **Android TV box** (Chromecast, Shield, Xiaomi) | `/devices/android-tv/` | IPTV Smarters Pro, TiviMate | `iptv android tv {country}` |
| 4 | **Formuler Z** (Z8, Z10, Z11 Pro) | `/devices/formuler/` | MyTVOnline 3 (pre-installed) | `iptv formuler {country}` |
| 5 | **iPhone / iOS** | `/devices/ios-iphone/` | GSE Smart IPTV, IPTV Smarters Pro | `iptv iphone {country}` |
| 6 | **Android phone/tablet** | `/devices/android/` | IPTV Smarters Pro | `iptv android {country}` |
| 7 | **MAG box** (254, 322, 524, 540) | `/devices/mag-box/` | Native STB portal URL | `iptv mag box {country}` |
| 8 | **Apple TV** (4K, HD) | `/devices/apple-tv/` | IPTV Smarters Pro, GSE Smart IPTV | `iptv apple tv {country}` |

## Install guide structure (per device)

Each `/devices/{slug}/` page follows this **locked** structure:

1. **Hero** — H1: "How to Install IPTV on {Device} in {Year}" (translated). Subhead: one-sentence promise.
2. **Prerequisites callout** — Active subscription + app name + ~5 min time estimate.
3. **Install steps** — 5–9 numbered steps. Screenshots or icons per step. Plain language, no jargon.
4. **Mid-page CTA** — Link to `/pricing/` with "Get your subscription" copy.
5. **Troubleshooting** — 3 common issues + fixes (buffering, login error, missing channels).
6. **Related devices** — 3 link cards to adjacent devices in the 8-grid.
7. **Schema** — `HowTo` + `BreadcrumbList`.

## Install step count per device (tested)

| Device | Steps | Avg install time |
|---|---|---|
| Smart TV (LG/Samsung) | 7 | 8 min |
| Firestick | 9 | 10 min (Downloader sideload) |
| Android TV | 6 | 6 min |
| Formuler | 5 | 4 min (pre-installed app) |
| iPhone | 6 | 5 min |
| Android phone | 5 | 4 min |
| MAG box | 5 | 5 min (portal URL only) |
| Apple TV | 7 | 8 min |

If a guide exceeds 9 steps it's too complex — split prerequisites into the callout box rather than step 1/2.

## Prerequisites callout (standard format)

```markdown
> **Before you start:**
> - Active {brand_name} subscription (not purchased yet? [View plans](/pricing/))
> - {app_name} app installed
> - Stable internet connection (≥25 Mbps recommended for 4K)
> - ~{install_time} of your time
```

## Troubleshooting (3 canonical issues)

Every device page covers the same 3 issues in the same order:

1. **Buffering / lag** → Check internet speed, switch to 5GHz Wi-Fi or Ethernet, clear app cache
2. **Login error** → Verify M3U/Xtream credentials, check subscription status, try the backup server URL
3. **Missing channels** → Full channel list refresh, check country restrictions, contact support

## App names per device (reference)

Keep these consistent across pages — users re-read install guides and expect the same app names.

| App | Supported devices | Download source |
|---|---|---|
| **IPTV Smarters Pro** | Firestick, Android TV, Android phone, iPhone, Apple TV, Smart TV | App store / sideload |
| **TiviMate** | Android TV (paid premium) | Google Play |
| **Smart IPTV** | Samsung/LG Smart TV | Built-in app store (whitelist required) |
| **GSE Smart IPTV** | iPhone, iPad, Apple TV | App Store |
| **MyTVOnline 3** | Formuler Z series | Pre-installed |
| **STB Emulator** | Android (MAG emulation) | Google Play |
| **Native portal** | MAG boxes | Built-in STB |

**Never** mention sideload-only apps like Kodi, TivimateRx, or Stremio in the main install flow — they're flagged as piracy-adjacent by Google's ranking signals and add legal risk.

## Relationship to DeviceGrid.astro

`assets/components/DeviceGrid.astro` has all 8 devices as hardcoded SVG icon tiles. When re-skinning:
- **Keep all 8 slots** even if the brand technically doesn't support one (ghost it with "Coming soon" overlay)
- Only swap text labels (translate) and the accent color
- Never change the icon SVGs — they're proven, accessible, and lightweight
