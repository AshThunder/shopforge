import 'dart:convert';
import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shopforge/config/app.dart';

import 'db_helper.dart';

class ShopAction {
  DBHelper dbHelper = new DBHelper();
  addToCart(Map product, int qty, int variationID, cartState, List selections,
      variationPrice) async {
    var box = await Hive.openBox('appBox');
    List alldata = [];
    int quantity = 0;
    if (box.get('cart') != null) {
      alldata = jsonDecode(box.get('cart'));
      try {
        Map each = alldata.firstWhere((element) =>
            (element['product_id'] == product['id'] &&
                element['variation_id'] == variationID));
        if (each['quantity'] != null) {
          quantity = each['quantity'];
        }
      } catch (e) {}
    }
    Map newItem = {
      "name": product["name"],
      "price": variationID != 0 && variationPrice != null
          ? variationPrice
          : product["price"],
      "photo": product["images"] != null && product["images"].length > 0
          ? product["images"][0]["src"]
          : "",
      "quantity": quantity + qty,
      "product_id": product["id"],
      "product_sku": product["sku"],
      "variation_id": variationID,
      "selections": selections,
    };

    await dbHelper.addOrUpdateCart(newItem);
    if (box.get('cart') != null) {
      cartState.state = jsonDecode(box.get('cart'));
    }
  }

  updateCartSingle(String productKey, int qty, cartState) async {
    var box = await Hive.openBox('appBox');
    await dbHelper.updateCartItem(productKey, qty);
    if (box.get('cart') != null) {
      cartState.state = jsonDecode(box.get('cart'));
    }
  }

  deleteCartSingle(String productKey, cartState) async {
    var box = await Hive.openBox('appBox');
    await dbHelper.deleteCartItem(productKey);
    if (box.get('cart') != null) {
      cartState.state = await jsonDecode(box.get('cart'));
    }
  }

  deleteWishListSingle(String productID, wishlist) async {
    var box = await Hive.openBox('appBox');
    await dbHelper.deleteWishListItem(productID);
    if (box.get('wishlists') != null) {
      wishlist.state = await jsonDecode(box.get('wishlists'));
    }
  }

  logout(account, token, wishlists, orders) async {
    if (account.state['login_type'] == 'social') {
      try {
        if (account.state['login_mode'] == 'google') {
          GoogleSignIn _googleSignIn = GoogleSignIn();
          await _googleSignIn.signOut();
        } else if (account.state['login_mode'] == 'facebook') {
          await FacebookAuth.instance.logOut();
        }

        account.state = {};
        wishlists.state = [];
        orders.state = [];
        token.state = "";
        var box = await Hive.openBox('appBox');
        box.delete('account');
        box.delete('token');
        box.delete('wishlists');
        box.delete('orders');
      } catch (e) {
        print(e);
      }
    } else {
      account.state = {};
      wishlists.state = [];
      orders.state = [];
      token.state = "";
      var box = await Hive.openBox('appBox');
      box.delete('account');
      box.delete('token');
      box.delete('wishlists');
      box.delete('orders');
    }
  }

  newToastSuccess(context, String message) {
    showToastWidget(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
        margin: EdgeInsets.symmetric(horizontal: 25.0),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: Color(0xFF0E7E19),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconsPath + 'emoji-happy.svg',
              height: 24,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '$message',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: () => {ToastManager().dismissAll(showAnim: true)},
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Color(0xFF0C5814),
                    borderRadius: BorderRadius.circular(20)),
                child: SvgPicture.asset(
                  iconsPath + 'close.svg',
                ),
              ),
            ),
          ],
        ),
      ),
      context: context,
      animation: StyledToastAnimation.slideFromTop,
      reverseAnimation: StyledToastAnimation.slideToTop,
      position: StyledToastPosition.top,
      startOffset: Offset(0.0, -3.0),
      reverseEndOffset: Offset(0.0, -3.0),
      duration: Duration(seconds: 4),
      //Animation duration   animDuration * 2 <= duration
      animDuration: Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.fastOutSlowIn,
    );
  }

  newToastError(context, String message) {
    showToastWidget(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
        margin: EdgeInsets.symmetric(horizontal: 25.0),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: Color(0xFF9F2828),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconsPath + 'emoji-sad.svg',
              height: 24,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '$message',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: () => {ToastManager().dismissAll(showAnim: true)},
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Color(0xFF842121),
                    borderRadius: BorderRadius.circular(20)),
                child: SvgPicture.asset(
                  iconsPath + 'close.svg',
                ),
              ),
            ),
          ],
        ),
      ),
      context: context,
      animation: StyledToastAnimation.slideFromTop,
      reverseAnimation: StyledToastAnimation.slideToTop,
      position: StyledToastPosition.top,
      startOffset: Offset(0.0, -3.0),
      reverseEndOffset: Offset(0.0, -3.0),
      duration: Duration(seconds: 4),
      //Animation duration   animDuration * 2 <= duration
      animDuration: Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.fastOutSlowIn,
    );
  }

  bool validateBillingInfo(info) {
    if (info["billing"]?['first_name'].length == 0 ||
        info["billing"]?['last_name'].length == 0 ||
        info["billing"]?['address_1'].length == 0 ||
        info["billing"]?['city'].length == 0 ||
        info["billing"]?['state'].length == 0 ||
        info["billing"]?['country'].length == 0 ||
        info["billing"]?['email'].length == 0 ||
        info["billing"]?['phone'].length == 0) {
      return false;
    } else {
      if (info["different"]) {
        if (info["shipping"]?['first_name'].length == 0 ||
            info["shipping"]?['last_name'].length == 0 ||
            info["shipping"]?['address_1'].length == 0 ||
            info["shipping"]?['city'].length == 0 ||
            info["shipping"]?['state'].length == 0 ||
            info["shipping"]?['country'].length == 0) {
          return false;
        } else {
          return true;
        }
      }
      return true;
    }
  }

  bool validateEmails(email) {
    if (EmailValidator.validate(email)) {
      return true;
    } else {
      return false;
    }
  }

  String strRandom(int length) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  nestCategories(List categories) {
    List newCategories = [];
    for (var category in categories) {
      if (category['parent'] == 0) {
        newCategories = [category, ...newCategories];
      } else {
        Map getParent = categories
            .firstWhere((element) => element['id'] == category['parent']);
        if (getParent['id'] != null) {
          int getIndex =
              newCategories.indexWhere((el) => el['id'] == category['parent']);
          if (getIndex >= 0) {
            List children = newCategories[getIndex]['children'] != null
                ? newCategories[getIndex]['children']
                : [];
            children = [category, ...children];
            newCategories[getIndex]['children'] = children;
          } else {
            List children =
                getParent['children'] != null ? getParent['children'] : [];
            children = [category, ...children];
            getParent['children'] = children;
            int myIndex =
                newCategories.indexWhere((em) => em['id'] == getParent['id']);
            if (myIndex >= 0) {
              print('got here');
              newCategories[getIndex] = getParent;
            } else {
              newCategories = [getParent, ...newCategories];
            }
          }
        }
      }
    }
    return newCategories.toSet().toList();
  }
}
