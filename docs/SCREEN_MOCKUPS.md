# HerokuDroid - Screen Mockups (ASCII)

**Project**: HerokuDroid  
**Platform**: Flutter (Android)  
**Date**: November 10, 2025

---

## Table of Contents

1. [Splash Screen](#1-splash-screen)
2. [Token Input Screen](#2-token-input-screen)
3. [Dashboard Screen](#3-dashboard-screen)
4. [App Details Screen - Overview Tab](#4-app-details-screen---overview-tab)
5. [App Details Screen - Dynos Tab](#5-app-details-screen---dynos-tab)
6. [App Details Screen - Config Tab](#6-app-details-screen---config-tab)
7. [App Details Screen - Add-ons Tab](#7-app-details-screen---add-ons-tab)
8. [App Details Screen - Logs Tab](#8-app-details-screen---logs-tab)
9. [Scale Dyno Screen](#9-scale-dyno-screen)
10. [Restart Dyno Confirmation Dialog](#10-restart-dyno-confirmation-dialog)
11. [Edit Config Var Screen](#11-edit-config-var-screen)
12. [Log Filters Panel](#12-log-filters-panel)

---

## 1. Splash Screen

```
╔═══════════════════════════════════════╗
║                                       ║
║                                       ║
║                                       ║
║            ╔═════════╗                ║
║            ║ HEROKU  ║                ║
║            ║  DROID  ║                ║
║            ╚═════════╝                ║
║                                       ║
║              [Logo]                   ║
║                                       ║
║         Loading...  ━━━━━○            ║
║                                       ║
║                                       ║
║                                       ║
║       v1.0.0                          ║
╚═══════════════════════════════════════╝
```

**Description**:

- App logo/icon centered
- Loading indicator
- Version number at bottom
- Auto-transitions to Dashboard (if token exists) or Token Input

---

## 2. Token Input Screen

```
╔═══════════════════════════════════════╗
║  ← Back          Login                ║
╠═══════════════════════════════════════╣
║                                       ║
║         Welcome to HerokuDroid        ║
║                                       ║
║     Manage your Heroku apps with      ║
║            ease and speed             ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ Enter Heroku API Token          │  ║
║  │ ○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○  │  ║
║  └─────────────────────────────────┘  ║
║                              [👁]     ║
║                                       ║
║  ┌───────────────────────────────┐   ║
║  │  ℹ How to get your token?    │   ║
║  │  1. Install Heroku CLI        │   ║
║  │  2. Run: heroku auth:token    │   ║
║  │  3. Copy and paste here       │   ║
║  └───────────────────────────────┘   ║
║                                       ║
║        ┌─────────────────────┐        ║
║        │   LOGIN WITH TOKEN  │        ║
║        └─────────────────────┘        ║
║                                       ║
║           [ Learn More ]              ║
║                                       ║
╚═══════════════════════════════════════╝
```

**Elements**:

- Masked password field for API token
- Eye icon to toggle visibility
- Information card with instructions
- Login button (disabled until valid token entered)
- Link to documentation

---

## 3. Dashboard Screen

```
╔═══════════════════════════════════════╗
║  ☰  HerokuDroid        🔄  ⚙  👤     ║
╠═══════════════════════════════════════╣
║  ┌─────────────────────────────────┐  ║
║  │ 🔍 Search apps...               │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  My Apps (12)            [Grid][List]║
║  ═════════════════════════════════    ║
║                                       ║
║  ┌────────────────┐ ┌──────────────┐ ║
║  │ 🌐 prod-api    │ │ 🌐 staging   │ ║
║  │ ●●○ 2 dynos    │ │ ●○○ 1 dyno   │ ║
║  │ 📍 us          │ │ 📍 eu        │ ║
║  │ ⏰ 2h ago      │ │ ⏰ 5m ago    │ ║
║  └────────────────┘ └──────────────┘ ║
║                                       ║
║  ┌────────────────┐ ┌──────────────┐ ║
║  │ 🌐 worker-app  │ │ 🌐 dev-test  │ ║
║  │ ●●● 3 dynos    │ │ ○○○ 0 dynos  │ ║
║  │ 📍 us          │ │ 📍 us        │ ║
║  │ ⏰ 1d ago      │ │ ⏰ 3h ago    │ ║
║  └────────────────┘ └──────────────┘ ║
║                                       ║
║  ┌────────────────┐ ┌──────────────┐ ║
║  │ 🌐 analytics   │ │ 🔧 maint...  │ ║
║  │ ●○○ 1 dyno     │ │ ⚠ MAINT MODE │ ║
║  │ 📍 us          │ │ 📍 us        │ ║
║  │ ⏰ 12h ago     │ │ ⏰ 30m ago   │ ║
║  └────────────────┘ └──────────────┘ ║
║                                       ║
║                                 [+]   ║
╚═══════════════════════════════════════╝
```

**Elements**:

- Header with app name, refresh, settings, profile icons
- Search bar with filter
- Grid/List view toggle
- App cards showing:
  - App name with icon
  - Dyno status (colored dots: green=up, yellow=idle, red=down)
  - Region badge
  - Last deployed time
  - Maintenance warning if applicable
- Pull-to-refresh (swipe down)
- FAB (+) for quick actions

**Status Indicators**:

- ● Green = Running
- ● Yellow = Idle
- ○ Gray = Stopped
- ⚠ Orange = Maintenance mode

---

## 4. App Details Screen - Overview Tab

```
╔═══════════════════════════════════════╗
║  ← prod-api                    ⋮      ║
╠═══════════════════════════════════════╣
║ Overview│Dynos│Config│Add-ons│Logs   ║
║─────────────────────────────────────  ║
║                                       ║
║  STATUS                               ║
║  ┌─────────────────────────────────┐  ║
║  │ ✓ Deployed                      │  ║
║  │ ● 2 dynos running               │  ║
║  │ 📦 Release v142                 │  ║
║  │ ⏰ Deployed 2 hours ago         │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  APP INFO                             ║
║  ┌─────────────────────────────────┐  ║
║  │ Name:     prod-api              │  ║
║  │ Owner:    john@example.com      │  ║
║  │ Region:   us (Virginia)         │  ║
║  │ Stack:    heroku-22             │  ║
║  │ Created:  Jan 15, 2024          │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  LINKS                                ║
║  ┌─────────────────────────────────┐  ║
║  │ 🌐 Open App                 [→] │  ║
║  │ https://prod-api.herokuapp.com  │  ║
║  │                                 │  ║
║  │ 📋 Git URL              [Copy]  │  ║
║  │ https://git.heroku.com/...      │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  MAINTENANCE MODE                     ║
║  ┌─────────────────────────────────┐  ║
║  │ Enable maintenance mode    [○]  │  ║
║  │ ℹ Puts app in maintenance state │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
╚═══════════════════════════════════════╝
```

**Elements**:

- App name in header
- Tab navigation
- Status card (deployment info)
- App info card (metadata)
- Quick links (web URL, git URL with copy)
- Maintenance mode toggle
- More menu (⋮) for delete/transfer

---

## 5. App Details Screen - Dynos Tab

```
╔═══════════════════════════════════════╗
║  ← prod-api                    ⋮      ║
╠═══════════════════════════════════════╣
║ Overview│Dynos│Config│Add-ons│Logs   ║
║─────────────────────────────────────  ║
║                                       ║
║  FORMATION                            ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ web                             │  ║
║  │ ● 2 × standard-1X       [Scale] │  ║
║  │ ├─ web.1    ● up    2h  [Stop]  │  ║
║  │ └─ web.2    ● up    2h  [Stop]  │  ║
║  │                         [Restart]│  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ worker                          │  ║
║  │ ● 1 × standard-2X       [Scale] │  ║
║  │ └─ worker.1 ● up    2h  [Stop]  │  ║
║  │                         [Restart]│  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ release                         │  ║
║  │ ○ 0 × standard-1X       [Scale] │  ║
║  │ (no dynos running)              │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │        [ Restart All Dynos ]    │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
╚═══════════════════════════════════════╝
```

**Elements**:

- Formation cards for each process type
- Dyno count and size display
- Individual dyno instances listed
- Scale button (opens scale dialog)
- Restart button for each process type
- Stop button for individual dynos
- Restart all button at bottom
- Status indicators (● = running, ○ = stopped)

---

## 6. App Details Screen - Config Tab

```
╔═══════════════════════════════════════╗
║  ← prod-api                    ⋮      ║
╠═══════════════════════════════════════╣
║ Overview│Dynos│Config│Add-ons│Logs   ║
║─────────────────────────────────────  ║
║  ┌─────────────────────────────────┐  ║
║  │ 🔍 Search config vars...        │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  CONFIG VARS (8)           [ + Add ]  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ DATABASE_URL                    │→ ║
║  │ postgres://user:***@host/db     │  ║
║  │                        [👁] [×]  │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ REDIS_URL                       │→ ║
║  │ redis://:*****@host:6379        │  ║
║  │                        [👁] [×]  │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ API_KEY                         │→ ║
║  │ ●●●●●●●●●●●●●●●●                │  ║
║  │                        [👁] [×]  │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ NODE_ENV                        │→ ║
║  │ production                      │  ║
║  │                        [👁] [×]  │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ PORT                            │→ ║
║  │ 5000                            │  ║
║  │                        [👁] [×]  │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
╚═══════════════════════════════════════╝
```

**Elements**:

- Search bar for filtering vars
- Add button (opens edit dialog)
- Config var cards showing:
  - Key name
  - Value (masked by default for sensitive data)
  - Eye icon to toggle visibility
  - Delete icon (×)
  - Tap to edit
- Swipe left/right for quick delete
- Values auto-detect sensitive data (password, key, secret, token)

---

## 7. App Details Screen - Add-ons Tab

```
╔═══════════════════════════════════════╗
║  ← prod-api                    ⋮      ║
╠═══════════════════════════════════════╣
║ Overview│Dynos│Config│Add-ons│Logs   ║
║─────────────────────────────────────  ║
║                                       ║
║  INSTALLED ADD-ONS (3)                ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ 🐘 Heroku Postgres              │  ║
║  │ Essential-0                     │  ║
║  │ ● Provisioned                   │  ║
║  │ $50.00/month                    │  ║
║  │                                 │  ║
║  │ Database: 10GB / 10GB used      │  ║
║  │ Connections: 24 / 120           │  ║
║  │                                 │  ║
║  │ [Open Dashboard] [Remove]       │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ 🔴 Heroku Redis                 │  ║
║  │ Premium-0                       │  ║
║  │ ● Provisioned                   │  ║
║  │ $15.00/month                    │  ║
║  │                                 │  ║
║  │ Memory: 25MB                    │  ║
║  │ Connections: 40                 │  ║
║  │                                 │  ║
║  │ [Open Dashboard] [Remove]       │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ 📊 Papertrail                   │  ║
║  │ Choklad                         │  ║
║  │ ● Provisioned                   │  ║
║  │ FREE                            │  ║
║  │                                 │  ║
║  │ Log capacity: 50MB/day          │  ║
║  │ Retention: 7 days               │  ║
║  │                                 │  ║
║  │ [Open Dashboard] [Remove]       │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
╚═══════════════════════════════════════╝
```

**Elements**:

- Add-on cards showing:
  - Add-on name with icon
  - Plan name
  - Provisioning status
  - Pricing
  - Key metrics/info
  - "Open Dashboard" button (opens browser)
  - "Remove" button (with confirmation)
- Empty state if no add-ons

---

## 8. App Details Screen - Logs Tab

```
╔═══════════════════════════════════════╗
║  ← prod-api          🔍 ⚙ ↗          ║
╠═══════════════════════════════════════╣
║ Overview│Dynos│Config│Add-ons│Logs   ║
║─────────────────────────────────────  ║
║                                       ║
║ ⚡ Connected │ 247 lines │ [Clear]    ║
║                                       ║
║┌─────────────────────────────────────┐║
║│2024-11-10T14:23:01.234Z app[web.1]:│║
║│Starting process with command `npm  ││║
║│start`                              ││║
║├─────────────────────────────────────┤║
║│2024-11-10T14:23:02.456Z app[web.1]:│║
║│Server listening on port 5000       ││║
║├─────────────────────────────────────┤║
║│2024-11-10T14:23:05.789Z heroku[r...│║
║│State changed from starting to up   ││║
║├─────────────────────────────────────┤║
║│2024-11-10T14:23:10.123Z app[web.1]:│║
║│GET / 200 45ms                      ││║
║├─────────────────────────────────────┤║
║│2024-11-10T14:23:12.456Z app[web.1]:│║
║│GET /api/users 200 123ms            ││║
║├─────────────────────────────────────┤║
║│2024-11-10T14:23:15.789Z app[web.2]:│║
║│POST /api/data 201 89ms             ││║
║├─────────────────────────────────────┤║
║│2024-11-10T14:23:20.123Z router:    │║
║│at=info method=GET path="/api/user..│║
║├─────────────────────────────────────┤║
║│2024-11-10T14:23:25.456Z app[web.1]:│║
║│⚠ Warning: High memory usage (85%) ││║
║├─────────────────────────────────────┤║
║│2024-11-10T14:23:30.789Z postgres[..│║
║│[DATABASE] checkpoint starting      ││║
║├─────────────────────────────────────┤║
║│2024-11-10T14:23:35.123Z app[web.1]:│║
║│❌ Error: Connection timeout        ││║
║└─────────────────────────────────────┘║
║                                       ║
║              [⏸ PAUSE]                ║
╚═══════════════════════════════════════╝
```

**Elements**:

- Connection status indicator
- Log count
- Filter icon (opens filter panel)
- Settings icon (log preferences)
- Share icon (export logs)
- Auto-scrolling log viewer with:
  - Timestamps
  - Source (app, heroku, router, postgres)
  - Dyno identifier
  - Log message
  - Color coding:
    - White/Gray: Info
    - Yellow: Warnings (⚠)
    - Red: Errors (❌)
    - Green: Success (✓)
- Pause/Resume FAB
- Long-press to copy log line
- Pull down to load earlier logs

---

## 9. Scale Dyno Screen

```
╔═══════════════════════════════════════╗
║  ← Scale Dyno                         ║
╠═══════════════════════════════════════╣
║                                       ║
║  APP: prod-api                        ║
║  PROCESS TYPE: web                    ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ CURRENT CONFIGURATION           │  ║
║  │                                 │  ║
║  │ Quantity: 2                     │  ║
║  │ Size: standard-1X               │  ║
║  │ Cost: $50/month                 │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ─────────────────────────────────    ║
║                                       ║
║  QUANTITY                             ║
║  ┌─────────────────────────────────┐  ║
║  │ How many dynos?                 │  ║
║  │                                 │  ║
║  │  [-]  ━━●━━━━━━━━  [+]          │  ║
║  │         3 dynos                 │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  SIZE                                 ║
║  ┌─────────────────────────────────┐  ║
║  │ Select dyno size                │  ║
║  │                                 │  ║
║  │ ○ Eco ($5/mo)        512MB RAM  │  ║
║  │ ○ Basic ($7/mo)      512MB RAM  │  ║
║  │ ● Standard-1X ($25/mo) 512MB    │  ║
║  │ ○ Standard-2X ($50/mo) 1GB      │  ║
║  │ ○ Performance-M ($250/mo) 2.5GB │  ║
║  │ ○ Performance-L ($500/mo) 14GB  │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ NEW COST ESTIMATE               │  ║
║  │                                 │  ║
║  │ 3 × Standard-1X                 │  ║
║  │ $75.00/month                    │  ║
║  │                                 │  ║
║  │ Change: +$25/month              │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │         [ SCALE DYNOS ]         │  ║
║  └─────────────────────────────────┘  ║
║            [ Cancel ]                 ║
║                                       ║
╚═══════════════════════════════════════╝
```

**Elements**:

- Current configuration display
- Quantity slider (0-10)
- Size radio buttons with pricing
- Cost estimate calculator
- Scale button (applies changes)
- Cancel button
- Warning if scaling to 0 (app will be down)

---

## 10. Restart Dyno Confirmation Dialog

```
        ╔═══════════════════════════╗
        ║  Restart Dynos?           ║
        ╠═══════════════════════════╣
        ║                           ║
        ║   ⚠                       ║
        ║                           ║
        ║  Are you sure you want    ║
        ║  to restart all dynos     ║
        ║  for process type "web"?  ║
        ║                           ║
        ║  This will cause brief    ║
        ║  downtime while dynos     ║
        ║  restart.                 ║
        ║                           ║
        ║  Affected dynos:          ║
        ║  • web.1                  ║
        ║  • web.2                  ║
        ║                           ║
        ║  ┌───────┐  ┌──────────┐  ║
        ║  │Cancel │  │ Restart  │  ║
        ║  └───────┘  └──────────┘  ║
        ║                           ║
        ╚═══════════════════════════╝
```

**Elements**:

- Warning icon
- Clear message
- List of affected dynos
- Cancel button (gray)
- Restart button (red/danger)
- Dimmed background overlay

---

## 11. Edit Config Var Screen

```
╔═══════════════════════════════════════╗
║  ← Edit Config Var            [Save]  ║
╠═══════════════════════════════════════╣
║                                       ║
║  APP: prod-api                        ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ KEY                             │  ║
║  │ API_KEY                         │  ║
║  └─────────────────────────────────┘  ║
║  ℹ Variable name (uppercase, no space)║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │ VALUE                           │  ║
║  │ sk_live_123abc456def789ghi...   │  ║
║  │                                 │  ║
║  │                                 │  ║
║  │                                 │  ║
║  └─────────────────────────────────┘  ║
║                              [👁]     ║
║                                       ║
║  ⚠ Warning: Changing config vars will║
║     restart all dynos                 ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │  SENSITIVE VALUE DETECTED       │  ║
║  │  This appears to be an API key  │  ║
║  │  or secret. It will be masked   │  ║
║  │  by default for security.       │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │         [ SAVE CHANGES ]        │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║            [ Cancel ]                 ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │      [ DELETE VARIABLE ]        │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
╚═══════════════════════════════════════╝
```

**Elements**:

- Key input field (uppercase validation)
- Multi-line value input
- Eye icon to toggle visibility
- Auto-detection of sensitive values
- Warning about dyno restart
- Save button (enabled when valid)
- Cancel button
- Delete button (red/danger)
- Validation messages

---

## 12. Log Filters Panel

```
╔═══════════════════════════════════════╗
║  Log Filters                   [Done] ║
╠═══════════════════════════════════════╣
║                                       ║
║  SOURCE                               ║
║  ┌─────────────────────────────────┐  ║
║  │ ▼ All sources                   │  ║
║  └─────────────────────────────────┘  ║
║  • All sources                        ║
║  • app                                ║
║  • heroku                             ║
║  • router                             ║
║  • postgres                           ║
║  • redis                              ║
║                                       ║
║  DYNO                                 ║
║  ┌─────────────────────────────────┐  ║
║  │ ▼ All dynos                     │  ║
║  └─────────────────────────────────┘  ║
║  • All dynos                          ║
║  • web.1                              ║
║  • web.2                              ║
║  • worker.1                           ║
║                                       ║
║  LOG LEVEL                            ║
║  ┌────┐ ┌────┐ ┌────┐ ┌──────┐       ║
║  │ All│ │Info│ │Warn│ │Error │       ║
║  └────┘ └────┘ └────┘ └──────┘       ║
║    ●      ●      ●       ●            ║
║                                       ║
║  TAIL                                 ║
║  ┌─────────────────────────────────┐  ║
║  │ Number of lines  [100]          │  ║
║  └─────────────────────────────────┘  ║
║  Show last N lines (10 - 1500)        ║
║                                       ║
║  TIME RANGE                           ║
║  ┌─────────────────────────────────┐  ║
║  │ ○ Real-time (live)              │  ║
║  │ ○ Last hour                     │  ║
║  │ ○ Last 24 hours                 │  ║
║  │ ○ Custom range...               │  ║
║  └─────────────────────────────────┘  ║
║                                       ║
║  SEARCH                               ║
║  ┌─────────────────────────────────┐  ║
║  │ 🔍 Filter by text...            │  ║
║  └─────────────────────────────────┘  ║
║  Case sensitive [ ]                   ║
║                                       ║
║  ┌─────────────────────────────────┐  ║
║  │      [ APPLY FILTERS ]          │  ║
║  └─────────────────────────────────┘  ║
║            [ Clear All ]              ║
║                                       ║
╚═══════════════════════════════════════╝
```

**Elements**:

- Source dropdown
- Dyno dropdown
- Log level chips (multi-select)
- Tail line count input
- Time range radio buttons
- Text search with case-sensitive option
- Apply button
- Clear all filters button
- Close (Done) button in header

---

## Additional UI Patterns

### Pull-to-Refresh Indicator

```
        ┌───────────┐
        │     ↓     │
        │  Release  │
        │ to refresh│
        └───────────┘
            ↓↓↓
        ┌───────────┐
        │     ⟳     │
        │ Refreshing│
        └───────────┘
```

### Loading Skeleton (App Card)

```
  ┌────────────────┐
  │ ░░░░░░░░░░     │
  │ ░░░ ░░░░░      │
  │ ░░ ░░░░        │
  │ ░░░░ ░░░░      │
  └────────────────┘
```

### Empty State (No Apps)

```
        ╔═══════════════╗
        ║               ║
        ║      📱       ║
        ║               ║
        ║  No apps yet  ║
        ║               ║
        ║  [ Create  ]  ║
        ║  [  App    ]  ║
        ║               ║
        ╚═══════════════╝
```

### Error State

```
        ╔═══════════════╗
        ║               ║
        ║      ⚠️       ║
        ║               ║
        ║ Failed to load║
        ║     apps      ║
        ║               ║
        ║  [ Try Again ]║
        ║               ║
        ╚═══════════════╝
```

### Snackbar (Success)

```
╔═══════════════════════════════════════╗
║                                       ║
║  ... (content)                        ║
║                                       ║
║ ┌─────────────────────────────────┐   ║
║ │ ✓ Dyno scaled successfully  [×] │   ║
║ └─────────────────────────────────┘   ║
╚═══════════════════════════════════════╝
```

### Snackbar (Error)

```
╔═══════════════════════════════════════╗
║                                       ║
║  ... (content)                        ║
║                                       ║
║ ┌─────────────────────────────────┐   ║
║ │ ❌ Failed to update config  [×] │   ║
║ │         [ Retry ]               │   ║
║ └─────────────────────────────────┘   ║
╚═══════════════════════════════════════╝
```

---

## Navigation Flow

```
┌─────────────┐
│   Splash    │
└──────┬──────┘
       │
       ├─ Has Token? ─ No ──┐
       │                    ↓
       Yes            ┌──────────────┐
       │              │ Token Input  │
       │              └──────┬───────┘
       │                     │
       ↓                     │
┌─────────────┐              │
│  Dashboard  │ ←────────────┘
└──────┬──────┘
       │
       ├─ Tap App Card
       │
       ↓
┌─────────────────────────────┐
│      App Details            │
│  ┌─────────────────────┐    │
│  │ Overview            │    │
│  ├─────────────────────┤    │
│  │ Dynos ─────→ Scale  │    │
│  ├─────────────────────┤    │
│  │ Config ────→ Edit   │    │
│  ├─────────────────────┤    │
│  │ Add-ons             │    │
│  ├─────────────────────┤    │
│  │ Logs ──────→ Filter │    │
│  └─────────────────────┘    │
└─────────────────────────────┘
```

---

## Color Palette Reference

```
PRIMARY (Heroku Purple)
■ #6567A5 / #430098

ACCENT (Orange/Yellow)
■ #FF9500 (Warning)
■ #FFD500 (Info)

STATUS
■ #00D084 (Success/Running)
■ #FFD500 (Idle/Warning)
■ #FF3B30 (Error/Stopped)
■ #8E8E93 (Disabled/Gray)

BACKGROUNDS
■ #FFFFFF (Light mode card)
■ #F2F2F7 (Light mode bg)
■ #1C1C1E (Dark mode card)
■ #000000 (Dark mode bg)

TEXT
■ #000000 (Primary)
■ #3C3C43 (Secondary)
■ #FFFFFF (On dark)
■ #8E8E93 (Tertiary)
```

---

## Typography Reference

```
HEADERS
════════════════
H1: 32sp Bold (Screen titles)
H2: 24sp SemiBold (Section headers)
H3: 20sp Medium (Card titles)

BODY
════════════════
Body1: 16sp Regular (Main content)
Body2: 14sp Regular (Secondary text)
Caption: 12sp Regular (Timestamps, hints)

MONOSPACE (Logs)
════════════════
Code: 14sp Monospace (Log entries)
```

---

## Icon Legend

```
🌐 = App/Web
🔴 = Redis
🐘 = PostgreSQL
📊 = Analytics/Charts
🔧 = Settings/Maintenance
⚙️ = Settings/Config
👤 = User Profile
🔍 = Search
🔄 = Refresh/Reload
⋮ = More Options
← = Back
→ = Forward/Open
↗ = External Link
+ = Add
× = Close/Delete
👁 = Show/Hide
📋 = Copy
⏸ = Pause
▶ = Play/Resume
⚠️ = Warning
❌ = Error
✓ = Success
● = Status (running)
○ = Status (stopped)
ℹ = Information
```

---

**Document Version**: 1.0  
**Last Updated**: November 10, 2025  
**Status**: Complete - Ready for UI Implementation
