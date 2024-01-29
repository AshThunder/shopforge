import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';

class ProductCheckoutList extends HookWidget {
  const ProductCheckoutList({
    Key? key,
    //required this.sfname,
  }) : super(key: key);

  //final TextEditingController sfname;

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final cartState = useProvider(cartProvider);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
                color: color.state == 'dark'
                    ? Color(0xFF292922).withOpacity(0.3)
                    : Color(0xFF292922).withOpacity(0.04),
                borderRadius: BorderRadius.circular(4)),
            child: Table(
              columnWidths: {
                0: IntrinsicColumnWidth(),
                1: IntrinsicColumnWidth()
              },
              border: TableBorder.all(
                  color: Colors.transparent, style: BorderStyle.none, width: 1),
              children: [
                TableRow(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: color.state == 'dark'
                                    ? darkModeText
                                    : primaryText)),
                        SizedBox(height: 10)
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Subtotal',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: color.state == 'dark'
                                    ? darkModeText
                                    : primaryText)),
                        SizedBox(height: 10)
                      ])
                ]),
                ...cartState.state.map(
                  (product) => TableRow(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EachProductCheckoutList(product: product),
                      ],
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                "\$${(double.parse(product['quantity'].toString()) * double.parse(product['price'].toString())).toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: color.state == 'dark'
                                        ? darkModeTextHigh
                                        : primaryText,
                                    fontWeight: FontWeight.w500),
                              ))
                        ]),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EachProductCheckoutList extends HookWidget {
  final Map product;
  const EachProductCheckoutList({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    List selections = product['selections'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 32.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                      color: Color(0xFFF3F3E8),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: product['photo'].length > 0
                              ? Image.network("${product['photo']}").image
                              : Image.asset("assets/images/placeholder.png")
                                  .image),
                      borderRadius: BorderRadius.all(Radius.circular(2.0)))),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${product['name']}",
                          style: TextStyle(
                              color: color.state == 'dark'
                                  ? darkModeTextHigh
                                  : Color(0xFF595959)),
                        ),
                        SizedBox(height: 6),
                        Text("x ${product['quantity']}",
                            style: TextStyle(
                                color: color.state == 'dark'
                                    ? darkModeText
                                    : primaryText,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
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
                                                    fontSize: 13)),
                                            SizedBox(width: 6),
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
                                                            fontSize: 13)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ))
                                .toList()),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
