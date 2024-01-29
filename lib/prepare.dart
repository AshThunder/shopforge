import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/onboarding.dart';

import 'pages/dashboard.dart';
import 'utils/Providers.dart';

class Prepare extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final cartState = useProvider(cartProvider);
    final wishlists = useProvider(wishlistsProvider);
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final orders = useProvider(ordersProvider);
    final recommendations = useProvider(recommendationsProvider);
    final categories = useProvider(categoryProvider);
    final color = useProvider(colorProvider);
    final boarded = useState('no');

    final loaded = useState(false);

    startSequence() async {
      await Hive.initFlutter();
      var box = await Hive.openBox('appBox');
      box.delete('wishlistitems');
      if (box.get('color') != null) {
        color.state = box.get('color');
      }
      loaded.value = true;
      if (box.get('cart') != null) {
        cartState.state = jsonDecode(box.get('cart'));
      }
      if (box.get('wishlists') != null) {
        wishlists.state = jsonDecode(box.get('wishlists'));
      }
      if (box.get('account') != null) {
        account.state = jsonDecode(box.get('account'));
      }
      if (box.get('orders') != null) {
        orders.state = jsonDecode(box.get('orders'));
      }
      if (box.get('recommendations') != null) {
        recommendations.state = jsonDecode(box.get('recommendations'));
      }
      if (box.get('categories') != null) {
        categories.state = jsonDecode(box.get('categories'));
      }
      if (box.get('token') != null) {
        token.state = box.get('token');
      }
      if (box.get('boarded') != null) {
        boarded.value = await box.get('boarded');
      }
      await Future.delayed(Duration(seconds: 2));
      if (boarded.value == 'no') {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Onboarding()),
            (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Dashboard()),
            (Route<dynamic> route) => false);
      }
    }

    useEffect(() {
      startSequence();
    }, const []);
    return Scaffold(
      body: Container(
        color: color.state == 'dark' ? bgPrimaryDark : bgPrimary,
        child: Center(
          child: loaded.value
              ? SvgPicture.asset(
                  iconsPath + 'ShopForge.svg',
                  height: 20,
                  color: color.state == 'dark' ? Colors.white : Colors.black,
                )
              : SizedBox(),
        ),
      ),
    );
  }
}
