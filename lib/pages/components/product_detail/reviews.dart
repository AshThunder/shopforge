import 'dart:convert';

import 'package:cupertino_progress_bar/cupertino_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/auth/login.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';

class Reviews extends HookWidget {
  final Map product;
  final ValueNotifier<List> revs;

  const Reviews({Key? key, required this.product, required this.revs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final account = useProvider(accountProvider);
    final color = useProvider(colorProvider);
    final token = useProvider(userTokenProvider);
    final wishlists = useProvider(wishlistsProvider);
    final orders = useProvider(ordersProvider);
    final reviews = useState([]);
    final loading = useState(true);
    final loadingError = useState(false);
    Future<bool> submitReview(messageInput, ratingValue) async {
      if (messageInput.text.length > 0) {
        try {
          var result = await Network().validateToken();
          if (result == false) {
            await ShopAction().logout(account, token, wishlists, orders);
          }
          var formData = {
            'product_id': product['id'],
            'review': messageInput.text,
            'reviewer':
                "${account.state['first_name']} ${account.state['last_name']}",
            'reviewer_email': "${account.state['email']}",
            'rating': ratingValue.value.toInt()
          };
          try {
            var response =
                await Network().postAsync("products/reviews", formData);
            if (response['id'] != null) {
              reviews.value = [response, ...reviews.value];
              revs.value = [response, ...reviews.value];
              var box = await Hive.openBox('appBox');
              box.put("review_${product['id']}", json.encode(reviews.value));
              return true;
            } else {
              ShopAction().newToastError(context, "Unable to submit review...");
              return false;
            }
          } catch (e) {
            ShopAction().newToastError(context,
                "Unable to submit review, check your internet connection.");
            return false;
          }
        } catch (e) {
          ShopAction().newToastError(context,
              "Unable to submit review, check your internet connection.");
          return false;
        }
      } else {
        ShopAction().newToastError(context, "The message field is required");
        return false;
      }
    }

    Future<bool> updateReview(messageInput, ratingValue, ratingID) async {
      if (messageInput.text.length > 0) {
        try {
          var result = await Network().validateToken();
          if (result == false) {
            await ShopAction().logout(account, token, wishlists, orders);
          }
          var formData = {
            'review': messageInput.text,
            'rating': ratingValue.value.toInt()
          };
          try {
            var response = await Network()
                .postAsync("products/reviews/$ratingID", formData);
            if (response['id'] != null) {
              int getIndex = reviews.value
                  .indexWhere((element) => element['id'] == response['id']);
              if (getIndex >= 0) {
                List temps = reviews.value;
                temps[getIndex] = response;
                reviews.value = [];
                revs.value = [];
                reviews.value = temps;
                revs.value = temps;
              }
              var box = await Hive.openBox('appBox');
              box.put("review_${product['id']}", json.encode(reviews.value));
              return true;
            } else {
              ShopAction().newToastError(context, "Unable to update review...");
              return false;
            }
          } catch (e) {
            ShopAction().newToastError(context,
                "Unable to update review, check your internet connection.");
            return false;
          }
        } catch (e) {
          ShopAction().newToastError(context,
              "Unable to update review, check your internet connection.");
          return false;
        }
      } else {
        ShopAction().newToastError(context, "The message field is required");
        return false;
      }
    }

    Future<bool> deleteReview(ratingID) async {
      try {
        var result = await Network().validateToken();
        if (result == false) {
          await ShopAction().logout(account, token, wishlists, orders);
        }
        try {
          var response = await Network()
              .deleteAsync("products/reviews/$ratingID?force=true");
          var body = json.decode(response.body);
          if (body['deleted'] != null && body['deleted'] == true) {
            List temps = reviews.value;
            temps.removeWhere((element) => element['id'] == ratingID);
            reviews.value = [];
            reviews.value = temps;
            revs.value = [];
            revs.value = temps;
            var box = await Hive.openBox('appBox');
            box.put("review_${product['id']}", json.encode(reviews.value));
            return true;
          } else {
            print(body);
            ShopAction().newToastError(context, "Unable to delete review...");
            return false;
          }
        } catch (e) {
          print(e);
          ShopAction().newToastError(context,
              "Unable to delete review, check your internet connection.");
          return false;
        }
      } catch (e) {
        print(e);
        ShopAction().newToastError(context,
            "Unable to delete review, check your internet connection.");
        return false;
      }
    }

    void loadData() async {
      var box = await Hive.openBox('appBox');
      loading.value = true;
      try {
        if (box.get("review_${product['id']}") != null) {
          reviews.value = jsonDecode(box.get("review_${product['id']}"));
        }
        var response = await Network()
            .getAsync("products/reviews?per_page=50&product=${product['id']}");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          loading.value = false;
          loadingError.value = false;
          reviews.value = body;
          revs.value = body;
          box.put("review_${product['id']}", json.encode(body));
        } else {
          loading.value = false;
          loadingError.value = true;
        }
      } catch (e) {
        loading.value = false;
        loadingError.value = true;
        print(e);
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
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Reviews",
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
              SizedBox(height: 30),
              Expanded(
                  child: SingleChildScrollView(
                      child: Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Column(children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: color.state == 'dark'
                                    ? darkModeBg
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: color.state == 'dark'
                                    ? appBoxShadowDark
                                    : appBoxShadow,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text("Reviews",
                                            style: TextStyle(
                                                color: color.state == 'dark'
                                                    ? Colors.white
                                                    : primaryText,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14)),
                                      ),
                                      loading.value && reviews.value.length > 0
                                          ? SpinKitFadingCube(
                                              color: colorPrimary,
                                              size: 15.0,
                                            )
                                          : SizedBox()
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  loading.value && reviews.value.length == 0
                                      ? Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: SpinKitFadingCube(
                                            color: colorPrimary,
                                            size: 30.0,
                                          ),
                                        )
                                      : loadingError.value &&
                                              reviews.value.length == 0
                                          ? Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 20),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                          "Unable to load reviews",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF8F8F8F),
                                                              fontSize: 14)),
                                                      SizedBox(height: 10),
                                                      InkWell(
                                                        onTap: loadData,
                                                        child: Text(
                                                            "Tap to retry",
                                                            style: TextStyle(
                                                                color: color.state ==
                                                                        'dark'
                                                                    ? darkModeTextHigh
                                                                    : primaryText,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14)),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          : reviews.value.length > 0
                                              ? ReviewGraph(
                                                  reviews: reviews.value)
                                              : Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 20),
                                                  child: Text("No review found",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF8F8F8F),
                                                          fontSize: 14)),
                                                )
                                ],
                              ),
                            ),
                            reviews.value.length == 0
                                ? SizedBox()
                                : Container(
                                    margin: EdgeInsets.only(top: 40),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 25, bottom: 5),
                                              child: Text("All Reviews",
                                                  style: TextStyle(
                                                      color:
                                                          color.state == 'dark'
                                                              ? Colors.white
                                                              : primaryText,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14)),
                                            ),
                                          ],
                                        ),
                                        ...reviews.value
                                            .map((rev) => EachReview(
                                                  review: rev,
                                                  updateReview: updateReview,
                                                  deleteReview: deleteReview,
                                                )),
                                      ],
                                    ),
                                  )
                          ])))),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                child: ButtonWidget(
                  action: () => {
                    if (account.state['id'] != null)
                      {
                        showMaterialModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            barrierColor: Colors.black.withOpacity(0.5),
                            context: context,
                            builder: (context) =>
                                ReviewModal(submitReview: submitReview))
                      }
                    else
                      {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        )
                      }
                  },
                  text: "Write Review",
                ),
              )
            ])));
  }
}

class ReviewGraph extends HookWidget {
  final List reviews;
  const ReviewGraph({Key? key, required this.reviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final averageRatings = useState(0.0);
    double getAverageRatings() {
      double sum = 0.0;
      for (var item in reviews) {
        sum += double.parse(item['rating'].toString());
      }
      return (sum / reviews.length);
    }

    averageRatings.value = getAverageRatings();

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: color.state == 'dark'
              ? Color(0xFFF9F9F9).withOpacity(0.03)
              : Color(0xFFF9F9F9)),
      child: Row(
        children: [
          Container(
              child: Column(
            children: [
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 4.0,
                animation: true,
                percent:
                    averageRatings.value != 0 ? averageRatings.value / 5 : 0,
                center: Text(
                  "${averageRatings.value.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color:
                          color.state == 'dark' ? darkModeText : primaryText),
                ),
                footer: Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    "${reviews.length} Reviews",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color.state == 'dark'
                            ? darkModeTextHigh
                            : primaryText),
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: colorPrimary,
                backgroundColor: color.state == 'dark'
                    ? darkModeTextHigh.withOpacity(0.5)
                    : Colors.black12,
              ),
              SizedBox(height: 20),
              RatingBar.builder(
                initialRating: averageRatings.value,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                ignoreGestures: true,
                itemCount: 5,
                itemSize: 16.0,
                itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Color(0xFFEB920D),
                ),
                unratedColor: color.state == 'dark'
                    ? darkModeTextHigh.withOpacity(0.5)
                    : Colors.black12,
                onRatingUpdate: (rating) {},
              )
            ],
          )),
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    children: [
                      EachProgress(
                          progress: double.parse(((reviews
                                      .where(
                                          (element) => element['rating'] == 5)
                                      .length) /
                                  reviews.length)
                              .toString()),
                          star: 5),
                      EachProgress(
                          progress: double.parse(((reviews
                                      .where(
                                          (element) => element['rating'] == 4)
                                      .length) /
                                  reviews.length)
                              .toString()),
                          star: 4),
                      EachProgress(
                          progress: double.parse(((reviews
                                      .where(
                                          (element) => element['rating'] == 3)
                                      .length) /
                                  reviews.length)
                              .toString()),
                          star: 3),
                      EachProgress(
                          progress: double.parse(((reviews
                                      .where(
                                          (element) => element['rating'] == 2)
                                      .length) /
                                  reviews.length)
                              .toString()),
                          star: 2),
                      EachProgress(
                          progress: double.parse(((reviews
                                      .where(
                                          (element) => element['rating'] == 1)
                                      .length) /
                                  reviews.length)
                              .toString()),
                          star: 1),
                    ],
                  ))),
        ],
      ),
    );
  }
}

class ReviewModal extends HookWidget {
  final Function submitReview;
  const ReviewModal({Key? key, required this.submitReview}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final ratingValue = useState(1.0);
    final messageInput = useTextEditingController();
    final focusedMessage = useState(false);
    final _focusNodeMessage = useFocusNode();
    final loading = useState(false);

    useEffect(() {
      _focusNodeMessage.addListener(() {
        focusedMessage.value = _focusNodeMessage.hasFocus ? true : false;
      });
    }, const []);

    makeReview() async {
      loading.value = true;
      bool submit = await submitReview(messageInput, ratingValue);
      loading.value = false;
      if (submit) {
        Navigator.pop(context);
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: color.state == 'dark' ? primaryText : Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CloseWidget(),
                      ],
                    ),
                    Text(
                      "Write a review.",
                      style: TextStyle(
                          color: color.state == 'dark'
                              ? Colors.white
                              : primaryText,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingBar.builder(
                          initialRating: 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 30.0,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Color(0xFFEB920D),
                          ),
                          unratedColor: color.state == 'dark'
                              ? darkModeTextHigh.withOpacity(0.5)
                              : Colors.black12,
                          onRatingUpdate: (rating) {
                            ratingValue.value = rating;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        decoration: BoxDecoration(
                            color: color.state == 'dark'
                                ? Color(0xFFEFEFE1).withOpacity(0.1)
                                : Color(0xFFF6F6ED),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: focusedMessage.value
                                    ? colorPrimary
                                    : Colors.transparent)),
                        child: TextField(
                          focusNode: _focusNodeMessage,
                          maxLines: 4,
                          controller: messageInput,
                          style: TextStyle(
                            fontSize: 14,
                            color: color.state == 'dark'
                                ? Colors.white
                                : primaryText,
                          ),
                          decoration: InputDecoration.collapsed(
                              hintStyle: TextStyle(
                                color: color.state == 'dark'
                                    ? darkModeText
                                    : primaryTextLow,
                                fontSize: 14,
                              ),
                              hintText: "Enter your review message here"),
                        )),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Opacity(
                        opacity: loading.value ? 0.3 : 1,
                        child: ButtonWidget(
                          action: loading.value ? () => {} : makeReview,
                          text: "Submit Review",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: focusedMessage.value == true
                          ? MediaQuery.of(context).viewInsets.bottom
                          : 0,
                    )
                  ]))),
    );
  }
}

class EditReviewModal extends HookWidget {
  final Function updateReview;
  final Map review;
  const EditReviewModal(
      {Key? key, required this.updateReview, required this.review})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final ratingValue = useState(1.0);
    final messageInput = useTextEditingController();
    final focusedMessage = useState(false);
    final _focusNodeMessage = useFocusNode();
    final loading = useState(false);

    useEffect(() {
      _focusNodeMessage.addListener(() {
        focusedMessage.value = _focusNodeMessage.hasFocus ? true : false;
      });
      ratingValue.value = double.parse(review['rating'].toString());
      messageInput.text =
          review['review'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
    }, const []);

    makeReview() async {
      loading.value = true;
      bool submit = await updateReview(messageInput, ratingValue, review['id']);
      loading.value = false;
      if (submit) {
        Navigator.pop(context);
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: color.state == 'dark' ? primaryText : Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CloseWidget(),
                      ],
                    ),
                    Text(
                      "Write a review.",
                      style: TextStyle(
                          color: color.state == 'dark'
                              ? Colors.white
                              : primaryText,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingBar.builder(
                          initialRating:
                              double.parse(review['rating'].toString()),
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 30.0,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Color(0xFFEB920D),
                          ),
                          unratedColor: color.state == 'dark'
                              ? darkModeTextHigh.withOpacity(0.5)
                              : Colors.black12,
                          onRatingUpdate: (rating) {
                            ratingValue.value = rating;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        decoration: BoxDecoration(
                            color: color.state == 'dark'
                                ? Color(0xFFEFEFE1).withOpacity(0.1)
                                : Color(0xFFF6F6ED),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: focusedMessage.value
                                    ? colorPrimary
                                    : Colors.transparent)),
                        child: TextField(
                          focusNode: _focusNodeMessage,
                          maxLines: 4,
                          controller: messageInput,
                          style: TextStyle(
                            fontSize: 14,
                            color: color.state == 'dark'
                                ? Colors.white
                                : primaryText,
                          ),
                          decoration: InputDecoration.collapsed(
                              hintStyle: TextStyle(
                                color: color.state == 'dark'
                                    ? darkModeText
                                    : primaryTextLow,
                                fontSize: 14,
                              ),
                              hintText: "Enter your review message here"),
                        )),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Opacity(
                        opacity: loading.value ? 0.3 : 1,
                        child: ButtonWidget(
                          action: loading.value ? () => {} : makeReview,
                          text: "Update Review",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: focusedMessage.value == true
                          ? MediaQuery.of(context).viewInsets.bottom
                          : 0,
                    )
                  ]))),
    );
  }
}

class DeleteReviewModal extends HookWidget {
  final Function deleteReview;
  final Map review;
  const DeleteReviewModal(
      {Key? key, required this.deleteReview, required this.review})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final ratingValue = useState(1.0);
    final messageInput = useTextEditingController();
    final focusedMessage = useState(false);
    final _focusNodeMessage = useFocusNode();
    final loading = useState(false);

    useEffect(() {
      _focusNodeMessage.addListener(() {
        focusedMessage.value = _focusNodeMessage.hasFocus ? true : false;
      });
      ratingValue.value = double.parse(review['rating'].toString());
      messageInput.text =
          review['review'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
    }, const []);

    makeReview() async {
      loading.value = true;
      bool submit = await deleteReview(review['id']);
      loading.value = false;
      if (submit) {
        Navigator.pop(context);
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: color.state == 'dark' ? primaryText : Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CloseWidget(),
                      ],
                    ),
                    SizedBox(height: 35),
                    Text(
                      "Are you sure you want to delete this review?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: color.state == 'dark'
                              ? Colors.white
                              : primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 40),
                        child: Opacity(
                          opacity: loading.value ? 0.3 : 1,
                          child: TextButton(
                              onPressed: loading.value ? () => {} : makeReview,
                              style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFFBD3030),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 60)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      loading.value
                                          ? "Deleting..."
                                          : "Yes, delete.",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(width: 10),
                                  SvgPicture.asset(
                                      iconsPath + 'arrow-right.svg',
                                      color: Colors.white)
                                ],
                              )),
                        )),
                    SizedBox(
                      height: focusedMessage.value == true
                          ? MediaQuery.of(context).viewInsets.bottom
                          : 0,
                    )
                  ]))),
    );
  }
}

class EachReview extends HookWidget {
  final Map review;
  final Function updateReview, deleteReview;
  const EachReview(
      {Key? key,
      required this.review,
      required this.updateReview,
      required this.deleteReview})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final account = useProvider(accountProvider);
    final color = useProvider(colorProvider);
    String date = Jiffy(review['date_created_gmt'], "yyyy-MM-dd").yMMMMd;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.state == 'dark' ? darkModeBg : Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: color.state == 'dark' ? appBoxShadowDark : appBoxShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            color: Color(0xFFF3F3E8),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: review['reviewer_avatar_urls'] != null &&
                                        review['reviewer_avatar_urls']["96"] !=
                                            null
                                    ? Image.network(
                                            review['reviewer_avatar_urls']
                                                ["96"])
                                        .image
                                    : Image.asset(
                                            "assets/images/placeholder.png")
                                        .image),
                            border:
                                Border.all(color: darkModeTextHigh, width: 2),
                            shape: BoxShape.circle)),
                    SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 2.8,
                              padding: EdgeInsets.only(left: 3.0),
                              child: Text(
                                "${review['reviewer']}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    height: 1,
                                    color: color.state == 'dark'
                                        ? darkModeTextHigh
                                        : primaryText),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        RatingBar.builder(
                          initialRating:
                              double.parse(review['rating'].toString()),
                          minRating: 1,
                          direction: Axis.horizontal,
                          ignoreGestures: true,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 16.0,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Color(0xFFEB920D),
                          ),
                          unratedColor: color.state == 'dark'
                              ? darkModeTextHigh.withOpacity(0.5)
                              : Colors.black12,
                          onRatingUpdate: (rating) {
                            print(rating);
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                child: Text(
                  "$date",
                  style: TextStyle(color: Color(0xFF8F8F8F), fontSize: 12),
                ),
              )
            ],
          ),
          review['review'].length == 0
              ? SizedBox()
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 15),
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: color.state == 'dark'
                                    ? Color(0xFFF9F9F9).withOpacity(0.03)
                                    : Color(0xFFF9F9F9)),
                            child: Text(
                              "${review['review'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}",
                              style: TextStyle(
                                  color: color.state == 'dark'
                                      ? darkModeText
                                      : Color(0xFF8F8F8F)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    account.state['email'] == review['reviewer_email']
                        ? Container(
                            margin: EdgeInsets.only(top: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () => {
                                    if (account.state['id'] != null)
                                      {
                                        showMaterialModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            barrierColor:
                                                Colors.black.withOpacity(0.5),
                                            context: context,
                                            builder: (context) =>
                                                EditReviewModal(
                                                    review: review,
                                                    updateReview: updateReview))
                                      }
                                    else
                                      {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Login()),
                                        )
                                      }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 10, left: 10, right: 5),
                                    child: Text(
                                      "Edit",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: color.state == 'dark'
                                              ? darkModeText
                                              : primaryText),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => {
                                    if (account.state['id'] != null)
                                      {
                                        showMaterialModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            barrierColor:
                                                Colors.black.withOpacity(0.5),
                                            context: context,
                                            builder: (context) =>
                                                DeleteReviewModal(
                                                    review: review,
                                                    deleteReview: deleteReview))
                                      }
                                    else
                                      {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Login()),
                                        )
                                      }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(top: 10, left: 5),
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFBD3030)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox()
                  ],
                )
        ],
      ),
    );
  }
}

class EachProgress extends HookWidget {
  final double progress;
  final int star;
  const EachProgress({
    Key? key,
    required this.progress,
    required this.star,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$star star",
            style: TextStyle(
                fontSize: 12,
                height: 1,
                color: color.state == 'dark'
                    ? darkModeTextHigh.withOpacity(0.8)
                    : Color(0xFF393939)),
          ),
          Expanded(
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: CupertinoProgressBar(
                  valueColor: colorPrimary,
                  value: progress,
                  trackColor: color.state == 'dark'
                      ? darkModeTextHigh.withOpacity(0.3)
                      : Colors.black12,
                )),
          ),
          Text(
            "${(progress * 100).toStringAsFixed(1)}%",
            style: TextStyle(
                fontSize: 12,
                height: 1,
                color: color.state == 'dark'
                    ? darkModeTextHigh.withOpacity(0.8)
                    : Color(0xFF393939)),
          ),
        ],
      ),
    );
  }
}
