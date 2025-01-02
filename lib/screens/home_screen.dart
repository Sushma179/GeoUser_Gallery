import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geouser_gallery/controllers/user_controller.dart';
import 'package:geouser_gallery/widgets/user_card.dart';
import 'package:geouser_gallery/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String location = "Loading location...";
  final UserController userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _getLocation() async {
    String currentLocation = await LocationService().getCurrentLocation();
    setState(() {
      location = currentLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Geo User Gallery")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Current Location: $location", style: TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: Obx(
              () {
                return ListView.builder(
                  itemCount: userController.users.length,
                  itemBuilder: (context, index) {
                    var user = userController.users[index];
                    return UserCard(
                      avatarUrl: user.avatar,
                      fullName: "${user.firstName} ${user.lastName}",
                      email: user.email,
                      onUploadImage: () async {
                        // Implement image upload functionality here
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
