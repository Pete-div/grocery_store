import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:gostery/consts/firebase_const.dart';
import 'package:gostery/providers/products_provider.dart';
import 'package:gostery/screens/auth/login.dart';
import 'package:gostery/services/global_methods.dart';
import 'package:provider/provider.dart';

import '../providers/wishlist_provider.dart';
import '../services/utils.dart';

class HeartBTN extends StatefulWidget {
  const HeartBTN({Key? key, required this.productId, this.isInWishlist = false})
      : super(key: key);
  final String productId;
  final bool? isInWishlist;

  @override
  State<HeartBTN> createState() => _HeartBTNState();
}

class _HeartBTNState extends State<HeartBTN> {
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductsProvider>(context);
    final getCurrProduct = productProvider.findProdById(widget.productId);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final Color color = Utils(context).color;
    bool _isLoading = false;
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isLoading = true;
        });
        try {
          final User? user = authInstance.currentUser;
          if (user == null) {
            GlobalMethods.errorDialog(
                subtitle: "No user Found, please login first",
                context: context);
            return;
          }
          if (widget.isInWishlist == false && widget.isInWishlist != null) {
            GlobalMethods.addToWishList(
                productId: widget.productId, context: context);
          } else {
            await wishlistProvider.removeOneItem(
                productId: widget.productId,
                wishListId:
                    wishlistProvider.getWishlistItems[getCurrProduct.id]!.id);
          }
          await wishlistProvider.fetchWishList();
          setState(() {
            _isLoading = false;
          });
        } catch (err) {
          GlobalMethods.errorDialog(subtitle: "$err", context: context);
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: _isLoading
          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
          : Icon(
              widget.isInWishlist != null && widget.isInWishlist == true
                  ? IconlyBold.heart
                  : IconlyLight.heart,
              size: 22,
              color: widget.isInWishlist != null && widget.isInWishlist == true
                  ? Colors.red
                  : color,
            ),
    );
  }
}
