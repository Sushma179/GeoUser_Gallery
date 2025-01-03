import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geouser_gallery/controllers/user_controller.dart';
import 'package:geouser_gallery/widgets/user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String location = 'Null, Press Button';
  String address = 'Searching for address...';
  final UserController userController = Get.put(UserController());
  late AnimationController _animationController;
  late Box<String> imageBox;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeHive();
    _getLocationAndAddress();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  // ignore: non_constant_identifier_names
  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    });
  }

  Future<void> _getLocationAndAddress() async {
    try {
      Position position = await _getGeoLocationPosition();
      setState(() {
        location = 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
      });
      await GetAddressFromLatLong(position);
    } catch (e) {
      setState(() {
        location = 'Location not available';
        address = 'Address not available';
      });
    }
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // ignore: deprecated_member_use
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    imageBox = await Hive.openBox<String>('user_images');
  }

  Future<void> _pickImage(ImageSource source, String userId) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      await imageBox.put(userId, pickedFile.path);
      setState(() {});
    }
  }

  void _showImageSourceSelection(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageOption(Icons.camera_alt, "Take a Photo", () => _pickImage(ImageSource.camera, userId)),
            _buildImageOption(Icons.image, "Choose from Gallery", () => _pickImage(ImageSource.gallery, userId)),
          ],
        ),
      ),
    );
  }

  ListTile _buildImageOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, 
      body: Padding(
        padding:  EdgeInsets.fromLTRB(0,50,0,0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coordinates',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 16), 
                  Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(70)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)],
                ),
                child: Obx(() {
                  return ListView.builder(
                    itemCount: userController.users.length,
                    itemBuilder: (context, index) {
                      var user = userController.users[index];
                      String? localImage = imageBox.get(user.id.toString());
                      _animationController.forward();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: UserCard(
                          avatarUrl: localImage ?? user.avatar,
                          fullName: "${user.firstName} ${user.lastName}",
                          email: user.email,
                          onUploadImage: () => _showImageSourceSelection(context, user.id.toString()),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
