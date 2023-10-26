import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gostery/consts/contss.dart';
import 'package:gostery/consts/firebase_const.dart';
import 'package:gostery/providers/cart_provider.dart';
import 'package:gostery/providers/products_provider.dart';
import 'package:gostery/providers/wishlist_provider.dart';
import 'package:gostery/screens/btm_bar.dart';
import 'package:provider/provider.dart';

class FetchScreen extends StatefulWidget {
  const FetchScreen({Key? key}) : super(key: key);

  @override
  State<FetchScreen> createState() => _FetchScreenState();
}

class _FetchScreenState extends State<FetchScreen> {
  List<String> images = Constss.authImagesPaths;
  @override
  void initState() {
    // TODO: implement initState
    images.shuffle();
    Future.delayed(const Duration(microseconds: 5), () async {
      final productProvider =
          Provider.of<ProductsProvider>(context, listen: false);

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final wishListProvider =
          Provider.of<WishlistProvider>(context, listen: false);
      final User? user = authInstance.currentUser;
      if (user == null) {
        await productProvider.fetchProducts();
        cartProvider.clearLocalCart();
        wishListProvider.clearLocalWishlist();
      } else {
        await productProvider.fetchProducts();
        await cartProvider.fetchCart();
        await wishListProvider.fetchWishList();
      }

      await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomBarScreen()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            images[0],
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          const Center(
            child: SpinKitFadingFour(
              duration: Duration(seconds: 4),
              color: Colors.white,
              size: 50.0,
            ),
          )
        ],
      ),
    );
  }
}
