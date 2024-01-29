import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/checkout/billing_fields.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';

class EditProfileBA extends HookWidget {
  const EditProfileBA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final wishlists = useProvider(wishlistsProvider);
    final orders = useProvider(ordersProvider);
    final loading = useState(false);

    final bfname = useTextEditingController();
    final blname = useTextEditingController();
    final baddress1 = useTextEditingController();
    final bcity = useTextEditingController();
    final bstate = useTextEditingController();
    final bpostalcode = useTextEditingController();
    final bcountry = useTextEditingController();
    final bemail = useTextEditingController();
    final bphone = useTextEditingController();

    final checkError = useState(false);

    loadData() async {
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
          if (bfname.text.length > 0 &&
              blname.text.length > 0 &&
              bemail.text.length > 0) {
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
          ShopAction().newToastError(context,
              "Unable to update your profile, check your internet connection.");
          loading.value = false;
        }
      } catch (e) {
        ShopAction().newToastError(context,
            "Unable to update your profile, check your internet connection.");
        loading.value = false;
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
                                                "Billing Address",
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
                                    child: BillingFields(
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
