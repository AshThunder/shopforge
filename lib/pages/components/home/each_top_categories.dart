import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/tabs/shop.dart';
import 'package:shopforge/utils/Providers.dart';

class EachTopCategories extends HookWidget {
  final Map category;

  const EachTopCategories(this.category);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);

    return InkWell(
      onTap: () => {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Shop(
                    categoried: true,
                    categoryID: category['id'],
                    categoryName: category['name'])))
      },
      child: Container(
        child: Column(
          children: [
            Container(
              width: 63.0,
              height: 63.0,
              decoration: BoxDecoration(
                  color: Color(0xFFF3F3E8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFFF1DEC1),
                    width: 3,
                  )),
              child: Container(
                width: 60.0,
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
            SizedBox(height: 10),
            Text("${category['name']}",
                style: TextStyle(
                    color:
                        color.state == 'dark' ? darkModeText : primaryTextLow,
                    fontSize: 13))
          ],
        ),
      ),
    );
  }
}
