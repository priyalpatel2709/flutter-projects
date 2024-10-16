import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../constant/constants.dart';
import '../../models/stations_details_model.dart';
import '../../providers/appsettings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingStateProvider>(
      builder: (context, appSettings, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Settings',
              style: TextStyle(
                fontSize: 22,
                color: KdsConst.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: KdsConst.mainColor,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 8 + appSettings.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context,
                    'App Settings',
                    Column(
                      children: [
                        _selectStoreDropDown(appSettings),

                        _buildSliderSetting(
                          'Font Size',
                          appSettings.fontSize,
                          10.0,
                          30.0,
                          appSettings.changeFontSize,
                          appSettings,
                        ),
                        _buildSliderSetting(
                          'Padding',
                          appSettings.padding,
                          0.0,
                          20.0,
                          appSettings.changePadding,
                          appSettings,
                        ),
                        _buildSliderSetting(
                          'Grid Columns',
                          appSettings.crossAxisCount.toDouble(),
                          1.0,
                          8.0,
                          (value) =>
                              appSettings.changeCrossAxisCount(value.toInt()),
                          appSettings,
                          divisions: 7,
                        ),
                        _buildSliderSetting(
                          'App Bar Logo Size',
                          appSettings.appBarLogoSize,
                          60.0,
                          100.0,
                          appSettings.changeAppBarLogoSize,
                          appSettings,
                        ),
                        _buildPaginationToggle(appSettings),
                        Visibility(
                          visible: appSettings.showPagination,
                          child: _buildSliderSetting(
                            'Max Card In One Page',
                            appSettings.itemsPerPage.toDouble(),
                            1.0,
                            10.0,
                            (value) =>
                                appSettings.changeItemsPerPage(value.toInt()),
                            appSettings,
                            divisions: 10,
                          ),
                        ),
                        // _buildButtonStyle(appSettings),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    context,
                    'Order Settings',
                    Column(
                      children: [
                        _buildRadioGroup(
                          appSettings,
                          orderTypes: [
                            OrderTypeOption(KdsConst.dineIn, 'Dine In'),
                            OrderTypeOption(
                                KdsConst.pickup, 'Delivery - Pick Up'),
                            OrderTypeOption(KdsConst.allFilter, 'All Orders'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    context,
                    'Page Selection',
                    Column(
                      children: [
                        _buildRadioGroup(
                          appSettings,
                          pageOptions: [
                            PageOption(0, KdsConst.multiStationScreen),
                            PageOption(1, KdsConst.singleStationScreen),
                            PageOption(2, KdsConst.expoScreen),
                            PageOption(3, KdsConst.fontDeskScreen),
                            PageOption(4, KdsConst.scheduleScreen),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    context,
                    'View Settings',
                    _buildViewSelection(appSettings),
                  ),
                  // const Center(child: Text('Release Date: 30/09/2024'))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _selectStoreDropDown(AppSettingStateProvider appSettings) {
    return Row(
      children: [
        Text('Select Store:', style: TextStyle(fontSize: appSettings.fontSize)),
        const SizedBox(
          width: 10.0,
        ),
        DropdownButton<int>(
          value: appSettings.storeId,
          items: List.generate(10, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text('${index + 1}'),
            );
          }),
          onChanged: (int? newValue) {
            appSettings.changeStoreId(newValue ?? 1);
          },
        ),
      ],
    );
  }

  // Helper method for wrapping sections in a Card-like container
  Widget _buildSectionCard(BuildContext context, String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: KdsConst.mainColor, width: .5),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        elevation: 0.0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: KdsConst.black,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              content,
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build Slider setting
  Widget _buildSliderSetting(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    AppSettingStateProvider appSettings, {
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: TextStyle(fontSize: appSettings.fontSize),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: KdsConst.mainColor,
          inactiveColor: KdsConst.grey,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Refactored View Selection
  Widget _buildViewSelection(AppSettingStateProvider appSettings) {
    const views = [KdsConst.grid, KdsConst.fixedGrid, KdsConst.list];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...views.map((view) => RadioListTile<String>(
              title:
                  Text(view, style: TextStyle(fontSize: appSettings.fontSize)),
              value: view,
              groupValue: appSettings.selectedView,
              onChanged: (value) => appSettings.changeView(value!),
              activeColor: KdsConst.black,
              dense: true,
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  // Refactored Radio Group for both OrderType and PageSelection
  Widget _buildRadioGroup(AppSettingStateProvider appSettings,
      {List<OrderTypeOption>? orderTypes, List<PageOption>? pageOptions}) {
    final options = orderTypes ?? pageOptions;

    return Column(
      children: options!.map((option) {
        if (option is OrderTypeOption) {
          return RadioListTile<String>(
            title: Text(
              option.title,
              style: TextStyle(fontSize: appSettings.fontSize),
            ),
            value: option.value,
            groupValue: appSettings.selectedOrderType,
            onChanged: (value) => appSettings.changeSelectedOrderType(value!),
            dense: true,
            activeColor: KdsConst.black,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.0 + appSettings.padding,
              vertical: 4.0,
            ),
          );
        } else if (option is PageOption) {
          return RadioListTile<int>(
            title: Text(
              option.title,
              style: TextStyle(fontSize: appSettings.fontSize),
            ),
            value: option.index,
            groupValue: appSettings.selectedIndexPage,
            onChanged: (value) => appSettings.changeSelectedIndexPage(value!),
            dense: true,
            activeColor: KdsConst.black,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.0 + appSettings.padding,
              vertical: 4.0,
            ),
          );
        } else {
          return const SizedBox(); // If option is neither, return an empty widget
        }
      }).toList(),
    );
  }

  // Refactored Pagination Toggle
  Widget _buildPaginationToggle(AppSettingStateProvider appSettings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Show Pagination',
          style: TextStyle(fontSize: appSettings.fontSize),
        ),
        Switch(
          value: appSettings.showPagination,
          onChanged: appSettings.changeShowPagination,
          activeColor: KdsConst.black,
          activeTrackColor: KdsConst.mainColor,
          inactiveThumbColor: KdsConst.white,
          inactiveTrackColor: KdsConst.grey,
        ),
      ],
    );
  }

  Widget _buildButtonStyle(AppSettingStateProvider appSettings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Increment Button Size',
          style: TextStyle(fontSize: appSettings.fontSize),
        ),
        Switch(
          value: appSettings.isBigButton,
          onChanged: appSettings.changeButtonStyle,
          activeColor: KdsConst.black,
          activeTrackColor: KdsConst.mainColor,
          inactiveThumbColor: KdsConst.white,
          inactiveTrackColor: KdsConst.grey,
        ),
      ],
    );
  }
}
