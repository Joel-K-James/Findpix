import 'package:findpix_flutter/app/app.router.dart';
import 'package:findpix_flutter/models/appuser.dart';
import 'package:findpix_flutter/services/user_service.dart';
import 'package:stacked/stacked.dart';

import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';

class ProfileViewModel extends BaseViewModel {
  final _userService = locator<UserService>();
  final NavigationService _navigationService = locator<NavigationService>();

  logout() {
    _userService.logout();
    _navigationService.navigateToLoginRegisterView();
  }

  AppUser? get user => _userService.user;
}
