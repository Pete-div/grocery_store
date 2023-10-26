import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:gostery/consts/firebase_const.dart';
import 'package:gostery/models/cart_model.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartModel> _cartItems = {};

  Map<String, CartModel> get getCartItems {
    return _cartItems;
  }

  final User? user = authInstance.currentUser;
  final userCollection = FirebaseFirestore.instance.collection("users");
  Future<void> fetchCart() async {
    final User? user = authInstance.currentUser;
    final DocumentSnapshot userDoc = await userCollection.doc(user!.uid).get();
    if (userDoc == null) {
      return;
    }
    final leng = userDoc.get("userCart").lemgth;
    for (int i = 0; i < leng; i++) {
      String productId = userDoc.get("userCart")[i]["productId"];
      String cartId = userDoc.get("userCart")[i]["cartId"];
      int quantity = userDoc.get("userCart")[i]["quantity"];
      _cartItems.putIfAbsent(
          productId,
          () =>
              CartModel(id: cartId, productId: productId, quantity: quantity));
    }
    notifyListeners();
  }

  void reduceQuantityByOne(String productId) {
    _cartItems.update(
      productId,
      (value) => CartModel(
        id: value.id,
        productId: productId,
        quantity: value.quantity - 1,
      ),
    );

    notifyListeners();
  }

  void increaseQuantityByOne(String productId) {
    _cartItems.update(
      productId,
      (value) => CartModel(
        id: value.id,
        productId: productId,
        quantity: value.quantity + 1,
      ),
    );
    notifyListeners();
  }

  Future<void> removeOneItem(
      {required String productId,
      required String cartId,
      required int quantity}) async {
    final User? user = authInstance.currentUser;
    await userCollection.doc(user!.uid).update({
      "userCart": FieldValue.arrayRemove([
        {"cartId": cartId, "productId": productId, "quantity": quantity}
      ])
    });

    _cartItems.remove(productId);
    await fetchCart();
    notifyListeners();
  }

  void clearLocalCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<void> clearOnlineCart() async {
    await userCollection.doc(user!.uid).update({
      "userCart": [],
    });
    _cartItems.clear();
    notifyListeners();
  }
}
