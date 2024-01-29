import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:shopforge/screens/orders/status_chip.dart';
import 'package:shopforge/utils/Providers.dart';

class OrderDetail extends HookWidget {
  final Map order;
  const OrderDetail({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    String date = Jiffy(order['date_created_gmt'], "yyyy-MM-dd").yMMMMd;
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
                            "Order #${order['number']}",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: color.state == 'dark'
                                    ? Colors.white
                                    : Color(0xFF1B1B1B)),
                          ),
                        ),
                        CloseWidget()
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(child: StatusChip(status: order['status'])),
                        Text(
                          "$date",
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF949494)),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Container(
                              padding: EdgeInsets.only(top: 10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 25),
                                            child: Text(
                                              "Order Information",
                                              style: TextStyle(
                                                color: color.state == 'dark'
                                                    ? darkModeText
                                                    : primaryText,
                                              ),
                                            )),
                                        SizedBox(height: 15),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 15),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 20),
                                                  decoration: BoxDecoration(
                                                    color: color.state == 'dark'
                                                        ? darkModeBg
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    boxShadow:
                                                        color.state == 'dark'
                                                            ? appBoxShadowDark
                                                            : appBoxShadow,
                                                  ),
                                                  child: Table(
                                                    columnWidths: {
                                                      0: IntrinsicColumnWidth(),
                                                      1: IntrinsicColumnWidth()
                                                    },
                                                    border: TableBorder.all(
                                                        color:
                                                            Colors.transparent,
                                                        style: BorderStyle.none,
                                                        width: 1),
                                                    children: [
                                                      TableRow(children: [
                                                        Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Email",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF949494)),
                                                              ),
                                                              SizedBox(
                                                                  height: 8),
                                                              Text(
                                                                  "${order['billing']['email']}",
                                                                  style: TextStyle(
                                                                      color: color.state ==
                                                                              'dark'
                                                                          ? darkModeTextHigh
                                                                          : primaryText,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
                                                            ]),
                                                        Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        "Total",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0xFF949494))),
                                                                    SizedBox(
                                                                        height:
                                                                            8),
                                                                    Text(
                                                                        "${order['currency']}${order['total']}",
                                                                        style: TextStyle(
                                                                            color: color.state == 'dark'
                                                                                ? darkModeTextHigh
                                                                                : primaryText,
                                                                            fontWeight:
                                                                                FontWeight.w500)),
                                                                  ],
                                                                ),
                                                              ),
                                                            ])
                                                      ]),
                                                      TableRow(children: [
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 30),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "Payment Method",
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xFF949494)),
                                                                ),
                                                                SizedBox(
                                                                    height: 8),
                                                                Text(
                                                                    "${order['payment_method_title']}",
                                                                    style: TextStyle(
                                                                        color: color.state ==
                                                                                'dark'
                                                                            ? darkModeTextHigh
                                                                            : primaryText,
                                                                        fontWeight:
                                                                            FontWeight.w500)),
                                                              ]),
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 30),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              20),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                          "Shipping Method",
                                                                          style:
                                                                              TextStyle(color: Color(0xFF949494))),
                                                                      SizedBox(
                                                                          height:
                                                                              8),
                                                                      Text(
                                                                          "${order['shipping_lines']?[0]?['method_title']}",
                                                                          style: TextStyle(
                                                                              color: color.state == 'dark' ? darkModeTextHigh : primaryText,
                                                                              fontWeight: FontWeight.w500)),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ]),
                                                        )
                                                      ]),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 40),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 25),
                                            child: Text(
                                              "Purchased Items",
                                              style: TextStyle(
                                                color: color.state == 'dark'
                                                    ? darkModeText
                                                    : primaryText,
                                              ),
                                            )),
                                        SizedBox(height: 15),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 15),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: color.state == 'dark'
                                                        ? darkModeBg
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    boxShadow:
                                                        color.state == 'dark'
                                                            ? appBoxShadowDark
                                                            : appBoxShadow,
                                                  ),
                                                  child: Table(
                                                    columnWidths: {
                                                      0: IntrinsicColumnWidth(),
                                                      1: IntrinsicColumnWidth(),
                                                    },
                                                    border: TableBorder.all(
                                                        color:
                                                            Colors.transparent,
                                                        style: BorderStyle.none,
                                                        width: 1),
                                                    children: [
                                                      ...(order['line_items']
                                                              as List)
                                                          .asMap()
                                                          .entries
                                                          .map(
                                                            (product) =>
                                                                TableRow(
                                                                    children: [
                                                                  Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.symmetric(vertical: 15),
                                                                          child:
                                                                              Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                margin: EdgeInsets.only(right: 10),
                                                                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: color.state == 'dark' ? Color(0xFFEFEFE1).withOpacity(0.1) : Color(0xFFEFEFE1)),
                                                                                child: Text(
                                                                                  "${(product.key + 1) < 10 ? '0' : ''}${(product.key + 1).toString()}",
                                                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF656565)),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Container(
                                                                                  margin: EdgeInsets.only(right: 10),
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text.rich(
                                                                                          TextSpan(children: [
                                                                                            TextSpan(text: "${product.value['name']}", style: TextStyle(color: color.state == 'dark' ? darkModeText : primaryText)),
                                                                                            TextSpan(text: " ×${product.value['quantity']}", style: TextStyle(color: Color(0xFFBD3030), fontWeight: FontWeight.w600))
                                                                                          ]),
                                                                                          style: TextStyle(color: primaryText)),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                  Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.symmetric(vertical: 15),
                                                                          child:
                                                                              Text(
                                                                            "\$${product.value['total']}",
                                                                            style:
                                                                                TextStyle(color: color.state == 'dark' ? darkModeTextHigh : primaryText, fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ]),
                                                          ),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    order['payment_method'] == 'bacs'
                                        ? Container(
                                            margin: EdgeInsets.only(top: 40),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 25),
                                                    child: Text(
                                                      "Payment Information",
                                                      style: TextStyle(
                                                        color: color.state ==
                                                                'dark'
                                                            ? darkModeText
                                                            : primaryText,
                                                      ),
                                                    )),
                                                SizedBox(height: 15),
                                                Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 15),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                            vertical: 20),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          color.state == 'dark'
                                                              ? darkModeBg
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      boxShadow:
                                                          color.state == 'dark'
                                                              ? appBoxShadowDark
                                                              : appBoxShadow,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "Please use the payment information below to make payment, we start processing your order as soon as we recieve payment",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF606060),
                                                              height: 1.4),
                                                        ),
                                                        SizedBox(height: 20),
                                                        Row(
                                                          children: [
                                                            Table(
                                                              columnWidths: {
                                                                0: IntrinsicColumnWidth(),
                                                                1: IntrinsicColumnWidth()
                                                              },
                                                              border: TableBorder.all(
                                                                  color: Colors
                                                                      .transparent,
                                                                  style:
                                                                      BorderStyle
                                                                          .none,
                                                                  width: 1),
                                                              children: [
                                                                TableRow(
                                                                    children: [
                                                                      Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "Account Name",
                                                                              style: TextStyle(color: Color(0xFF949494)),
                                                                            ),
                                                                            SizedBox(height: 8),
                                                                            Text("Shopforge App",
                                                                                style: TextStyle(color: color.state == 'dark' ? darkModeTextHigh : primaryText, fontWeight: FontWeight.w500)),
                                                                          ]),
                                                                      Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              padding: EdgeInsets.only(left: 20),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text("Account Number", style: TextStyle(color: Color(0xFF949494))),
                                                                                  SizedBox(height: 8),
                                                                                  Text("0933843545453", style: TextStyle(color: color.state == 'dark' ? darkModeTextHigh : primaryText, fontWeight: FontWeight.w500)),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ])
                                                                    ]),
                                                                TableRow(
                                                                    children: [
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                30),
                                                                        child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "Bank Name",
                                                                                style: TextStyle(color: Color(0xFF949494)),
                                                                              ),
                                                                              SizedBox(height: 8),
                                                                              Text("Bank of America", style: TextStyle(color: color.state == 'dark' ? darkModeTextHigh : primaryText, fontWeight: FontWeight.w500)),
                                                                            ]),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                30),
                                                                        child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                padding: EdgeInsets.only(left: 20),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text("Sort Code", style: TextStyle(color: Color(0xFF949494))),
                                                                                    SizedBox(height: 8),
                                                                                    Text("33843545453", style: TextStyle(color: color.state == 'dark' ? darkModeTextHigh : primaryText, fontWeight: FontWeight.w500)),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ]),
                                                                      )
                                                                    ]),
                                                                TableRow(
                                                                    children: [
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                30),
                                                                        child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "IBAN",
                                                                                style: TextStyle(color: Color(0xFF949494)),
                                                                              ),
                                                                              SizedBox(height: 8),
                                                                              Text("TEST-IBAN", style: TextStyle(color: color.state == 'dark' ? darkModeTextHigh : primaryText, fontWeight: FontWeight.w500)),
                                                                            ]),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                30),
                                                                        child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                padding: EdgeInsets.only(left: 20),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text("BIC/SWIFT Code", style: TextStyle(color: Color(0xFF949494))),
                                                                                    SizedBox(height: 8),
                                                                                    Text("0933845453", style: TextStyle(color: color.state == 'dark' ? darkModeTextHigh : primaryText, fontWeight: FontWeight.w500)),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ]),
                                                                      )
                                                                    ]),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          )
                                        : SizedBox(),
                                    order['payment_method'] == 'cheque'
                                        ? Container(
                                            margin: EdgeInsets.only(top: 40),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 25),
                                                      child: Text(
                                                        "Payment Information",
                                                        style: TextStyle(
                                                          color: color.state ==
                                                                  'dark'
                                                              ? darkModeText
                                                              : primaryText,
                                                        ),
                                                      )),
                                                  SizedBox(height: 15),
                                                  Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 20),
                                                      decoration: BoxDecoration(
                                                        color: color.state ==
                                                                'dark'
                                                            ? darkModeBg
                                                            : Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        boxShadow: color
                                                                    .state ==
                                                                'dark'
                                                            ? appBoxShadowDark
                                                            : appBoxShadow,
                                                      ),
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Please address your check to the following address, we start processing your order as soon as we recieve and confirm the check",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF606060),
                                                                  height: 1.4),
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Text(
                                                                "Shopforge Plaza, Williams Street, \nDenvers, Colorado, \nUSA. 12323",
                                                                style: TextStyle(
                                                                    color: color
                                                                                .state ==
                                                                            'dark'
                                                                        ? darkModeTextHigh
                                                                        : primaryText,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    height:
                                                                        1.4)),
                                                          ]))
                                                ]),
                                          )
                                        : SizedBox(),
                                    SizedBox(height: 40),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 25),
                                            child: Text(
                                              "Addresses",
                                              style: TextStyle(
                                                color: color.state == 'dark'
                                                    ? darkModeText
                                                    : primaryText,
                                              ),
                                            )),
                                        SizedBox(height: 15),
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 20),
                                            decoration: BoxDecoration(
                                              color: color.state == 'dark'
                                                  ? darkModeBg
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              boxShadow: color.state == 'dark'
                                                  ? appBoxShadowDark
                                                  : appBoxShadow,
                                            ),
                                            child: Table(
                                              columnWidths: {
                                                0: FlexColumnWidth(),
                                                1: FlexColumnWidth()
                                              },
                                              border: TableBorder.all(
                                                  color: Colors.transparent,
                                                  style: BorderStyle.none,
                                                  width: 1),
                                              children: [
                                                TableRow(children: [
                                                  Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Billing Address",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF949494)),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                            "${order['billing']['first_name']} ${order['billing']['last_name']}, \n${order['billing']['address_1']}, ${order['billing']['city']}, ${order['billing']['state']}. \n${order['billing']['country']}. ${order['billing']['postcode']}",
                                                            style: TextStyle(
                                                                color: color.state ==
                                                                        'dark'
                                                                    ? darkModeTextHigh
                                                                    : primaryText,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                height: 1.4)),
                                                      ]),
                                                  Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  "Shipping Address",
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xFF949494))),
                                                              SizedBox(
                                                                  height: 8),
                                                              Text(
                                                                  "${order['shipping']['first_name']} ${order['shipping']['last_name']}, \n${order['shipping']['address_1']}, ${order['shipping']['city']}, ${order['shipping']['state']}. \n${order['shipping']['country']}. ${order['shipping']['postcode']}",
                                                                  style: TextStyle(
                                                                      color: color.state ==
                                                                              'dark'
                                                                          ? darkModeTextHigh
                                                                          : primaryText,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      height:
                                                                          1.4)),
                                                            ],
                                                          ),
                                                        ),
                                                      ])
                                                ]),
                                              ],
                                            )),
                                      ],
                                    ),
                                    SizedBox(height: 40)
                                  ])))),
                ])));
  }
}
