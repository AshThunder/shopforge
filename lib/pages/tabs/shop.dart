import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/error_messages/empty_error.dart';
import 'package:shopforge/pages/components/error_messages/network_error.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';
import 'package:shopforge/pages/components/home/each_shop_products.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:shopforge/utils/Providers.dart';
import 'package:shopforge/utils/network.dart';

const FILTERS = {
  "order": "desc",
  "order_by": "date",
  "in_stock": false,
  "on_sale": false,
  "featured": false
};

class Shop extends HookWidget {
  final bool categoried;
  final int categoryID;
  final String categoryName;
  const Shop(
      {Key? key,
      this.categoried = false,
      this.categoryID = 0,
      this.categoryName = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final products = useProvider(newestsProvider);
    final search = useTextEditingController();
    final _focusNode = useFocusNode();
    final focused = useState(false);
    final page = useState(1);
    bool largeScreen = MediaQuery.of(context).size.width > 800 ? true : false;
    bool mdScreen = MediaQuery.of(context).size.width > 500 &&
            MediaQuery.of(context).size.width <= 800
        ? true
        : false;
    final filter = useState({
      "order": "desc",
      "order_by": "date",
      "in_stock": false,
      "on_sale": false,
      "featured": false
    });

    final searching = useState(false);
    final loading = useState(true);
    final loadingError = useState(true);
    final loadingMore = useState(false);
    final isLoadMoreDone = useState(false);

    final searchText = useState('');
    final morelink = useState('');
    final categoryString =
        useState(categoryID != 0 ? '&category=$categoryID' : '');

    loadData() async {
      loading.value = true;
      loadingError.value = false;
      loadingError.value = false;
      isLoadMoreDone.value = false;
      page.value = 1;
      try {
        await Future.delayed(Duration(microseconds: 500));
        if (categoried) {
          products.state = [];
        }
        var response = await Network().getAsync(
            "products?per_page=20&status=publish${morelink.value}${categoryString.value}&search=${search.text}&page=${page.value}");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          loading.value = false;
          loadingError.value = false;
          products.state = body;
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

    void loadMore() async {
      try {
        loadingMore.value = true;
        page.value++;
        var response = await Network().getAsync(
            "products?per_page=20&status=publish${morelink.value}${categoryString.value}&search=${search.text}&page=${page.value}");
        var body = json.decode(response.body);
        loadingMore.value = false;
        if (response.statusCode == 200) {
          if (body.length > 0) {
            products.state = [...products.state, ...body];
            isLoadMoreDone.value = false;
          } else {
            isLoadMoreDone.value = true;
          }
        } else {
          isLoadMoreDone.value = false;
        }
      } catch (e) {
        loadingMore.value = false;
        isLoadMoreDone.value = false;
      }
    }

    searchData() async {
      if (search.text.length > 0) {
        searching.value = true;
        searchText.value = search.text;
        await Future.delayed(Duration(seconds: 2));
        if (!loading.value) {
          loading.value = true;
          loadingError.value = false;
          page.value = 1;
          try {
            var response = await Network().getAsync(
                "products?per_page=20&status=publish&page=${page.value}&search=${search.text}${morelink.value}${categoryString.value}&page=${page.value}");
            var body = json.decode(response.body);
            if (response.statusCode == 200) {
              loading.value = false;
              searching.value = false;
              loadingError.value = false;
              products.state = body;
            } else {
              loading.value = false;
              searching.value = false;
              loadingError.value = true;
            }
          } catch (e) {
            loading.value = false;
            searching.value = false;
            loadingError.value = true;
            print(e);
          }
        }
      }
    }

    bool isFiltered() {
      if (DeepCollectionEquality().equals(FILTERS, filter.value)) {
        return false;
      } else {
        return true;
      }
    }

    makeFilter() {
      String attache = '';
      attache +=
          "&order=${filter.value['order']}&orderby=${filter.value['order_by']}";
      if (filter.value['in_stock'] == true) {
        attache += "&stock_status=instock";
      }
      if (filter.value['on_sale'] == true) {
        attache += "&on_sale=true";
      }
      if (filter.value['featured'] == true) {
        attache += "&featured=true";
      }
      morelink.value = attache;
      if (search.text.length > 0) {
        searchData();
      } else {
        loadData();
      }
    }

    setFilter(value) {
      filter.value = {};
      filter.value = value;
      makeFilter();
    }

    useEffect(() {
      _focusNode.addListener(() {
        focused.value = _focusNode.hasFocus ? true : false;
      });
      loadData();
    }, const []);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
            color: color.state == 'dark' ? bgPrimaryDark : bgPrimary,
            padding: EdgeInsets.only(top: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    categoried
                        ? Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    "Shop",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFBEBEBE)),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Container(
                                  margin: EdgeInsets.only(top: 0.5),
                                  child: SvgPicture.asset(
                                    iconsPath + "chevron-right.svg",
                                    color: Color(0xFFBEBEBE),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "$categoryName",
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
                          )
                        : Expanded(
                            child: Text(
                              "Shop",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: color.state == 'dark'
                                      ? Colors.white
                                      : Color(0xFF1B1B1B)),
                            ),
                          ),
                    categoried ? CloseWidget() : SizedBox()
                  ],
                ),
              ),
              SizedBox(height: categoried ? 30 : 20),
              Row(
                children: [
                  SizedBox(width: 25),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: focused.value
                              ? Color(0xFFF1F1F1).withOpacity(0.1)
                              : color.state == 'dark'
                                  ? Color(0xFFF1F1F1).withOpacity(0.2)
                                  : Color(0xFFEFEFEB),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: focused.value
                                ? colorPrimary
                                : Colors.transparent,
                            width: 1,
                          )),
                      child: Container(
                        padding: EdgeInsets.only(left: 15, right: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 2),
                                child: TextFormField(
                                    focusNode: _focusNode,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: color.state == 'dark'
                                            ? darkModeTextHigh
                                            : Colors.black,
                                        height: 1.2,
                                        fontWeight: FontWeight.w100),
                                    decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Color(0xFFA9A9A9),
                                            fontSize: 14,
                                            height: 1.2,
                                            fontWeight: FontWeight.w100),
                                        border: InputBorder.none,
                                        hintText: "Search Products"),
                                    onChanged: (text) {
                                      searchData();
                                    },
                                    controller: search),
                              ),
                            ),
                            loading.value || searching.value
                                ? Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: SpinKitFadingCube(
                                      color: colorPrimary,
                                      size: 16.0,
                                    ),
                                  )
                                : searchText.value.length > 0
                                    ? InkWell(
                                        onTap: () => {
                                          searchText.value = '',
                                          search.text = "",
                                          FocusScope.of(context).unfocus(),
                                          loadData()
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: focused.value
                                              ? colorPrimary
                                              : color.state == 'dark'
                                                  ? darkModeTextHigh
                                                  : primaryText,
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        iconsPath + "search.svg",
                                        color: focused.value
                                            ? colorPrimary
                                            : color.state == 'dark'
                                                ? darkModeTextHigh
                                                : primaryText,
                                        width: 26,
                                      )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 25)
                ],
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                          text: search.text.length > 1
                              ? "Searching: ${search.text}"
                              : categoried
                                  ? "Category: $categoryName"
                                  : "New Arrivals"),
                      style: TextStyle(
                          color: color.state == 'dark'
                              ? darkModeText
                              : primaryText,
                          fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => showMaterialModalBottomSheet(
                            enableDrag: false,
                            backgroundColor: Colors.transparent,
                            barrierColor: Colors.black.withOpacity(0.5),
                            context: context,
                            builder: (context) => FilterModal(
                                filter: filter, setFilter: setFilter),
                          ),
                          child: SvgPicture.asset(
                            iconsPath + "filter.svg",
                            color: isFiltered()
                                ? colorPrimary
                                : color.state == 'dark'
                                    ? darkModeText
                                    : primaryText,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              loading.value && products.state.length == 0
                  ? Expanded(
                      child: Center(
                        child: SpinKitFadingCube(
                          color: colorPrimary,
                          size: 30.0,
                        ),
                      ),
                    )
                  : loadingError.value && products.state.length == 0
                      ? Expanded(
                          child: Center(
                            child: NetworkError(
                                loadData: loadData, message: "Network error,"),
                          ),
                        )
                      : products.state.length > 0
                          ? Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  if (!loading.value) loadData();
                                },
                                child: NotificationListener<ScrollNotification>(
                                  onNotification:
                                      (ScrollNotification scrollInfo) {
                                    if (scrollInfo.metrics.pixels ==
                                        scrollInfo.metrics.maxScrollExtent) {
                                      if (!isLoadMoreDone.value &&
                                          !loadingMore.value) {
                                        loadMore();
                                      }
                                    }
                                    return false;
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: GridView(
                                        padding: EdgeInsets.zero,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: largeScreen
                                                    ? 5
                                                    : mdScreen
                                                        ? 3
                                                        : 2,
                                                childAspectRatio: largeScreen
                                                    ? 0.85
                                                    : mdScreen
                                                        ? 0.90
                                                        : 0.65,
                                                crossAxisSpacing: 20),
                                        children: [
                                          ...products.state.map((product) =>
                                              EachShopProducts(product)),
                                        ]),
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              child: Center(
                                child: EmptyError(
                                    loadData: loadData,
                                    message: "No product found,"),
                              ),
                            ),
              loadingMore.value
                  ? Container(
                      margin: EdgeInsets.only(top: 10, bottom: 20),
                      child: SpinKitRotatingCircle(
                        color: colorPrimary,
                        size: 30.0,
                      ),
                    )
                  : SizedBox()
            ])),
      ),
    );
  }
}

class FilterModal extends HookWidget {
  const FilterModal({Key? key, required this.filter, required this.setFilter})
      : super(key: key);
  final Function setFilter;
  final ValueNotifier<Map> filter;

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final myFilter = useState(filter.value);

    final backupFilter = useState({
      "order": "desc",
      "order_by": "date",
      "in_stock": false,
      "on_sale": false,
      "featured": false
    });

    _handleOrderChange(value) {
      Map mine = myFilter.value;
      mine['order'] = value;
      myFilter.value = {};
      myFilter.value = mine;
    }

    _handleToggle(name) {
      Map mine = myFilter.value;
      mine[name] = !mine[name];
      myFilter.value = {};
      myFilter.value = mine;
    }

    return Container(
        height: MediaQuery.of(context).size.height / 1.4,
        padding: EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
            color: color.state == 'dark' ? primaryText : Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4), topRight: Radius.circular(4))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filter Products",
                  style: TextStyle(
                      color: color.state == 'dark' ? Colors.white : primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                ),
                CloseWidget(),
              ],
            ),
          ),
          SizedBox(height: 20),
          DeepCollectionEquality().equals(FILTERS, myFilter.value)
              ? SizedBox()
              : InkWell(
                  onTap: () => myFilter.value = backupFilter.value,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Clear filter",
                          style: TextStyle(
                              color: color.state == 'dark'
                                  ? Colors.white
                                  : primaryText,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order",
                            style: TextStyle(
                                color: color.state == 'dark'
                                    ? darkModeTextHigh
                                    : primaryText,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                          ),
                          SizedBox(height: 15),
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: color.state == 'dark'
                                  ? darkModeText
                                  : primaryText,
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => _handleOrderChange('asc'),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Radio(
                                            value: 'asc',
                                            toggleable: true,
                                            activeColor: colorPrimary,
                                            groupValue: myFilter.value['order'],
                                            onChanged: _handleOrderChange),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Ascending",
                                        style: TextStyle(
                                            color: color.state == 'dark'
                                                ? darkModeText
                                                : primaryText),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20),
                                InkWell(
                                  onTap: () => _handleOrderChange('desc'),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Radio(
                                            value: 'desc',
                                            toggleable: true,
                                            activeColor: colorPrimary,
                                            groupValue: myFilter.value['order'],
                                            onChanged: _handleOrderChange),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Descending",
                                        style: TextStyle(
                                            color: color.state == 'dark'
                                                ? darkModeText
                                                : primaryText),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(height: 25),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order By",
                          style: TextStyle(
                              color: color.state == 'dark'
                                  ? darkModeTextHigh
                                  : primaryText,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                        SizedBox(height: 15),
                        Container(
                          padding: EdgeInsets.only(left: 15, right: 10),
                          decoration: BoxDecoration(
                            color: color.state == 'dark'
                                ? Color(0xFFF1F1F1).withOpacity(0.2)
                                : Color(0xFFF1F1F1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButtonFormField(
                              dropdownColor: color.state == 'dark'
                                  ? primaryText
                                  : Colors.white,
                              decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.transparent))),
                              value: myFilter.value['order_by'],
                              style: TextStyle(
                                  color: color.state == 'dark'
                                      ? darkModeTextHigh
                                      : primaryText),
                              items: [
                                DropdownMenuItem(
                                  child: Text(
                                    "Date Added",
                                    style: TextStyle(
                                        color: color.state == 'dark'
                                            ? darkModeTextHigh
                                            : primaryText),
                                  ),
                                  value: 'date',
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    "Popularity",
                                    style: TextStyle(
                                        color: color.state == 'dark'
                                            ? darkModeTextHigh
                                            : primaryText),
                                  ),
                                  value: 'popularity',
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    "Ratings",
                                    style: TextStyle(
                                        color: color.state == 'dark'
                                            ? darkModeTextHigh
                                            : primaryText),
                                  ),
                                  value: 'rating',
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    "Product Price",
                                    style: TextStyle(
                                        color: color.state == 'dark'
                                            ? darkModeTextHigh
                                            : primaryText),
                                  ),
                                  value: 'price',
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    "Product Name",
                                    style: TextStyle(
                                        color: color.state == 'dark'
                                            ? darkModeTextHigh
                                            : primaryText),
                                  ),
                                  value: 'title',
                                )
                              ],
                              onChanged: (value) {
                                Map mine = myFilter.value;
                                mine['order_by'] = value.toString();
                                myFilter.value = {};
                                myFilter.value = mine;
                              },
                              hint: Text("Select item")),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  InkWell(
                    onTap: () => _handleToggle('in_stock'),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: color.state == 'dark'
                                      ? darkModeTextHigh.withOpacity(0.2)
                                      : Color(0xFFDFDFDF),
                                  width: 0.5),
                              bottom: BorderSide(
                                  color: color.state == 'dark'
                                      ? darkModeTextHigh.withOpacity(0.2)
                                      : Color(0xFFDFDFDF),
                                  width: 0.5))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "In Stock",
                            style: TextStyle(
                                color: color.state == 'dark'
                                    ? darkModeTextHigh
                                    : primaryText,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                          ),
                          CupertinoSwitch(
                            value: myFilter.value['in_stock'],
                            activeColor: colorPrimary,
                            onChanged: (value) {
                              Map mine = myFilter.value;
                              mine['in_stock'] = value;
                              myFilter.value = {};
                              myFilter.value = mine;
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _handleToggle('on_sale'),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: color.state == 'dark'
                                      ? darkModeTextHigh.withOpacity(0.2)
                                      : Color(0xFFDFDFDF),
                                  width: 0.5))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "On Sale",
                            style: TextStyle(
                                color: color.state == 'dark'
                                    ? darkModeTextHigh
                                    : primaryText,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                          ),
                          CupertinoSwitch(
                            value: myFilter.value['on_sale'],
                            activeColor: colorPrimary,
                            onChanged: (value) {
                              Map mine = myFilter.value;
                              mine['on_sale'] = value;
                              myFilter.value = {};
                              myFilter.value = mine;
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _handleToggle('featured'),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: color.state == 'dark'
                                      ? darkModeTextHigh.withOpacity(0.2)
                                      : Color(0xFFDFDFDF),
                                  width: 0.5))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Featured",
                            style: TextStyle(
                                color: color.state == 'dark'
                                    ? darkModeTextHigh
                                    : primaryText,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                          ),
                          CupertinoSwitch(
                            value: myFilter.value['featured'],
                            activeColor: colorPrimary,
                            onChanged: (value) {
                              Map mine = myFilter.value;
                              mine['featured'] = value;
                              myFilter.value = {};
                              myFilter.value = mine;
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20)
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: ButtonWidget(
              action: () {
                setFilter(myFilter.value);

                Navigator.pop(context);
              },
              text: "Filter results",
            ),
          )
        ]));
  }
}
