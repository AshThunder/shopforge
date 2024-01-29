import 'dart:convert';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/auth/create_account.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';
import 'package:shopforge/pages/components/form/text_input_widget.dart';
import 'package:shopforge/pages/dashboard.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/shop_action.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../checkout.dart';

class Login extends HookWidget {
  final String anchor;
  const Login({Key? key, this.anchor = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final email = useTextEditingController();
    final password = useTextEditingController();
    final loading = useState(false);
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final color = useProvider(colorProvider);

    completeLogin(data) async {
      account.state = data;
      var box = await Hive.openBox('appBox');
      box.put('account', json.encode(data));
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
    }

    createAccount(formData, mode) async {
      try {
        loading.value = true;
        var response = await Network().postAsync("customers", formData);
        if (response['id'] != null) {
          ShopAction()
              .newToastSuccess(context, "Account created successfully.");
          Map data = response;
          data['login_type'] = 'social';
          data['login_mode'] = mode;
          completeLogin(data);
        } else {
          print(response);
          loading.value = false;
          ShopAction().newToastError(context, "${response['message']}");
        }
      } catch (e) {
        print(e);
        ShopAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    continueSignup(data, mode) async {
      try {
        var response = await Network()
            .getAsync("customers?email=${data['email']}&role=all");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          if (body.length > 0) {
            ShopAction().newToastSuccess(context, "Successfully logged in.");
            Map data = body[0];
            data['login_type'] = 'social';
            data['login_mode'] = mode;
            completeLogin(data);
          } else {
            createAccount(data, mode);
          }
        } else {
          createAccount(data, mode);
        }
      } catch (e) {
        print(e);
        ShopAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    signInWithGoogle() async {
      loading.value = true;
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly'],
      );
      try {
        await _googleSignIn.signIn();
        List names = _googleSignIn.currentUser!.displayName!.split(' ');
        var data = {
          'first_name': names[0],
          'last_name': names.length > 1 ? names[1] : '',
          'email': _googleSignIn.currentUser!.email,
          "billing": {
            "first_name": names[0],
            "last_name": names.length > 1 ? names[1] : '',
            "email": _googleSignIn.currentUser!.email,
          }
        };

        continueSignup(data, 'google');
      } catch (error) {
        print("errorrr: $error");
        ShopAction().newToastError(context, "Unable to log in.");
        loading.value = false;
      }
    }

    signInWithFacebook() async {
      loading.value = true;
      try {
        final LoginResult result = await FacebookAuth.instance.login();
        if (result.status == LoginStatus.success) {
          // you are logged
          // final AccessToken accessToken = result.accessToken!;
          final userData = await FacebookAuth.i
              .getUserData(fields: "first_name,last_name,email");
          var data = {
            'first_name': userData['first_name'],
            'last_name': userData['last_name'],
            'email': userData['email'],
            "billing": {
              "first_name": userData['first_name'],
              "last_name": userData['last_name'],
              "email": userData['email'],
            }
          };

          continueSignup(data, 'facebook');
        } else {
          ShopAction().newToastError(context, "Unable to log in.");
          loading.value = false;
        }
      } catch (e) {
        print("errorrr: $e");
        ShopAction().newToastError(context, "Unable to log in.");
        loading.value = false;
      }
    }

    getCustomer(String customeremail, String tk) async {
      try {
        var response =
            await Network().getAsync("customers?email=$customeremail&role=all");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          if (body.length > 0) {
            ShopAction().newToastSuccess(context, "Successfully logged in.");
            account.state = body[0];
            token.state = tk;
            var box = await Hive.openBox('appBox');
            box.put('account', json.encode(body[0]));
            box.put('token', tk);
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
            ShopAction().newToastError(context, "Customer's profile not found");
          }
          loading.value = false;
        } else {
          loading.value = false;
          ShopAction().newToastError(context, "Customer's profile not found");
        }
      } catch (e) {
        print(e);
        ShopAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    login() async {
      //
      try {
        if (email.text.length > 0 && password.text.length > 0) {
          var formData = {
            "username": email.text,
            "password": password.text,
          };

          loading.value = true;
          var response = await Network().postAuth(formData);
          var body = json.decode(response.body);
          if (response.statusCode == 200) {
            getCustomer(body["user_email"], body["token"]);
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          color: color.state == 'dark' ? bgPrimaryDark : bgPrimary,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: 90, left: 25, right: 25),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Account Login",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color.state == 'dark'
                        ? Colors.white
                        : Color(0xFF1B1B1B)),
              ),
              SizedBox(height: 20),
              Text(
                "Please login to continue using the app",
                style: TextStyle(
                    color: color.state == 'dark'
                        ? darkModeText
                        : Color(0xFF595959)),
              ),
              SizedBox(height: 100),
              ColumnSuper(
                innerDistance: -1,
                children: [
                  TextInputWidget(
                    controller: email,
                    placeholder: "Username or Email address",
                    position: 0,
                  ),
                  TextInputWidget(
                    controller: password,
                    placeholder: "Password",
                    isPassword: true,
                    position: 2,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Opacity(
                  opacity: loading.value ? 0.38 : 1,
                  child: ButtonWidget(
                      action: loading.value ? () => {} : login,
                      text: loading.value ? "Please wait..." : "Login")),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Have no account?",
                    style: TextStyle(color: Color(0xFF595959)),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateAccount(anchor: anchor)),
                    ),
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                          color: color.state == 'dark'
                              ? darkModeTextHigh
                              : primaryText,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
              SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You can also login with",
                    style: TextStyle(color: Color(0xFF595959)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: loading.value ? () => {} : signInWithFacebook,
                    child: Opacity(
                      opacity: loading.value ? 0.38 : 1,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: color.state == 'dark'
                                  ? darkModeText
                                  : Color(0xFF404040),
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          children: [
                            Image.asset(iconsPath + 'facebook.png', height: 22),
                            SizedBox(width: 5),
                            Text(
                              "Facebook",
                              style: TextStyle(
                                  color: color.state == 'dark'
                                      ? darkModeText
                                      : Color(0xFF404040),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: loading.value ? () => {} : signInWithGoogle,
                    child: Opacity(
                      opacity: loading.value ? 0.38 : 1,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: color.state == 'dark'
                                  ? darkModeText
                                  : Color(0xFF404040),
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          children: [
                            Image.asset(iconsPath + 'google.png', height: 22),
                            SizedBox(width: 5),
                            Text(
                              "Google",
                              style: TextStyle(
                                  color: color.state == 'dark'
                                      ? darkModeText
                                      : Color(0xFF404040),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
