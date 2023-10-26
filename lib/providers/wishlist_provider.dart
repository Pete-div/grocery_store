import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:gostery/consts/firebase_const.dart';
import 'package:gostery/models/wishlist_model.dart';

class WishlistProvider with ChangeNotifier {
  Map<String, WishlistModel> _wishlistItems = {};

  Map<String, WishlistModel> get getWishlistItems {
    return _wishlistItems;
  }

  // void addRemoveProductToWishlist({required String productId}) {
  //   if (_wishlistItems.containsKey(productId)) {
  //     removeOneItem(productId);
  //   } else {
  //     _wishlistItems.putIfAbsent(
  //         productId,
  //         () => WishlistModel(
  //             id: DateTime.now().toString(), productId: productId));
  //   }
  //   notifyListeners();
  // }

  final User? user = authInstance.currentUser;
  final userCollection = FirebaseFirestore.instance.collection("users");
  Future<void> fetchWishList() async {
    final User? user = authInstance.currentUser;
    final DocumentSnapshot userDoc = await userCollection.doc(user!.uid).get();
    if (userDoc == null) {
      return;
    }
    final leng = userDoc.get("userWish").lemgth;
    for (int i = 0; i < leng; i++) {
      String productId = userDoc.get("userWish")[i]["wishListId"];
      String cartId = userDoc.get("userWish")[i]["wishListId"];
      _wishlistItems.putIfAbsent(
          productId, () => WishlistModel(id: cartId, productId: productId));
    }
    notifyListeners();
  }

  Future<void> removeOneItem({
    required String productId,
    required String wishListId,
  }) async {
    final User? user = authInstance.currentUser;
    await userCollection.doc(user!.uid).update({
      "userCart": FieldValue.arrayRemove([
        {
          "wishListId": wishListId,
          "productId": productId,
        }
      ])
    });

    _wishlistItems.remove(productId);
    await fetchWishList();
    notifyListeners();
  }

  Future<void> clearOnlinewishList() async {
    await userCollection.doc(user!.uid).update({
      "userCart": [],
    });
    _wishlistItems.clear();
    await fetchWishList();
    notifyListeners();
  }

  void clearLocalWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}
