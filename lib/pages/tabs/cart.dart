import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/auth/login.dart';
import 'package:shopforge/pages/checkout.dart';
import 'package:shopforge/pages/components/error_messages/empty_error.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:shopforge/pages/components/shop/each_cart_item.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';

class Cart extends HookWidget {
  final bool closable;
  const Cart({Key? key, this.closable = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final account = useProvider(accountProvider);
    final color = useProvider(colorProvider);
    final cartState = useProvider(cartProvider);
    final currency = useProvider(currencyProvider);
    final token = useProvider(userTokenProvider);
    final wishlists = useProvider(wishlistsProvider);
    final orders = useProvider(ordersProvider);
    final selected = useState([]);

    final loading = useState(false);

    checkout() async {
      try {
        loading.value = true;
        var result = await Network().validateToken();
        if (result == false) {
          await ShopAction().logout(account, token, wishlists, orders);
        }
        loading.value = false;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => account.state['id'] != null
                  ? Checkout()
                  : Login(anchor: 'checkout')),
        );
      } catch (e) {
        loading.value = false;
      }
    }

    toggleSelect(String productKey) {
      if (selected.value.where((element) => element == productKey).length > 0) {
        selected.value.removeWhere((element) => element == productKey);
        List myList = selected.value;
        selected.value = [];
        selected.value = myList;
      } else {
        selected.value.add(productKey);
        selected.value = selected.value.toSet().toList();
      }
    }

    selectAll() {
      List allItems =
          cartState.state.map((item) => item['product_key']).toList();
      if (selected.value.length < allItems.length) {
        selected.value = allItems;
      } else {
        selected.value = [];
      }
    }

    loadData() async {
      var box = await Hive.openBox('appBox');
      if (box.get('cart') != null) {
        cartState.state = await jsonDecode(box.get('cart'));
      }
    }

    deleteSelection() async {
      for (var item in selected.value) {
        await ShopAction().deleteCartSingle(item, cartState);
      }
      selected.value = [];
      await loadData();
    }

    calculateCart() {
      double sum = 0;
      for (var item in cartState.state) {
        sum += (int.parse(item['quantity'].toString()) *
            double.parse(item['price'].toString()));
      }
      return sum.toStringAsFixed(2);
    }

    useEffect(() {
      loadData();
    }, const []);

    return Scaffold(
      body: Container(
          color: color.state == 'dark' ? bgPrimaryDark : bgPrimary,
          padding: EdgeInsets.only(top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Cart",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: color.state == 'dark'
                                ? Colors.white
                                : Color(0xFF1B1B1B)),
                      ),
                    ),
                    closable ? CloseWidget() : SizedBox()
                  ],
                ),
              ),
              SizedBox(height: 20),
              selected.value.length > 0 && cartState.state.length > 0
                  ? Padding(
                      padding: EdgeInsets.only(left: 25, right: 25, bottom: 20),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            "${selected.value.length} selected",
                            style: TextStyle(color: Color(0xFF898989)),
                          )),
                          Row(
                            children: [
                              InkWell(
                                onTap: selectAll,
                                child: Container(
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        iconsPath + 'plus.svg',
                                        color: color.state == 'dark'
                                            ? darkModeText
                                            : Color(0xFF1C1C1C),
                                        width: 18,
                                      ),
                                      SizedBox(width: 2),
                                      Text("Select all",
                                          style: TextStyle(
                                              color: color.state == 'dark'
                                                  ? darkModeText
                                                  : Color(0xFF1C1C1C))),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              InkWell(
                                onTap: deleteSelection,
                                child: Container(
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        iconsPath + 'trash.svg',
                                        color: color.state == 'dark'
                                            ? darkModeText
                                            : Color(0xFF1C1C1C),
                                        width: 18,
                                      ),
                                      SizedBox(width: 2),
                                      Text("Delete",
                                          style: TextStyle(
                                              color: color.state == 'dark'
                                                  ? darkModeText
                                                  : Color(0xFF1C1C1C))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  : SizedBox(),
              cartState.state.length == 0
                  ? Expanded(
                      child: Center(
                        child: EmptyError(
                            showAction: false,
                            loadData: loadData,
                            message: "You have nothing in the cart."),
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(top: 4),
                          child: Column(
                              children: cartState.state
                                  .asMap()
                                  .entries
                                  .map((product) => EachCartItem(
                                        product: product.value,
                                        toggleSelect: toggleSelect,
                                        selected: selected,
                                      ))
                                  .toList()),
                        ),
                      ),
                    ),
              cartState.state.length == 0
                  ? SizedBox()
                  : Container(
                      padding: EdgeInsets.only(
                          top: 10, left: 25, right: 25, bottom: 20),
                      color: color.state == 'dark'
                          ? Color(0xFF000205)
                          : Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Total",
                                      style: TextStyle(
                                        color: Color(0xFF999999),
                                        fontSize: 14,
                                      )),
                                  SizedBox(height: 5),
                                  Text("${currency.state}${calculateCart()}",
                                      style: TextStyle(
                                          color: color.state == 'dark'
                                              ? Colors.white
                                              : primaryText,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: loading.value ? 0.3 : 1,
                            child: TextButton(
                                onPressed: loading.value ? () => {} : checkout,
                                style: TextButton.styleFrom(
                                    backgroundColor: Color(0xFF0692B0),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 60)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        loading.value
                                            ? "Checkout..."
                                            : "Checkout",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                                    SizedBox(width: 10),
                                    SvgPicture.asset(
                                        iconsPath + 'arrow-right.svg',
                                        color: Colors.white)
                                  ],
                                )),
                          ),
                        ],
                      ),
                    )
            ],
          )),
    );
  }
}
