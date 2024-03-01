import 'package:findpix_flutter/app/app.locator.dart';
import 'package:findpix_flutter/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.logger.dart';

class BottomNavbarViewmodel extends BaseViewModel {
  final log = getLogger('BottomNavbarViewmodel');

  final _navigationService = locator<NavigationService>();

  void onTap(int index) {
    log.i("Index: $index");
    if (index == 0) {
      _navigationService.navigateToHomeView();
    } else if (index == 1) {
      _navigationService.navigateToNotificationView();
    } else if (index == 2) {
      _navigationService.navigateToProfileView();
    }
  }
}
