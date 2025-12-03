import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Appearance'),
            _buildDarkModeToggle(),
            SizedBox(height: 24),
            _buildSectionHeader('Preferences'),
            _buildSettingsTile(
              icon: Icons.location_on,
              title: 'Search Radius',
              subtitle: settingsProvider.searchRadiusDisplay,
              onTap: () => _showRadiusPicker(context, settingsProvider),
            ),
            _buildSettingsTile(
              icon: Icons.attach_money,
              title: 'Price Range',
              subtitle: settingsProvider.priceRangeDisplay,
              onTap: () => _showPriceRangePicker(context, settingsProvider),
            ),
            _buildSettingsTile(
              icon: Icons.restaurant_menu,
              title: 'Cuisine Preferences',
              subtitle: settingsProvider.cuisineDisplay,
              onTap: () => _showCuisinePicker(context, settingsProvider),
            ),
            SizedBox(height: 24),
            if (settingsProvider.hasActiveFilters)
              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: ElevatedButton.icon(
                  onPressed: () {
                    settingsProvider.resetFilters();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Filters reset to defaults'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Reset Filters'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            _buildSectionHeader('About'),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0',
              onTap: null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: SwitchListTile(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.setDarkMode(value);
            },
            title: Text(
              'Dark Mode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              themeProvider.isDarkMode
                  ? 'Dark theme enabled'
                  : 'Light theme enabled',
            ),
            secondary: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.red,
              ),
            ),
            activeTrackColor: Color(0xFF4ECDC4),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.red),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
        trailing: onTap != null
            ? Icon(Icons.chevron_right, color: Colors.grey)
            : null,
        onTap: onTap,
        enabled: onTap != null,
      ),
    );
  }

  void _showRadiusPicker(BuildContext context, SettingsProvider provider) {
    final radiusOptions = [
      {'label': '1 km', 'value': 1000},
      {'label': '5 km', 'value': 5000},
      {'label': '10 km', 'value': 10000},
      {'label': '25 km', 'value': 25000},
      {'label': '50 km', 'value': 50000},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Radius'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: radiusOptions.map((option) {
            final isSelected = provider.searchRadius == option['value'];
            return RadioListTile<int>(
              title: Text(option['label'] as String),
              value: option['value'] as int,
              groupValue: provider.searchRadius,
              activeColor: Color(0xFF4ECDC4),
              selected: isSelected,
              onChanged: (value) {
                if (value != null) {
                  provider.setSearchRadius(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPriceRangePicker(BuildContext context, SettingsProvider provider) {
    int? tempMinPrice = provider.minPrice;
    int? tempMaxPrice = provider.maxPrice;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Price Range'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minimum Price',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _priceChip('Any', null, tempMinPrice, (value) {
                      setState(() => tempMinPrice = value);
                    }),
                    _priceChip('\$', 1, tempMinPrice, (value) {
                      setState(() => tempMinPrice = value);
                    }),
                    _priceChip('\$\$', 2, tempMinPrice, (value) {
                      setState(() => tempMinPrice = value);
                    }),
                    _priceChip('\$\$\$', 3, tempMinPrice, (value) {
                      setState(() => tempMinPrice = value);
                    }),
                    _priceChip('\$\$\$\$', 4, tempMinPrice, (value) {
                      setState(() => tempMinPrice = value);
                    }),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Maximum Price',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _priceChip('Any', null, tempMaxPrice, (value) {
                      setState(() => tempMaxPrice = value);
                    }),
                    _priceChip('\$', 1, tempMaxPrice, (value) {
                      setState(() => tempMaxPrice = value);
                    }),
                    _priceChip('\$\$', 2, tempMaxPrice, (value) {
                      setState(() => tempMaxPrice = value);
                    }),
                    _priceChip('\$\$\$', 3, tempMaxPrice, (value) {
                      setState(() => tempMaxPrice = value);
                    }),
                    _priceChip('\$\$\$\$', 4, tempMaxPrice, (value) {
                      setState(() => tempMaxPrice = value);
                    }),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.setPriceRange(
                    minPrice: tempMinPrice,
                    maxPrice: tempMaxPrice,
                  );
                  Navigator.pop(context);
                },
                child: Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _priceChip(
    String label,
    int? value,
    int? selectedValue,
    Function(int?) onSelected,
  ) {
    final isSelected = value == selectedValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: Color(0xFF4ECDC4).withValues(alpha: 0.3),
      checkmarkColor: Color(0xFF4ECDC4),
    );
  }

  void _showCuisinePicker(BuildContext context, SettingsProvider provider) {
    final cuisineTypes = [
      'Italian',
      'Chinese',
      'Japanese',
      'Mexican',
      'Indian',
      'Thai',
      'American',
      'French',
      'Mediterranean',
      'Korean',
      'Vietnamese',
      'Greek',
      'Spanish',
      'Middle Eastern',
      'Brazilian',
      'Cafe',
      'Bar',
      'Bakery',
      'Fast Food',
      'Seafood',
      'Steakhouse',
      'Vegetarian',
      'Vegan',
      'Pizza',
      'Burger',
      'Sushi',
      'BBQ',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cuisine Preferences'),
                if (provider.selectedCuisines.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        provider.clearCuisines();
                      });
                    },
                    child: Text('Clear All'),
                  ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: cuisineTypes.map((cuisine) {
                  final isSelected = provider.selectedCuisines.contains(cuisine);
                  return CheckboxListTile(
                    title: Text(cuisine),
                    value: isSelected,
                    activeColor: Color(0xFF4ECDC4),
                    onChanged: (value) {
                      setState(() {
                        provider.toggleCuisine(cuisine);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }
}
