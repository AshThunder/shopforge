import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/error_messages/empty_error.dart';
import 'package:shopforge/pages/components/error_messages/network_error.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:shopforge/screens/orders/order_detail.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';

import 'orders/status_chip.dart';

class OrderList extends HookWidget {
  const OrderList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final account = useProvider(accountProvider);
    final color = useProvider(colorProvider);
    final orders = useProvider(ordersProvider);

    final loading = useState(true);
    final loadingError = useState(false);
    final loadingMore = useState(false);
    final isLoadMoreDone = useState(false);
    final page = useState(1);
    final filter = useState("any");

    void loadData() async {
      loading.value = true;
      try {
        var response = await Network().getAsync(
            "orders?per_page=20&customer=${account.state['id']}&status=${filter.value}&page=${page.value}");
        var body = json.decode(response.body);
        page.value = 1;
        isLoadMoreDone.value = false;
        if (response.statusCode == 200) {
          loading.value = false;
          loadingError.value = false;
          orders.state = body;
          var box = await Hive.openBox('appBox');
          box.put('orders', json.encode(body));
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

    void loadMore() async {
      loadingMore.value = true;
      isLoadMoreDone.value = false;
      page.value++;
      try {
        var response = await Network().getAsync(
            "orders?per_page=20&customer=${account.state['id']}&status=${filter.value}&page=${page.value}");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          loadingMore.value = false;
          isLoadMoreDone.value = true;
          orders.state.addAll(body);
          var box = await Hive.openBox('appBox');
          box.put('orders', json.encode(orders.state));
        } else {
          loadingMore.value = false;
          isLoadMoreDone.value = true;
        }
      } catch (e) {
        loadingMore.value = false;
        isLoadMoreDone.value = true;
        print(e);
      }
    }

    useEffect(() {
      loadData();
    }, const []);
    return Scaffold(
        body: Container(
            color: color.state == 'dark' ? bgPrimaryDark : bgPrimary,
            padding: EdgeInsets.only(top: 30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Orders",
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
              Container(
                margin: EdgeInsets.only(top: 30, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    loading.value && orders.state.length > 0
                        ? Container(
                            margin: EdgeInsets.only(left: 35),
                            child: SpinKitFadingCube(
                              color: colorPrimary,
                              size: 20.0,
                            ),
                          )
                        : SizedBox(),
                    Container(
                      margin: EdgeInsets.only(right: 25),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          ButtonTheme(
                            child: DropdownButton<String>(
                              dropdownColor: color.state == 'dark'
                                  ? primaryText
                                  : Colors.white,
                              iconEnabledColor: color.state == 'dark'
                                  ? darkModeTextHigh
                                  : primaryText,
                              underline: SizedBox(),
                              isExpanded: false,
                              value: filter.value,
                              style: TextStyle(
                                  color: color.state == 'dark'
                                      ? darkModeTextHigh
                                      : primaryText),
                              items: [
                                DropdownMenuItem<String>(
                                  value: "any",
                                  child: Text("All Orders"),
                                ),
                                DropdownMenuItem<String>(
                                  value: "completed",
                                  child: Text("Completed"),
                                ),
                                DropdownMenuItem<String>(
                                  value: "pending",
                                  child: Text("Pending"),
                                ),
                                DropdownMenuItem<String>(
                                  value: "processing",
                                  child: Text("Processing"),
                                ),
                                DropdownMenuItem<String>(
                                  value: "on-hold",
                                  child: Text("On hold"),
                                ),
                                DropdownMenuItem<String>(
                                  value: "cancelled",
                                  child: Text("Cancelled"),
                                ),
                                DropdownMenuItem<String>(
                                  value: "refunded",
                                  child: Text("Refunded"),
                                ),
                                DropdownMenuItem<String>(
                                  value: "failed",
                                  child: Text("Failed"),
                                )
                              ],
                              hint: Text(
                                "Filter result",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              onChanged: (value) {
                                filter.value = value.toString();
                                loadData();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              loading.value && orders.state.length == 0
                  ? Expanded(
                      child: Center(
                        child: SpinKitFadingCube(
                          color: colorPrimary,
                          size: 30.0,
                        ),
                      ),
                    )
                  : loadingError.value && orders.state.length == 0
                      ? Expanded(
                          child: Center(
                            child: NetworkError(
                                loadData: loadData, message: "Network error,"),
                          ),
                        )
                      : orders.state.length > 0
                          ? Expanded(
                              child: RefreshIndicator(
                              onRefresh: () async {
                                if (!loading.value) loadData();
                              },
                              child: NotificationListener<ScrollNotification>(
                                onNotification:
                                    (ScrollNotification scrollInfo) {
                                  if (scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent) {
                                    if (!isLoadMoreDone.value &&
                                        !loadingMore.value) {
                                      loadMore();
                                    }
                                  }
                                  return false;
                                },
                                child: SingleChildScrollView(
                                    child: Container(
                                        padding: EdgeInsets.only(top: 0),
                                        child: Column(children: [
                                          ...orders.state
                                              .asMap()
                                              .entries
                                              .map((order) => EachOrderWidget(
                                                  order: order.value))
                                              .toList(),
                                          loadingMore.value
                                              ? Container(
                                                  margin: EdgeInsets.only(
                                                      top: 10, bottom: 20),
                                                  child: SpinKitRotatingCircle(
                                                    color: colorPrimary,
                                                    size: 30.0,
                                                  ),
                                                )
                                              : SizedBox()
                                        ]))),
                              ),
                            ))
                          : Expanded(
                              child: Center(
                                child: EmptyError(
                                    loadData: loadData,
                                    message: "No order found,"),
                              ),
                            ),
            ])));
  }
}

class EachOrderWidget extends HookWidget {
  final Map order;
  const EachOrderWidget({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    String date = Jiffy(order['date_created_gmt'], "yyyy-MM-dd").yMMMMd;
    return InkWell(
      onTap: () => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => OrderDetail(order: order)))
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: color.state == 'dark'
            ? BoxDecoration(
                color: darkModeBg,
                borderRadius: BorderRadius.circular(4),
                boxShadow: appBoxShadowDark,
              )
            : BoxDecoration(
                color: Color(0xFFEFEFE1),
                borderRadius: BorderRadius.circular(4)),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    child: Text(
                      "${order['line_items'].length > 0 ? order['line_items'][0]['name'] : ''} ${order['line_items'].length > 1 ? 'and ' + (order['line_items'].length - 1).toString() + ' others' : ''}",
                      style: TextStyle(
                          color: color.state == 'dark'
                              ? darkModeTextHigh
                              : primaryText,
                          fontWeight: FontWeight.w500,
                          height: 1.5),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: StatusChip(status: order['status']),
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total",
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF898989)),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "${order['currency']}${order['total']}",
                        style: TextStyle(
                            color: Color(0xFFBD3030),
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Order: #${order['number']}",
                      style: TextStyle(
                          fontSize: 13,
                          color: color.state == 'dark'
                              ? darkModeText
                              : Color(0xFF898989)),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "$date",
                      style: TextStyle(
                          fontSize: 13,
                          color: color.state == 'dark'
                              ? darkModeText.withOpacity(0.5)
                              : primaryText),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
