import 'dart:io'; 
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String avatarUrl;
  final String fullName;
  final String email;
  final Function() onUploadImage;

  const UserCard({super.key, 
    required this.avatarUrl,
    required this.fullName,
    required this.email,
    required this.onUploadImage,
  });

  @override
  Widget build(BuildContext context) {
    return 
       ListTile(
        leading: ClipOval(
          child: avatarUrl.startsWith('http') // Check if it's a URL
              ? Image.network(
                  avatarUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.person, size: 50, color: Colors.grey),
                )
              : Image.file(
                  File(avatarUrl), 
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.person, size: 50, color: Colors.grey),
                ),
        ),
        title: Text(
          fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          email,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.teal),
          onPressed: onUploadImage,
        ),
      );
    // );
  }
}
