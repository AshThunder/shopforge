import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/error_messages/empty_error.dart';
import 'package:shopforge/pages/components/error_messages/network_error.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';

import 'order_detail.dart';

class LoadOrder extends HookWidget {
  final int orderID;
  const LoadOrder({Key? key, required this.orderID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loading = useState(true);
    final loadingError = useState(true);
    final order = useState({});
    void loadData() async {
      try {
        loading.value = true;
        loadingError.value = false;

        var response = await Network().getAsync("orders/$orderID");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          order.value = body;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OrderDetail(order: body),
            ),
          );
        } else {
          if (response.statusCode == 404) {
            Navigator.of(context).pop(context);

            ShopAction().newToastError(context, "Order not found");
          }
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

    return Scaffold(
      body: loading.value && order.value['id'] == null
          ? Center(
              child: SpinKitFadingCube(
                color: colorPrimary,
                size: 30.0,
              ),
            )
          : loadingError.value && order.value['id'] == null
              ? Center(
                  child: NetworkError(
                      loadData: loadData, message: "Network error,"),
                )
              : Center(
                  child: EmptyError(
                      loadData: loadData, message: "Order not found,"),
                ),
    );
  }
}
