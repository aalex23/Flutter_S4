import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:projet_flutter_propre/screens/view_more.dart';

class ProductGrid extends StatelessWidget {
  final list;
  final text;
  final marques;
  final title;


  ProductGrid({super.key,required this.list,required this.text,required this.marques,required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 1,
      ),
      body: Visibility(
        visible: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(list.isNotEmpty)
                buildSectionAll('$text', list,marques),
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
        Container(
          height: 600,
          child: GridView.builder(
            scrollDirection: Axis.vertical,
            itemCount: 7,

            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => Get.to(() => ViewMore()),
                borderRadius: BorderRadius.circular(20),
                child: Card(
                  shadowColor: Colors.black,
                  margin: EdgeInsets.all(8),
                  child: Stack(
                      children:[ Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(child: Image.asset('images/cpus/logo_cpu.png', width: 130, height: 130, fit: BoxFit.scaleDown,)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(items[index]['nom_laptop']!, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                Text(items[index]['model_laptop']!, style: TextStyle(fontSize: 14)),
                                Text(items[index]['resolution_laptop']+' '+items[index]['fps_laptop'], style: TextStyle(fontSize: 14)),
                                Text(items[index]['taille_laptop']!, style: TextStyle(fontSize: 14)),
                                Text(items[index]['stockage_laptop']!, style: TextStyle(fontSize: 14)),

                                if (items[index]['promo_laptop']!=0)
                                  Column(
                                    children: [
                                      Padding(padding: EdgeInsets.only(left: 125)),
                                      Text(items[index]['promo_laptop'].toString()+' €', style: TextStyle(color: Colors.green,fontSize: 16)),
                                      Text(items[index]['prix_laptop'].toString()+' €', style: TextStyle(fontWeight: FontWeight.bold,decoration: TextDecoration.lineThrough,fontSize: 16)),

                                    ],

                                    crossAxisAlignment: CrossAxisAlignment.end,
                                  )
                                else
                                  Text(items[index]['prix_laptop'].toString()+' €', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),


                              ],
                            ),
                          ),
                        ],
                      ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: (){},

                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.red,

                            ),
                          ),
                        ),
                      ]
                  ),
                ),
              );
            }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 400
          ),
          ),
        ),
      ],
    );
  }

  Widget buildSectionAll(String title, List<Map<String, dynamic>> items,List<Map<String, dynamic>> marque) {
    items.shuffle(Random());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 750,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 400
            ),
            scrollDirection: Axis.vertical,
            itemCount: 20,

            itemBuilder: (context, index) {
              return InkWell(
                onTap: (){},
                borderRadius: BorderRadius.circular(20),
                child: Card(
                  shadowColor: Colors.black,
                  margin: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(items[index].containsKey('img_laptop'))
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(items[index]['img_laptop']!, width: 130, height: 130, fit: BoxFit.scaleDown,),
                                Text(items[index]['nom_laptop']!, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                Text(items[index]['resolution_laptop']+' '+items[index]['fps_laptop'], style: TextStyle(fontSize: 14)),
                                Text(items[index]['taille_laptop']!, style: TextStyle(fontSize: 14)),
                                Text(items[index]['stockage_laptop']!, style: TextStyle(fontSize: 14)),

                                if (items[index]['promo_laptop']!=0)
                                  Column(
                                    children: [
                                      Text(items[index]['prix_laptop'].toString()+' €', style: TextStyle(fontWeight: FontWeight.bold,decoration: TextDecoration.lineThrough)),
                                      Text(items[index]['promo_laptop'].toString()+' €', style: TextStyle(color: Colors.green)),
                                    ],
                                  )
                                else
                                  Text(items[index]['prix_laptop'].toString()+' €', style: TextStyle(fontWeight: FontWeight.bold)),


                              ],
                            ),
                          ),
                        ),
                      if(items[index].containsKey('img_cpu'))
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(items[index]['img_cpu']!, width: 130, height: 130, fit: BoxFit.scaleDown,),
                                Text(items[index]['nom_cpu']!, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                Text(marque[items[index]['id_marque']-1]['nom_marque'].toString(), style: TextStyle(fontSize: 14)),
                                Text(items[index]['model_cpu']!, style: TextStyle(fontSize: 14)),
                                Text('Nombre de coeur: '+items[index]['nombre_coeur'].toString(), style: TextStyle(fontSize: 14)),



                                if (items[index]['promo_cpu']!=0)
                                  Column(
                                    children: [
                                      Text(items[index]['prix_cpu'].toString()+' €', style: TextStyle(fontWeight: FontWeight.bold,decoration: TextDecoration.lineThrough)),
                                      Text(items[index]['promo_cpu'].toString()+' €', style: TextStyle(color: Colors.green)),
                                    ],
                                  )
                                else
                                  Text(items[index]['prix_cpu'].toString()+' €', style: TextStyle(fontWeight: FontWeight.bold)),


                              ],
                            ),
                          ),
                        ),
                      if(items[index].containsKey('img_gpu'))
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(items[index]['img_gpu']!, width: 130, height: 130, fit: BoxFit.scaleDown,),
                                Text(items[index]['nom_gpu']!, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                Text(marque[items[index]['id_marque']-1]['nom_marque'].toString(), style: TextStyle(fontSize: 14)),
                                Text(items[index]['v_ram_gpu']!, style: TextStyle(fontSize: 14)),
                                Text('Nombre de coeur: '+items[index]['type_gpu'].toString(), style: TextStyle(fontSize: 14)),



                                if (items[index]['promo_gpu']!=0)
                                  Column(
                                    children: [
                                      Text(items[index]['prix_gpu'].toString()+' €', style: TextStyle(fontWeight: FontWeight.bold,decoration: TextDecoration.lineThrough)),
                                      Text(items[index]['promo_gpu'].toString()+' €', style: TextStyle(color: Colors.green)),
                                    ],
                                  )
                                else
                                  Text(items[index]['prix_gpu'].toString()+' €', style: TextStyle(fontWeight: FontWeight.bold)),


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
