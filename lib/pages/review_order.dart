import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/config/payment.dart';
import 'package:shopforge/pages/checkout_success.dart';
import 'package:shopforge/pages/components/checkout/checkout_total_area.dart';
import 'package:shopforge/pages/components/checkout/product_checkout_list.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';

import 'components/checkout/billing_fields.dart';
import 'components/checkout/payment_method_options.dart';
import 'components/checkout/shipping_fields.dart';
import 'components/shop/close_widget.dart';

class ReviewOrder extends HookWidget {
  final Map formData;
  ReviewOrder({
    Key? key,
    required this.formData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final account = useProvider(accountProvider);
    final cartState = useProvider(cartProvider);
    final shippingMethods = useProvider(shippingMethodsProvider);
    final paymentMethods = useProvider(paymentMethodsProvider);
    final checkingOut = useProvider(checkingOutProvider);
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

    final different = useState(formData['different']);
    final checkError = useState(false);

    final billingState = useState(0);

    final shippingState = useState(0);
    final currentShipping = useState({});
    final shippingPrice = useState(0.0);

    final loadingShippingMethods = useState(true);
    final loadingShippingMethodsError = useState(false);

    final checkingOutError = useState(false);

    final currentPayment = useState({});

    choosePayment(value) {
      if (paymentMethods.state[value] != null) {
        currentPayment.value = paymentMethods.state
            .where((element) => element['enabled'] == true)
            .toList()[value];
      }
    }

    calculateCart() {
      double sum = 0;
      for (var item in cartState.state) {
        sum += (int.parse(item['quantity'].toString()) *
            double.parse(item['price'].toString()));
      }
      return sum.toStringAsFixed(2);
    }

    createOrder(formData) async {
      try {
        var response = await Network().postAsync("orders", formData);
        //var body = json.decode(response.body);
        if (response['id'] != null) {
          checkingOut.state = false;
          checkingOutError.value = false;
          ShopAction().newToastSuccess(context, "Order created successfully");
          cartState.state = [];

          var box = await Hive.openBox('appBox');
          box.delete('cart');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CheckoutSuccess()),
          );
        } else {
          checkingOut.state = false;
          checkingOutError.value = true;
          ShopAction().newToastError(
              context, "Unable to complete order, try again later");
        }
      } catch (e) {
        print(e);
        checkingOut.state = false;
        checkingOutError.value = true;
        ShopAction().newToastError(
            context, "Unable to create order, check your internet connection.");
      }
    }

    updateProfile(formData) async {
      try {
        var response = await Network()
            .postAsync("customers/${account.state['id']}", formData);
        if (response['id'] != null) {
          account.state = response;
          var box = await Hive.openBox('appBox');
          box.put('account', json.encode(response));
        } else {
          ShopAction()
              .newToastError(context, "Unable to proceed, please try again.");
        }
      } catch (e) {
        print(e);
        ShopAction().newToastError(
            context, "Unable to proceed, check your internet connection.");
      }
    }

    completeOrder() async {
      Map formData = {};
      formData["shipping_lines"] = [
        {
          "method_id": currentShipping.value['method_id'],
          "method_title": currentShipping.value['method_title'],
          "total": shippingPrice.value.toString()
        }
      ];
      formData["billing"] = {
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
      };
      formData["shipping"] = {
        "first_name": different.value ? sfname.text : bfname.text,
        "last_name": different.value ? slname.text : blname.text,
        "address_1": different.value ? saddress1.text : baddress1.text,
        "address_2": "",
        "city": different.value ? scity.text : bcity.text,
        "state": different.value ? sstate.text : bstate.text,
        "postcode": different.value ? spostalcode.text : bpostalcode.text,
        "country": different.value ? scountry.text : bcountry.text
      };
      List lineItems = [];
      for (var item in cartState.state) {
        List selections = item['selections'];
        List metaData = [];
        for (var selection in selections) {
          Map newMeta = {selection['title']: selection['option']};
          metaData = [newMeta, ...metaData];
        }
        Map newItem = {
          "product_id": item['product_id'],
          "quantity": item['quantity'],
          "variation_id": item['variation_id'],
          "meta_data": metaData,
        };
        lineItems = [newItem, ...lineItems];
      }
      formData["line_items"] = lineItems;
      final status = await OneSignal.shared.getDeviceState();
      final String? osUserID = status?.userId;
      formData["meta_data"] = [
        {"key": "player_id", "value": "$osUserID"}
      ];

      if (currentPayment.value['id'] != null) {
        formData["payment_method"] = currentPayment.value['id'];
        formData["payment_method_title"] = currentPayment.value['title'];
        formData['customer_id'] = account.state['id'];
        if (currentPayment.value['id'] == "bacs" ||
            currentPayment.value['id'] == "cheque" ||
            currentPayment.value['id'] == "cod") {
          checkingOut.state = true;
          checkingOutError.value = false;
          await updateProfile(formData);
          createOrder(formData);
        } else if (currentPayment.value['id'] == "ppcp-gateway") {
          List items = [];
          double subtotal = 0.0;
          for (var each in cartState.state) {
            subtotal += double.parse(each['price'].toString()) *
                int.parse(each['quantity'].toString());
            Map newItem = {
              "name": each['name'],
              "quantity": each['quantity'],
              "price": each['price'].toStringAsFixed(2),
              "currency": "USD",
            };
            items = [newItem, ...items];
          }

          BuildContext myContext = context;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => UsePaypal(
                  sandboxMode: false,
                  clientId: PAYPAL_CONFIG_SANDBOX_MODE
                      ? paypalConfig['sandbox']['clientId']
                      : paypalConfig['live']['clientId'],
                  secretKey: PAYPAL_CONFIG_SANDBOX_MODE
                      ? paypalConfig['sandbox']['secretKey']
                      : paypalConfig['live']['secretKey'],
                  returnURL: "https://shopforge.durabyte.org/return",
                  cancelURL: "https://shopforge.durabyte.org/cancel",
                  transactions: [
                    {
                      "amount": {
                        "total": (double.parse(calculateCart()) +
                                shippingPrice.value)
                            .toStringAsFixed(2),
                        "currency": "USD",
                        "details": {
                          "subtotal": subtotal.toStringAsFixed(2),
                          "shipping": shippingPrice.value.toStringAsFixed(2),
                          "shipping_discount": 0
                        }
                      },
                      "description": "The payment transaction description.",
                      "item_list": {
                        "items": items,
                      }
                    }
                  ],
                  note: "Contact us for any questions on your order.",
                  onSuccess: (Map params) async {
                    print("onSuccess: $params");
                    await updateProfile(formData);
                    await createOrder(formData);

                    Navigator.pop(context);
                  },
                  onCancel: (params) {
                    ShopAction()
                        .newToastError(context, "Transaction cancelled");
                    print('cancelled: $params');
                  },
                  onError: (error) {
                    print("onError: $error");
                    if (error is Map) {
                      ShopAction()
                          .newToastError(myContext, "${error['message']}");
                    } else {
                      ShopAction()
                          .newToastError(myContext, "${error.toString()}");
                    }
                  }),
            ),
          );
        } else {
          print(currentPayment.value['id']);
          ShopAction().newToastError(
              context, "The payment gateway is not yet setup, try again later");
        }
      } else {
        ShopAction().newToastError(context, "Please select a payment method");
      }
    }

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
          if (currentShipping.value['id'] != null) {
            if (cartState.state.length > 0) {
              account.state['billing'] = formData["billing"];
              account.state['shipping'] = formData["shipping"];
              var box = await Hive.openBox('appBox');
              box.put('account', json.encode(account.state));
              showMaterialModalBottomSheet(
                backgroundColor: Colors.transparent,
                barrierColor: Colors.black.withOpacity(0.5),
                context: context,
                builder: (context) => PaymentMethodOption(
                    choosePayment: choosePayment, completeOrder: completeOrder),
              );
            } else {
              ShopAction()
                  .newToastError(context, "You have nothing in the cart");
            }
          } else {
            ShopAction()
                .newToastError(context, "Please select a shipping method");
          }
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

    loadShipping() async {
      loadingShippingMethods.value = true;
      loadingShippingMethodsError.value = false;
      try {
        var response = await Network().getAsync("shipping/zones/0/methods");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          loadingShippingMethods.value = false;
          loadingShippingMethodsError.value = false;
          shippingMethods.state = body;
        } else {
          loadingShippingMethods.value = false;
          loadingShippingMethodsError.value = true;
        }
      } catch (e) {
        loadingShippingMethods.value = false;
        loadingShippingMethodsError.value = true;
        print(e);
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

      loadShipping();
    }

    setShipping(option) {
      currentShipping.value = option;
      if (option['method_id'] == 'flat_rate') {
        shippingPrice.value =
            double.parse(option['settings']?['cost']?['value']);
      } else {
        shippingPrice.value = 0;
      }
      //print(option);
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
                            "Review Order",
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
                                header: InkWell(
                                  onTap: () => billingState.value =
                                      billingState.value == 2 ? 0 : 2,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 25,
                                        right: 25,
                                        top: 10,
                                        bottom:
                                            billingState.value == 0 ? 0 : 25),
                                    transform: Matrix4.translationValues(
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
                                                "Billing Information",
                                                style: TextStyle(
                                                    color: color.state == 'dark'
                                                        ? darkModeTextHigh
                                                        : primaryText,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            RotatedBox(
                                              quarterTurns: billingState.value,
                                              child: SvgPicture.asset(
                                                iconsPath + "chevron-down.svg",
                                                color: color.state == 'dark'
                                                    ? darkModeTextHigh
                                                    : primaryText,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                content: billingState.value == 0
                                    ? Container(
                                        child: Row(
                                        children: [
                                          SizedBox(),
                                        ],
                                      ))
                                    : BillingFields(
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
                              SizedBox(
                                  height: billingState.value == 0 ? 10 : 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StickyHeader(
                                    header: InkWell(
                                      onTap: () => shippingState.value =
                                          shippingState.value == 2 ? 0 : 2,
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 25,
                                            right: 25,
                                            top: 10,
                                            bottom: billingState.value == 0
                                                ? 20
                                                : 25),
                                        transform: Matrix4.translationValues(
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
                                                            : primaryText,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                RotatedBox(
                                                  quarterTurns:
                                                      shippingState.value,
                                                  child: SvgPicture.asset(
                                                    iconsPath +
                                                        "chevron-down.svg",
                                                    color: color.state == 'dark'
                                                        ? darkModeTextHigh
                                                        : primaryText,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    content: shippingState.value == 0
                                        ? Container(
                                            child: Row(
                                            children: [
                                              SizedBox(),
                                            ],
                                          ))
                                        : Column(
                                            children: [
                                              InkWell(
                                                onTap: () => different.value =
                                                    !different.value,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: 25, right: 25),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        child: SizedBox(
                                                          width: 22.0,
                                                          height: 22.0,
                                                          child: Checkbox(
                                                            checkColor:
                                                                Colors.white,
                                                            activeColor:
                                                                colorPrimary,
                                                            side: BorderSide(
                                                                color: color.state ==
                                                                        'dark'
                                                                    ? darkModeTextHigh
                                                                    : Color(
                                                                        0xFF1C1C1C),
                                                                width: 1.2),
                                                            value:
                                                                different.value,
                                                            onChanged:
                                                                (bool? value) {
                                                              different.value =
                                                                  !different
                                                                      .value;
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "Ship to a different address",
                                                        style: TextStyle(
                                                            color: color.state ==
                                                                    'dark'
                                                                ? darkModeText
                                                                : primaryText,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 25),
                                              different.value
                                                  ? ShippingFields(
                                                      sfname: sfname,
                                                      checkError: checkError,
                                                      slname: slname,
                                                      saddress1: saddress1,
                                                      scity: scity,
                                                      sstate: sstate,
                                                      spostalcode: spostalcode,
                                                      scountry: scountry)
                                                  : SizedBox(),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: shippingState.value == 0 ? 0 : 25),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Your Order",
                                            style: TextStyle(
                                                color: color.state == 'dark'
                                                    ? darkModeTextHigh
                                                    : primaryText,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),

                                    //
                                    ProductCheckoutList(),

                                    SizedBox(height: 20),
                                    //
                                    loadingShippingMethods.value
                                        ? Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 40),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: Color(0xFF292922)
                                                    .withOpacity(0.04)),
                                            child: SpinKitFadingCube(
                                              color: colorPrimary,
                                              size: 30.0,
                                            ),
                                          )
                                        : loadingShippingMethodsError.value
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 20),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                            "Unable to load shipping methods",
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF8F8F8F),
                                                                fontSize: 14)),
                                                        SizedBox(height: 10),
                                                        InkWell(
                                                          onTap: loadShipping,
                                                          child: Text(
                                                              "Tap to retry",
                                                              style: TextStyle(
                                                                  color: color.state ==
                                                                          'dark'
                                                                      ? darkModeTextHigh
                                                                      : primaryText,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      14)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : CheckoutTotalArea(
                                                shippingMethods:
                                                    shippingMethods.state,
                                                setShipping: setShipping,
                                                shippingPrice: shippingPrice),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              )
                            ]),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    child: ButtonWidget(
                      action: checkout,
                      text: "Continue",
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
