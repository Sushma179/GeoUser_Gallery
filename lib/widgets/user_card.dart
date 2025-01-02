import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserCard extends StatelessWidget {
  final String avatarUrl;
  final String fullName;
  final String email;
  final Function() onUploadImage;

  UserCard({required this.avatarUrl, required this.fullName, required this.email, required this.onUploadImage});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(avatarUrl),
        ),
        title: Text(fullName),
        subtitle: Text(email),
        trailing: IconButton(
          icon: Icon(Icons.camera_alt),
          onPressed: onUploadImage,
        ),
      ),
    );
  }
}
