import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/screens/order_list.dart';
import 'package:shopforge/utils/Providers.dart';

import 'components/form/botton_widget.dart';
import 'dashboard.dart';

class CheckoutSuccess extends HookWidget {
  const CheckoutSuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    popAm() {
      // int count = 0;
      // Navigator.of(context).popUntil((_) => count++ >= 4);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Dashboard()),
          (Route<dynamic> route) => false);
    }

    return WillPopScope(
      onWillPop: () async {
        popAm();
        return false;
      },
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: color.state == 'dark' ? bgPrimaryDark : bgPrimary,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 120,
                  color: Color(0xFF0E7E19),
                ),
                SizedBox(height: 20),
                Container(
                  //margin: EdgeInsets.symmetric(horizontal: 15),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                  decoration: BoxDecoration(
                    color: color.state == 'dark' ? darkModeBg : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow:
                        color.state == 'dark' ? appBoxShadowDark : appBoxShadow,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Order Successful",
                        style: TextStyle(
                            fontSize: 20,
                            color: color.state == 'dark'
                                ? darkModeTextHigh
                                : primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Thank you for shopping with us 🎉.",
                        style: TextStyle(color: Color(0xFF595959)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ButtonWidget(
                      action: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderList()));
                      },
                      text: "View Orders",
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: popAm,
                  child: Text(
                    "Return to shop",
                    style: TextStyle(
                        color:
                            color.state == 'dark' ? darkModeText : primaryText),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
