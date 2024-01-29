import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';

class AnimatedBottomBar extends HookWidget {
  final List<BarItem> barItems;
  final Function onBarTap;
  final int tabIndex;
  const AnimatedBottomBar(this.barItems, this.tabIndex, this.onBarTap);

  @override
  Widget build(BuildContext context) {
    final selectedBarIndex = useState(0);
    final color = useProvider(colorProvider);
    bool largeScreen = MediaQuery.of(context).size.width > 800 ? true : false;
    return Material(
      elevation: 0,
      color: color.state == 'dark' ? primaryDark : Colors.white,
      child: Container(
        // margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 0),

        decoration: BoxDecoration(
          color: color.state == 'dark' ? Color(0xFF000205) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.state == 'dark'
                  ? Color(0xFF353535).withOpacity(0.17)
                  : Color(0xFFC7C7C7).withOpacity(0.17),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, -4), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: largeScreen
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceAround,
          children: _buildBarItems(selectedBarIndex, color, largeScreen),
        ),
      ),
    );
  }

  List<Widget> _buildBarItems(selectedBarIndex, color, largeScreen) {
    List<Widget> _barItems = [];
    for (int i = 0; i < barItems.length; i++) {
      BarItem item = barItems[i];
      bool isSelected = tabIndex == i;
      _barItems.add(InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          selectedBarIndex.value = i;
          onBarTap(selectedBarIndex.value);
        },
        child: Container(
          height: 65,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: largeScreen ? 30 : 0),
                  Container(
                    child: SvgPicture.asset(
                      item.icon,
                      color: isSelected
                          ? colorPrimary
                          : color.state == 'dark'
                              ? darkModeText
                              : Color(0xFF6F6F6F),
                      width: 24,
                    ),
                  ),
                  SizedBox(width: largeScreen ? 30 : 0),
                ],
              ),
              SizedBox(height: 5),
              Text(
                item.text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorPrimary
                      : color.state == 'dark'
                          ? darkModeText
                          : Color(0xFF6F6F6F),
                ),
              )
            ],
          ),
        ),
      ));
    }
    return _barItems;
  }
}

class BarItem {
  late String text, iconPath, icon;
  BarItem({required this.text, required this.icon});
}
