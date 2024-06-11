import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../navigation_menu.dart';

class Panier extends StatefulWidget {
  @override
  _PanierState createState() => _PanierState();
}

class _PanierState extends State<Panier> {
  final controller = Get.put(NavigationController());

  List<Map<String, dynamic>> laptops = [];
  List<List<int>> _listOfLists = [];


  @override
  void initState() {
    super.initState();
    _loadListOfLists();
  }


  Future<void> _loadListOfLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<List<int>> loadedList = await StorageHelper.getListOfLists();
    final laptopsResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/laptops'));
    setState(() {
      laptops = List<Map<String, dynamic>>.from(json.decode(laptopsResponse.body));
      _listOfLists = loadedList;
    });
  }
  Future<void> _saveListOfLists() async {
    await StorageHelper.saveListOfLists(_listOfLists);
  }
  void _deleteList(int index) {
    setState(() {
      _listOfLists.removeAt(index);
      _saveListOfLists();
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text("Panier"),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _listOfLists.length,
              itemBuilder: (context, index) {
                return InkWell(

                  onTap: () {},
                  borderRadius: BorderRadius.circular(25),
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Image.network(
                            laptops[_listOfLists[index][0]-1]['img_laptop'],
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  laptops[_listOfLists[index][0]-1]['nom_laptop'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text('Prix: € '+(_listOfLists[index][1]*_listOfLists[index][2]).toString()),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () =>setState(() {
                                  _listOfLists[index][2] += -1;
                                  if (_listOfLists[index][2] < 1)
                                  {
                                    _listOfLists[index][2] = 1;
                                  }
                                  _saveListOfLists();
                                }),
                              ),
                              Text(_listOfLists[index][2].toString()),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () =>setState(() {
                                  _listOfLists[index][2] += 1;
                                  if (_listOfLists[index][2] < 1)
                                  {
                                    _listOfLists[index][2] = 1;
                                  }
                                  _saveListOfLists();
                                }),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {_deleteList(index);},
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Logique pour passer à la caisse
              },
              child: Text('Passer à la caisse'),
            ),
          ),
        ],
      ),
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





