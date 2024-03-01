import 'package:findpix_flutter/ui/smart_widgets/custom_bottom_navbar/bottom_navbar_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:findpix_flutter/ui/common/ui_helpers.dart';

import '../../smart_widgets/is_online/online_status.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavBar(index: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              verticalSpaceLarge,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 70,
                  ),
                   const Column(
                    children: [
                      IsOnlineWidget(),
                      Text('Battery: 80%'),
                    ],
                  )
                ],
              ),
              if (viewModel.user != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    height: 100,
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hi Good Morning',
                          style: TextStyle(fontSize: 30),
                        ),
                        Row(
                          children: [
                            Text(
                              viewModel.user!.fullName,
                              style: const TextStyle(fontSize: 30),
                            ),
                            const Text(
                              '👋',
                              style: TextStyle(fontSize: 30),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter your search',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  // Adjust the height of each Card
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 253, 253, 253),
                    // Adjust the border radius
                  ),
                  child: ListView(
                    children: [
                      ListItemCard(
                        text: "REAL TIME\nLOCATION",
                        image: "assets/Rectangle.png",
                        isLeft: false,
                        color: 'green',
                        onTap: viewModel.openRealTime,
                      ),
                      ListItemCard(
                        text: "CHILD ACTIVITY",
                        image: "assets/Rectangle1.png",
                        isLeft: true,
                        color: 'green',
                        onTap: viewModel.openChildActivity,
                      ),
                      ListItemCard(
                        text: "DEVICE SETTINGS",
                        image: "assets/Rectangle2.png",
                        isLeft: false,
                        color: 'red',
                        onTap: viewModel.openDeviceSettings,
                      ),
                      ListItemCard(
                        text: "EMERGENCY\nHELPLINE",
                        image: "assets/Rectangle3.png",
                        isLeft: true,
                        color: 'red',
                        onTap: viewModel.openEmergency,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
}

class ListItemCard extends StatelessWidget {
  final String text;
  final String image;
  final bool isLeft;
  final String color;
  final VoidCallback onTap;
  const ListItemCard({
    super.key,
    required this.text,
    required this.image,
    required this.isLeft,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Adjust the border radius
        ),
        // Background color of each ListTile
        child: Row(
          children: [
            if (isLeft)
              SizedBox(
                  height: 150, width: 140, child: Center(child: Text(text))),
            SizedBox(
              height: 150,
              width: 162,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  image, // Adjust the image path
                  fit: BoxFit
                      .cover, // Adjust the fit of the image within the box
                ),
              ),
            ),
            if (!isLeft)
              SizedBox(
                  height: 150,
                  width: 140,
                  child: Center(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ))
          ],
        ),
      ),
    );
  }
}
