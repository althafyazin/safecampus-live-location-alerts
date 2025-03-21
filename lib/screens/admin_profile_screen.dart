import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String adminName = 'Admin User';
  String adminEmail = 'admin@example.com';
  String adminPhone = '+1234567890';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _updateProfilePicture() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() {
                      _profileImage = File(photo.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _profileImage = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _updateProfilePicture,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile Picture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.green),
                title: const Text('Name'),
                subtitle: Text(adminName),
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.green),
                title: const Text('Email'),
                subtitle: Text(adminEmail),
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Phone'),
                subtitle: Text(adminPhone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
