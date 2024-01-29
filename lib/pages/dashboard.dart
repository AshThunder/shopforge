import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/screens/account/edit_profile.dart';
import 'package:shopforge/screens/account/profile.dart';
import 'package:shopforge/screens/categories.dart';
import 'package:shopforge/screens/order_list.dart';
import 'package:shopforge/utils/shop_action.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/utils/Providers.dart';

import 'auth/login.dart';
import 'tabs/account.dart';
import 'tabs/cart.dart';
import 'tabs/home.dart';
import 'tabs/partials/animated_bottom_bar.dart';
import 'tabs/shop.dart';
import 'tabs/wishlist.dart';

class Dashboard extends StatefulWidget {
  final List<BarItem> barItems = [
    BarItem(text: "Home", icon: iconsPath + "building-store.svg"),
    BarItem(text: "Wishlist", icon: iconsPath + "heart.svg"),
    BarItem(text: "Shop", icon: iconsPath + "search.svg"),
    BarItem(text: "Cart", icon: iconsPath + "shopping-bag.svg"),
    BarItem(text: "Account", icon: iconsPath + "user.svg"),
  ];
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  late TabController _tabController;
  late double timeDilation;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 5);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar:
            AnimatedBottomBar(widget.barItems, _tabIndex, (index) {
          setState(() {
            _tabIndex = index;
          });
          _tabController.animateTo(_tabIndex);
        }),
        drawer: DrawerHolder(),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: Home()),
            Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: Wishlist()),
            Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: Shop()),
            Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: Cart()),
            Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: Account()),
          ],
        ),
      ),
    );
  }
}

class DrawerHolder extends HookWidget {
  const DrawerHolder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final account = useProvider(accountProvider);
    return Drawer(
      child: Container(
        color: color.state == 'dark' ? primaryText : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(25),
              child: Row(
                children: [
                  SvgPicture.asset(
                    iconsPath + 'ShopForge.svg',
                    height: 16,
                    color: color.state == 'dark' ? Colors.white : Colors.black,
                  ),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 25, top: 20, bottom: 10),
                child: Text(
                  "MENU",
                  style: TextStyle(color: Color(0xFF8E8E8E)),
                )),
            EachDrawerItem(
                title: "Categories",
                action: () => {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Categories()))
                    }),
            EachDrawerItem(
                title: "My Orders",
                action: () => {
                      account.state['id'] == null
                          ? Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()))
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrderList()))
                    }),
            EachDrawerItem(
                title: "Profile",
                action: () => {
                      account.state['id'] == null
                          ? Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()))
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Profile()))
                    }),
            EachDrawerItem(
                title: "Edit Profile",
                action: () => {
                      account.state['id'] == null
                          ? Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()))
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfile()))
                    }),
            SizedBox(
              height: MediaQuery.of(context).size.height / 2.3,
            ),
            LogoutArea()
          ],
        ),
      ),
    );
  }
}

class LogoutArea extends HookWidget {
  const LogoutArea({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final wishlists = useProvider(wishlistsProvider);
    final orders = useProvider(ordersProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        account.state['id'] != null
            ? TextButton(
                onPressed: () => {
                      ShopAction().logout(account, token, wishlists, orders),
                      Navigator.pop(context)
                    },
                style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFBD3030),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Logout",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    SizedBox(width: 10),
                    SvgPicture.asset(iconsPath + 'log-out.svg',
                        color: Colors.white)
                  ],
                ))
            : TextButton(
                onPressed: () => {
                      Navigator.pop(context),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()))
                    },
                style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFBD3030),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Login",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    SizedBox(width: 10),
                    SvgPicture.asset(iconsPath + 'log-out.svg',
                        color: Colors.white)
                  ],
                )),
      ],
    );
  }
}

class EachDrawerItem extends HookWidget {
  final String title;
  final Function action;
  const EachDrawerItem({Key? key, required this.title, required this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$title",
              style: TextStyle(
                  color: color.state == 'dark' ? darkModeTextHigh : primaryText,
                  fontSize: 16),
            ),
            SvgPicture.asset(
              iconsPath + 'chevron-right.svg',
              color: color.state == 'dark' ? darkModeTextHigh : Colors.black,
            ),
          ],
        ),
      ),
      onTap: () => {Navigator.pop(context), action()},
    );
  }
}
