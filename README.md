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

## WhatsApp payment notices

After each new auction, members can receive payment reminders (chit no., amount, date) via **WhatsApp Business API**.

Setup: see [docs/WHATSAPP_SETUP.md](docs/WHATSAPP_SETUP.md)

```bash
supabase functions deploy send-auction-whatsapp
supabase secrets set WHATSAPP_ACCESS_TOKEN=...
supabase secrets set WHATSAPP_PHONE_NUMBER_ID=...
```

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
