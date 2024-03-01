import 'package:findpix_flutter/ui/smart_widgets/custom_bottom_navbar/bottom_navbar_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class CustomBottomNavBar extends StackedView<BottomNavbarViewmodel> {
  final int index;
  const CustomBottomNavBar({Key? key, required this.index}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    BottomNavbarViewmodel viewModel,
    Widget? child,
  ) {
    return BottomNavigationBar(
      onTap: viewModel.onTap,
      currentIndex: index,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.alarm),
          label: 'notified',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  @override
  BottomNavbarViewmodel viewModelBuilder(
    BuildContext context,
  ) =>
      BottomNavbarViewmodel();
}
