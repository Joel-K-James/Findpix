import 'package:findpix_flutter/app/app.bottomsheets.dart';
import 'package:findpix_flutter/app/app.dialogs.dart';
import 'package:findpix_flutter/app/app.locator.dart';
import 'package:findpix_flutter/app/app.router.dart';
import 'package:findpix_flutter/services/database_service.dart';
import 'package:findpix_flutter/services/user_service.dart';
import 'package:findpix_flutter/ui/common/app_strings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../models/appuser.dart';
import '../../../models/device.dart';

class HomeViewModel extends ReactiveViewModel {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  final _databaseService = locator<DatabaseService>();

  DeviceReading? get node => _databaseService.node;

  @override
  List<ListenableServiceMixin> get listenableServices =>
      [_databaseService];


  String get counterLabel => 'Counter is: $_counter';

  int _counter = 0;
  AppUser? get user => _userService.user;
  void incrementCounter() {
    _counter++;
    rebuildUi();
  }

  void showDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Stacked Rocks!',
      description: 'Give stacked $_counter stars on Github',
    );
  }

  void showBottomSheet() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }

  void openRealTime() {
    _navigationService.navigateToRealTimeView();
  }

  void openChildActivity() {
    _navigationService.navigateToChildActivityView();
  }

  void openDeviceSettings() {
    _navigationService.navigateToDeviceSettingsView();
  }

  void openEmergency() {
    _navigationService.navigateToEmergencyView();
  }
}
