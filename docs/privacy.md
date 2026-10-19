---
title: HerokuDroid — Privacy Policy
---

# HerokuDroid — Privacy Policy

_Last updated: October 19, 2026_

HerokuDroid is a mobile client for the [Heroku Platform API](https://devcenter.heroku.com/articles/platform-api-reference).
It is developed independently and is **not affiliated with, endorsed by, or
sponsored by Heroku or Salesforce**.

## 1. Overview

HerokuDroid does not operate any backend servers that collect your data. All
communication happens directly between your device and Heroku's API
(`https://api.heroku.com`).

## 2. Information the app handles

| Data | Where it goes | Why |
| --- | --- | --- |
| Heroku API token | Stored **only on your device** in the platform secure storage (Android Keystore / iOS Keychain). | To authenticate your requests to Heroku. It is never sent to the developer. |
| App data (names, region, stack, dyno counts, config var keys/values, add-ons, releases) | Fetched from Heroku and cached **locally** on your device. | To display your apps and let you manage them. |
| Runtime logs | Streamed live from Heroku into memory while you view them. | To show the log console. Logs are not persisted by the app. |

## 3. How information is used

The information above is used solely to provide the app's features: listing
apps, showing status, viewing and editing configuration, scaling/restarting
dynos, managing add-ons, viewing releases, and rolling back deployments — all
only when you request it.

## 4. Sharing

- **No third parties.** Requests are sent only to the Heroku Platform API.
- **No analytics, advertising, crash-reporting, or tracking SDKs.**
- We do not sell or share your data, because we never receive it.

## 5. Data retention and deletion

- **Clear cache** (Settings) removes locally cached app data.
- **Log out** deletes the stored API token from secure storage.
- Uninstalling the app removes all locally stored data.

## 6. Security

Your API token is stored using the operating system's secure storage. You are
responsible for the security of your device and for keeping your API token
secret. Actions you perform in the app (for example deleting an app or removing
an add-on) are executed on your Heroku account and cannot be undone by us.

## 7. Children's privacy

HerokuDroid is a developer tool and is not directed to children under 13. We do
not knowingly collect personal information from children.

## 8. Changes to this policy

We may update this policy from time to time. Material changes will be reflected
by the "Last updated" date above and, where appropriate, an in-app notice.

## 9. Contact

Questions about this policy can be raised via the project's issue tracker:
<https://github.com/rjfahad/HerokuDroid/issues>.
