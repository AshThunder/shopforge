import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';

class NetworkError extends HookWidget {
  final Function loadData;
  final String message;
  final bool isSmall;

  const NetworkError(
      {required this.loadData, required this.message, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(iconsPath + 'cloud_state.svg',
              height: isSmall ? 80 : 120),
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
                width: 5,
              ),
              InkWell(
                onTap: () => loadData(),
                child: Text("Tap to retry",
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            color.state == 'dark' ? colorPrimary : Colors.black,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
