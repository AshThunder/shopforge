import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/shop_action.dart';

class CheckoutTotalArea extends HookWidget {
  const CheckoutTotalArea({
    Key? key,
    required this.shippingMethods,
    required this.shippingPrice,
    required this.setShipping,
  }) : super(key: key);

  final List shippingMethods;
  final ValueNotifier<double> shippingPrice;
  final Function setShipping;
  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final cartState = useProvider(cartProvider);
    final currency = useProvider(currencyProvider);
    final _radioValue = useState(0);

    calculateCart() {
      double sum = 0;
      for (var item in cartState.state) {
        sum += (int.parse(item['quantity'].toString()) *
            double.parse(item['price'].toString()));
      }
      return sum.toStringAsFixed(2);
    }

    _handleRadioValueChange(value) {
      if (value != null) {
        Map getSelection =
            shippingMethods.firstWhere((element) => element['id'] == value);
        if (getSelection['method_id'] == 'free_shipping' &&
            getSelection['settings']?['requires']?['value'] == 'min_amount' &&
            double.parse((getSelection['settings']?['min_amount']?['value'])
                    .toString()) >
                double.parse(calculateCart())) {
          ShopAction().newToastError(context,
              "You are required to order up to ${currency.state}${getSelection['settings']?['min_amount']?['value']} before you can use free shipping");
        } else {
          _radioValue.value = value is String ? int.parse(value) : value;
          setShipping(getSelection);
        }
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.symmetric(),
        decoration: BoxDecoration(
            color: color.state == 'dark'
                ? Color(0xFFEFEFE1).withOpacity(0.05)
                : Color(0xFFEFEFE1).withOpacity(0.2),
            borderRadius: BorderRadius.circular(4)),
        child: Wrap(
          children: [
            Table(
              columnWidths: {
                0: FixedColumnWidth(100.0),
                1: IntrinsicColumnWidth()
              },
              border: TableBorder.all(
                  color: Colors.transparent, style: BorderStyle.none, width: 1),
              children: [
                TableRow(children: [
                  Container(
                    padding: EdgeInsets.only(right: 20, top: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Subtotal',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: color.state == 'dark'
                                      ? darkModeText
                                      : primaryText)),
                          SizedBox(height: 10)
                        ]),
                  ),
                  Container(
                    color: Color(0xFF292922).withOpacity(0.04),
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('${currency.state}${calculateCart()}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: color.state == 'dark'
                                          ? darkModeTextHigh
                                          : primaryText)),
                            ],
                          ),
                          SizedBox(height: 10)
                        ]),
                  )
                ]),
                TableRow(children: [
                  Container(
                    padding: EdgeInsets.only(right: 20, top: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Shipping',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: color.state == 'dark'
                                      ? darkModeText
                                      : primaryText)),
                        ]),
                  ),
                  Container(
                    color: Color(0xFF292922).withOpacity(0.04),
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: color.state == 'dark'
                                  ? darkModeTextHigh
                                  : Colors.black38,
                            ),
                            child: Column(
                              children: shippingMethods
                                  .where(
                                      (element) => element['enabled'] == true)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((sm) => InkWell(
                                        onTap: () => _handleRadioValueChange(
                                            sm.value['id']),
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 22.0,
                                                height: 22.0,
                                                child: Radio(
                                                    value: sm.value['id'],
                                                    toggleable: true,
                                                    activeColor: colorPrimary,
                                                    groupValue:
                                                        _radioValue.value,
                                                    onChanged:
                                                        _handleRadioValueChange),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: 20),
                                                  child: Text(
                                                      "${sm.value['title']} ${sm.value['method_id'] == 'flat_rate' ? "for ${currency.state}${sm.value['settings']?['cost']?['value']}" : ''}",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: color.state ==
                                                                  'dark'
                                                              ? darkModeTextHigh
                                                              : primaryText)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ]),
                  )
                ]),
                TableRow(children: [
                  Container(
                    padding: EdgeInsets.only(right: 20, top: 20, bottom: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: color.state == 'dark'
                                      ? darkModeText
                                      : primaryText)),
                          SizedBox(height: 10)
                        ]),
                  ),
                  Container(
                    color: Color(0xFF292922).withOpacity(0.04),
                    padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${currency.state}${(double.parse(calculateCart()) + shippingPrice.value).toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: color.state == 'dark'
                                      ? darkModeTextHigh
                                      : primaryText)),
                          SizedBox(height: 10)
                        ]),
                  )
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
