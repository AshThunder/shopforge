import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shopforge/utils/shop_action.dart';

class DBHelper {
  addOrUpdateCart(Map data) async {
    var box = await Hive.openBox('appBox');
    List alldata = [];
    if (box.get('cart') != null) {
      alldata = jsonDecode(box.get('cart'));
      bool exists = alldata
                  .where((element) =>
                      (element['product_id'] == data['product_id'] &&
                          element['variation_id'] == data['variation_id']))
                  .length >
              0
          ? true
          : false;
      if (exists) {
        int index = alldata.indexWhere((el) =>
            (el['product_id'] == data['product_id'] &&
                el['variation_id'] == data['variation_id']));
        if (data['product_key'] == null) {
          data['product_key'] = ShopAction().strRandom(12);
          print(data);
        }
        alldata[index] = data;
        box.put('cart', json.encode(alldata));
      } else {
        data['product_key'] = ShopAction().strRandom(12);
        print(data);
        alldata = [data, ...alldata];
        box.put('cart', json.encode(alldata));
      }
    } else {
      data['product_key'] = ShopAction().strRandom(12);
      print(data);
      alldata.add(data);
      box.put('cart', json.encode(alldata));
    }
  }

  updateCartItem(String productKey, int qty) async {
    var box = await Hive.openBox('appBox');
    List alldata = [];
    if (box.get('cart') != null) {
      alldata = jsonDecode(box.get('cart'));
      int getIndex =
          alldata.indexWhere((element) => element['product_key'] == productKey);
      if (getIndex >= 0) {
        Map me = alldata[getIndex];
        me['quantity'] = qty;
        alldata[getIndex] = me;
        box.put('cart', json.encode(alldata));
      }
    }
  }

  deleteCartItem(String productKey) async {
    var box = await Hive.openBox('appBox');
    List alldata = [];
    if (box.get('cart') != null) {
      alldata = jsonDecode(box.get('cart'));
      alldata.removeWhere((element) => element['product_key'] == productKey);
      box.put('cart', json.encode(alldata));
    }
  }

  deleteWishListItem(String productID) async {
    var box = await Hive.openBox('appBox');
    List alldata = [];
    if (box.get('wishlists') != null) {
      alldata = jsonDecode(box.get('wishlists'));
      alldata.removeWhere((element) => element.toString() == productID);
      box.put('wishlists', json.encode(alldata));
    }
  }

  toggleWishlist(int productID) async {
    var box = await Hive.openBox('appBox');
    List alldata = [];
    if (box.get('wishlists') != null) {
      alldata = jsonDecode(box.get('wishlists'));
      bool exists = alldata.where((element) => element == productID).length > 0
          ? true
          : false;
      if (exists) {
        alldata.removeWhere((element) => element == productID);
        box.put('wishlists', json.encode(alldata));
      } else {
        alldata = [productID, ...alldata];
        box.put('wishlists', json.encode(alldata));
      }
    } else {
      alldata.add(productID);
      box.put('wishlists', json.encode(alldata));
    }
  }
}
