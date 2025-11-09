# Phase 0.2: Documentation Research - Dyno Management

**Research Date**: November 10, 2025  
**Researcher**: GitHub Copilot  
**Phase**: Phase 2 - App Details & Dyno Management  

---

## 1. Heroku Platform API - Dyno Management Endpoints

### 1.1 Formation Management (Dyno Scaling)

**API Reference**: Heroku CLI - ps:scale, ps:resize

**Key Commands & Patterns**:
- `heroku ps:scale web=3:Standard-2X worker+1` - Scale dyno quantity and size
- `heroku ps:scale --app APP` - View current formation
- Format: `<process-type>=<quantity>:<size>` or `<process-type>+<increment>`

**Request/Response Examples**:
```bash
# Scale web dynos to 3 with Standard-2X size
$ heroku ps:scale web=3:Standard-2X worker+1 --app APP
Scaling dynos... done, now running web at 3:Standard-2X, worker at 1:Standard-1X.

# View current formation
$ heroku ps:scale --app APP
web=3:Standard-2X worker=1:Standard-1X
```

**Key Learnings**:
- Scaling combines both quantity and size in a single operation
- Can use incremental syntax (`worker+1`) for relative scaling
- Response confirms both quantity and size for each process type
- **API Endpoint Pattern**: PATCH `/apps/{app_id}/formation/{formation_id}` with `{quantity, size}` in request body

---

### 1.2 Dyno Restart Operations

**API Reference**: Heroku CLI - ps:restart, ps:stop/kill

**Key Commands & Patterns**:
- `heroku ps:restart --app myapp` - Restart all dynos
- `heroku ps:restart --app myapp --dyno-name web.1` - Restart specific dyno
- `heroku ps:restart --app myapp --process-type web` - Restart all dynos of a process type
- `heroku ps:stop --app myapp --dyno-name run.1` - Stop specific dyno

**Request/Response Examples**:
```bash
# Restart specific dyno
$ heroku ps:restart --app myapp --dyno-name web.1

# Restart all web process type
$ heroku ps:restart --app myapp --process-type web

# Stop one-off dyno
$ heroku ps:stop --app myapp --dyno-name run.1828
```

**Key Learnings**:
- Three restart scopes: all dynos, specific dyno, or process type
- Restart is non-destructive (applies to running dynos)
- Stop/kill is for one-off dynos (run commands)
- **API Endpoint Patterns**: 
  - DELETE `/apps/{app_id}/dynos/{dyno_id}` - Restart/stop specific dyno
  - DELETE `/apps/{app_id}/dynos` - Restart all dynos
  - DELETE `/apps/{app_id}/dynos/{process_type}` - Restart process type

---

### 1.3 Dyno Types & Sizes

**Available Dyno Types**: 
- **Free**: Free (sleep after 30 min inactivity)
- **Hobby**: Hobby (never sleeps)
- **Standard**: Standard-1X, Standard-2X (production-grade)
- **Performance**: Performance-M, Performance-L (high-performance)
- **Private**: Private-S, Private-M, Private-L (Private Spaces only)

**Key Learnings**:
- Dyno sizes determine RAM, CPU shares, and pricing
- Standard-1X: 512MB RAM (baseline)
- Standard-2X: 1GB RAM (2x Standard-1X)
- Performance dynos have dedicated resources
- Each app has a "formation" defining process types and their dyno counts/sizes
- Process types come from Procfile (e.g., `web`, `worker`, `release`)

---

## 2. Flutter - Tabs & Navigation

### 2.1 TabBar Widget

**Documentation**: Flutter Material Design - TabBar

**Usage Pattern**:
```dart
DefaultTabController(
  length: 5, // Number of tabs
  child: Scaffold(
    appBar: AppBar(
      bottom: TabBar(
        tabs: [
          Tab(text: 'Overview'),
          Tab(text: 'Dynos'),
          Tab(text: 'Config'),
          Tab(text: 'Add-ons'),
          Tab(text: 'Logs'),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        OverviewTab(),
        DynosTab(),
        ConfigTab(),
        AddOnsTab(),
        LogsTab(),
      ],
    ),
  ),
)
```

**Key Learnings**:
- `TabBar` displays the tab headers
- Requires a `TabController` (use `DefaultTabController` for simple cases)
- `length` property must match number of tabs and views
- Supports icons, text, or both via `Tab` widget
- Can customize indicator color, label style, and tab alignment
- Works seamlessly with `AppBar.bottom` for sticky tabs

---

### 2.2 TabBarView Widget

**Documentation**: Flutter Material Design - TabBarView

**Usage Pattern**:
```dart
TabBarView(
  children: [
    Center(child: Text('Tab 1 Content')),
    Center(child: Text('Tab 2 Content')),
    Center(child: Text('Tab 3 Content')),
  ],
)
```

**Key Learnings**:
- `TabBarView` displays the content for each tab
- Automatically syncs with `TabBar` via shared `TabController`
- Supports swipe gestures for navigation between tabs
- Each child is built lazily (only when tab is active)
- Must have same number of children as tabs in `TabBar`

---

### 2.3 DefaultTabController

**Documentation**: Flutter Material Design - DefaultTabController

**Usage Pattern**:
```dart
DefaultTabController(
  length: 3,
  initialIndex: 0, // Optional: start on specific tab
  child: Scaffold(
    appBar: AppBar(
      bottom: TabBar(
        tabs: [/* tabs */],
      ),
    ),
    body: TabBarView(
      children: [/* content */],
    ),
  ),
)
```

**Key Learnings**:
- `DefaultTabController` provides `TabController` to descendants via InheritedWidget
- Simplifies tab implementation (no manual controller management)
- `length` property is required (number of tabs)
- `initialIndex` sets starting tab (defaults to 0)
- Use `TabController.indexIsChanging` to detect tab changes
- For advanced control (programmatic tab switching), use explicit `TabController`

---

## 3. Flutter - Bottom Sheets & Dialogs

### 3.1 showModalBottomSheet

**Documentation**: Flutter Material Design - showModalBottomSheet

**Usage Pattern**:
```dart
showModalBottomSheet<int>(
  context: context,
  isScrollControlled: true, // For taller sheets
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
  builder: (BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Scale Dynos', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16),
          // Slider or input fields
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, newValue); // Return value
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  },
);
```

**Key Learnings**:
- Returns `Future<T?>` with result when dismissed
- `isScrollControlled: true` allows sheet to expand beyond half-screen
- `isDismissible: true` (default) allows tap-outside to dismiss
- `enableDrag: true` (default) allows swipe-down to dismiss
- `shape` property customizes border radius
- Use `Navigator.pop(context, result)` to return data
- Barrier color and label are customizable
- Can use `showDragHandle: true` for iOS-style handle

---

### 3.2 showDialog & AlertDialog

**Documentation**: Flutter Material Design - showDialog, AlertDialog

**Usage Pattern**:
```dart
showDialog<bool>(
  context: context,
  barrierDismissible: false, // Prevent tap-outside dismiss
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text('Restart Dyno?'),
      content: Text('This will restart web.1 dyno. Continue?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Restart'),
        ),
      ],
    );
  },
);
```

**Key Learnings**:
- `showDialog` displays modal dialog with barrier
- `AlertDialog` is Material Design confirmation dialog
- `barrierDismissible: false` requires button interaction to dismiss
- Returns `Future<T?>` for async/await result handling
- `actions` list renders buttons in row (typically Cancel + Confirm)
- Can use `showAdaptiveDialog` for platform-specific dialog (Material/Cupertino)
- `WillPopScope` or `PopScope` can prevent back-button dismissal

---

### 3.3 Form Inputs (Slider, TextField)

**Documentation**: Flutter Material Design - Slider, TextField

**Usage Pattern**:
```dart
// Slider for dyno quantity
int _dynoCount = 1;

Slider(
  value: _dynoCount.toDouble(),
  min: 0,
  max: 10,
  divisions: 10,
  label: _dynoCount.toString(),
  onChanged: (double value) {
    setState(() {
      _dynoCount = value.toInt();
    });
  },
)

// TextField for direct input
TextField(
  decoration: InputDecoration(
    labelText: 'Dyno Count',
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  onChanged: (String value) {
    // Handle input
  },
)
```

**Key Learnings**:
- `Slider` provides visual control for numeric ranges
- `divisions` property creates discrete steps (snapping behavior)
- `label` shows value indicator when dragging
- `min` and `max` define range boundaries
- `TextField` offers keyboard input for precise values
- Use `TextEditingController` for programmatic value setting
- Combine `Slider` + `TextField` for flexible input UX

---

## 4. API Endpoints Summary

### Dyno Formation Endpoints
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/apps/{app_id}/formation` | GET | List all process formations |
| `/apps/{app_id}/formation/{formation_id}` | GET | Get specific formation details |
| `/apps/{app_id}/formation/{formation_id}` | PATCH | Update formation (scale quantity/size) |
| `/apps/{app_id}/formation` | PATCH | Batch update formations |

### Dyno Restart Endpoints
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/apps/{app_id}/dynos` | DELETE | Restart all dynos |
| `/apps/{app_id}/dynos/{dyno_id}` | DELETE | Restart specific dyno |
| `/apps/{app_id}/dynos/{process_type}` | DELETE | Restart all dynos of process type |

### Dyno Info Endpoints
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/apps/{app_id}/dynos` | GET | List all running dynos |
| `/apps/{app_id}/dynos/{dyno_id}` | GET | Get specific dyno info |

---

## 5. UI Pattern Decisions

### 5.1 App Details Screen Layout
**Decision**: Use `DefaultTabController` with 5 tabs (Overview, Dynos, Config, Add-ons, Logs)

**Rationale**: 
- TabBar provides clear navigation for different app aspects
- Matches Heroku dashboard UX paradigm
- Each tab can lazy-load data independently
- Swipe gestures improve mobile UX
- Sticky tabs (in AppBar.bottom) keep navigation visible

---

### 5.2 Dyno Scaling UI
**Decision**: Use `showModalBottomSheet` with Slider + TextField combo for quantity selection, and dropdown for dyno size

**Rationale**: 
- Bottom sheet is non-blocking and familiar on mobile
- Slider provides quick visual adjustment (0-10 dynos)
- TextField allows direct input for precise values
- Dropdown for dyno size selection (Standard-1X, Standard-2X, etc.)
- Save/Cancel buttons make changes explicit (not auto-save)
- Can show current cost estimate before confirming

---

### 5.3 Confirmation Dialogs
**Decision**: Use `AlertDialog` for destructive operations (restart dyno, delete config var)

**Rationale**: 
- Standard Material Design pattern for confirmations
- Clear title/message/actions layout
- `barrierDismissible: false` prevents accidental dismissal
- Two-button layout (Cancel + Confirm) reduces errors
- Can include additional context (e.g., "This will cause brief downtime")
- Returns boolean for easy async/await handling

---

## Implementation Checklist for Phase 2

- [ ] Create app details screen with TabBar (5 tabs)
- [ ] Implement dyno list widget showing formation
- [ ] Build scale dyno bottom sheet with Slider + TextField
- [ ] Add restart dyno confirmation dialog
- [ ] Implement maintenance mode toggle
- [ ] Create DynoProvider for state management
- [ ] Add error handling for dyno operations
- [ ] Test all dyno operations end-to-end

---

**Next Steps**: Proceed to Phase 2 implementation with documented patterns above.
