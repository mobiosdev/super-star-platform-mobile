# SuperStar Platform — Mobile

Flutter app wired to **SuperStar Platform REST API v1** (`postman/SuperStar_Platform_API.postman_collection.json`).

## Run

```bash
flutter pub get
flutter run -d emulator-5554 --dart-define=API_BASE_URL=https://super-star-platform-backend.onrender.com/v1
```

Local backend (Android emulator): `http://10.0.2.2:3000/v1`

## API layers

| Layer | Path |
|-------|------|
| Endpoints | `lib/core/constants/api_constants.dart` |
| HTTP + auth refresh | `lib/core/network/dio_client.dart` |
| All REST calls | `lib/data/api/platform_api.dart` |
| Repositories | `lib/data/repositories/` |
| UI | `lib/presentation/` |

## Integrated features

### Customer
- Login / session restore (`/auth/login`, `/users/me`)
- Home feed (`/subscriptions/me`, `/feed/{superstarId}`, `/superstars`)
- **Explore** — list superstars (`GET /superstars`)
- **Superstar profile** — creator feed (`GET /superstars/{id}`, `GET /feed/{id}`)
- **Content detail** — view, like, comments (`GET /content/{id}`, `POST .../like`, comments APIs)
- **Subscriptions** — list & cancel (`GET /subscriptions/me`, `POST .../cancel`)
- **Messages** — inbox (`GET /messages/inbox`)
- Profile & logout (`POST /auth/logout`)

### Creator (Superstar)
- **Upload content** — create + optional image (`POST /content`, `POST /content/{id}/media`)
- **Library** — list & delete (`GET /superstars/{id}/content`, `DELETE /content/{id}`)
- **Analytics** (`GET /analytics/superstars/{id}/overview`)
- Account & logout

### Admin
- Moderation queue, approve, reject, claim (`/moderation/*`)

## Test accounts (Postman)

Register via API first, then sign in:

- Customer: `fan@example.com`
- Superstar: `artist@example.com` (register with `role: SUPERSTAR`)

Superstar users need a linked superstar profile in the API for upload/library (resolved automatically when possible).
