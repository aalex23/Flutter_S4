import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

List<Map<String, dynamic>> laptops = [];
List<Map<String, dynamic>> marques = [];
List<Map<String, dynamic>> cpus = [];
List<Map<String, dynamic>> gpus = [];
List<Map<String, dynamic>> produts = [];
List<Map<String, dynamic>> promo = [];

var isLoaded=false;

class ApiLists extends StatefulWidget {
  @override
  State<ApiLists> createState() => _ApiListsState();
}

class _ApiListsState extends State<ApiLists> {


  @override
  void initState() {
    super.initState();
    fetchItem();
  }

  Future<void> fetchItem() async {
    // Remplacez les URL par celles de votre propre API
    final laptopsResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/laptops'));
    final marquesResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/marques'));
    final cpusResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/cpus'));
    final gpusResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/gpus'));


    setState(() {
      laptops =
      List<Map<String, dynamic>>.from(json.decode(laptopsResponse.body));
      marques =
      List<Map<String, dynamic>>.from(json.decode(marquesResponse.body));
      cpus = List<Map<String, dynamic>>.from(json.decode(cpusResponse.body));
      gpus = List<Map<String, dynamic>>.from(json.decode(gpusResponse.body));
      produts = laptops + cpus + gpus;
      promo = produts.where((item) {
        return !(item['promo_laptop'] == 0 || item['promo_cpu'] == 0 ||
            item['promo_gpu'] == 0);
      }).toList();
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
