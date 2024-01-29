import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shopforge/config/app.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/utils/Providers.dart';

class CloseWidget extends HookWidget {
  const CloseWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
            color:
                color.state == 'dark' ? Color(0xFF1D191D) : Color(0xFFEFEFE1),
            borderRadius: BorderRadius.circular(20)),
        child: SvgPicture.asset(
          iconsPath + 'close.svg',
          color: color.state == 'dark' ? Colors.white : Color(0xFF141414),
        ),
      ),
    );
  }
}
