import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/auth/login.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';
import 'package:shopforge/screens/account/edit_profile.dart';
import 'package:shopforge/screens/account/edit_profile_ba.dart';
import 'package:shopforge/screens/account/edit_profile_sa.dart';
import 'package:shopforge/screens/account/profile.dart';
import 'package:shopforge/screens/order_list.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';

class Account extends HookWidget {
  const Account({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final color = useProvider(colorProvider);
    final wishlists = useProvider(wishlistsProvider);
    final orders = useProvider(ordersProvider);
    loadData() async {
      var result = await Network().validateToken();
      print(result);
      if (result == false) {
        await ShopAction().logout(account, token, wishlists, orders);
      }

      if (account.state['email'] != null) {
        try {
          var response = await Network()
              .getAsync("customers?email=${account.state['email']}&role=all");
          var body = json.decode(response.body);
          if (response.statusCode == 200) {
            if (body.length == 0) {
              await ShopAction().logout(account, token, wishlists, orders);
            } else {
              account.state = body[0];
              var box = await Hive.openBox('appBox');
              box.put('account', json.encode(body[0]));
              print("Account exists");
            }
          } else {
            await ShopAction().logout(account, token, wishlists, orders);
          }
        } catch (e) {
          print(e);
        }
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
            SizedBox(height: 10),
            Expanded(
                child: SingleChildScrollView(
                    child: Container(
                        padding: EdgeInsets.only(top: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            account.state['id'] != null
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFFF3F3E8),
                                                      image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: account.state['avatar_url'] !=
                                                                      null &&
                                                                  account.state['avatar_url'].length >
                                                                      0
                                                              ? Image.network(account
                                                                          .state[
                                                                      'avatar_url'])
                                                                  .image
                                                              : Image.asset(
                                                                      "assets/images/placeholder.png")
                                                                  .image),
                                                      border: Border.all(
                                                          color: colorPrimary,
                                                          width: 4),
                                                      shape: BoxShape.circle)),
                                              SizedBox(height: 15),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${account.state['first_name']}${account.state['last_name']}"
                                                                .length >
                                                            0
                                                        ? "${account.state['first_name']} ${account.state['last_name']}"
                                                        : "${account.state['username']}",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: color.state ==
                                                                'dark'
                                                            ? Colors.white
                                                            : Color(
                                                                0xFF1B1B1B)),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    "@${account.state['username']}",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFF949494)),
                                                  ),
                                                  "${account.state['billing']?['city']}"
                                                                  .length >
                                                              0 &&
                                                          "${account.state['billing']?['state']}"
                                                                  .length >
                                                              0
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 20),
                                                          child: Row(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  SizedBox(
                                                                    height: 22,
                                                                    width: 22,
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      iconsPath +
                                                                          'pin.svg',
                                                                      color:
                                                                          colorPrimary,
                                                                      width: 20,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: 2),
                                                                  Text(
                                                                    "${account.state['billing']['city']}, ${account.state['billing']['state']}.",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: color.state ==
                                                                                'dark'
                                                                            ? Color(0xFFC5C5C5)
                                                                            : primaryText),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(right: 25),
                                        child: TextButton(
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Profile())),
                                            style: TextButton.styleFrom(
                                                backgroundColor:
                                                    color.state == 'dark'
                                                        ? colorSecondary
                                                        : primaryText,
                                                padding: EdgeInsets.only(
                                                    top: 8,
                                                    bottom: 8,
                                                    left: 12,
                                                    right: 14)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                    iconsPath + 'user.svg',
                                                    color: Colors.white),
                                                SizedBox(width: 10),
                                                Text("My Profile",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600))
                                              ],
                                            )),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 25, right: 25),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Account",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: color.state == 'dark'
                                                        ? Colors.white
                                                        : Color(0xFF1B1B1B)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 40),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: ButtonWidget(
                                                action: () => {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Login()))
                                                },
                                                text: "Login/Create Account",
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                            SizedBox(height: 40),
                            Row(
                              children: [
                                Container(
                                  child: Expanded(
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 15),
                                      decoration: BoxDecoration(
                                        color: color.state == 'dark'
                                            ? darkModeBg
                                            : Color(0xFFF6F6ED),
                                        border: Border.all(
                                            color: color.state == 'dark'
                                                ? darkModeBorder
                                                : Color(0xFF464440)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          EachMenuItem(
                                              title: "My Orders",
                                              icon: "check-circle",
                                              action: () => {
                                                    account.state['id'] == null
                                                        ? Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Login()))
                                                        : Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        OrderList()))
                                                  }),
                                          EachMenuItem(
                                              title: "My Profile",
                                              icon: "user",
                                              action: () => {
                                                    account.state['id'] == null
                                                        ? Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Login()))
                                                        : Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Profile()))
                                                  }),
                                          account.state['id'] != null
                                              ? EachMenuItemWDropDown(
                                                  title: "Edit Profile",
                                                  icon: "edit",
                                                  action: () => {
                                                        account.state['id'] ==
                                                                null
                                                            ? Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Login()))
                                                            : Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            EditProfile()))
                                                      })
                                              : SizedBox(),
                                          EachMenuItemWToggle(
                                              title: "Dark Mode", icon: "moon"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "© Shopforge ${DateTime.now().year}",
                                  style: TextStyle(
                                      color: color.state == 'dark'
                                          ? Color(0xFF6B686B)
                                          : Color(0xFFBCBCBC),
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                          ],
                        ))))
          ])),
    );
  }
}

class EachMenuItem extends HookWidget {
  final String title, icon;
  final Function action;
  const EachMenuItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);

    return InkWell(
      onTap: () => action(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  SvgPicture.asset(
                    iconsPath + '$icon.svg',
                    color: color.state == 'dark' ? darkModeText : primaryText,
                    width: 24,
                  ),
                  SizedBox(width: 15),
                  Text(
                    "$title",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: color.state == 'dark' ? darkModeText : primaryText,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              iconsPath + 'chevron-right.svg',
              color: color.state == 'dark' ? darkModeText : primaryText,
              width: 24,
            )
          ],
        ),
      ),
    );
  }
}

class EachMenuItemWToggle extends HookWidget {
  final String title, icon;
  const EachMenuItemWToggle({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);

    changeColor() async {
      color.state = color.state == 'dark' ? 'light' : 'dark';
      var box = await Hive.openBox('appBox');
      box.put('color', color.state);
    }

    return InkWell(
      onTap: changeColor,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  SvgPicture.asset(
                    iconsPath + '$icon.svg',
                    color: color.state == 'dark' ? darkModeText : primaryText,
                    width: 24,
                  ),
                  SizedBox(width: 15),
                  Text(
                    "$title",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: color.state == 'dark' ? darkModeText : primaryText,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: color.state == 'dark' ? true : false,
              activeColor: colorPrimary,
              onChanged: (value) {
                changeColor();
              },
            )
          ],
        ),
      ),
    );
  }
}

class EachMenuItemWDropDown extends HookWidget {
  final String title, icon;
  final Function action;
  const EachMenuItemWDropDown({
    Key? key,
    required this.title,
    required this.icon,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final toggleMode = useState(4);

    return Column(
      children: [
        InkWell(
          onTap: () => {toggleMode.value = toggleMode.value == 1 ? 4 : 1},
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        iconsPath + '$icon.svg',
                        color:
                            color.state == 'dark' ? darkModeText : primaryText,
                        width: 24,
                      ),
                      SizedBox(width: 15),
                      Text(
                        "$title",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: color.state == 'dark'
                              ? darkModeText
                              : primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                RotatedBox(
                  quarterTurns: toggleMode.value,
                  child: SvgPicture.asset(
                    iconsPath + 'chevron-right.svg',
                    color: color.state == 'dark' ? darkModeText : primaryText,
                    width: 24,
                  ),
                )
              ],
            ),
          ),
        ),
        toggleMode.value == 4
            ? SizedBox()
            : Container(
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                decoration: BoxDecoration(
                    color: color.state == 'dark'
                        ? Color(0xFF130E13)
                        : Color(0xFFEFEFE1),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfile())),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Primary Information",
                              style: TextStyle(
                                color: color.state == 'dark'
                                    ? Color(0xFFAAA6A6)
                                    : primaryText,
                              ),
                            ),
                            SvgPicture.asset(
                              iconsPath + 'chevron-right.svg',
                              color: color.state == 'dark'
                                  ? Color(0xFFAAA6A6)
                                  : primaryText,
                              width: 24,
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfileBA())),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Billing Address",
                              style: TextStyle(
                                color: color.state == 'dark'
                                    ? Color(0xFFAAA6A6)
                                    : primaryText,
                              ),
                            ),
                            SvgPicture.asset(
                              iconsPath + 'chevron-right.svg',
                              color: color.state == 'dark'
                                  ? Color(0xFFAAA6A6)
                                  : primaryText,
                              width: 24,
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfileSA())),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Shipping Address",
                              style: TextStyle(
                                color: color.state == 'dark'
                                    ? Color(0xFFAAA6A6)
                                    : primaryText,
                              ),
                            ),
                            SvgPicture.asset(
                              iconsPath + 'chevron-right.svg',
                              color: color.state == 'dark'
                                  ? Color(0xFFAAA6A6)
                                  : primaryText,
                              width: 24,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
      ],
    );
  }
}
