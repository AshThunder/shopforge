import 'package:flutter/material.dart';

const shopUrl = "https://tk.ctgames.site";
const consumerKey = "ck_aad8381914ec1204081ee1f2a5e774a92e3552c1";
const consumerSecret = "cs_e81bf2e2e8fcaa46815c804706dd2cecdbd7ccfa";

const iconsPath = "assets/icons/";

// COLORS
const primaryDark = Color(0xFF060A10);
var bgPrimary = Color(0xFFFFFFF5);
//var bgPrimary = Color(0xFFFFFF00).withOpacity(0.04);
var bgPrimaryDark = Color(0xFF110D11);
const primaryText = Color(0xFF272727);
const primaryTextLow = Color(0xFF404040);
const colorPrimary = Color(0xFFEB920D);
const colorSecondary = Color(0xFF0692B0);

const darkModeBg = Color(0xFF0A010A);
const darkModeBorder = Color(0xFF2F212F);
const darkModeText = Color(0xFFC5C5C5);
const darkModeTextHigh = Color(0xFFDDDDDD);

const appBoxShadow = [
  BoxShadow(
    color: Color(0xFFEEEDED),
    spreadRadius: 0,
    blurRadius: 4,
    offset: Offset(0, 0), // changes position of shadow
  ),
];

var appBoxShadowDark = [
  BoxShadow(
    color: Color(0xFF110D11),
    spreadRadius: 2,
    blurRadius: 4,
    offset: Offset(0, 0), // changes position of shadow
  ),
];

// Tabs
const tabIconColor = Color(0xFF6F6F6F);
