import 'package:flutter/material.dart';

class ViewMore extends StatelessWidget {
  const ViewMore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,

              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){},
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    shadowColor: Colors.black,
                    margin: EdgeInsets.all(8),
                    child: Stack(
                        children:[ Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network('img_laptop', width: 130, height: 130, fit: BoxFit.scaleDown,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('nom_laptop', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                  Text('model_laptop', style: TextStyle(fontSize: 14)),
                                  Text('resolution_laptop'+' ''fps_laptop', style: TextStyle(fontSize: 14)),
                                  Text('taille_laptop', style: TextStyle(fontSize: 14)),
                                  Text('stockage_laptop', style: TextStyle(fontSize: 14)),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
