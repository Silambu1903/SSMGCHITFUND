# SSMGCHITFUND

SSMG Chit Fund — Flutter application for digital chit fund management.

## Features

- Dashboard with monthly overview and prize settlement
- Chit scheme creation and member management
- Auction recording with Tamil PDF receipts
- Payment tracking and reports
- Tamil / English UI

## Getting Started

```bash
flutter pub get
flutter run
```

## Backend

Supabase project: `SSMG_CHIT_FUND_BACKEND`

Configure API keys in `lib/core/constants/supabase_config.dart`.

## Deploy to Cloudflare Pages

Site name: **ssmgchitfund** → `https://ssmgchitfund.pages.dev`

```bash
# One-time: authenticate with Cloudflare
npx wrangler login

# Build and deploy
./scripts/deploy-cloudflare.sh
```

Or set `CLOUDFLARE_API_TOKEN` and run the script (CI-friendly).

Login screen uses the Vinayagar (Ganesha) hero image on the left panel.
