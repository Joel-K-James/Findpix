import 'package:findpix_flutter/ui/smart_widgets/custom_bottom_navbar/bottom_navbar_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'profile_viewmodel.dart';

class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ProfileViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('PROFILE')),
      bottomNavigationBar: const CustomBottomNavBar(index: 2),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            width: 400,
            child: Card(
              color: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircleAvatar(
                      radius: 50.0, // Adjust the radius as needed
                      child: Icon(Icons.person),
                    ),
                  ),
                  if (viewModel.user != null)
                    Column(
                      children: [
                        Text(
                          viewModel.user!.fullName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(viewModel.user!.email)
                      ],
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                child: SizedBox(
                  width: 340,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align children to the left
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: const Text(
                          'Account',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: ListTile(
                          leading: const Icon(
                            Icons
                                .account_circle, // Replace with your logo or icon
                            color: Colors.black, // Icon color
                          ),
                          title: const Text(
                            'Edit profile',
                            style: TextStyle(color: Colors.black), // Text color
                          ),
                          tileColor: const Color.fromARGB(
                              255, 238, 232, 232), // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the border radius
                          ),
                          // Other properties as needed
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: const Text(
                          'Support and About',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: ListTile(
                          leading: const Icon(
                            Icons
                                .card_membership, // Replace with your logo or icon
                            color: Colors.black, // Icon color
                          ),
                          title: const Text(
                            'My subscription',
                            style: TextStyle(color: Colors.black), // Text color
                          ),
                          tileColor: const Color.fromARGB(
                              255, 238, 232, 232), // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the border radius
                          ),
                          // Other properties as needed
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: ListTile(
                          leading: const Icon(
                            Icons.help, // Replace with your logo or icon
                            color: Colors.black, // Icon color
                          ),
                          title: const Text(
                            'Help and support',
                            style: TextStyle(color: Colors.black), // Text color
                          ),
                          tileColor: const Color.fromARGB(
                              255, 238, 232, 232), // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the border radius
                          ),
                          // Other properties as needed
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: ListTile(
                          leading: const Icon(
                            Icons.info, // Replace with your logo or icon
                            color: Colors.black, // Icon color
                          ),
                          title: const Text(
                            'Terms and policies',
                            style: TextStyle(color: Colors.black), // Text color
                          ),
                          tileColor: const Color.fromARGB(
                              255, 238, 232, 232), // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the border radius
                          ),
                          // Other properties as needed
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: const Text(
                          'Cashe and cellular',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: ListTile(
                          leading: const Icon(
                            Icons.delete, // Replace with your logo or icon
                            color: Colors.black, // Icon color
                          ),
                          title: const Text(
                            'Free up space ',
                            style: TextStyle(color: Colors.black), // Text color
                          ),
                          tileColor: const Color.fromARGB(
                              255, 238, 232, 232), // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the border radius
                          ),
                          // Other properties as needed
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: ListTile(
                          leading: const Icon(
                            Icons.graphic_eq, // Replace with your logo or icon
                            color: Colors.black, // Icon color
                          ),
                          title: const Text(
                            'Data saver',
                            style: TextStyle(color: Colors.black), // Text color
                          ),
                          tileColor: const Color.fromARGB(
                              255, 238, 232, 232), // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the border radius
                          ),
                          // Other properties as needed
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: const Text(
                          'Actions ',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: ListTile(
                          leading: const Icon(
                            Icons.flag, // Replace with your logo or icon
                            color: Colors.black, // Icon color
                          ),
                          title: const Text(
                            'Report a problem ',
                            style: TextStyle(color: Colors.black), // Text color
                          ),
                          tileColor: const Color.fromARGB(
                              255, 238, 232, 232), // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the border radius
                          ),
                          // Other properties as needed
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: ListTile(
                          leading: const Icon(
                            Icons.group, // Replace with your logo or icon
                            color: Colors.black, // Icon color
                          ),
                          title: const Text(
                            'Add',
                            style: TextStyle(color: Colors.black), // Text color
                          ),
                          tileColor: const Color.fromARGB(
                              255, 238, 232, 232), // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the border radius
                          ),
                          // Other properties as needed
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: ListTile(
                          onTap: viewModel.logout,
                          leading: const Icon(
                            Icons.logout, // Replace with your logo or icon
                            color: Colors.black, // Icon color
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.black), // Text color
                          ),
                          tileColor: const Color.fromARGB(
                              255, 238, 232, 232), // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the border radius
                          ),
                          // Other properties as needed
                        ),
                      ),

                      // Add more ListTiles or other widgets as needed
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  ProfileViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ProfileViewModel();
}
