import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shopforge/config/app.dart';
import 'package:http/http.dart' as http;
import 'woocommerce/woocommerce.dart';

class Network {
  getAsync(path) async {
    WooCommerce wooCommerceAPI = WooCommerce(
        url: shopUrl, consumerKey: consumerKey, consumerSecret: consumerSecret);
    return await wooCommerceAPI.getRequest(path);
  }

  deleteAsync(path) async {
    WooCommerce wooCommerceAPI = WooCommerce(
        url: shopUrl, consumerKey: consumerKey, consumerSecret: consumerSecret);
    return await wooCommerceAPI.deleteRequest(path);
  }

  postAsync(path, formData) async {
    WooCommerce wooCommerceAPI = WooCommerce(
        url: shopUrl, consumerKey: consumerKey, consumerSecret: consumerSecret);
    return await wooCommerceAPI.postAsync(path, formData);
  }

  postAuth(formData) async {
    var fullUrl = shopUrl + "/wp-json/jwt-auth/v1/token";
    return await http.post(
      Uri.parse(fullUrl),
      body: formData,
    );
  }

  validateToken() async {
    var fullUrl = shopUrl + "/wp-json/jwt-auth/v1/token/validate";
    var box = await Hive.openBox('appBox');
    if (box.get('token') != null) {
      if (box.get('token').length > 0) {
        String token = box.get('token');
        var response = await http.post(Uri.parse(fullUrl),
            body: {}, headers: {"Authorization": "Bearer " + token});
        var body = json.decode(response.body);
        if (body['data']?['status'] == 403) {
          return false;
        } else {
          return true;
        }
      }
      return true;
    }
    return true;
  }
}
