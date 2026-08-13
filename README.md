# BTS Rider App

Flutter app for riders on the Basit Transport Service delivery platform — go online, accept job
offers, navigate, complete deliveries with OTP verification, and track earnings and cash-in-hand
debt.

One of four repositories:

| Repository | Role |
| --- | --- |
| `bts-admin-web-controller` | Admin dashboard + central API |
| `bts_user_app` | Customer app |
| `bts_rider_app` | Rider app (this repo) |
| `bts_vendor_app` | Vendor app |

Progress: [`docs/11-implementation-status.md`](../bts-admin-web-controller/docs/11-implementation-status.md).

---

## Current state

**Auth, job offers, and delivery OTP talk to the real API. Maps navigation is still a canvas.**

What exists:

- Splash, permission priming, phone OTP login, name completion
- Go online / offline against `POST /v1/rider/presence` (server cash-cap reject)
- Polled job offers, accept/reject, status swipes, camera POD, 4-digit delivery OTP
- Wallet from `GET /v1/rider/earnings` and `/ledger`
- Riverpod + `go_router` (replaces `RiderSessionController`)

What does not exist:

- Socket job pings (Phase 5). The app polls offers every 4 seconds while online
- Google Maps turn-by-turn (needs Maps keys)
- KYC webview (Phase 7). Until then an admin runs `npm run rider:create`
- GCS upload of the proof photo (`podImageUrl` is optional)

---

## Getting started

Create an approved rider, then run the API and the app.

```bash
# In bts-admin-web-controller
npm run rider:create
npm run dev

# In this repo
flutter pub get
# iOS simulator
flutter run --dart-define=BTS_API_BASE_URL=http://localhost:3000
# Android emulator
flutter run --dart-define=BTS_API_BASE_URL=http://10.0.2.2:3000
```

OTP codes print in the Next.js terminal while `SMS_PRIMARY_PROVIDER=console`.

---

## Must be fixed before store submission

**The bundle identifiers do not match across platforms:**

| Platform | Current |
| --- | --- |
| Android | `com.basittransportservice.riders.rider_app` |
| iOS | `com.basittransportservice.riders.riderApp` |

They must be identical, and this is effectively irreversible after publication.

Also outstanding: upload keystore, background-location Play justification, Sign in with Apple,
in-app account deletion, deep links (`gh.bts.rider`), Android foreground service for Phase 5
location streaming.

KYC (Phase 7) and Socket.io job pings (Phase 5) are the next product gaps. Cash-cap and commission
are already enforced on the server.
