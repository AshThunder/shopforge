import 'package:flutter/material.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/color.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ColorChip extends HookWidget {
  final String title, option;
  final Function action;
  final ValueNotifier<List> selections;
  final ValueNotifier<List> variations;
  final ValueNotifier<Map> currentVariation;
  const ColorChip({
    Key? key,
    this.title = "",
    this.option = "",
    required this.action,
    required this.selections,
    required this.variations,
    required this.currentVariation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool selected = selections.value
            .where((element) =>
                (element['title'] == title) && (element['option'] == option))
            .length >
        0;
    bool active = true;
    if (currentVariation.value['id'] != null) {
      List myAttributes = currentVariation.value['attributes'];
      bool member = myAttributes
              .where((em) => (em['name'] == title) && (em['option'] == option))
              .length >
          0;

      if (!member) {
        active = false;
      }
    }

    return Opacity(
      opacity: active == true ? 1 : 0.2,
      child: InkWell(
        onTap: () => active ? action({"title": title, "option": option}) : null,
        child: Container(
          margin: EdgeInsets.only(right: 10),
          height: 30,
          width: 30,
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: selected && active
                  ? colorPrimary.withOpacity(0.02)
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                  width: selected && active ? 2 : 0.5,
                  color: selected && active ? colorPrimary : primaryText)),
          child: Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
                color: colors[option.toLowerCase()] != null
                    ? HexColor("${colors[option.toLowerCase()]}")
                    : Colors.black,
                shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
