import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';

class AdditionalInfo extends HookWidget {
  const AdditionalInfo({
    Key? key,
    required this.attributes,
  }) : super(key: key);

  final ValueNotifier<List> attributes;

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
                  child: Text("Additional Information",
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
          toggleMode.value == 3
              ? SizedBox()
              : Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: color.state == 'dark'
                          ? Color(0xFFF9F9F9).withOpacity(0.03)
                          : Color(0xFFF9F9F9)),
                  child: Column(
                    children: attributes.value
                        .asMap()
                        .entries
                        .map((atr) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: atr.key == 0 ? 0 : 15),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${atr.value['name']}:",
                                        style: TextStyle(
                                            color: color.state == 'dark'
                                                ? darkModeText
                                                : Color(0xFF272727),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                                "${atr.value['options'] != null ? atr.value['options'].map((eachoption) => eachoption) : ''}",
                                                style: TextStyle(
                                                    color: Color(0xFF8F8F8F),
                                                    fontSize: 14)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
