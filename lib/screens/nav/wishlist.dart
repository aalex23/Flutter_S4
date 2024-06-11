import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../navigation_menu.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({super.key});

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  List<Map<String, dynamic>> wish = [];
  List<Map<String, dynamic>> laptops = [];
  List<Map<String, dynamic>> cpu = [];
  List<Map<String, dynamic>> gpu = [];

  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchItem();
  }

  Future<void> fetchItem() async {
    final laptopResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/laptops'));
    final cpuResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/cpus'));
    final gpuResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/gpus'));
    final wishResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/wishlists'));
    if (wishResponse.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        laptops= List<Map<String, dynamic>>.from(json.decode(laptopResponse.body));
        cpu = List<Map<String, dynamic>>.from(json.decode(cpuResponse.body));
        gpu = List<Map<String, dynamic>>.from(json.decode(gpuResponse.body));
        wish = List<Map<String, dynamic>>.from(json.decode(wishResponse.body)).where((item) {
          return (item['id_user'] == prefs.getInt('id'));
        }).toList();
        isLoaded = true;
      });
    } else {
      Get.snackbar('Error', 'Failed to load wishlist items.');
    }
  }

  Future<void> deleteItem(int id) async {
    final response = await http.delete(Uri.parse('http://10.0.2.2:8000/api/wishlists/$id'));
    if (response.statusCode == 200) {
      Get.snackbar('Success', 'Produit supprimer.');
      fetchItem();  // Refresh the list after deleting an item
    } else {
      Get.snackbar('Error', 'Failed to delete item.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());


    return Scaffold(
      appBar: AppBar(
        title: Text("Wishlist"),
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
      body: Visibility(
        visible: isLoaded,
        child: ListView.builder(
          itemCount: wish.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                // Add any desired action on item tap
              },
              borderRadius: BorderRadius.circular(25),
              child: Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if(wish[index]['type_product']==1)
                        Image.network(
                          laptops[wish[index]['id_product']-1]['img_laptop'],
                          width: 90,
                          height: 90,
                          fit: BoxFit.scaleDown,
                        ),
                      if(wish[index]['type_product']==1)
                        SizedBox(width: 16.0),
                      if(wish[index]['type_product']==1)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                laptops[wish[index]['id_product']-1]['nom_laptop'],

                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(laptops[wish[index]['id_product']-1]['nom_laptop']),
                            ],
                          ),
                        ),
                      if(wish[index]['type_product']==1)
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteItem(wish[index]['id_wishlist']),
                        ),

                      if(wish[index]['type_product']==2)
                        Image.network(
                          cpu[wish[index]['id_product']-1]['img_cpu'],
                          width: 90,
                          height: 90,
                          fit: BoxFit.scaleDown,
                        ),
                      if(wish[index]['type_product']==2)
                        SizedBox(width: 16.0),
                      if(wish[index]['type_product']==2)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cpu[wish[index]['id_product']-1]['nom_cpu'],

                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(cpu[wish[index]['id_product']-1]['nom_cpu']),
                            ],
                          ),
                        ),
                      if(wish[index]['type_product']==2)
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteItem(wish[index]['id_wishlist']),
                        ),

                      if(wish[index]['type_product']==3)
                        Image.network(
                          gpu[wish[index]['id_product']-1]['img_gpu'],
                          width: 90,
                          height: 90,
                          fit: BoxFit.scaleDown,
                        ),
                      if(wish[index]['type_product']==3)
                        SizedBox(width: 16.0),
                      if(wish[index]['type_product']==3)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gpu[wish[index]['id_product']-1]['nom_gpu'],

                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(gpu[wish[index]['id_product']-1]['nom_gpu']),
                            ],
                          ),
                        ),
                      if(wish[index]['type_product']==3)
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteItem(wish[index]['id_wishlist']),
                        ),

                    ],
                  ),
                ),
              ),
            );
          },
        ),
        replacement: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
