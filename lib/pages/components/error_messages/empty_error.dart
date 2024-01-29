import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';

class EmptyError extends HookWidget {
  final Function loadData;
  final String message;
  final bool isSmall, showAction;

  EmptyError(
      {required this.loadData,
      required this.message,
      this.isSmall = false,
      this.showAction = true});

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconsPath + 'search_state.svg',
            height: 120,
          ),
          SizedBox(
            height: isSmall ? 20 : 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$message",
                  style: TextStyle(
                      fontSize: 14,
                      color: color.state == 'dark' ? darkModeText : primaryText,
                      fontWeight: FontWeight.w400)),
              SizedBox(
                width: showAction ? 5 : 0,
              ),
              showAction
                  ? InkWell(
                      onTap: () => loadData(),
                      child: Text("Tap to retry",
                          style: TextStyle(
                              fontSize: 14,
                              color: color.state == 'dark'
                                  ? colorPrimary
                                  : Colors.black,
                              fontWeight: FontWeight.w800)),
                    )
                  : SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}
