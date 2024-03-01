import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'device_settings_viewmodel.dart';

class DeviceSettingsView extends StackedView<DeviceSettingsViewModel> {
  const DeviceSettingsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DeviceSettingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEVICE SETTINGS'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 500,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Child Name", style: TextStyle(fontSize: 16)),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Enter Child Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Text("Emergency Contact", style: TextStyle(fontSize: 16)),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Enter Emergency Contact",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("SOS Snooze", style: TextStyle(fontSize: 16)),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Enter SOS Snooze",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                      onPressed: () {}, child: const Text('Save changes')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  DeviceSettingsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DeviceSettingsViewModel();
}
