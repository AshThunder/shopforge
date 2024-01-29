import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';

class DescriptionArea extends HookWidget {
  const DescriptionArea({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Map product;

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final toggleMode = useState(0);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.state == 'dark' ? darkModeBg : Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: color.state == 'dark' ? appBoxShadowDark : appBoxShadow,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => {
              toggleMode.value = toggleMode.value == 3 ? 0 : 3,
            },
            child: Row(
              children: [
                Expanded(
                  child: Text("Description",
                      style: TextStyle(
                          color: color.state == 'dark'
                              ? Colors.white
                              : primaryText,
                          fontWeight: FontWeight.w500,
                          fontSize: 14)),
                ),
                RotatedBox(
                  quarterTurns: toggleMode.value,
                  child: SvgPicture.asset(
                    iconsPath + "chevron-down.svg",
                    color: color.state == 'dark'
                        ? Colors.white
                        : Color(0xFF282828),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: toggleMode.value == 3 ? 0 : 15),
          // Text("old variations"),
          // Container(
          //     child: Column(
          //   children: backupVariations.value
          //       .map((each) => JsonViewer(each))
          //       .toList(),
          // )),
          // Divider(
          //   color: Color(0xFFDDDDDD),
          //   height: 5,
          // ),
          // Text("attributes"),
          // Container(
          //     child: Column(
          //   children: attributes.value
          //       .map((each) => JsonViewer(each))
          //       .toList(),
          // )),
          toggleMode.value == 3
              ? SizedBox()
              : Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: color.state == 'dark'
                          ? Color(0xFFF9F9F9).withOpacity(0.03)
                          : Color(0xFFF9F9F9)),
                  child: Text(
                      "${product['description'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}",
                      style: TextStyle(
                          color: color.state == 'dark'
                              ? darkModeText
                              : Color(0xFF383737),
                          height: 1.4,
                          fontSize: 14)),
                ),
        ],
      ),
    );
  }
}
