import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';
import 'package:shopforge/pages/review_order.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/shop_action.dart';

import 'components/checkout/billing_fields.dart';
import 'components/checkout/shipping_fields.dart';
import 'components/shop/close_widget.dart';

class Checkout extends HookWidget {
  const Checkout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final account = useProvider(accountProvider);
    final bfname = useTextEditingController();
    final blname = useTextEditingController();
    final baddress1 = useTextEditingController();
    final bcity = useTextEditingController();
    final bstate = useTextEditingController();
    final bpostalcode = useTextEditingController();
    final bcountry = useTextEditingController();
    final bemail = useTextEditingController();
    final bphone = useTextEditingController();

    final sfname = useTextEditingController();
    final slname = useTextEditingController();
    final saddress1 = useTextEditingController();
    final scity = useTextEditingController();
    final sstate = useTextEditingController();
    final spostalcode = useTextEditingController();
    final scountry = useTextEditingController();

    final different = useState(false);

    final checkError = useState(false);

    checkout() async {
      checkError.value = false;

      var formData = {
        "billing": {
          "first_name": bfname.text,
          "last_name": blname.text,
          "address_1": baddress1.text,
          "address_2": "",
          "city": bcity.text,
          "state": bstate.text,
          "postcode": bpostalcode.text,
          "country": bcountry.text,
          "email": bemail.text,
          "phone": bphone.text
        },
        "shipping": {
          "first_name": sfname.text,
          "last_name": slname.text,
          "address_1": saddress1.text,
          "address_2": "",
          "city": scity.text,
          "state": sstate.text,
          "postcode": spostalcode.text,
          "country": scountry.text
        },
        "different": different.value
      };
      if (ShopAction().validateBillingInfo(formData)) {
        if (ShopAction().validateEmails(bemail.text)) {
          account.state['billing'] = formData["billing"];
          account.state['shipping'] = formData["shipping"];

          var box = await Hive.openBox('appBox');
          box.put('account', json.encode(account.state));
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReviewOrder(formData: formData)),
          );
        } else {
          ShopAction().newToastError(
              context, "You have entered an invalid email, please check again");
        }
      } else {
        ShopAction().newToastError(
            context, "Some fields are required, please check again");

        checkError.value = true;
      }
    }

    loadData() {
      bfname.text = account.state['billing']?['first_name'];
      blname.text = account.state['billing']?['last_name'];
      baddress1.text = account.state['billing']?['address_1'];
      bcity.text = account.state['billing']?['city'];
      bstate.text = account.state['billing']?['state'];
      bpostalcode.text = account.state['billing']?['postcode'];
      bcountry.text = account.state['billing']?['country'].length > 0
          ? account.state['billing']['country']
          : "US";
      bemail.text = account.state['billing']?['email'];
      bphone.text = account.state['billing']?['phone'];

      sfname.text = account.state['shipping']?['first_name'];
      slname.text = account.state['shipping']?['last_name'];
      saddress1.text = account.state['shipping']?['address_1'];
      scity.text = account.state['shipping']?['city'];
      sstate.text = account.state['shipping']?['state'];
      spostalcode.text = account.state['shipping']?['postcode'];
      scountry.text = account.state['shipping']?['country'].length > 0
          ? account.state['shipping']['country']
          : "US";
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
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            "Checkout",
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
                              StickyHeader(
                                header: Container(
                                  padding: EdgeInsets.only(
                                      left: 25, right: 25, top: 10, bottom: 25),
                                  transform:
                                      Matrix4.translationValues(0.0, -3.0, 0.0),
                                  color: color.state == 'dark'
                                      ? bgPrimaryDark
                                      : Color(0xFFFFFFF5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Billing Information",
                                              style: TextStyle(
                                                  color: color.state == 'dark'
                                                      ? darkModeTextHigh
                                                      : primaryText,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                content: BillingFields(
                                    bfname: bfname,
                                    checkError: checkError,
                                    blname: blname,
                                    baddress1: baddress1,
                                    bcity: bcity,
                                    bstate: bstate,
                                    bpostalcode: bpostalcode,
                                    bcountry: bcountry,
                                    bemail: bemail,
                                    bphone: bphone),
                              ),
                              SizedBox(height: 20),
                              InkWell(
                                onTap: () => different.value = !different.value,
                                child: Container(
                                  padding: EdgeInsets.only(left: 25, right: 25),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: SizedBox(
                                          width: 22.0,
                                          height: 22.0,
                                          child: Checkbox(
                                            checkColor: Colors.white,
                                            activeColor: colorPrimary,
                                            side: BorderSide(
                                                color: color.state == 'dark'
                                                    ? darkModeTextHigh
                                                    : Color(0xFF1C1C1C),
                                                width: 1.2),
                                            value: different.value,
                                            onChanged: (bool? value) {
                                              different.value =
                                                  !different.value;
                                            },
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Ship to a different address",
                                        style: TextStyle(
                                            color: color.state == 'dark'
                                                ? darkModeText
                                                : primaryText,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 25),
                              different.value
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        StickyHeader(
                                          header: Container(
                                            padding: EdgeInsets.only(
                                                left: 25,
                                                right: 25,
                                                top: 10,
                                                bottom: 25),
                                            transform:
                                                Matrix4.translationValues(
                                                    0.0, -3.0, 0.0),
                                            color: color.state == 'dark'
                                                ? bgPrimaryDark
                                                : Color(0xFFFFFFF5),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Shipping Information",
                                                        style: TextStyle(
                                                            color: color.state ==
                                                                    'dark'
                                                                ? darkModeTextHigh
                                                                : Color(
                                                                    0xFF272727),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          content: ShippingFields(
                                              sfname: sfname,
                                              checkError: checkError,
                                              slname: slname,
                                              saddress1: saddress1,
                                              scity: scity,
                                              sstate: sstate,
                                              spostalcode: spostalcode,
                                              scountry: scountry),
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              SizedBox(height: 20),
                            ]),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    child: ButtonWidget(
                      action: checkout,
                      text: "Checkout",
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
