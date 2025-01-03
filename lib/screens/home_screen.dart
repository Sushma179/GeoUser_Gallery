import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geouser_gallery/controllers/user_controller.dart';
import 'package:geouser_gallery/widgets/user_card.dart';
import 'package:geouser_gallery/services/location_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String location = "Loading location...";
  String address = "Loading address...";
  final UserController userController = Get.put(UserController());
  late AnimationController _animationController;
  late Box<String> imageBox;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeHive();
    _requestPermissions();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _getLocation();
  }

  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    imageBox = await Hive.openBox<String>('user_images');
  }

  Future<void> _requestPermissions() async {
    await Future.wait([Permission.locationWhenInUse.request(), Permission.camera.request(), Permission.photos.request()]);
  }

  Future<void> _getLocation() async {
    Map<String, String> locationData = await LocationService().getCurrentLocation();
    setState(() {
      location = locationData['location'] ?? "Location unavailable";
      address = locationData['address'] ?? "Address unavailable";
    });
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
      appBar: AppBar(title: const Text("Geo User Gallery"), backgroundColor: Colors.teal),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(child: Text("Current Location: $location", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.place, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(child: Text("Address: $address", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: userController.users.length,
                itemBuilder: (context, index) {
                  var user = userController.users[index];
                  String? localImage = imageBox.get(user.id.toString());
                  _animationController.forward();
                  return FadeTransition(
                    opacity: CurvedAnimation(parent: _animationController, curve: const Interval(0, 1, curve: Curves.easeInOut)),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.2, 1, curve: Curves.easeInOut),
                      )),
                      child: UserCard(
                        avatarUrl: localImage ?? user.avatar,
                        fullName: "${user.firstName} ${user.lastName}",
                        email: user.email,
                        onUploadImage: () => _showImageSourceSelection(context, user.id.toString()),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
