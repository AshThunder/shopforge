import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/error_messages/empty_error.dart';
import 'package:shopforge/pages/components/error_messages/network_error.dart';
import 'package:shopforge/pages/components/loaders/rec_products_loader.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopforge/utils/network.dart';

import 'each_rec_products.dart';

class RecProducts extends HookWidget {
  RecProducts({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recommendations = useProvider(recommendationsProvider);
    final color = useProvider(colorProvider);
    final loading = useState(true);
    final loadingError = useState(true);

    void getRecommendations() async {
      loading.value = true;
      loadingError.value = false;
      try {
        var response = await Network()
            .getAsync("products?per_page=10&order_by=popularity");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          loading.value = false;
          loadingError.value = false;
          recommendations.state = body;
          var box = await Hive.openBox('appBox');
          box.put('recommendations', json.encode(body));
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
      getRecommendations();
    }, const []);

    return Container(
      margin: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(left: 25),
                child: Text(
                  "Recommended Products",
                  style: TextStyle(
                      color: color.state == 'dark' ? Colors.white : primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
              loading.value && recommendations.state.length > 0
                  ? Container(
                      margin: EdgeInsets.only(right: 35),
                      child: SpinKitWanderingCubes(
                        color: colorPrimary,
                        size: 18.0,
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          SizedBox(height: 20),
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: loading.value && recommendations.state.length == 0
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 25),
                        Shimmer.fromColors(
                            baseColor: Colors.black.withOpacity(0.2),
                            highlightColor: Colors.black.withOpacity(0.5),
                            child: RecProductsLoader()),
                        SizedBox(width: 10)
                      ],
                    )
                  : loadingError.value && recommendations.state.length == 0
                      ? Center(
                          child: NetworkError(
                              loadData: getRecommendations,
                              isSmall: true,
                              message: "Network error,"),
                        )
                      : recommendations.state.length > 0
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 25),
                                ...recommendations.state
                                    .map((recommendation) => Row(
                                          children: [
                                            EachRecProducts(recommendation),
                                            SizedBox(width: 15)
                                          ],
                                        )),
                                SizedBox(width: 10)
                              ],
                            )
                          : Center(
                              child: EmptyError(
                                  loadData: getRecommendations,
                                  isSmall: true,
                                  message: "No product found,"),
                            ),
            ),
          )
        ],
      ),
    );
  }
}
