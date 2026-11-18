# Hotel ERP Frontend (Flutter)

One Flutter codebase for **web, Android, iOS, tablets and kitchen TVs**. Rules, build plan and API
docs live in [Hotel-ERP-Backend](https://github.com/ganesh991212/Hotel-ERP-Backend) (`CLAUDE.md`, `docs/`).

## What is here

| Who | Screens |
|---|---|
| Platform admin | Overview (hotels, monthly revenue, sign-ups, plan mix), Hotels (register, suspend/resume, change plan, per-hotel feature overrides), Plans (prices, features, limits) |
| Hotel admin / manager | Overview dashboard, Floor, Kitchen, Menu, Tables & QR, Team (people + role permission matrix), Expenses, Settings (kitchen mode, QR confirmation, plan & billing) |
| Server | Floor: tables, take orders, confirm QR orders, mark served |
| Chef | Kitchen: pick up new orders, strict queue (only the head can start), mark ready, see other chefs live |
| Diner (public) | `/#/t/<qr-token>`: menu, cart with server-priced totals, live order tracker, language switch |

Tabs are derived from the signed-in user's **permissions** and the hotel's **plan features**
(`GET /me`, `GET /me/entitlements`). Hiding is UX only; the API enforces everything.

## Run locally

Start the backend first (see its README), then:

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE=http://localhost:8000
```

Release web build (bundles CanvasKit instead of loading it from a CDN):

```bash
flutter build web --release --no-web-resources-cdn --dart-define=API_BASE=https://api.example.com
```

Android/iOS: `flutter run` on a device with the same `--dart-define`.

## Structure

```
lib/
  core/        api client (serialised token refresh), realtime socket, session, router, money, theme tokens
  ui/          component library: Glass card, PillTabs, StatusChip, PillBar, CapsuleBars, NightPanel, dialogs
  features/    auth, platform, hotel, floor, kitchen, diner
  l10n/        app_en.arb (every string, with descriptions)
```

## Rules this code follows
- **No money arithmetic.** The server sends `_minor` paise; `core/money.dart` formats them by string
  slicing. Cart totals come from `POST /orders/quote` and `POST /d/{qr}/quote`.
- **No literal strings** in feature code; everything is in `lib/l10n/app_en.arb` (CI checks).
- **Theme tokens only** (`core/theme/tokens.dart`, light and dark sets). Status is always icon + label.
- **Serialised refresh.** One in-flight refresh shared by all callers, because refresh tokens rotate
  and reuse revokes the family.
- **Realtime.** One WebSocket per outlet; screens refetch on events, show a stale banner when the
  socket drops, and the kitchen polls every 5 s as fallback.

## Printing, sounds, push
- **Printing** (`core/printing/`): the server sends layout blocks for each KOT/bill. The app renders them to PDF and
  opens the system print dialog (any printer: thermal with driver, laser, inkjet, Android print services, AirPrint)
  at 58 mm, 80 mm or A4. On Android/iOS it can instead send ESC/POS straight to a network thermal printer
  (profile menu → Printer setup). Adapted from the CMS app's invoice generator.
- **Loud alerts** (`core/sound/`, `assets/sounds/`): original synthesised sounds near full scale, played on live
  events (new order for chefs, ready for servers). Browsers need one tap before audio; "Test alert sound" unlocks it.
- **Push** (`core/push/`, ported from GigBridge): FCM on Android/iOS/web, configured **only in the backend `.env`**
  (`FCM_*` secret + public `FIREBASE_*` app ids). The app reads `GET /api/v1/push/config` at sign-in; no
  google-services.json, plist or per-build defines. Android channels play on the alarm stream (`MainActivity.kt`,
  `res/raw/`); the iOS sounds are already in the Runner target. Browsers cannot play custom notification sounds:
  staff tap **Enable alerts** once and keep the tab open for the loud in-page sound.
- **Languages**: English, Telugu, Hindi (`lib/l10n/app_*.arb`), switch with the 文A button; remembered per device.
  Telugu/Devanagari fonts load only when chosen. Prints (KOT, bill, QR) stay English for thermal printers.
  Translations are a first draft: have a native speaker review before launch.
- **Table QR codes**: Tables → ⋯ → Print QR, or Print all QR codes (A4 sheet of cards, or one ticket per table on
  roll/network thermal printers; thermal printers draw the QR natively).

## Design
Visual language: soft mint glass cards on a green gradient, Outfit display + Inter body type,
pill-shaped segmented navigation with a stretching indicator, a dark contrast panel for live work,
large numerals, staggered card entrances. It was **inspired by** a commercial dashboard template the
owner shared; no code, images or assets from that template are used (its licence forbids
redistributing its source, and this repo is public). Fonts are bundled from Google Fonts under the
SIL Open Font License (`assets/fonts/OFL-*.txt`).
