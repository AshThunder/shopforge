import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/shop_action.dart';

import 'change_quantity_const.dart';

class EachCartItem extends HookWidget {
  final Function toggleSelect;
  final Map product;
  final ValueNotifier<List> selected;
  const EachCartItem({
    Key? key,
    required this.product,
    required this.toggleSelect,
    required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final cartState = useProvider(cartProvider);
    final currency = useProvider(currencyProvider);
    List selections = product['selections'];
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, bottom: 20),
      decoration: BoxDecoration(
        color: color.state == 'dark' ? darkModeBg : Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: color.state == 'dark' ? appBoxShadowDark : appBoxShadow,
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: 87,
                      height: 130,
                      decoration: BoxDecoration(
                          color: Color(0xFFF3F3E8),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: product['photo'].length > 0
                                  ? Image.network("${product['photo']}").image
                                  : Image.asset("assets/images/placeholder.png")
                                      .image),
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                ],
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            transform: Matrix4.translationValues(0, -7, 0.0),
                            child: Text(
                              "${product['name']}",
                              style: TextStyle(
                                  color: color.state == 'dark'
                                      ? darkModeTextHigh
                                      : primaryText,
                                  fontWeight: FontWeight.w600,
                                  height: 1.6),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: SizedBox(
                            width: 22.0,
                            height: 22.0,
                            child: Checkbox(
                              checkColor: Colors.white,
                              activeColor: colorPrimary,
                              side: BorderSide(
                                  color: Color(0xFF656565), width: 1.2),
                              value: selected.value
                                      .contains(product['product_key'])
                                  ? true
                                  : false,
                              onChanged: (bool? value) {
                                //checked.value = !checked.value;
                                toggleSelect(product['product_key']);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6),
                        Text("${currency.state}${product['price']}",
                            style: TextStyle(
                                color: Color(0xFFBD3030),
                                fontWeight: FontWeight.w500,
                                height: 1)),
                        // Text("${product['product_key']}"),
                        SizedBox(height: 20),
                        Column(
                            children: selections
                                .asMap()
                                .entries
                                .map((atr) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: atr.key == 0 ? 0 : 5),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("${atr.value['title']}:",
                                                style: TextStyle(
                                                    color: Color(0xFF272727),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    height: 1)),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                        "${atr.value['option']}",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF8F8F8F),
                                                            fontSize: 13,
                                                            height: 1)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ))
                                .toList()),
                        SizedBox(height: 10),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ChangeQuantityConst(
                          product: product,
                        ),
                        InkWell(
                          onTap: () => ShopAction().deleteCartSingle(
                              product['product_key'], cartState),
                          child: Container(
                            padding: EdgeInsets.only(left: 10, top: 10),
                            child: SvgPicture.asset(
                              iconsPath + 'trash.svg',
                              color: Color(0xFF656565),
                              width: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
