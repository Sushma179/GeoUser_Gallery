import 'package:get/get.dart';
import 'package:geouser_gallery/models/user.dart';
import 'package:geouser_gallery/services/user_service.dart';

class UserController extends GetxController {
  var users = <User>[].obs;

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  void fetchUsers() async {
    try {
      List<User> fetchedUsers = await UserService().fetchUsers();
      users.assignAll(fetchedUsers);
    // ignore: empty_catches
    } catch (e) {
    }
  }
}
