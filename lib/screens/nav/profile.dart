import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../navigation_menu.dart';
import '../login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? email;
  String? name;

  @override
  void initState() {
    super.initState();
    _getInfo();
  }

  Future<void> _getInfo()async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email=prefs.getString('email');
      name=prefs.getString('name');
    });


  }

  // Method to handle the logout API call
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final url = 'http://10.0.2.2:8000/api/logout'; // Replace with your API endpoint
    try {
      final response = await http.post(Uri.parse(url),headers:{ 'Authorization':'Bearer ${prefs.getString('token')}'});
      if (response.statusCode == 200) {
        Get.snackbar('Logout', 'You have successfully logged out.');
        await prefs.clear();
        Get.offAll(() => LoginScreen());
      } else {
        Get.snackbar('Error', 'Failed to logout. Please try again.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred. Please try again.');
    }


  }


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.blue,
        elevation: 2,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => controller.selectedIndex.value = 0,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            SizedBox(height: 16),
            Text(
              '$name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '$email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _logout,

                  child: Text('Logout',style: TextStyle(color: Colors.red),),

                ),
              ],
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 1,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text('Order #${index + 1}'),
                    subtitle: Text('Date: 2023-05-24\nTotal: \$${(index + 1) * 50}.00'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to order details
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy LoginScreen widget to be used in Get.offAll()
