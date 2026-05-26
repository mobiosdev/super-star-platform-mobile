# SuperStar Platform — Mobile

Flutter app for the SuperStar creator–fan subscription platform.

## API integration

REST endpoints match `postman/SuperStar_Platform_API.postman_collection.json`.

| Layer | Location |
|-------|----------|
| Path constants | `lib/core/constants/api_constants.dart` |
| HTTP client (Dio + Bearer + refresh) | `lib/core/network/dio_client.dart` |
| Response envelope helper | `lib/core/network/api_response.dart` |
| Typed API client | `lib/data/api/platform_api.dart` |
| DTOs | `lib/data/models/` |
| Repositories | `lib/data/repositories/` |

### Wired flows

- **Auth** — login, register, logout, session restore via `GET /users/me`
- **Customer feed** — `GET /subscriptions/me` then `GET /feed/{superstarId}` (falls back to public superstar list)
- **Admin moderation** — queue, approve, reject, claim (escalate)

### Configuration

Default base URL (local backend):

```text
https://super-star-platform-backend.onrender.com/v1
```

Override at run/build time:

```bash
# Physical device / emulator pointing at your machine
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1

# Offline UI demo (no backend)
flutter run --dart-define=USE_MOCK_API=true
```

**Android emulator:** use `10.0.2.2` instead of `localhost` (maps to your PC). Debug builds allow HTTP to the host; release uses HTTPS only.

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1
```

**Physical Android device** (same Wi‑Fi as your PC): use your PC’s LAN IP, e.g. `http://192.168.1.42:3000/v1`.

**iOS simulator:** `localhost` works.

### “Failed host lookup” on emulator

The API URL in code is correct (`https://super-star-platform-backend.onrender.com/v1/auth/login`). That error means the **emulator cannot resolve DNS** (no internet), not a wrong path.

1. In the emulator, open **Chrome** → visit `https://google.com`. If it fails, fix emulator networking (cold boot AVD, disable VPN on PC, use a **Google Play** system image).
2. **Full restart** after manifest changes: stop the app → `flutter run` (not hot reload).
3. Confirm Render is up: open `https://super-star-platform-backend.onrender.com/v1/health` in your PC browser.
4. VS Code: run **“Flutter (Render API)”** from `.vscode/launch.json`.

### First-time setup

1. Start the SuperStar backend on port `3000`.
2. In Postman, run **Auth → Register** or **Login** to create a user.
3. Sign in from the app with the same email/password.

Roles from the API (`CUSTOMER`, `SUPERSTAR`, `ADMIN`, `SUPERADMIN`) map to app navigation automatically after `GET /users/me`.
