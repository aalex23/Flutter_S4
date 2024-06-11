import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:projet_flutter_propre/screens/product_grid.dart';
import 'package:projet_flutter_propre/screens/view_more.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

import '../../utils/constants/sizes.dart';
import '../../utils/helpers/device_utility.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> laptops = [];
  List<Map<String, dynamic>> marques = [];
  List<Map<String, dynamic>> cpus = [];
  List<Map<String, dynamic>> gpus = [];
  List<Map<String, dynamic>> produts = [];
  List<Map<String, dynamic>> promo = [];
  List<Map<String, dynamic>> wish = [];

  List<List<int>> _listOfLists = [];

  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchItem();
    _loadListOfLists();
  }

  Future<void> fetchItem() async {
    // Remplacez les URL par celles de votre propre API
    final laptopsResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/laptops'));
    final marquesResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/marques'));
    final cpusResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/cpus'));
    final gpusResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/gpus'));
    final wishResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/wishlists'));
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      laptops = List<Map<String, dynamic>>.from(json.decode(laptopsResponse.body));
      marques = List<Map<String, dynamic>>.from(json.decode(marquesResponse.body));
      cpus = List<Map<String, dynamic>>.from(json.decode(cpusResponse.body));
      gpus = List<Map<String, dynamic>>.from(json.decode(gpusResponse.body));
      wish = List<Map<String, dynamic>>.from(json.decode(wishResponse.body))
          .where((item) {
        return (item['id_user'] == prefs.getInt('id'));
      }).toList();
      produts = laptops + cpus + gpus;
      produts.shuffle(Random());

      promo = produts.where((item) {
        return !(item['promo_laptop'] == 0 ||
            item['promo_cpu'] == 0 ||
            item['promo_gpu'] == 0);
      }).toList();

      isLoaded = true;
    });
  }

  Future<void> addWish(int id_user, int id_product, int type_product) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/wishlists'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_user': id_user,
        'id_product': id_product,
        'type_product': type_product
      }),
    );
  }

  Future<void> _loadListOfLists() async {
    List<List<int>> loadedList = await StorageHelper.getListOfLists();
    setState(() {
      _listOfLists = loadedList;
    });
  }

  Future<void> _saveListOfLists() async {
    await StorageHelper.saveListOfLists(_listOfLists);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset('images/logos/logo1.png',height: 60,),
        ),
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Visibility(
        visible: isLoaded,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopCarousel(),
              if (laptops.isNotEmpty)
                buildSectionLaptops('Nos meilleurs laptops', laptops),
              if (produts.isNotEmpty)
                buildSectionPourVous('Pour Vous', produts, marques),
              if (promo.isNotEmpty)
                buildSectionPromo('Bonnes affaires dans votre sélection', promo, marques),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nos catégories',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: () => Get.to(() => ProductGrid(
                                    list: laptops,
                                    text: '',
                                    marques: marques,
                                    title: 'laptops',
                                  )),
                              borderRadius: BorderRadius.circular(15),
                              child: CircleAvatar(
                                radius: 40,
                                child: Icon(Icons.phone_android, size: 40),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text('Laptops'),
                          ],
                        ),
                        Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () => Get.to(() => ProductGrid(
                                    list: gpus,
                                    text: '',
                                    marques: marques,
                                    title: 'gpus',
                                  )),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    AssetImage('images/gpus/logo_gpu.png'),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text('Gpus'),
                          ],
                        ),
                        Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () => Get.to(() => ProductGrid(
                                    list: cpus,
                                    text: '',
                                    marques: marques,
                                    title: 'Cpus',
                                  )),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    AssetImage('images/cpus/logo_cpu.png'),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text('Cpus'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              ButtomCarousel(marques: marques),
              Padding(padding: EdgeInsets.only(bottom: 50))
            ],
          ),
        ),
        replacement: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget buildSectionLaptops(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InkWell(
                  child: Text('Plus', style: TextStyle(color: Colors.blue)),
                  onTap: () => Get.to(() => ProductGrid(
                        list: laptops,
                        text: '',
                        marques: marques,
                        title: 'laptops',
                      )),
                  borderRadius: BorderRadius.circular(10)),
            ],
          ),
        ),
        Container(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => Get.to(() => ViewMore()),
                borderRadius: BorderRadius.circular(20),
                child: Card(
                  shadowColor: Colors.black,
                  margin: EdgeInsets.all(8),
                  child: Stack(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          items[index]['img_laptop']!,
                          width: 130,
                          height: 130,
                          fit: BoxFit.scaleDown,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(items[index]['nom_laptop']!,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text(items[index]['model_laptop']!,
                                  style: TextStyle(fontSize: 14)),
                              Text(
                                  items[index]['resolution_laptop'] +
                                      ' ' +
                                      items[index]['fps_laptop'],
                                  style: TextStyle(fontSize: 14)),
                              Text(items[index]['taille_laptop']!,
                                  style: TextStyle(fontSize: 14)),
                              Text(items[index]['stockage_laptop']!,
                                  style: TextStyle(fontSize: 14)),
                              if (items[index]['promo_laptop'] != 0)
                                Column(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 125)),
                                    Text(
                                        items[index]['promo_laptop']
                                                .toString() +
                                            ' €',
                                        style: TextStyle(
                                            color: Colors.green, fontSize: 16)),
                                    Text(
                                        items[index]['prix_laptop'].toString() +
                                            ' €',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: 16)),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                )
                              else
                                Text(
                                    items[index]['prix_laptop'].toString() +
                                        ' €',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          bool isWished = wish.any((item) => item['id_product'] == items[index]['id_laptop']);
                          if(!isWished){addWish(prefs.getInt('id')!, items[index]['id_laptop'], 1);Get.snackbar('Produit ajouter', 'Produit ajouter a votre Wishlist');}
                          else{Get.snackbar('Error', 'Ce produit est deja dans votre Wishlist.');};
                          final wishResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/wishlists'));
                          setState(() {
                            wish = List<Map<String, dynamic>>.from(json.decode(wishResponse.body))
                                .where((item) {
                              return (item['id_user'] == prefs.getInt('id'));
                            }).toList();
                          });
                          print(wish);
                        },
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          List<int> sublistToCheck = [items[index]['id_laptop'], items[index]['prix_laptop'], 1];

                          bool alreadyExists = false;
                          for (List<int> sublist in _listOfLists) {
                            if (ListEquality<int>().equals(sublist, sublistToCheck)) {
                              alreadyExists = true;
                              break;
                            }
                          }
                          if (!alreadyExists)
                          {
                            _listOfLists.add([items[index]['id_laptop'], items[index]['prix_laptop'], 1]);
                            _saveListOfLists();
                            Get.snackbar('Produit ajouter', 'Produit ajouter a votre panier.');
                          }
                          else
                          {
                            Get.snackbar('Erreur', 'Ce produit est deja dans votre panier.');
                          }

                          print(_listOfLists);
                            // Example list
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.green,
                        ),
                      ),
                    )
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSectionCpus(String title, List<Map<String, dynamic>> items,
      List<Map<String, dynamic>> marque) {
    List<int> excludedIndexes = [55, 71, 88, 69, 30, 87, 91, 38, 16];
    List<Map<String, dynamic>> filteredItems = items
        .where((item) => !excludedIndexes.contains(items.indexOf(item)))
        .toList();

    items.shuffle(Random());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Plus', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        Container(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Card(
                  shadowColor: Colors.black,
                  margin: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        items[index]['img_cpu']!,
                        width: 130,
                        height: 130,
                        fit: BoxFit.scaleDown,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(items[index]['nom_cpu']!,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                                marque[items[index]['id_marque'] - 1]['nom_marque'].toString(),
                                style: TextStyle(fontSize: 14)),
                            Text(items[index]['model_cpu']!,
                                style: TextStyle(fontSize: 14)),
                            Text(
                                'Nombre de coeur: ' +
                                    items[index]['nombre_coeur'].toString(),
                                style: TextStyle(fontSize: 14)),
                            if (items[index]['promo_cpu'] != 0)
                              Column(
                                children: [
                                  Text(
                                      items[index]['prix_cpu'].toString() +
                                          ' €',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                              TextDecoration.lineThrough)),
                                  Text(
                                      items[index]['promo_cpu'].toString() +
                                          ' €',
                                      style: TextStyle(color: Colors.green)),
                                ],
                              )
                            else
                              Text(items[index]['prix_cpu'].toString() + ' €',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSectionGpus(
      String title, List<Map<String, dynamic>> items, int maxItemsToShow) {
    items.shuffle(Random());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Plus', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        Container(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: maxItemsToShow,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Card(
                  shadowColor: Colors.black,
                  margin: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        items[index]['img_laptop']!,
                        width: 130,
                        height: 130,
                        fit: BoxFit.scaleDown,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(items[index]['nom_laptop']!,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                                items[index]['resolution_laptop'] +
                                    ' ' +
                                    items[index]['fps_laptop'],
                                style: TextStyle(fontSize: 14)),
                            Text(items[index]['taille_laptop']!,
                                style: TextStyle(fontSize: 14)),
                            Text(items[index]['stockage_laptop']!,
                                style: TextStyle(fontSize: 14)),
                            if (items[index]['promo_laptop'] != 0)
                              Column(
                                children: [
                                  Text(
                                      items[index]['prix_laptop'].toString() +
                                          ' €',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                              TextDecoration.lineThrough)),
                                  Text(
                                      items[index]['promo_laptop'].toString() +
                                          ' €',
                                      style: TextStyle(color: Colors.green)),
                                ],
                              )
                            else
                              Text(
                                  items[index]['prix_laptop'].toString() + ' €',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSectionPourVous(String title, List<Map<String, dynamic>> items,
      List<Map<String, dynamic>> marque) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Plus', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        Container(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Card(
                  shadowColor: Colors.black,
                  margin: EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (items[index].containsKey('img_laptop'))
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      items[index]['img_laptop']!,
                                      width: 130,
                                      height: 130,
                                      fit: BoxFit.scaleDown,
                                    ),
                                    Text(items[index]['nom_laptop']!,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        items[index]['resolution_laptop'] +
                                            ' ' +
                                            items[index]['fps_laptop'],
                                        style: TextStyle(fontSize: 14)),
                                    Text(items[index]['taille_laptop']!,
                                        style: TextStyle(fontSize: 14)),
                                    Text(items[index]['stockage_laptop']!,
                                        style: TextStyle(fontSize: 14)),
                                    if (items[index]['promo_laptop'] != 0)
                                      Column(
                                        children: [
                                          Text(
                                              items[index]['prix_laptop']
                                                      .toString() +
                                                  ' €',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  decoration:
                                                      TextDecoration.lineThrough)),
                                          Text(
                                              items[index]['promo_laptop']
                                                      .toString() +
                                                  ' €',
                                              style:
                                                  TextStyle(color: Colors.green)),
                                        ],
                                      )
                                    else
                                      Text(
                                          items[index]['prix_laptop'].toString() +
                                              ' €',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          if (items[index].containsKey('img_cpu'))
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      items[index]['img_cpu']!,
                                      width: 130,
                                      height: 130,
                                      fit: BoxFit.scaleDown,
                                    ),
                                    Padding(padding:  const EdgeInsets.all(8.0),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                                        Text(items[index]['nom_cpu']!,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            marque[items[index]['id_marque'] - 1]
                                            ['nom_marque']
                                                .toString(),
                                            style: TextStyle(fontSize: 14)),
                                        Text(items[index]['model_cpu']!,
                                            style: TextStyle(fontSize: 14)),
                                        Text(
                                            'Nombre de coeur: ' +
                                                items[index]['nombre_coeur'].toString(),
                                            style: TextStyle(fontSize: 14)),
                                        if (items[index]['promo_cpu'] != 0)
                                          Column(
                                            children: [
                                              Text(
                                                  items[index]['prix_cpu'].toString() +
                                                      ' €',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      decoration:
                                                      TextDecoration.lineThrough)),
                                              Text(
                                                  items[index]['promo_cpu'].toString() +
                                                      ' €',
                                                  style:
                                                  TextStyle(color: Colors.green)),
                                            ],
                                          )
                                        else
                                          Text(
                                              items[index]['prix_cpu'].toString() +
                                                  ' €',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                      ],),),

                                  ],
                                ),
                              ),
                            ),
                          if (items[index].containsKey('img_gpu'))
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      items[index]['img_gpu']!,
                                      width: 130,
                                      height: 130,
                                      fit: BoxFit.scaleDown,
                                    ),
                                    Padding(
                                      padding:  const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(items[index]['nom_gpu']!,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              marque[items[index]['id_marque'] - 1]
                                              ['nom_marque']
                                                  .toString(),
                                              style: TextStyle(fontSize: 14)),
                                          Text(items[index]['v_ram_gpu']!,
                                              style: TextStyle(fontSize: 14)),
                                          Text(
                                              'Nombre de coeur: ' +
                                                  items[index]['type_gpu'].toString(),
                                              style: TextStyle(fontSize: 14)),
                                          if (items[index]['promo_gpu'] != 0)
                                            Column(
                                              children: [
                                                Text(
                                                    items[index]['prix_gpu'].toString() +
                                                        ' €',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        decoration:
                                                        TextDecoration.lineThrough)),
                                                Text(
                                                    items[index]['promo_gpu'].toString() +
                                                        ' €',
                                                    style:
                                                    TextStyle(color: Colors.green)),
                                              ],
                                            )
                                          else
                                            Text(
                                                items[index]['prix_gpu'].toString() +
                                                    ' €',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                        ],
                                      ),),


                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (items[index].containsKey('img_laptop'))
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              bool isWished = wish.any((item) => item['id_product'] == items[index]['id_laptop']);
                              if(!isWished){addWish(prefs.getInt('id')!, items[index]['id_laptop'], 1);Get.snackbar('Produit ajouter', 'Produit ajouter a votre Wishlist');}
                              else{Get.snackbar('Error', 'Ce produit est deja dans votre Wishlist.');};
                              final wishResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/wishlists'));
                              setState(() {
                                wish = List<Map<String, dynamic>>.from(json.decode(wishResponse.body))
                                    .where((item) {
                                  return (item['id_user'] == prefs.getInt('id'));
                                }).toList();
                              });
                              print(wish);
                            },
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      if (items[index].containsKey('img_laptop'))
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              List<int> sublistToCheck = [items[index]['id_laptop'], items[index]['prix_laptop'], 1];

                              bool alreadyExists = false;
                              for (List<int> sublist in _listOfLists) {
                                if (ListEquality<int>().equals(sublist, sublistToCheck)) {
                                  alreadyExists = true;
                                  break;
                                }
                              }
                              if (!alreadyExists)
                              {
                                _listOfLists.add([items[index]['id_laptop'], items[index]['prix_laptop'], 1]);
                                _saveListOfLists();
                                Get.snackbar('Produit ajouter', 'Produit ajouter a votre panier.');
                              }
                              else
                              {
                                Get.snackbar('Erreur', 'Ce produit est deja dans votre panier.');
                              }

                              print(_listOfLists);
                              // Example list
                            },
                            child: Icon(
                              Icons.add,
                              color: Colors.green,
                            ),
                          ),
                        ),

                      if (items[index].containsKey('img_cpu'))
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              bool isWished = wish.any((item) => item['id_product'] == items[index]['id_cpu']);
                              if(!isWished){addWish(prefs.getInt('id')!, items[index]['id_cpu'], 2);Get.snackbar('Produit ajouter', 'Produit ajouter a votre Wishlist');}
                              else{Get.snackbar('Error', 'Ce produit est deja dans votre Wishlist.');};
                              final wishResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/wishlists'));
                              setState(() {
                                wish = List<Map<String, dynamic>>.from(json.decode(wishResponse.body))
                                    .where((item) {
                                  return (item['id_user'] == prefs.getInt('id'));
                                }).toList();
                              });
                              print(wish);
                            },
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      if (items[index].containsKey('img_cpu'))
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              List<int> sublistToCheck = [items[index]['id_cpu'], items[index]['prix_cpu'], 1];

                              bool alreadyExists = false;
                              for (List<int> sublist in _listOfLists) {
                                if (ListEquality<int>().equals(sublist, sublistToCheck)) {
                                  alreadyExists = true;
                                  break;
                                }
                              }
                              if (!alreadyExists)
                              {
                                _listOfLists.add([items[index]['id_cpu'], items[index]['prix_cpu'], 1]);
                                _saveListOfLists();
                                Get.snackbar('Produit ajouter', 'Produit ajouter a votre panier.');
                              }
                              else
                              {
                                Get.snackbar('Erreur', 'Ce produit est deja dans votre panier.');
                              }

                              print(_listOfLists);
                              // Example list
                            },
                            child: Icon(
                              Icons.add,
                              color: Colors.green,
                            ),
                          ),
                        ),

                      if (items[index].containsKey('img_gpu'))
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              bool isWished = wish.any((item) => item['id_product'] == items[index]['id_gpu']);
                              if(!isWished){addWish(prefs.getInt('id')!, items[index]['id_gpu'], 3);Get.snackbar('Produit ajouter', 'Produit ajouter a votre Wishlist');}
                              else{Get.snackbar('Error', 'Ce produit est deja dans votre Wishlist.');};
                              final wishResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/wishlists'));
                              setState(() {
                                wish = List<Map<String, dynamic>>.from(json.decode(wishResponse.body))
                                    .where((item) {
                                  return (item['id_user'] == prefs.getInt('id'));
                                }).toList();
                              });
                              print(wish);
                            },
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      if (items[index].containsKey('img_gpu'))
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              List<int> sublistToCheck = [items[index]['id_gpu'], items[index]['prix_gpu'], 1];

                              bool alreadyExists = false;
                              for (List<int> sublist in _listOfLists) {
                                if (ListEquality<int>().equals(sublist, sublistToCheck)) {
                                  alreadyExists = true;
                                  break;
                                }
                              }
                              if (!alreadyExists)
                              {
                                _listOfLists.add([items[index]['id_gpu'], items[index]['prix_gpu'], 1]);
                                _saveListOfLists();
                                Get.snackbar('Produit ajouter', 'Produit ajouter a votre panier.');
                              }
                              else
                              {
                                Get.snackbar('Erreur', 'Ce produit est deja dans votre panier.');
                              }

                              print(_listOfLists);
                              // Example list
                            },
                            child: Icon(
                              Icons.add,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),

                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSectionPromo(String title, List<Map<String, dynamic>> items,
      List<Map<String, dynamic>> marque) {
    items.shuffle(Random());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Plus', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        Container(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Card(
                  shadowColor: Colors.black,
                  margin: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (items[index].containsKey('img_laptop'))
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          items[index]['img_laptop']!,
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.scaleDown,
                                        ),
                                        Text(items[index]['nom_laptop']!,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            items[index]['resolution_laptop'] +
                                                ' ' +
                                                items[index]['fps_laptop'],
                                            style: TextStyle(fontSize: 14)),
                                        Text(items[index]['taille_laptop']!,
                                            style: TextStyle(fontSize: 14)),
                                        Text(items[index]['stockage_laptop']!,
                                            style: TextStyle(fontSize: 14)),
                                        if (items[index]['promo_laptop'] != 0)
                                          Column(
                                            children: [
                                              Text(
                                                  items[index]['prix_laptop']
                                                          .toString() +
                                                      ' €',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      decoration: TextDecoration
                                                          .lineThrough)),
                                              Text(
                                                  items[index]['promo_laptop']
                                                          .toString() +
                                                      ' €',
                                                  style: TextStyle(
                                                      color: Colors.green)),
                                            ],
                                          )
                                        else
                                          Text(
                                              items[index]['prix_laptop']
                                                      .toString() +
                                                  ' €',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              if (items[index].containsKey('img_cpu'))
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          items[index]['img_cpu']!,
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.scaleDown,
                                        ),
                                        Text(items[index]['nom_cpu']!,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            marque[items[index]['id_marque'] -
                                                    1]['nom_marque']
                                                .toString(),
                                            style: TextStyle(fontSize: 14)),
                                        Text(items[index]['model_cpu']!,
                                            style: TextStyle(fontSize: 14)),
                                        Text(
                                            'Nombre de coeur: ' +
                                                items[index]['nombre_coeur']
                                                    .toString(),
                                            style: TextStyle(fontSize: 14)),
                                        if (items[index]['promo_cpu'] != 0)
                                          Column(
                                            children: [
                                              Text(
                                                  items[index]['prix_cpu']
                                                          .toString() +
                                                      ' €',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      decoration: TextDecoration
                                                          .lineThrough)),
                                              Text(
                                                  items[index]['promo_cpu']
                                                          .toString() +
                                                      ' €',
                                                  style: TextStyle(
                                                      color: Colors.green)),
                                            ],
                                          )
                                        else
                                          Text(
                                              items[index]['prix_cpu']
                                                      .toString() +
                                                  ' €',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              if (items[index].containsKey('img_gpu'))
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          items[index]['img_gpu']!,
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.scaleDown,
                                        ),
                                        Text(items[index]['nom_gpu']!,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            marque[items[index]['id_marque'] -
                                                    1]['nom_marque']
                                                .toString(),
                                            style: TextStyle(fontSize: 14)),
                                        Text(items[index]['v_ram_gpu']!,
                                            style: TextStyle(fontSize: 14)),
                                        Text(
                                            'Nombre de coeur: ' +
                                                items[index]['type_gpu']
                                                    .toString(),
                                            style: TextStyle(fontSize: 14)),
                                        if (items[index]['promo_gpu'] != 0)
                                          Column(
                                            children: [
                                              Text(
                                                  items[index]['prix_gpu']
                                                          .toString() +
                                                      ' €',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      decoration: TextDecoration
                                                          .lineThrough)),
                                              Text(
                                                  items[index]['promo_gpu']
                                                          .toString() +
                                                      ' €',
                                                  style: TextStyle(
                                                      color: Colors.green)),
                                            ],
                                          )
                                        else
                                          Text(
                                              items[index]['prix_gpu']
                                                      .toString() +
                                                  ' €',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ButtomCarousel extends StatelessWidget {
  const ButtomCarousel({
    super.key,
    required this.marques,
  });

  final List<Map<String, dynamic>> marques;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nos Marques',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 150.0,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 2.0,
          ),
          items: marques.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(i['img_marque']),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class TopCarousel extends StatelessWidget {
  const TopCarousel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 170.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 2.0,
      ),
      items: ['images/promo/promo1.png', 'images/promo/promo2.png'].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(i),
                  fit: BoxFit.scaleDown,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}


class StorageHelper {
  static const String _key = 'list_of_lists';

  static Future<void> saveListOfLists(List<List<int>> listOfLists) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedList = listOfLists.map((list) => jsonEncode(list)).toList();
    await prefs.setStringList(_key, encodedList);
  }

  static Future<List<List<int>>> getListOfLists() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? encodedList = prefs.getStringList(_key);
    if (encodedList == null) return [];
    return encodedList.map((str) => List<int>.from(jsonDecode(str))).toList();
  }
}
