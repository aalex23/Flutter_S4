import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:projet_flutter_propre/screens/nav/home.dart';
import 'package:projet_flutter_propre/screens/nav/panier.dart';
import 'package:projet_flutter_propre/screens/nav/profile.dart';
import 'package:projet_flutter_propre/screens/nav/wishlist.dart';

class NavMenu extends StatelessWidget {
  const NavMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =Get.put(NavigationController());
    return Scaffold(
      bottomNavigationBar: Obx(
            ()=> NavigationBar(
          height: 80,
          elevation: 2,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index)=> controller.selectedIndex.value=index,

          destinations: const[
            NavigationDestination(icon: Icon(Iconsax.home), label: "Home"),
            NavigationDestination(icon: Icon(Iconsax.heart), label: "Wishlist"),
            NavigationDestination(icon: Icon(Iconsax.shopping_bag), label: "Panier"),
            NavigationDestination(icon: Icon(Iconsax.user), label: "Profile"),
          ],
        ),
      ),
      body: Obx(()=> controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex =0.obs;

  final screens=[HomeScreen(),Wishlist(),Panier(),Profile(),];
}