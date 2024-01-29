import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';

import '../../product_detail.dart';

class EachRecProducts extends HookWidget {
  final Map recommendation;

  const EachRecProducts(this.recommendation);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final currency = useProvider(currencyProvider);
    double regularPrice = recommendation['regular_price'].toString().length > 0
        ? double.parse(recommendation['regular_price'].toString())
        : 0.0;
    double price = recommendation['price'].toString().length > 0
        ? double.parse(recommendation['price'].toString())
        : 0.0;
    return InkWell(
      onTap: () => {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetail(product: recommendation)))
      },
      child: Container(
        width: 125,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: "recommendation-${recommendation['slug']}",
              child: Stack(
                children: [
                  Container(
                      width: 125,
                      height: 133,
                      decoration: BoxDecoration(
                          color: Color(0xFFF3F3E8),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: recommendation["images"] != null &&
                                      recommendation["images"].length > 0
                                  ? Image.network(
                                          recommendation["images"][0]["src"])
                                      .image
                                  : Image.asset("assets/images/placeholder.png")
                                      .image),
                          borderRadius:
                              BorderRadius.all(Radius.circular(2.0)))),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: (regularPrice - price) > 0
                        ? Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  margin: EdgeInsets.only(left: 0),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF92316),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    "-${(((regularPrice - price) / regularPrice) * 100).toStringAsFixed(1)}%",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  )),
                            ],
                          )
                        : SizedBox(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text("${recommendation['name']}",
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                    color:
                        color.state == 'dark' ? darkModeTextHigh : primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            Row(
              children: [
                recommendation['type'] == 'variable'
                    ? SizedBox()
                    : (regularPrice - price) == 0
                        ? SizedBox()
                        : Container(
                            margin: EdgeInsets.only(right: 6),
                            child: Text(
                                "${currency.state}${recommendation['regular_price']}",
                                style: TextStyle(
                                    color: Color(0xFFADADAD),
                                    fontSize: 13,
                                    decoration: TextDecoration.lineThrough)),
                          ),
                Text(
                    "${recommendation['type'] == 'variable' ? 'From ' : ''}${currency.state}${recommendation['price']}",
                    style: TextStyle(
                        color: (regularPrice - price) == 0 ||
                                recommendation['type'] == 'variable'
                            ? color.state == 'dark'
                                ? Color(0xFFADADAD)
                                : primaryTextLow
                            : Color(0xFFBD3030),
                        fontSize: 13)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
