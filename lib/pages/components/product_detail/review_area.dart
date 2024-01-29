import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/product_detail/reviews.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';

class ReviewArea extends HookWidget {
  final Map product;
  final ValueNotifier<List> reviews;
  const ReviewArea({Key? key, required this.product, required this.reviews})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final toggleMode = useState(0);
    final loading = useState(true);
    final loadingError = useState(false);

    void loadData() async {
      var box = await Hive.openBox('appBox');
      loading.value = true;
      try {
        if (box.get("review_${product['id']}") != null) {
          reviews.value = jsonDecode(box.get("review_${product['id']}"));
        }
        var response = await Network()
            .getAsync("products/reviews?per_page=50&product=${product['id']}");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          loading.value = false;
          loadingError.value = false;
          reviews.value = body;
          box.put("review_${product['id']}", json.encode(body));
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
      loadData();
    }, const []);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.state == 'dark' ? darkModeBg : Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: color.state == 'dark' ? appBoxShadowDark : appBoxShadow,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => {
              toggleMode.value = toggleMode.value == 3 ? 0 : 3,
            },
            child: Row(
              children: [
                Expanded(
                  child: Text("Reviews",
                      style: TextStyle(
                          color: color.state == 'dark'
                              ? Colors.white
                              : primaryText,
                          fontWeight: FontWeight.w500,
                          fontSize: 14)),
                ),
                RotatedBox(
                  quarterTurns: toggleMode.value,
                  child: SvgPicture.asset(
                    iconsPath + "chevron-down.svg",
                    color: color.state == 'dark'
                        ? Colors.white
                        : Color(0xFF282828),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: toggleMode.value == 3 ? 0 : 15),
          toggleMode.value == 3
              ? SizedBox()
              : Container(
                  child: Column(
                    children: [
                      loading.value && reviews.value.length == 0
                          ? Container(
                              margin: EdgeInsets.symmetric(vertical: 20),
                              child: SpinKitFadingCube(
                                color: colorPrimary,
                                size: 30.0,
                              ),
                            )
                          : loadingError.value && reviews.value.length == 0
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Text("Unable to load reviews",
                                              style: TextStyle(
                                                  color: Color(0xFF8F8F8F),
                                                  fontSize: 14)),
                                          SizedBox(height: 10),
                                          InkWell(
                                            onTap: loadData,
                                            child: Text("Tap to retry",
                                                style: TextStyle(
                                                    color: color.state == 'dark'
                                                        ? darkModeTextHigh
                                                        : primaryText,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : reviews.value.length > 0
                                  ? ReviewGraph(reviews: reviews.value)
                                  : Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Text("No review found",
                                          style: TextStyle(
                                              color: Color(0xFF8F8F8F),
                                              fontSize: 14)),
                                    ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Reviews(product: product, revs: reviews)))
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Write review",
                              style: TextStyle(
                                  height: 1,
                                  color: color.state == 'dark'
                                      ? Colors.white
                                      : primaryText,
                                  fontWeight: FontWeight.w500),
                            ),
                            SvgPicture.asset(
                              iconsPath + "chevron-right.svg",
                              color: color.state == 'dark'
                                  ? Colors.white
                                  : primaryText,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
