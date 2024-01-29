import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:shopforge/pages/tabs/shop.dart';
import 'package:shopforge/screens/categories_more.dart';
import 'package:shopforge/utils/Providers.dart';

class Categories extends HookWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = useProvider(categoryProvider);
    final color = useProvider(colorProvider);

    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            color: color.state == 'dark' ? bgPrimaryDark : bgPrimary,
            padding: EdgeInsets.only(
              top: 30,
            ),
            child: Column(children: [
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [CloseWidget()],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Categories",
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
              ),
              SizedBox(height: 40),
              Expanded(
                  child: SingleChildScrollView(
                      child: Container(
                          padding: EdgeInsets.only(left: 25, right: 25),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 25, horizontal: 30),
                                  decoration: BoxDecoration(
                                      color: color.state == 'dark'
                                          ? darkModeBg
                                          : Color(0xFFEFEFEB),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Column(
                                    children: [
                                      ...categories.state.map((category) =>
                                          InkWell(
                                            onTap: () => {
                                              if (category['children'] !=
                                                      null &&
                                                  category['children'].length >
                                                      0)
                                                {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CategoriesMore(
                                                                  category:
                                                                      category)))
                                                }
                                              else
                                                {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Shop(
                                                                  categoried:
                                                                      true,
                                                                  categoryID:
                                                                      category[
                                                                          'id'],
                                                                  categoryName:
                                                                      category[
                                                                          'name'])))
                                                }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 15),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 32.0,
                                                        height: 32.0,
                                                        margin: EdgeInsets.only(
                                                            right: 15),
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0xFFF1DEC1),
                                                                  width: 2,
                                                                )),
                                                        child: Container(
                                                          width: 30.0,
                                                          height: 60.0,
                                                          decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                  fit: BoxFit.fitWidth,
                                                                  image: category['image'] != null
                                                                      ? Image.network(category['image']['src']).image
                                                                      : Image.asset(
                                                                          "assets/images/placeholder.png",
                                                                        ).image),
                                                              shape: BoxShape.circle),
                                                        ),
                                                      ),
                                                      Text(
                                                        "${category['name']}",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: color.state ==
                                                                    'dark'
                                                                ? darkModeText
                                                                : primaryText),
                                                      ),
                                                    ],
                                                  ),
                                                  SvgPicture.asset(
                                                    iconsPath +
                                                        "arrow-right.svg",
                                                    color: color.state == 'dark'
                                                        ? darkModeText
                                                        : primaryText,
                                                  )
                                                ],
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                )
                              ]))))
            ])));
  }
}
