# Play Console — "App access" (reviewer credentials)

> **Internal document. Never commit real credentials here.**
> Paste the finished text into Play Console → **App content → App access**.

## Why this is required

HerokuDroid has no sign-up of its own: it authenticates with a **Heroku API
key**. A reviewer who cannot sign in sees only the login screen, and Play will
reject the listing with *"App is not accessible for review."* You must declare
the restriction and supply working access.

## What to select in Play Console

1. **App content → App access → Manage → Add new instruction**.
2. Choose **"All or some functionality is restricted"**.
3. **Name:** `Heroku API key login`
4. **Instructions:** paste the block below, filling in the demo values.
5. Save, then submit the app for review.

## Instructions text to paste

```text
HerokuDroid signs in with a Heroku API key. There is no in-app sign-up.

1. Launch the app. The first screen is the login screen.
2. Paste the API key provided below into the "Heroku API token" field.
3. Tap "Connect account". The dashboard loads with the demo account's apps.
4. Tap any app to open it. The bottom bar switches between Overview, Dynos,
   Config Vars, Add-ons, Logs and Releases. All are available for review.

Credentials
  Account:  <demo-account-email>
  API key:  <DEMO_HEROKU_API_KEY>

Reviewing actions (scale, restart, config edits, add-on removal, release
rollback, maintenance mode) is optional. If you use them, they affect the demo
account only; feel free to use it.

The API key is sent only to api.heroku.com to authenticate your requests. It is
stored in the device keychain and is never sent to the developer.
```

## Preparing the demo account

1. Create a **free** Heroku account used only for review (Heroku Eco apps are
   free).
2. Add 2–3 sample apps (at least one with a web dyno, one scaled to zero, one
   with a config var and an add-on) so every screen shows real data.
3. Create the API key:
   **Heroku Dashboard → Account settings → API Key → Reveal**.
4. Paste that key into the Play Console field above — **not** into this repo.
5. Keep the account alive while the app is published; rotating the key
   invalidates the old one, so update Play Console if you regenerate it.

## Related declarations

- **Data safety:** the API key is stored on-device (not "collected"); no data is
  sent to the developer. See `docs/privacy.html`.
- Keep the login instructions in sync with any future onboarding changes.
