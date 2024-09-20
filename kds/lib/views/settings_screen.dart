import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/appsettings_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appSettingStateProvider =
        Provider.of<AppSettingStateProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Font Size Slider
          Text(
              'Font Size: ${appSettingStateProvider.fontSize.toStringAsFixed(1)}'),
          Slider(
            value: appSettingStateProvider.fontSize,
            min: 10.0,
            max: 30.0,
            onChanged: (value) {
              appSettingStateProvider.changeFontSize(value);
            },
          ),
          const SizedBox(height: 16),

          // Padding Slider
          Text(
              'Padding: ${appSettingStateProvider.padding.toStringAsFixed(1)}'),
          Slider(
            value: appSettingStateProvider.padding,
            min: 0.0,
            max: 20.0,
            onChanged: (value) {
              appSettingStateProvider.changePadding(value);
            },
          ),
          const SizedBox(height: 16),

          // Cross Axis Count
          Text('Grid Columns: ${appSettingStateProvider.crossAxisCount}'),
          Slider(
            value: appSettingStateProvider.crossAxisCount.toDouble(),
            min: 1.0,
            max: 8,
            divisions: 8,
            onChanged: (value) {
              appSettingStateProvider.changeCrossAxisCount(value.toInt());
            },
          ),
        ],
      ),
    );
  }
}
