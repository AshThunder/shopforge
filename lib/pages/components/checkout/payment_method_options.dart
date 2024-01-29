import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';

class PaymentMethodOption extends HookWidget {
  const PaymentMethodOption({
    Key? key,
    required this.choosePayment,
    required this.completeOrder,
  }) : super(key: key);

  final Function choosePayment, completeOrder;

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final paymentMethods = useProvider(paymentMethodsProvider);
    final checkingOut = useProvider(checkingOutProvider);
    final loadingPayments = useState(true);
    final loadingPaymentsError = useState(false);

    final selectedPayment = useState(0);

    loadPayments() async {
      loadingPayments.value = true;
      loadingPaymentsError.value = false;
      try {
        var response = await Network().getAsync("payment_gateways");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          loadingPayments.value = false;
          loadingPaymentsError.value = false;
          paymentMethods.state = body;
          choosePayment(0);
        } else {
          loadingPayments.value = false;
          loadingPaymentsError.value = true;
        }
      } catch (e) {
        loadingPayments.value = false;
        loadingPaymentsError.value = true;
        print(e);
      }
    }

    useEffect(() {
      loadPayments();
    }, const []);

    return SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
            color: color.state == 'dark' ? primaryText : Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4), topRight: Radius.circular(4))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CloseWidget(),
              ],
            ),
            Text(
              "How do you wish to pay?",
              style: TextStyle(
                  color: color.state == 'dark' ? Colors.white : primaryText,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 25),
            Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              decoration: BoxDecoration(
                  color: color.state == 'dark'
                      ? Color(0xFFEFEFE1).withOpacity(0.1)
                      : Color(0xFFF6F6ED),
                  borderRadius: BorderRadius.circular(4)),
              child: loadingPayments.value
                  ? Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: SpinKitFadingCube(
                        color: colorPrimary,
                        size: 30.0,
                      ),
                    )
                  : loadingPaymentsError.value
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text("Unable to load payment methods",
                                      style: TextStyle(
                                          color: Color(0xFF8F8F8F),
                                          fontSize: 14)),
                                  SizedBox(height: 10),
                                  InkWell(
                                    onTap: loadPayments,
                                    child: Text("Tap to retry",
                                        style: TextStyle(
                                            color: color.state == 'dark'
                                                ? darkModeTextHigh
                                                : primaryText,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            ...paymentMethods.state
                                .where((element) => element['enabled'] == true)
                                .toList()
                                .asMap()
                                .entries
                                .map((payment) => EachPaymentMethod(
                                    defaultValue: payment.key == 0 ? 2 : 0,
                                    paymentKey: payment.key,
                                    paymentValue: payment.value,
                                    choosePayment: choosePayment,
                                    selectedPayment: selectedPayment)),
                          ],
                        ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(top: 12),
              child: Opacity(
                opacity:
                    (loadingPayments.value || loadingPaymentsError.value) ||
                            checkingOut.state
                        ? 0.2
                        : 1,
                child: ButtonWidget(
                  action:
                      (loadingPayments.value || loadingPaymentsError.value) ||
                              checkingOut.state
                          ? () {}
                          : completeOrder,
                  text: "Complete Order",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EachPaymentMethod extends HookWidget {
  const EachPaymentMethod(
      {Key? key,
      required this.defaultValue,
      required this.paymentKey,
      required this.paymentValue,
      required this.choosePayment,
      required this.selectedPayment})
      : super(key: key);

  final int defaultValue;
  final int paymentKey;
  final Map paymentValue;
  final ValueNotifier selectedPayment;
  final Function choosePayment;

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final firstState = useState(defaultValue);

    _handleRadioValueChange(value) {
      selectedPayment.value = value;
      choosePayment(value);
    }

    return Container(
      margin: EdgeInsets.only(top: paymentKey == 0 ? 0 : 16),
      child: Column(
        children: [
          InkWell(
            onTap: () => {
              selectedPayment.value = paymentKey,
              firstState.value = firstState.value == 2 ? 0 : 2,
              choosePayment(paymentKey)
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor: color.state == 'dark'
                              ? darkModeTextHigh
                              : Colors.black38,
                        ),
                        child: SizedBox(
                          width: 22.0,
                          height: 22.0,
                          child: Radio(
                            value: paymentKey,
                            toggleable: true,
                            activeColor: colorPrimary,
                            groupValue: selectedPayment.value,
                            onChanged: _handleRadioValueChange,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(right: 20),
                          child: Text('${paymentValue['title']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: color.state == 'dark'
                                      ? darkModeTextHigh
                                      : primaryText)),
                        ),
                      ),
                    ],
                  ),
                ),
                RotatedBox(
                  quarterTurns: firstState.value,
                  child: SvgPicture.asset(
                    iconsPath + "chevron-down.svg",
                    color:
                        color.state == 'dark' ? darkModeTextHigh : primaryText,
                  ),
                )
              ],
            ),
          ),
          firstState.value == 0
              ? SizedBox()
              : Container(
                  margin: EdgeInsets.only(top: 10, left: 3),
                  child: Text(
                    "${paymentValue['description']}",
                    style: TextStyle(
                        color: color.state == 'dark'
                            ? darkModeText.withOpacity(0.8)
                            : Color(0xFF595959),
                        height: 1.6),
                  ),
                ),
        ],
      ),
    );
  }
}
