import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shopforge/config/app.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shopforge/config/modules.dart';
import 'package:shopforge/pages/components/home/rec_products.dart';
import 'package:shopforge/pages/components/home/top_categories.dart';
import 'package:shopforge/screens/orders/load_order.dart';
import 'package:shopforge/utils/Providers.dart';

import 'cart.dart';

final List<String> bannerList = [
  'https://shopforge.durabyte.org/wp-content/uploads/2021/09/banner5-scaled.jpg',
  'https://shopforge.durabyte.org/wp-content/uploads/2021/09/banner3-scaled.jpg',
  'https://shopforge.durabyte.org/wp-content/uploads/2021/09/banner4-scaled.jpg',
  'https://shopforge.durabyte.org/wp-content/uploads/2021/09/banner2-scaled.jpg'
];

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final cartState = useProvider(cartProvider);
    CarouselController _controller = CarouselController();
    final _current = useState(0);

    Future<void> setupNotification() async {
      //Remove this method to stop OneSignal Debugging
      //OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

      OneSignal.shared.setAppId(ONESIGNAL_APP_ID);

      // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
      OneSignal.shared
          .promptUserForPushNotificationPermission()
          .then((accepted) {
        print("Accepted permission: $accepted");
      });

      OneSignal.shared.setNotificationWillShowInForegroundHandler(
          (OSNotificationReceivedEvent event) {
        // Will be called whenever a notification is received in foreground
        // Display Notification, pass null param for not displaying the notification
        event.complete(event.notification);
      });

      OneSignal.shared
          .setPermissionObserver((OSPermissionStateChanges changes) {
        // Will be called whenever the permission changes
        // (ie. user taps Allow on the permission prompt in iOS)
      });

      OneSignal.shared
          .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
        // Will be called whenever the subscription changes
        // (ie. user gets registered with OneSignal and gets a user ID)
      });

      OneSignal.shared.setEmailSubscriptionObserver(
          (OSEmailSubscriptionStateChanges emailChanges) {
        // Will be called whenever then user's email subscription changes
        // (ie. OneSignal.setEmail(email) is called and the user gets registered
      });
      OneSignal.shared
          .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
        // Will be called whenever a notification is opened/button pressed.
        if (result.notification.additionalData?['data'] != null &&
            result.notification.additionalData?['data']['order_id'] != null) {
          var orderID = result.notification.additionalData?['data']['order_id'];
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoadOrder(orderID: orderID)),
          );
        } else {
          print(result.notification.additionalData);
        }
      });
    }

    calculateCart() {
      var sum = 0;
      for (var item in cartState.state) {
        sum += int.parse(item['quantity'].toString());
      }
      return sum;
    }

    useEffect(() {
      setupNotification();
    }, const []);

    final List<Widget> imageSliders = bannerList
        .map((each) => Container(
              child: InkWell(
                onTap: null,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: color.state == 'dark'
                        ? darkModeText.withOpacity(0.02)
                        : Color(0xFFF3F3E8),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 25.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      child: Stack(
                        children: <Widget>[
                          Image.network('$each',
                              fit: BoxFit.cover, width: 1000.0),
                        ],
                      )),
                ),
              ),
            ))
        .toList();

    return Scaffold(
      body: Container(
          color: color.state == 'dark' ? bgPrimaryDark : bgPrimary,
          padding: EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(right: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 25, right: 25, bottom: 10, top: 10),
                        child: SvgPicture.asset(
                          color.state == 'dark'
                              ? iconsPath + 'hamburger-dark.svg'
                              : iconsPath + 'hamburger.svg',
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      iconsPath + 'ShopForge.svg',
                      height: 16,
                      color:
                          color.state == 'dark' ? Colors.white : Colors.black,
                    ),
                    InkWell(
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Cart(closable: true)))
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 25),
                        child: Row(
                          children: [
                            Container(
                              transform: Matrix4.translationValues(
                                  cartState.state.length > 0 ? 10.0 : 0,
                                  0.0,
                                  0.0),
                              child: SvgPicture.asset(
                                iconsPath + 'shopping-bag.svg',
                                color: color.state == 'dark'
                                    ? Colors.white
                                    : primaryText,
                              ),
                            ),
                            cartState.state.length > 0
                                ? InkWell(
                                    onTap: () => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Cart(closable: true)))
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: colorPrimary,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      transform: Matrix4.translationValues(
                                          0.0, -10.0, 0.0),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2.0, horizontal: 5.5),
                                        child: Text(
                                          "${calculateCart() == 1 ? '0' : ''}${calculateCart()}",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    CarouselSlider(
                      items: imageSliders,
                      carouselController: _controller,
                      options: CarouselOptions(
                          autoPlay: false,
                          enlargeCenterPage: true,
                          aspectRatio: 2.2,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            _current.value = index;
                          }),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: bannerList.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _controller.animateToPage(entry.key),
                          child: Container(
                            width: _current.value == entry.key ? 12.0 : 12.0,
                            height: 12.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: _current.value == entry.key
                                    ? Color(0xFFEB920D)
                                    : color.state == 'dark'
                                        ? darkModeText
                                        : Color(0xFFF3F3E8)),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.only(top: 20, bottom: 40),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.state == 'dark'
                                  ? Color(0xFFCF6ACF).withOpacity(0.04)
                                  : Color(0xFFFCA828).withOpacity(0.04),
                              color.state == 'dark'
                                  ? Color(0xFFCF6ACF).withOpacity(0)
                                  : Color(0xFFF1DEC1).withOpacity(0)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      child: Column(
                        children: [TopCategories(), RecProducts()],
                      ),
                    ),
                  ]),
                ),
              )
            ],
          )),
    );
  }
}
