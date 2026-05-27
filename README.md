# WATT Smart Meter App

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Flutter dashboard: live energy readings, mining history, wallet and meter settings.

## Quick start

```bash
cp .env.example .env
flutter pub get
flutter run
```

## Database

Apply migrations from [server/supabase/migrations](https://github.com/Watt-Protocol/server/tree/main/supabase/migrations) (canonical schema in the **server** repo).

## Related repositories

| Repo | Role |
|------|------|
| [meter-firmware](https://github.com/Watt-Protocol/meter-firmware) | ESP32 → Supabase |
| [watt-minter](https://github.com/Watt-Protocol/watt-minter) | On-chain WATT payouts |
| [server](https://github.com/Watt-Protocol/server) | Waitlist + migrations |
