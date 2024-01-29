import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/shop_action.dart';

class ChangeQuantityConst extends HookWidget {
  const ChangeQuantityConst({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Map product;
  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final cartState = useProvider(cartProvider);
    changeQty(String type) async {
      if (type == 'plus') {
        product['quantity'] = product['quantity'] + 1;
      } else {
        if (product['quantity'] > 1)
          product['quantity'] = product['quantity'] - 1;
      }
      await ShopAction().updateCartSingle(
          product['product_key'], product['quantity'], cartState);
    }

    return Container(
      width: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colorPrimary),
          color: colorPrimary.withOpacity(0.05)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => changeQty('minus'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: SvgPicture.asset(
                iconsPath + 'minus.svg',
                width: 22,
                color: colorPrimary,
              ),
            ),
          ),
          Text(
            "${product['quantity']}".padLeft(2, "0"),
            style: TextStyle(
                color: color.state == 'dark' ? darkModeText : primaryText,
                fontWeight: FontWeight.w500),
          ),
          InkWell(
            onTap: () => changeQty('plus'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: SvgPicture.asset(
                iconsPath + 'plus.svg',
                width: 22,
                color: colorPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
