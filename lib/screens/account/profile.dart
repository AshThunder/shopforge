import 'package:flutter/material.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';

class Profile extends HookWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final wishlists = useProvider(wishlistsProvider);
    final orders = useProvider(ordersProvider);
    loadData() async {
      var result = await Network().validateToken();
      if (result == false) {
        await ShopAction().logout(account, token, wishlists, orders);
      }
    }

    useEffect(() {
      loadData();
    }, const []);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            body: Container(
                height: MediaQuery.of(context).size.height,
                color: color.state == 'dark' ? bgPrimaryDark : bgPrimary,
                padding: EdgeInsets.only(
                  top: 30,
                ),
                child: Form(
                    child: Column(children: [
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            "My Profile",
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
                  SizedBox(height: 20),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Container(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                        SizedBox(height: 30),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              "Profile Information",
                              style: TextStyle(
                                color: color.state == 'dark'
                                    ? darkModeText
                                    : primaryText,
                              ),
                            )),
                        SizedBox(height: 20),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            decoration: BoxDecoration(
                              color: color.state == 'dark'
                                  ? darkModeBg
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: color.state == 'dark'
                                  ? appBoxShadowDark
                                  : appBoxShadow,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Table(
                                      columnWidths: {
                                        0: IntrinsicColumnWidth(),
                                        1: IntrinsicColumnWidth()
                                      },
                                      border: TableBorder.all(
                                          color: Colors.transparent,
                                          style: BorderStyle.none,
                                          width: 1),
                                      children: [
                                        TableRow(children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "First Name",
                                                  style: TextStyle(
                                                      color: Color(0xFF949494)),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                    "${account.state['first_name']}",
                                                    style: TextStyle(
                                                        color: color.state ==
                                                                'dark'
                                                            ? darkModeTextHigh
                                                            : primaryText,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ]),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(left: 20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text("Last Name",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF949494))),
                                                      SizedBox(height: 8),
                                                      Text(
                                                          "${account.state['last_name']}",
                                                          style: TextStyle(
                                                              color: color.state ==
                                                                      'dark'
                                                                  ? darkModeTextHigh
                                                                  : primaryText,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                    ],
                                                  ),
                                                ),
                                              ])
                                        ]),
                                        TableRow(children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 30),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Email",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF949494)),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                      "${account.state['email']}",
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
                                            margin: EdgeInsets.only(top: 30),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 20),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text("Username",
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF949494))),
                                                        SizedBox(height: 8),
                                                        Text(
                                                            "@${account.state['username']}",
                                                            style: TextStyle(
                                                                color: color.state ==
                                                                        'dark'
                                                                    ? darkModeTextHigh
                                                                    : primaryText,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                      ],
                                                    ),
                                                  ),
                                                ]),
                                          )
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(height: 30),
                        account.state['billing']['city'].length == 0
                            ? SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 25),
                                      child: Text(
                                        "Addresses",
                                        style: TextStyle(
                                          color: color.state == 'dark'
                                              ? darkModeText
                                              : primaryText,
                                        ),
                                      )),
                                  SizedBox(height: 20),
                                  Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      decoration: BoxDecoration(
                                        color: color.state == 'dark'
                                            ? darkModeBg
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(4),
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
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Billing Address",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF949494)),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                      "${account.state['billing']['first_name']} ${account.state['billing']['last_name']}, \n${account.state['billing']['address_1']}, ${account.state['billing']['city']}, ${account.state['billing']['state']}. \n${account.state['billing']['country']}. ${account.state['billing']['postcode']}",
                                                      style: TextStyle(
                                                          color: color.state ==
                                                                  'dark'
                                                              ? darkModeTextHigh
                                                              : primaryText,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          height: 1.4)),
                                                ]),
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 20),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text("Shipping Address",
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF949494))),
                                                        SizedBox(height: 8),
                                                        Text(
                                                            "${account.state['shipping']['first_name']} ${account.state['shipping']['last_name']}, \n${account.state['shipping']['address_1']}, ${account.state['shipping']['city']}, ${account.state['shipping']['state']}. \n${account.state['shipping']['country']}. ${account.state['shipping']['postcode']}",
                                                            style: TextStyle(
                                                                color: color.state ==
                                                                        'dark'
                                                                    ? darkModeTextHigh
                                                                    : primaryText,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                height: 1.4)),
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
                      ]))))
                ])))));
  }
}
