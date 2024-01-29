import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';

class MainChip extends HookWidget {
  final String title, option;
  final Function action;
  final ValueNotifier<List> selections;
  final ValueNotifier<List> variations;
  final ValueNotifier<Map> currentVariation;
  const MainChip({
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
    final color = useProvider(colorProvider);
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
      opacity: active == true ? 1 : 0.4,
      child: InkWell(
        onTap: () => active ? action({"title": title, "option": option}) : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              color: selected && active
                  ? colorPrimary.withOpacity(0.02)
                  : color.state == 'dark'
                      ? darkModeTextHigh
                      : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  width: selected && active ? 2 : 0.5,
                  color: selected && active ? colorPrimary : primaryText)),
          child: Text("$option",
              style: TextStyle(
                  color: color.state == 'dark'
                      ? selected && active
                          ? darkModeText
                          : Colors.black
                      : Colors.black,
                  fontSize: 13)),
        ),
      ),
    );
  }
}
