import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shopforge/config/app.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/utils/Providers.dart';

class ChangeQuantity extends HookWidget {
  final Function changeQuantity;
  const ChangeQuantity({
    Key? key,
    required this.quantity,
    required this.changeQuantity,
  }) : super(key: key);

  final ValueNotifier<int> quantity;

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    return Container(
      width: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colorPrimary),
          color: colorPrimary.withOpacity(0.02)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => changeQuantity('minus'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: SvgPicture.asset(
                iconsPath + 'minus.svg',
                width: 22,
                color: colorPrimary,
              ),
            ),
          ),
          Text(
            "${quantity.value}".padLeft(2, "0"),
            style: TextStyle(
                color: color.state == 'dark' ? darkModeText : primaryText,
                fontWeight: FontWeight.w500),
          ),
          InkWell(
            onTap: () => changeQuantity('plus'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: SvgPicture.asset(
                iconsPath + 'plus.svg',
                width: 22,
                color: colorPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
