import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:antiragging1/models/student.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _admissionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Box<Student> studentBox = Hive.box<Student>('students');

  @override
  Widget build(BuildContext context) {
    void validateAndSubmit() {
      if (_formKey.currentState!.validate()) {
        if (_passwordController.text != _confirmpasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Passwords do not match!")),
          );
          return;
        }

        // Check if admission number already exists
        if (studentBox.values.any((student) =>
            student.admissionNumber == _admissionController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Admission number already registered!")),
          );
          return;
        }

        // Save new student
        final newStudent = Student(
          name: _nameController.text,
          admissionNumber: _admissionController.text,
          password: _passwordController.text,
          phoneNumber: _phoneController.text,
        );

        studentBox.add(newStudent);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful!")),
        );
        Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Create Your Account",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Your Name",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.person, color: Colors.blueGrey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field shouldn't be empty!";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _admissionController,
                    decoration: InputDecoration(
                      labelText: "Admission Number",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.badge, color: Colors.blueGrey),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field shouldn't be empty!";
                      } else if (value.length != 8) {
                        return "Admission number is incorrect";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.phone, color: Colors.blueGrey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Phone number is required";
                      }
                      if (value.length != 10) {
                        return "Enter valid 10-digit phone number";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Create a New Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.lock, color: Colors.blueGrey),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field shouldn't be empty!";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmpasswordController,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon:
                          Icon(Icons.lock_outline, color: Colors.blueGrey),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field shouldn't be empty!";
                      } else if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: validateAndSubmit,
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Sign Up", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
