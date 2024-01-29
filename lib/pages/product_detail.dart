import 'dart:convert';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/tabs/cart.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/db_helper.dart';
import 'package:shopforge/utils/network.dart';
import 'package:shopforge/utils/shop_action.dart';
import 'components/product_detail/additional_info.dart';
import 'components/product_detail/color_chip.dart';
import 'components/product_detail/description_area.dart';
import 'components/product_detail/main_chip.dart';
import 'components/product_detail/price_widget.dart';
import 'components/product_detail/review_area.dart';
import 'components/shop/change_quantity.dart';

class ProductDetail extends HookWidget {
  final Map product;
  const ProductDetail({Key? key, required this.product}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    CarouselController _controller = CarouselController();
    final color = useProvider(colorProvider);
    final cartState = useProvider(cartProvider);
    final variationState = useProvider(variationProvider);
    final wishlists = useProvider(wishlistsProvider);
    final _current = useState(0);
    final quantity = useState(1);
    List productImages = product["images"];
    final variations = useState([]);
    final attributes = useState([]);
    final variationMap = useState([]);
    final selections = useState([]);
    final newVariations = useState([]);
    final backupVariations = useState([]);
    final reviews = useState([]);
    final currentVariation = useState({});
    final loadingVariation = useState(true);
    final loadingVariationError = useState(true);
    final wished = useState(false);
    DBHelper dbHelper = new DBHelper();
    final averageRatings = useState(1.0);
    double getAverageRatings() {
      double sum = 0.0;
      for (var item in reviews.value) {
        sum += double.parse(item['rating'].toString());
      }
      return (sum / reviews.value.length);
    }

    averageRatings.value = getAverageRatings();

    calculateCart() {
      var sum = 0;
      for (var item in cartState.state) {
        sum += int.parse(item['quantity'].toString());
      }
      return sum;
    }

    bool checkSelections() {
      for (var item in selections.value) {
        List variate = currentVariation.value['attributes'];
        bool check = variate
                .where((element) =>
                    (element['name'] == item['title']) &&
                    (element['option'] == item['option']))
                .length ==
            0;
        if (check) {
          return false;
        }
      }
      return true;
    }

    addToCart() async {
      if (product['type'] == 'variable' &&
          currentVariation.value['id'] == null) {
        ShopAction()
            .newToastError(context, "Please select from the list of options");
      } else {
        if (product['type'] == 'variable' &&
            selections.value.length != product['attributes'].length) {
          ShopAction()
              .newToastError(context, "Please complete the option selection");
        } else {
          if (product['type'] == 'variable' && !checkSelections()) {
            ShopAction()
                .newToastError(context, "Please complete the option selection");
          } else {
            ShopAction().addToCart(
                product,
                quantity.value,
                currentVariation.value['id'] != null
                    ? currentVariation.value['id']
                    : 0,
                cartState,
                selections.value,
                currentVariation.value['price']);
            ShopAction().newToastSuccess(context,
                "(${quantity.value}) ${product['name']} added to cart");
            quantity.value = 1;
          }
        }
      }
    }

    changeQuantity(String type) {
      if (type == 'plus') {
        quantity.value++;
      } else {
        if (quantity.value > 1) quantity.value--;
      }
    }

    makeChoices(choice) async {
      var find = selections.value
          .where((element) => (element['title'] == choice['title']));
      if (find.length == 0) {
        selections.value = [...selections.value, choice];
      } else {
        selections.value = selections.value
            .where((element) => (element['title'] != choice['title']))
            .toList();
        selections.value = [...selections.value, choice];
      }
      for (var element in variationMap.value) {
        Map me = element;
        for (var item in attributes.value) {
          String name = item['name'];
          List options = item['options'];

          for (var option in options) {
            List thisAttr = me['attributes'];
            bool exists = thisAttr
                    .where((el) =>
                        (el['name'] == name) && (el['option'] == option))
                    .length >
                0;
            if (!exists) {
              bool hasID = thisAttr
                      .where((em) => (em['name'] == name) && (em['id'] != null))
                      .length >
                  0;
              if (!hasID) {
                me['attributes'] = [
                  ...me['attributes'],
                  {"name": name, "option": option}
                ];
              }
            }
          }
        }

        newVariations.value = [...newVariations.value, me];
      }

      bool changeVariation = true;

      for (var single in newVariations.value) {
        List singleAttributes = single['attributes'];
        int findOne = singleAttributes
            .where((cv) =>
                (cv['name'] == choice['title']) &&
                cv['option'] == choice['option'])
            .length;
        if (findOne > 0) {
          if (currentVariation.value['id'] == null) {
            currentVariation.value = single;
          }
          changeVariation = false;
          break;
        }
      }
      if (changeVariation) {
        for (var mine in newVariations.value) {
          List mineAttributes = mine['attributes'];
          List xy = mineAttributes
              .where((et) =>
                  (et['name'] == choice['title']) &&
                  et['option'] == choice['option'])
              .toList();
          if (xy.length > 0) {
            currentVariation.value = mine;
            break;
          }
        }
      }
      // print(newVariations);
      // print(selections.value);
      print(currentVariation.value);
    }

    clearChoices() {
      selections.value = [];
      currentVariation.value = {};
    }

    setVariations(body) {
      variationState.state[product['id']] = body;
      variations.value = body;
      body.forEach((variant) {
        var each = {
          "id": variant["id"],
          "attributes": variant["attributes"],
          "price": variant["price"],
          "regular_price": variant["regular_price"],
        };
        variationMap.value = [...variationMap.value, each];
        backupVariations.value = [...backupVariations.value, each];
      });

      print(variationMap.value);
    }

    loadData() async {
      loadingVariation.value = true;
      var box = await Hive.openBox('appBox');
      if (box.get('cart') != null) {
        cartState.state = jsonDecode(box.get('cart'));
      }
      attributes.value = product['attributes'];
      print(product['id']);

      if (product['type'] == 'variable') {
        int productId = product['id'];
        try {
          if (variationState.state.length > 0 &&
              variationState.state[productId] != null) {
            setVariations(variationState.state[product['id']]);

            loadingVariation.value = false;
            loadingVariationError.value = false;
          }
        } catch (e) {}
        try {
          var response = await Network()
              .getAsync("products/${product['id']}/variations?per_page=20");
          var body = json.decode(response.body);
          if (response.statusCode == 200) {
            loadingVariation.value = false;
            loadingVariationError.value = false;

            setVariations(body);
          } else {
            loadingVariation.value = false;
            loadingVariationError.value = true;
          }
        } catch (e) {
          loadingVariation.value = false;
          loadingVariationError.value = true;
          print(e);
        }
      } else {
        loadingVariation.value = false;
        loadingVariationError.value = false;
      }
    }

    addToWishlist() async {
      await dbHelper.toggleWishlist(product['id']);
      wished.value = !wished.value;
      if (wished.value) {
        ShopAction().newToastSuccess(context, "Product added to wishlist");
      } else {
        ShopAction().newToastSuccess(context, "Product removed from wishlist");
      }
      var box = await Hive.openBox('appBox');
      if (box.get('bookmarks') != null) {
        wishlists.state = jsonDecode(box.get('wishlists'));
      }
    }

    checkWishlist() async {
      var box = await Hive.openBox('appBox');
      List alldata = jsonDecode(box.get('wishlists'));
      bool exists =
          alldata.where((element) => element == product['id']).length > 0
              ? true
              : false;
      if (exists) {
        wished.value = true;
      } else {
        wished.value = false;
      }
    }

    useEffect(() {
      checkWishlist();
      loadData();
    }, const []);

    final List<Widget> imageSliders = productImages
        .asMap()
        .entries
        .map((pImage) => Container(
              child: InkWell(
                onTap: null,
                child: pImage.key == 0
                    ? Hero(
                        tag: "recommendation-${product['slug']}",
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 25.0),
                            height: 216,
                            decoration: BoxDecoration(
                                color: Color(0xFFF3F3E8),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: Image.network(pImage.value["src"])
                                        .image),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.0)))),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 25.0),
                        height: 216,
                        decoration: BoxDecoration(
                            color: Color(0xFFF3F3E8),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                    Image.network(pImage.value["src"]).image),
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)))),
              ),
            ))
        .toList();

    return Scaffold(
      body: Container(
        color: color.state == 'dark' ? bgPrimaryDark : bgPrimary,
        padding: EdgeInsets.only(top: 30),
        child: Column(children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    child: SvgPicture.asset(
                      iconsPath + 'arrow-left.svg',
                      color: color.state == 'dark' ? Colors.white : primaryText,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Cart(closable: true)))
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          transform: Matrix4.translationValues(
                              cartState.state.length > 0 ? 10.0 : 0, 0.0, 0.0),
                          child: SvgPicture.asset(
                            iconsPath + 'shopping-bag.svg',
                            color: color.state == 'dark'
                                ? Colors.white
                                : primaryText,
                          ),
                        ),
                        cartState.state.length > 0
                            ? InkWell(
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Cart(closable: true)))
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(10)),
                                  transform: Matrix4.translationValues(
                                      0.0, -10.0, 0.0),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 5.5),
                                    child: Text(
                                      "${calculateCart() == 1 ? '0' : ''}${calculateCart()}",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CarouselSlider(
                    items: imageSliders,
                    carouselController: _controller,
                    options: CarouselOptions(
                        autoPlay: false,
                        enlargeCenterPage: false,
                        aspectRatio: 1.6,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          _current.value = index;
                        }),
                  ),
                  SizedBox(height: 10),
                  product["images"] != null && product["images"].length > 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: productImages.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () => _controller.animateToPage(entry.key),
                              child: Container(
                                width:
                                    _current.value == entry.key ? 12.0 : 12.0,
                                height: 12.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: _current.value == entry.key
                                        ? Color(0xFFEB920D)
                                        : Color(0xFFF3F3E8)),
                              ),
                            );
                          }).toList(),
                        )
                      : SizedBox(),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${product['name']}",
                            style: TextStyle(
                                color: color.state == 'dark'
                                    ? Colors.white
                                    : primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: PriceWidget(
                                  product: product,
                                  currentVariation: currentVariation),
                            ),
                            reviews.value.length == 0
                                ? SizedBox()
                                : RatingBar.builder(
                                    initialRating: averageRatings.value,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    ignoreGestures: true,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 2.0),
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
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 35),
                  Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                          child: loadingVariation.value
                              ? Container(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color:
                                          Color(0xFF292922).withOpacity(0.04)),
                                  child: SpinKitFadingCube(
                                    color: colorPrimary,
                                    size: 30.0,
                                  ),
                                )
                              : loadingVariationError.value
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Text("Unable to load variations",
                                                  style: TextStyle(
                                                      color: Color(0xFF8F8F8F),
                                                      fontSize: 14)),
                                              SizedBox(height: 10),
                                              InkWell(
                                                onTap: loadData,
                                                child: Text("Tap to retry",
                                                    style: TextStyle(
                                                        color: color.state ==
                                                                'dark'
                                                            ? Colors.white
                                                            : primaryText,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ...attributes.value
                                            .asMap()
                                            .entries
                                            .map((attribute) => Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          7.0),
                                                              child: Text(
                                                                  "${attribute.value['name']}",
                                                                  style: TextStyle(
                                                                      color: color.state ==
                                                                              'dark'
                                                                          ? darkModeText
                                                                          : primaryText,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          14)),
                                                            ),
                                                          ),
                                                          selections.value.length >
                                                                      0 &&
                                                                  attribute
                                                                          .key ==
                                                                      0
                                                              ? InkWell(
                                                                  onTap:
                                                                      clearChoices,
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            6.0,
                                                                        horizontal:
                                                                            8),
                                                                    decoration: BoxDecoration(
                                                                        color: color.state ==
                                                                                'dark'
                                                                            ? Color(
                                                                                0xFF1D191D)
                                                                            : Color(
                                                                                0xFFF8F8F8),
                                                                        borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                    child: Row(
                                                                      children: [
                                                                        SvgPicture.asset(
                                                                            iconsPath +
                                                                                'close.svg',
                                                                            height:
                                                                                18,
                                                                            color: color.state == 'dark'
                                                                                ? Color(0xFFDDDDDD)
                                                                                : primaryText),
                                                                        Text(
                                                                          "Clear selection",
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              color: color.state == 'dark' ? Color(0xFFDDDDDD) : primaryText),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ))
                                                              : SizedBox(),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                      attribute.value['name'] ==
                                                                  "Color" ||
                                                              attribute.value[
                                                                      'name'] ==
                                                                  "Colour" ||
                                                              attribute.value[
                                                                      'name'] ==
                                                                  "Colors" ||
                                                              attribute.value[
                                                                      'name'] ==
                                                                  "Colours"
                                                          ? Row(
                                                              children: (attribute
                                                                              .value[
                                                                          'options']
                                                                      as List)
                                                                  .map((option) => ColorChip(
                                                                      option:
                                                                          option,
                                                                      selections:
                                                                          selections,
                                                                      variations:
                                                                          variationMap,
                                                                      currentVariation:
                                                                          currentVariation,
                                                                      title: attribute
                                                                              .value[
                                                                          'name'],
                                                                      action:
                                                                          (me) =>
                                                                              {
                                                                                makeChoices(me)
                                                                              }))
                                                                  .toList(),
                                                            )
                                                          : Row(
                                                              children: (attribute
                                                                              .value[
                                                                          'options']
                                                                      as List)
                                                                  .map((option) => MainChip(
                                                                      option:
                                                                          option,
                                                                      selections:
                                                                          selections,
                                                                      variations:
                                                                          variationMap,
                                                                      currentVariation:
                                                                          currentVariation,
                                                                      title: attribute
                                                                              .value[
                                                                          'name'],
                                                                      action:
                                                                          (me) =>
                                                                              {
                                                                                makeChoices(me)
                                                                              }))
                                                                  .toList(),
                                                            ),
                                                    ],
                                                  ),
                                                ))
                                            .toList(),
                                        SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  ChangeQuantity(
                                                      quantity: quantity,
                                                      changeQuantity:
                                                          changeQuantity),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () => addToWishlist(),
                                                  child: SvgPicture.asset(
                                                      iconsPath + 'heart.svg',
                                                      height: 30,
                                                      color: wished.value
                                                          ? Color(0xFFBD3030)
                                                          : primaryText),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 7),
                                      ],
                                    ),
                        ),
                        Container(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 25),
                            DescriptionArea(product: product),
                            SizedBox(height: 25),
                            AdditionalInfo(attributes: attributes),
                            SizedBox(height: 25),
                            ReviewArea(
                              product: product,
                              reviews: reviews,
                            ),
                            SizedBox(height: 25),
                          ],
                        ))
                      ]))
                ],
              ),
            ),
          ),
          Container(
            color: color.state == 'dark' ? Color(0xFF000205) : Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: addToWishlist,
                    style: TextButton.styleFrom(
                        backgroundColor: color.state == 'dark'
                            ? Color(0xFF000205)
                            : Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(iconsPath + 'heart.svg',
                            color: wished.value
                                ? Color(0xFFBD3030)
                                : color.state == 'dark'
                                    ? darkModeText
                                    : primaryText),
                        SizedBox(width: 1),
                        Text(
                            wished.value
                                ? "Added to wishlist"
                                : "Add to wishlist",
                            style: TextStyle(
                                color: wished.value
                                    ? Color(0xFFBD3030)
                                    : color.state == 'dark'
                                        ? darkModeText
                                        : primaryText,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline)),
                      ],
                    )),
                SizedBox(width: 14),
                TextButton(
                    onPressed: addToCart,
                    style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF0692B0),
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF0692B0)),
                            borderRadius: BorderRadius.circular(4))),
                    child: Row(
                      children: [
                        Text("Add to cart",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: 10),
                        SvgPicture.asset(iconsPath + 'shopping-bag.svg',
                            color: Colors.white)
                      ],
                    )),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
