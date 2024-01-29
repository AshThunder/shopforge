import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/error_messages/empty_error.dart';
import 'package:shopforge/pages/components/error_messages/network_error.dart';
import 'package:shopforge/pages/components/shop/each_wishlist_item.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';

class Wishlist extends HookWidget {
  const Wishlist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final wishlists = useProvider(wishlistsProvider);
    final selected = useState([]);
    final wishlistItems = useState([]);
    final loading = useState(true);
    final loadingError = useState(true);

    toggleSelect(String productID) {
      if (selected.value
              .where((element) => element.toString() == productID)
              .length >
          0) {
        selected.value
            .removeWhere((element) => element.toString() == productID);
        List myList = selected.value;
        selected.value = [];
        selected.value = myList;
      } else {
        selected.value.add(productID);
        selected.value = selected.value.toSet().toList();
      }
    }

    selectAll() {
      List allItems = wishlists.state.map((item) => item).toList();
      if (selected.value.length < allItems.length) {
        selected.value = allItems;
      } else {
        selected.value = [];
      }
    }

    loadData() async {
      var box = await Hive.openBox('appBox');
      if (box.get('wishlists') != null) {
        wishlists.state = await jsonDecode(box.get('wishlists'));
      }
      if (box.get('wishlistitems') != null) {
        wishlistItems.value = await jsonDecode(box.get('wishlistitems'));
      }
      if (wishlists.state.length > 0) {
        loading.value = true;
        loadingError.value = false;
        String filter =
            wishlists.state.toString().replaceAll('[', '').replaceAll(']', '');
        try {
          var response =
              await Network().getAsync("products?per_page=20&include=$filter");
          var body = json.decode(response.body);
          if (response.statusCode == 200) {
            loading.value = false;
            loadingError.value = false;
            wishlistItems.value = body;
            var box = await Hive.openBox('appBox');
            box.put('wishlistitems', json.encode(body));
          } else {
            loading.value = false;
            loadingError.value = true;
          }
        } catch (e) {
          loading.value = false;
          loadingError.value = true;
          print(e);
        }
      }
    }

    deleteSelection() async {
      for (var item in selected.value) {
        await ShopAction().deleteWishListSingle(item.toString(), wishlists);
      }
      selected.value = [];
      await loadData();
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
                        "Wishlist",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: color.state == 'dark'
                                ? Colors.white
                                : Color(0xFF1B1B1B)),
                      ),
                    ),
                    loading.value &&
                            wishlistItems.value.length > 0 &&
                            wishlists.state.length > 0
                        ? Container(
                            margin: EdgeInsets.only(right: 0),
                            child: SpinKitWanderingCubes(
                              color: colorPrimary,
                              size: 18.0,
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              SizedBox(height: 30),
              selected.value.length > 0 && wishlistItems.value.length > 0
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
              wishlists.state.length == 0
                  ? Expanded(
                      child: Center(
                        child: EmptyError(
                            showAction: false,
                            loadData: loadData,
                            message: "You have nothing in your wishlist."),
                      ),
                    )
                  : (loading.value && wishlistItems.value.length == 0)
                      ? Expanded(
                          child: Center(
                            child: SpinKitFadingCube(
                              color: colorPrimary,
                              size: 30.0,
                            ),
                          ),
                        )
                      : loadingError.value && wishlistItems.value.length == 0
                          ? Expanded(
                              child: Center(
                                child: NetworkError(
                                    loadData: loadData,
                                    message: "Network error,"),
                              ),
                            )
                          : wishlistItems.value.length > 0
                              ? Expanded(
                                  child: SingleChildScrollView(
                                    child: Container(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Column(
                                          children: wishlists.state
                                              .asMap()
                                              .entries
                                              .map((product) => wishlistItems
                                                          .value
                                                          .where((element) =>
                                                              element['id']
                                                                  .toString() ==
                                                              product.value
                                                                  .toString())
                                                          .length >
                                                      0
                                                  ? EachWishlistItem(
                                                      product: wishlistItems
                                                          .value
                                                          .firstWhere((element) =>
                                                              element['id']
                                                                  .toString() ==
                                                              product.value
                                                                  .toString()),
                                                      toggleSelect:
                                                          toggleSelect,
                                                      selected: selected,
                                                    )
                                                  : SizedBox())
                                              .toList()),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: Center(
                                    child: EmptyError(
                                        loadData: loadData,
                                        message:
                                            "You have nothing in your wishlist,"),
                                  ),
                                ),
            ],
          )),
    );
  }
}
