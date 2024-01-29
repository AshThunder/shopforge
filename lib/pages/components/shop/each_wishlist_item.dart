import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/shop_action.dart';

import '../../product_detail.dart';

class EachWishlistItem extends HookWidget {
  final Function toggleSelect;
  final Map product;
  final ValueNotifier<List> selected;
  const EachWishlistItem({
    Key? key,
    required this.product,
    required this.toggleSelect,
    required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final wishlists = useProvider(wishlistsProvider);
    final currency = useProvider(currencyProvider);
    List productImages = product["images"];
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
            InkWell(
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductDetail(product: product)))
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Hero(
                      tag: "recommendation-${product['slug']}",
                      child: Container(
                          width: 87,
                          height: 100,
                          decoration: BoxDecoration(
                              color: Color(0xFFF3F3E8),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: productImages[0] != null &&
                                          productImages[0]["src"].length > 0
                                      ? Image.network(
                                              "${productImages[0]?["src"]}")
                                          .image
                                      : Image.asset(
                                              "assets/images/placeholder.png")
                                          .image),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)))),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Container(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetail(product: product)))
                            },
                            child: Container(
                              transform: Matrix4.translationValues(0, -7, 0.0),
                              child: Text(
                                "${product['name']}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    color: color.state == 'dark'
                                        ? darkModeTextHigh
                                        : primaryText,
                                    fontWeight: FontWeight.w600,
                                    height: 1.6),
                              ),
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
                                      .contains(product['id'].toString())
                                  ? true
                                  : selected.value.contains(product['id'])
                                      ? true
                                      : false,
                              onChanged: (bool? value) {
                                //checked.value = !checked.value;
                                toggleSelect(product['id'].toString());
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetail(product: product)))
                      },
                      child: Text("${currency.state}${product['price']}",
                          style: TextStyle(
                              color: Color(0xFFBD3030),
                              fontWeight: FontWeight.w500,
                              height: 1)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => ShopAction().deleteWishListSingle(
                              product['id'].toString(), wishlists),
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
