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

---

## Current state

**This is a UI prototype running entirely on mock data. It is not connected to any backend.**

It is the strongest of the three prototypes. The delivery flow, cash cap behaviour and wallet UI
closely match what the server will actually provide, so a large share of this UI survives into
production rather than being rebuilt.

What exists:

- `dashboard_screen`, `wallet_screen`
- `auth_placeholder_screen` — an orphaned "Auth coming soon" screen
- `go_online_sheet`, `searching_radar`, `job_ping_sheet`
- `delivery_state_sheet`, `delivery_stepper`
- `cash_cap_warning`, `ledger_list`

What does not exist:

- No authentication. The auth screen is a placeholder and is not wired into navigation.
- **No KYC onboarding at all** — no webview, no Ghana Card capture, no document upload, no approval
  status screen. A rider currently cannot be verified by any means.
- No location streaming. There is no foreground service and no position reporting.
- No delivery OTP entry, which is the only legitimate path to marking an order delivered.
- Proof of delivery is a simulated tap, not a camera.
- Job offers come from a `Future.delayed(8s)` mock ping.
- Earnings, ledger and cash-in-hand all come from `MockWallet`.
- Dark mode is fake — the dark theme calls the light factory.

---

## What was done in this pass

**No code in this repository was changed.** The work was a complete architecture and API
specification covering all four apps.

The specification lives in the admin repository at
[`../bts-admin-web-controller/docs/`](../bts-admin-web-controller/docs/00-overview.md). Start with
`00-overview.md`.

Most relevant to this app:

| Document | Why it matters here |
| --- | --- |
| `08-mobile-architecture.md` | Flutter stack, `bts_core`, **and a screen-by-screen gap analysis for this app** |
| `07-onboarding-kyc.md` | The seven-step webview KYC flow and Ghana Card upload |
| `06-pricing-and-money.md` | Earnings, commission, and how cash-in-hand debt is derived |
| `05-realtime.md` | Job offer events and throttled location streaming |
| `04-auth-and-security.md` | OTP login, device binding, token rotation |
| `03-api-contract.md` | Every endpoint this app calls |

### Decisions that change how this app gets built

**Two hardcoded constants must move to the server.** In
`lib/core/constants/app_constants.dart`:

- `platformCommissionRate = 0.20`
- `cashCapGhs = 500.0`

Both become display values fetched from `GET /v1/config`, and every enforcement decision moves to
the API. A rider whose device decides its own commission rate is a rider who can pay whatever
commission they like. The cash cap is the same problem with a bigger blast radius — it is the
control that stops a rider accumulating unlimited company cash.

`jobPingSeconds = 15` stays as a local countdown for the UI, but the server's `expiresAt` on the
offer is authoritative, because client clocks drift.

Other decisions:

- **Cash-in-hand debt is derived from the double-entry ledger**, never stored as a running total on
  the rider row. `06-pricing-and-money.md` works through the accounting for both MoMo and COD
  orders.
- **Payout details are view-only in the app.** Changing a MoMo payout number requires admin review.
  This is the actual defence against a rider redirecting their earnings — the Paystack Transfer
  Recipient is locked server-side.
- **KYC happens in an in-app webview**, with documents uploaded straight to Google Cloud Storage
  through signed URLs so the images never pass through the API server. Full flow in
  `07-onboarding-kyc.md`.
- **Location streaming is deliberately limited to active deliveries.** This is a privacy decision
  and it is also what makes the Play Store background-location justification defensible.
- **Accepting a job must handle losing the race** — `409 ORDER_ALREADY_ASSIGNED` is a normal
  outcome, not an error state.

---

## Must be fixed before store submission

**The bundle identifiers do not match across platforms:**

| Platform | Current |
| --- | --- |
| Android | `com.basittransportservice.riders.rider_app` |
| iOS | `com.basittransportservice.riders.riderApp` |

They must be identical, and this is effectively irreversible after publication. Settle it now.

Also outstanding:

- Debug keystore — a real upload keystore is needed and must be backed up.
- **Background location permission** requires a written justification and a demo video for Google
  Play, and adds review time. Budget for it.
- Sign in with Apple is mandatory alongside Google sign-in.
- In-app account deletion is mandatory.
- Deep link scheme `gh.bts.rider` plus Universal Links and App Links.
- A foreground service notification is required for Android location tracking.

---

## Getting started

```bash
flutter pub get
flutter run
```

Runs standalone today because everything is mocked.

---

## Next steps

Sequenced in the roadmap as Phase 4 (fulfilment), Phase 5 (realtime) and Phase 7 (KYC):

1. Wire the orphaned auth screen to real phone OTP login.
2. Build the KYC webview and Ghana Card upload; add the approval waiting screen.
3. Replace mock job pings with Socket.io `job.offered` events.
4. Add the foreground location service and throttled position streaming.
5. Delivery OTP entry and real proof-of-delivery capture.
6. Replace `MockWallet` with real earnings and ledger endpoints.
7. Move the commission and cash-cap constants to `GET /v1/config`.
