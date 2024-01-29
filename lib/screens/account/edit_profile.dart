import 'dart:convert';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';
import 'package:shopforge/pages/components/form/text_input_with_label.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';

class EditProfile extends HookWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final wishlists = useProvider(wishlistsProvider);
    final orders = useProvider(ordersProvider);
    final loading = useState(false);

    final fname = useTextEditingController();
    final lname = useTextEditingController();
    final email = useTextEditingController();

    final checkError = useState(false);

    loadData() async {
      fname.text = account.state['first_name'];
      lname.text = account.state['last_name'];
      email.text = account.state['email'];
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
          if (fname.text.length > 0 &&
              lname.text.length > 0 &&
              email.text.length > 0) {
            var formData = {
              "first_name": fname.text,
              "last_name": lname.text,
              "email": email.text
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
              ShopAction()
                  .newToastError(context, "Unable to update your profile");
            }

            loading.value = false;
          } else {
            loading.value = false;
            ShopAction().newToastError(context, "All fields are required");
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
                                                "Primary Information",
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 25),
                                    decoration: BoxDecoration(
                                      color: color.state == 'dark'
                                          ? Colors.transparent
                                          : Color(0xFFF6F6ED),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ColumnSuper(
                                      innerDistance: 20,
                                      children: [
                                        TextInputWithLabel(
                                          controller: fname,
                                          placeholder: "First Name",
                                          hasError: checkError.value &&
                                                  fname.text.length == 0
                                              ? true
                                              : false,
                                        ),
                                        TextInputWithLabel(
                                          controller: lname,
                                          placeholder: "Last Name",
                                          hasError: checkError.value &&
                                                  lname.text.length == 0
                                              ? true
                                              : false,
                                        ),
                                        TextInputWithLabel(
                                          controller: email,
                                          placeholder: "Email Address",
                                          hasError: checkError.value &&
                                                  email.text.length == 0
                                              ? true
                                              : false,
                                        ),
                                      ],
                                    ),
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
