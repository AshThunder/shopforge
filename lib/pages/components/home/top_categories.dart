import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/error_messages/empty_error.dart';
import 'package:shopforge/pages/components/error_messages/network_error.dart';
import 'package:shopforge/pages/components/loaders/top_categories_loader.dart';
import 'package:shopforge/screens/categories.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';

import 'each_top_categories.dart';

class TopCategories extends HookWidget {
  TopCategories({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = useProvider(categoryProvider);
    final color = useProvider(colorProvider);

    final loading = useState(true);
    final loadingError = useState(true);
    void getCategories() async {
      loading.value = true;
      loadingError.value = false;
      try {
        var response = await Network()
            .getAsync("products/categories?per_page=50&orderby=term_group");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          List nested = await ShopAction().nestCategories(body as List);
          nested.sort((a, b) => a["name"].compareTo(b["name"]));
          loading.value = false;
          loadingError.value = false;
          categories.state = nested;
          var box = await Hive.openBox('appBox');
          box.put('categories', json.encode(nested));
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

    useEffect(() {
      getCategories();
    }, const []);
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(left: 25),
                child: Text(
                  "Top Categories",
                  style: TextStyle(
                      color: color.state == 'dark' ? Colors.white : primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              )),
              loading.value && categories.state.length > 0
                  ? Container(
                      margin: EdgeInsets.only(right: 35),
                      child: SpinKitWanderingCubes(
                        color: colorPrimary,
                        size: 18.0,
                      ),
                    )
                  : InkWell(
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Categories()))
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 25),
                        child: Text(
                          "See all",
                          style: TextStyle(
                              color: color.state == 'dark'
                                  ? darkModeText
                                  : primaryTextLow),
                        ),
                      ),
                    ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: loading.value && categories.state.length == 0
                      ? Row(
                          children: [
                            SizedBox(width: 25),
                            Shimmer.fromColors(
                                baseColor: Colors.black.withOpacity(0.2),
                                highlightColor: Colors.black.withOpacity(0.5),
                                child: TopCategoriesLoader()),
                            SizedBox(width: 10),
                          ],
                        )
                      : loadingError.value && categories.state.length == 0
                          ? Center(
                              child: NetworkError(
                                  loadData: getCategories,
                                  isSmall: true,
                                  message: "Network error,"),
                            )
                          : categories.state.length > 0
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 25),
                                    ...categories.state.map((category) => Row(
                                          children: [
                                            EachTopCategories(category),
                                            SizedBox(width: 15)
                                          ],
                                        )),
                                    SizedBox(width: 10),
                                  ],
                                )
                              : Center(
                                  child: EmptyError(
                                      loadData: getCategories,
                                      isSmall: true,
                                      message: "No product found,"),
                                ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
