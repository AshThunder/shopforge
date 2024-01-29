import 'dart:convert';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';
import 'package:shopforge/pages/components/form/text_input_with_label.dart';
import 'package:shopforge/pages/dashboard.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/shop_action.dart';

import '../checkout.dart';
import 'login.dart';

class CreateAccount extends HookWidget {
  final String anchor;
  const CreateAccount({Key? key, this.anchor = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstName = useTextEditingController();
    final lastName = useTextEditingController();
    final username = useTextEditingController();
    final email = useTextEditingController();
    final password = useTextEditingController();
    final rpassword = useTextEditingController();
    final loading = useState(false);
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final color = useProvider(colorProvider);

    login(customer) async {
      try {
        if (email.text.length > 0 && password.text.length > 0) {
          var formData = {
            "username": customer['username'],
            "password": password.text,
          };

          loading.value = true;
          var response = await Network().postAuth(formData);
          var body = json.decode(response.body);
          if (response.statusCode == 200) {
            ShopAction()
                .newToastSuccess(context, "Account created successfully.");
            account.state = customer;
            token.state = body["token"];
            var box = await Hive.openBox('appBox');
            box.put('account', json.encode(customer));
            box.put('token', body["token"]);
            if (anchor == 'checkout') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Checkout()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
              );
            }
          } else {
            print(body["message"]);
            ShopAction().newToastError(context,
                "${body["message"].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}");
            loading.value = false;
          }
        } else {
          ShopAction().newToastError(context, "Both fields are required");
        }
      } catch (e) {
        print(e);
        ShopAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    register() async {
      try {
        if (email.text.length > 0 &&
            password.text.length > 0 &&
            firstName.text.length > 0 &&
            lastName.text.length > 0 &&
            username.text.length > 0) {
          if (password.text == rpassword.text) {
            var formData = {
              "email": email.text,
              "password": password.text,
              "first_name": firstName.text,
              "last_name": lastName.text,
              "username": username.text,
            };
            loading.value = true;

            var response = await Network().postAsync("customers", formData);
            if (response['id'] != null) {
              login(response);
            } else {
              print(response);
              loading.value = false;
              ShopAction().newToastError(context, "${response['message']}");
            }
          } else {
            ShopAction()
                .newToastError(context, "Your passwords are not the same.");
          }
        } else {
          ShopAction().newToastError(context, "All fields are required.");
        }
      } catch (e) {
        print(e);
        ShopAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          color: color.state == 'dark' ? bgPrimaryDark : bgPrimary,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: 60, left: 25, right: 25),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Create Account",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color:
                      color.state == 'dark' ? Colors.white : Color(0xFF1B1B1B)),
            ),
            SizedBox(height: 20),
            Text(
              "Register to continue using the app",
              style: TextStyle(
                  color:
                      color.state == 'dark' ? darkModeText : Color(0xFF595959)),
            ),
            SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    ColumnSuper(
                      innerDistance: 20,
                      children: [
                        TextInputWithLabel(
                          controller: firstName,
                          placeholder: "First Name",
                        ),
                        TextInputWithLabel(
                          controller: lastName,
                          placeholder: "Last Name",
                        ),
                        TextInputWithLabel(
                          controller: username,
                          placeholder: "Username",
                        ),
                        TextInputWithLabel(
                          controller: email,
                          placeholder: "Email address",
                        ),
                        TextInputWithLabel(
                          controller: password,
                          placeholder: "Password",
                          isPassword: true,
                        ),
                        TextInputWithLabel(
                          controller: rpassword,
                          placeholder: "Repeat Password",
                          isPassword: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Opacity(
                        opacity: loading.value ? 0.38 : 1,
                        child: ButtonWidget(
                            action: loading.value ? () => {} : register,
                            text: loading.value
                                ? "Please wait..."
                                : "Create Account")),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: Color(0xFF595959)),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Login(anchor: anchor)),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: color.state == 'dark' ? darkModeTextHigh : primaryText,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
