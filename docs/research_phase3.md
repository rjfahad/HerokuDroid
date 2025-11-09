# Phase 0.3: Config Vars & Add-ons Research

**Date**: November 10, 2025  
**Phase**: Documentation Research - Config & Add-ons  
**Duration**: 1 day  
**Status**: ✅ COMPLETE

---

## Research Objective

Research Heroku config vars API, add-ons management, secure input handling, and Flutter form patterns for implementing Phase 3 (Config Vars & Add-ons management).

---

## 1. Heroku Platform API - Config Vars

### Key Findings

Based on Heroku Platform API documentation research:

#### Config Vars Endpoint

- **GET** `/apps/{app_id}/config-vars` - Retrieve all config vars
  - Returns: `Map<String, String>` (flat key-value pairs)
  - Example response:
    ```json
    {
      "DATABASE_URL": "postgres://...",
      "SECRET_KEY": "abc123...",
      "NODE_ENV": "production"
    }
    ```

- **PATCH** `/apps/{app_id}/config-vars` - Update config vars
  - Request body: `Map<String, String?>` (null values delete keys)
  - Example:
    ```json
    {
      "NEW_VAR": "value",
      "UPDATE_VAR": "new_value",
      "DELETE_VAR": null
    }
    ```
  - Returns: Updated full config vars map

#### Important Notes

- **Single Endpoint for CRUD**: Unlike most REST APIs, config vars use PATCH for create, update, AND delete
- **Atomic Operations**: All changes in single PATCH are atomic
- **Sensitive Data**: Config vars often contain API keys, passwords, database URLs - must be treated as sensitive
- **No Individual Endpoints**: Cannot GET/DELETE single config var, must work with entire map

### API Constants to Add

```dart
/// lib/core/constants/api_constants.dart
static String configVars(String appId) => '/apps/$appId/config-vars';
```

---

## 2. Heroku Platform API - Add-ons

### Key Findings

#### Add-ons Endpoints

- **GET** `/apps/{app_id}/addons` - List all add-ons for an app
  - Returns: Array of add-on objects
  - Important fields:
    - `id`: Add-on UUID
    - `name`: Add-on instance name (e.g., "postgresql-acute-12345")
    - `addon_service.name`: Service type (e.g., "heroku-postgresql")
    - `plan.name`: Plan tier (e.g., "heroku-postgresql:hobby-dev")
    - `state`: "provisioned", "provisioning", "deprovisioned"
    - `web_url`: Dashboard URL (can be opened in browser)
    - `created_at`, `updated_at`

- **GET** `/addons/{addon_id}` - Get single add-on details
  - Returns: Detailed add-on object

#### Add-on Provisioning (Optional for MVP)

- **POST** `/apps/{app_id}/addons` - Provision new add-on
  - Requires `plan` (e.g., "heroku-postgresql:hobby-dev")
  - Optional `config` object for add-on specific settings

- **DELETE** `/apps/{app_id}/addons/{addon_id}` - Deprovision add-on

### Important Notes

- **Read-Only for MVP**: Phase 3 focuses on viewing/opening add-ons, not provisioning
- **External Dashboards**: Most add-on management happens in web dashboards
- **Plan Pricing**: Not directly available in API response (would need separate pricing API)

### API Constants to Add

```dart
/// lib/core/constants/api_constants.dart
static String addons(String appId) => '/apps/$appId/addons';
static String addon(String appId, String addonId) => '/apps/$appId/addons/$addonId';
```

---

## 3. Flutter Form Validation & Input

### Key Patterns from Flutter Documentation

#### Form Widget with Validation

```dart
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

@override
Widget build(BuildContext context) {
  return Form(
    key: _formKey,
    child: Column(
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Enter config var name',
            labelText: 'Key',
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a key name';
            }
            // Additional validation (e.g., no spaces, uppercase)
            if (value.contains(' ')) {
              return 'Key cannot contain spaces';
            }
            return null; // Valid
          },
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Process data
            }
          },
          child: const Text('Submit'),
        ),
      ],
    ),
  );
}
```

#### Dynamic Error Display with TextField

```dart
class _ConfigVarInputState extends State<ConfigVarInput> {
  String? _errorText;
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (text) {
        setState(() {
          // Validate on change
          if (text.isEmpty) {
            _errorText = 'Key cannot be empty';
          } else if (text.contains(' ')) {
            _errorText = 'Key cannot contain spaces';
          } else {
            _errorText = null; // Valid
          }
        });
      },
      decoration: InputDecoration(
        hintText: 'CONFIG_KEY',
        labelText: 'Key',
        errorText: _errorText,
      ),
    );
  }
}
```

#### Input Filtering (FilteringTextInputFormatter)

```dart
TextField(
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9_]')), // Only uppercase, digits, underscore
  ],
  decoration: const InputDecoration(
    hintText: 'DATABASE_URL',
  ),
)
```

### Validation Rules for Config Vars

Based on Heroku conventions:
- **Key naming**: Typically UPPERCASE_WITH_UNDERSCORES
- **No spaces**: Keys should not contain spaces
- **Alphanumeric + underscore**: `[A-Z0-9_]` pattern
- **Value validation**: Accept any string (can be empty for some vars)

---

## 4. Search & Filter Patterns

### Flutter Search Implementation

#### Option 1: TextField with Real-time Filtering

```dart
class ConfigVarsScreen extends StatefulWidget {
  // ...
}

class _ConfigVarsScreenState extends State<ConfigVarsScreen> {
  String _searchQuery = '';
  
  List<MapEntry<String, String>> get _filteredConfigVars {
    if (_searchQuery.isEmpty) {
      return configVars.entries.toList();
    }
    return configVars.entries.where((entry) {
      return entry.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             entry.value.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search config vars',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredConfigVars.length,
            itemBuilder: (context, index) {
              final entry = _filteredConfigVars[index];
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

#### Option 2: Search Delegate (Material Design Pattern)

```dart
class ConfigVarSearchDelegate extends SearchDelegate<String> {
  final Map<String, String> configVars;
  
  ConfigVarSearchDelegate(this.configVars);
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }
  
  @override
  Widget buildResults(BuildContext context) {
    // Show filtered results
    final results = configVars.entries.where((entry) {
      return entry.key.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].key),
          subtitle: Text(results[index].value),
        );
      },
    );
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions as user types
    return buildResults(context);
  }
}

// Usage in AppBar:
actions: [
  IconButton(
    icon: const Icon(Icons.search),
    onPressed: () {
      showSearch(
        context: context,
        delegate: ConfigVarSearchDelegate(configVars),
      );
    },
  ),
]
```

---

## 5. Masked Input Fields (Sensitive Values)

### Pattern: Toggle Visibility

```dart
class ConfigVarValueField extends StatefulWidget {
  final String value;
  
  const ConfigVarValueField({required this.value, super.key});
  
  @override
  State<ConfigVarValueField> createState() => _ConfigVarValueFieldState();
}

class _ConfigVarValueFieldState extends State<ConfigVarValueField> {
  bool _isVisible = false;
  
  String get displayValue {
    if (_isVisible) return widget.value;
    // Mask value (show first 4 chars, rest as dots)
    if (widget.value.length <= 4) return '••••';
    return '${widget.value.substring(0, 4)}${'•' * (widget.value.length - 4)}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            displayValue,
            style: const TextStyle(fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(_isVisible ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _isVisible = !_isVisible;
            });
          },
          tooltip: _isVisible ? 'Hide' : 'Show',
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            // Copy to clipboard
            Clipboard.setData(ClipboardData(text: widget.value));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard')),
            );
          },
          tooltip: 'Copy',
        ),
      ],
    );
  }
}
```

### Security Considerations

- **Default to masked**: Always show values masked by default
- **Explicit reveal**: User must tap to reveal sensitive values
- **Copy functionality**: Allow copying without revealing
- **Auto-hide on navigation**: Reset visibility state when leaving screen

---

## 6. Swipe Actions (flutter_slidable Alternative)

### Research Findings

**Note**: `flutter_slidable` package (v3.0.0) provides swipe-to-reveal actions, but may be overkill for this use case.

### Alternative: Dismissible Widget (Built-in Flutter)

```dart
Dismissible(
  key: Key(configVarKey),
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    child: const Icon(Icons.delete, color: Colors.white),
  ),
  direction: DismissDirection.endToStart,
  confirmDismiss: (direction) async {
    // Show confirmation dialog
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Config Var'),
        content: Text('Delete $configVarKey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  },
  onDismissed: (direction) {
    // Delete config var
    provider.deleteConfigVar(appId, configVarKey);
  },
  child: ListTile(
    title: Text(configVarKey),
    subtitle: ConfigVarValueField(value: configVarValue),
  ),
)
```

### Recommendation

**Use Dismissible for delete action** (swipe left to delete) and **long-press for edit** action instead of swipe actions library.

---

## 7. Data Models to Create

### ConfigVar Model

```dart
/// lib/data/models/config_var.dart
class ConfigVar {
  final String key;
  final String value;
  
  const ConfigVar({
    required this.key,
    required this.value,
  });
  
  factory ConfigVar.fromEntry(MapEntry<String, String> entry) {
    return ConfigVar(
      key: entry.key,
      value: entry.value,
    );
  }
  
  Map<String, String> toJson() {
    return {key: value};
  }
  
  ConfigVar copyWith({
    String? key,
    String? value,
  }) {
    return ConfigVar(
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }
}
```

**Note**: Actually, we may NOT need a dedicated model. Config vars are simple `Map<String, String>` - can work directly with MapEntry.

### Addon Model

```dart
/// lib/data/models/addon.dart
class Addon {
  final String id;
  final String name;
  final String serviceName; // e.g., "heroku-postgresql"
  final String planName;    // e.g., "heroku-postgresql:hobby-dev"
  final String state;       // "provisioned", "provisioning", "deprovisioned"
  final String? webUrl;     // Dashboard URL
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  Addon({
    required this.id,
    required this.name,
    required this.serviceName,
    required this.planName,
    required this.state,
    this.webUrl,
    this.createdAt,
    this.updatedAt,
  });
  
  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id'] as String,
      name: json['name'] as String,
      serviceName: json['addon_service']['name'] as String,
      planName: json['plan']['name'] as String,
      state: json['state'] as String,
      webUrl: json['web_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'addon_service': {'name': serviceName},
      'plan': {'name': planName},
      'state': state,
      'web_url': webUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
```

---

## 8. Repository Methods to Implement

### ConfigRepository

```dart
/// lib/data/repositories/config_repository.dart
class ConfigRepository {
  final HerokuApiService _apiService;
  
  ConfigRepository({required HerokuApiService apiService}) 
      : _apiService = apiService;
  
  /// Get all config vars for an app
  Future<Map<String, String>> getConfigVars(String appId) async {
    try {
      final response = await _apiService.get(ApiConstants.configVars(appId));
      return Map<String, String>.from(response.data as Map);
    } catch (e) {
      throw HerokuException(
        message: 'Failed to fetch config vars',
        originalError: e,
      );
    }
  }
  
  /// Update config vars (also creates new vars)
  Future<Map<String, String>> updateConfigVars(
    String appId,
    Map<String, String?> updates,
  ) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.configVars(appId),
        data: updates,
      );
      return Map<String, String>.from(response.data as Map);
    } catch (e) {
      throw HerokuException(
        message: 'Failed to update config vars',
        originalError: e,
      );
    }
  }
  
  /// Delete a config var (sends key with null value)
  Future<Map<String, String>> deleteConfigVar(
    String appId,
    String key,
  ) async {
    return updateConfigVars(appId, {key: null});
  }
}
```

### AddonRepository

```dart
/// lib/data/repositories/addon_repository.dart
class AddonRepository {
  final HerokuApiService _apiService;
  
  AddonRepository({required HerokuApiService apiService}) 
      : _apiService = apiService;
  
  /// Get all add-ons for an app
  Future<List<Addon>> getAddons(String appId) async {
    try {
      final response = await _apiService.get(ApiConstants.addons(appId));
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Addon.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw HerokuException(
        message: 'Failed to fetch add-ons',
        originalError: e,
      );
    }
  }
  
  /// Get single add-on details
  Future<Addon> getAddon(String appId, String addonId) async {
    try {
      final response = await _apiService.get(ApiConstants.addon(appId, addonId));
      return Addon.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw HerokuException(
        message: 'Failed to fetch add-on details',
        originalError: e,
      );
    }
  }
}
```

---

## 9. Provider Pattern for State Management

### ConfigProvider

```dart
/// lib/presentation/providers/config_provider.dart
class ConfigProvider extends ChangeNotifier {
  final ConfigRepository _repository;
  
  ConfigProvider({required ConfigRepository repository}) 
      : _repository = repository;
  
  Map<String, String> _configVars = {};
  bool _isLoading = false;
  String? _error;
  
  Map<String, String> get configVars => _configVars;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Load config vars for an app
  Future<void> loadConfigVars(String appId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _configVars = await _repository.getConfigVars(appId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _configVars = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Add or update a config var
  Future<void> setConfigVar(String appId, String key, String value) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _configVars = await _repository.updateConfigVars(appId, {key: value});
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Delete a config var
  Future<void> deleteConfigVar(String appId, String key) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _configVars = await _repository.deleteConfigVar(appId, key);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### AddonProvider

```dart
/// lib/presentation/providers/addon_provider.dart
class AddonProvider extends ChangeNotifier {
  final AddonRepository _repository;
  
  AddonProvider({required AddonRepository repository}) 
      : _repository = repository;
  
  List<Addon> _addons = [];
  bool _isLoading = false;
  String? _error;
  
  List<Addon> get addons => _addons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Load add-ons for an app
  Future<void> loadAddons(String appId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _addons = await _repository.getAddons(appId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _addons = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## 10. UI/UX Decisions

### Config Vars Screen Layout

1. **AppBar** with search icon
2. **Search TextField** (always visible or in search delegate)
3. **ListView** of config vars:
   - Each item shows:
     - Key (bold, uppercase)
     - Masked value with show/hide toggle
     - Copy icon
   - Long-press to edit
   - Swipe left (Dismissible) to delete
4. **FAB** (Floating Action Button) to add new config var

### Add-ons Screen Layout

1. **AppBar** with title
2. **ListView** of add-ons:
   - Each item shows:
     - Service name (e.g., "Heroku Postgres")
     - Plan tier (e.g., "Hobby Dev")
     - State badge (provisioned/provisioning)
   - Tap to open dashboard in browser (url_launcher)
3. **Empty state** if no add-ons

### Confirmation Dialogs

- **Delete config var**: Show alert dialog with var name
- **Edit config var**: Show dialog/bottom sheet with pre-filled form
- **Add config var**: Show dialog/bottom sheet with empty form

---

## 11. Dependencies to Add

```yaml
dependencies:
  # Already have:
  # provider, dio, flutter_secure_storage, intl
  
  # New for Phase 3:
  url_launcher: ^6.2.0  # Open add-on dashboards in browser
  
  # Optional (if implementing swipe actions):
  # flutter_slidable: ^3.0.0  # NOT NEEDED - using Dismissible instead
```

---

## 12. Implementation Checklist for Phase 3

### Data Layer
- [ ] Create `Addon` model (`lib/data/models/addon.dart`)
- [ ] Create `ConfigRepository` (`lib/data/repositories/config_repository.dart`)
- [ ] Create `AddonRepository` (`lib/data/repositories/addon_repository.dart`)
- [ ] Add API constants for config vars and add-ons

### Presentation Layer
- [ ] Create `ConfigProvider` (`lib/presentation/providers/config_provider.dart`)
- [ ] Create `AddonProvider` (`lib/presentation/providers/addon_provider.dart`)
- [ ] Register providers in `main.dart`

### UI - Config Vars
- [ ] Create `ConfigVarsScreen` (`lib/presentation/screens/config_vars/config_vars_screen.dart`)
- [ ] Create masked value widget with toggle visibility
- [ ] Implement search/filter functionality
- [ ] Add/Edit config var dialog
- [ ] Delete confirmation with Dismissible
- [ ] Copy to clipboard functionality

### UI - Add-ons
- [ ] Create `AddonsScreen` (`lib/presentation/screens/addons/addons_screen.dart`)
- [ ] Add-on card widget
- [ ] Open dashboard in browser (url_launcher)
- [ ] Empty state widget

### Navigation
- [ ] Add routes for config vars and add-ons screens
- [ ] Link from app details screen

---

## 13. Key Takeaways

1. **Config Vars API is Different**: Single PATCH endpoint for all CRUD operations
2. **Security First**: Always mask sensitive values by default
3. **Simple Data Model**: Config vars don't need complex model (work with Map)
4. **Add-ons are Read-Only**: Focus on viewing and opening dashboards
5. **Use Built-in Widgets**: Dismissible for swipe, TextField for search
6. **Form Validation**: Use Flutter's Form widget with validators
7. **Search Pattern**: Real-time filtering with TextField onChange

---

## Next Steps

Proceed to **Phase 3: Config Vars & Add-ons Implementation** with this research as reference.

**Status**: ✅ Documentation research complete - ready for implementation
