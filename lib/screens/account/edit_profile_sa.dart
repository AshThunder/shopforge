import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/checkout/shipping_fields.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';

class EditProfileSA extends HookWidget {
  const EditProfileSA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final wishlists = useProvider(wishlistsProvider);
    final orders = useProvider(ordersProvider);
    final loading = useState(false);

    final sfname = useTextEditingController();
    final slname = useTextEditingController();
    final saddress1 = useTextEditingController();
    final scity = useTextEditingController();
    final sstate = useTextEditingController();
    final spostalcode = useTextEditingController();
    final scountry = useTextEditingController();

    final checkError = useState(false);

    loadData() async {
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

    updateProfile() async {
      loading.value = true;
      try {
        var result = await Network().validateToken();
        if (result == false) {
          await ShopAction().logout(account, token, wishlists, orders);
          Navigator.pop(context);
        }
        try {
          if (sfname.text.length > 0 &&
              slname.text.length > 0 &&
              saddress1.text.length > 0) {
            var formData = {
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
            };
            var response = await Network()
                .postAsync("customers/${account.state['id']}", formData);
            if (response['id'] != null) {
              account.state = response;
              var box = await Hive.openBox('appBox');
              box.put('account', json.encode(response));
              ShopAction()
                  .newToastSuccess(context, "Profile updated successfully");
            } else {
              ShopAction().newToastError(
                  context, "Unable to update your profile, please try again.");
            }
            loading.value = false;
          } else {
            loading.value = false;
            ShopAction().newToastError(
                context, "Please the fill in the required fields");
          }
        } catch (e) {
          print(e);
          loading.value = false;

          ShopAction().newToastError(context,
              "Unable to update your profile, check your internet connection.");
        }
      } catch (e) {
        loading.value = false;
        ShopAction().newToastError(context,
            "Unable to update your profile, check your internet connection.");
      }
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
                    child: Column(children: [
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            "Edit Profile",
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
                                        left: 25,
                                        right: 25,
                                        top: 10,
                                        bottom: 25),
                                    transform: Matrix4.translationValues(
                                        0.0, -3.0, 0.0),
                                    color: color.state == 'dark'
                                        ? bgPrimaryDark
                                        : bgPrimary,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Shipping Address",
                                                style: TextStyle(
                                                    color: color.state == 'dark'
                                                        ? darkModeText
                                                        : primaryText,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  content: Container(
                                    padding: EdgeInsets.symmetric(vertical: 25),
                                    decoration: BoxDecoration(
                                      color: color.state == 'dark'
                                          ? Colors.transparent
                                          : Color(0xFFF6F6ED),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ShippingFields(
                                        sfname: sfname,
                                        checkError: checkError,
                                        slname: slname,
                                        saddress1: saddress1,
                                        scity: scity,
                                        sstate: sstate,
                                        spostalcode: spostalcode,
                                        scountry: scountry),
                                  )),
                              SizedBox(height: 20),
                            ]),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: loading.value ? 0.3 : 1,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      child: ButtonWidget(
                        action: loading.value ? () => {} : updateProfile,
                        text: "Update Profile",
                      ),
                    ),
                  )
                ])))));
  }
}
