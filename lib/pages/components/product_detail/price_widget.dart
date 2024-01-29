import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';

class PriceWidget extends HookWidget {
  const PriceWidget({
    Key? key,
    required this.product,
    required this.currentVariation,
  }) : super(key: key);

  final Map product;
  final ValueNotifier<Map> currentVariation;

  @override
  Widget build(BuildContext context) {
    final currency = useProvider(currencyProvider);
    final color = useProvider(colorProvider);

    double regularPrice = currentVariation.value['regular_price'] != null &&
            currentVariation.value['price'].toString().length > 0
        ? double.parse(currentVariation.value['regular_price'].toString()) >
                double.parse(currentVariation.value['price'].toString())
            ? double.parse(currentVariation.value['regular_price'].toString())
            : double.parse("0")
        : product['regular_price'].toString().length > 0 &&
                product['price'].toString().length > 0 &&
                double.parse(product['regular_price'].toString()) >
                    double.parse(product['price'].toString())
            ? double.parse(product['regular_price'].toString())
            : double.parse("0");
    double price = currentVariation.value['price'] != null &&
            currentVariation.value['price'].toString().length > 0
        ? double.parse(currentVariation.value['price'].toString())
        : product['price'].toString().length > 0
            ? double.parse(product['price'].toString())
            : double.parse("0");
    return Row(
      children: [
        regularPrice > 0
            ? Container(
                margin: EdgeInsets.only(right: 10),
                child: Text("${currency.state}$regularPrice",
                    style: TextStyle(
                        color: color.state == 'dark'
                            ? Color(0xFF656565)
                            : Color(0xFFA0A0A0),
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              )
            : SizedBox(),
        Text("${currency.state}$price",
            style: TextStyle(
                color: color.state == 'dark' ? darkModeText : Color(0xFF2D2D2D),
                fontWeight: FontWeight.w600,
                fontSize: 16)),
        regularPrice > 0
            ? Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                margin: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                    color: Color(0xFFF92316),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(
                  "-${(((regularPrice - price) / regularPrice) * 100).toStringAsFixed(1)}%",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ))
            : SizedBox()
      ],
    );
  }
}
