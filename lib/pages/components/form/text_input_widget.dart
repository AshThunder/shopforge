import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';

class TextInputWidget extends HookWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool isPassword;
  final int position;
  TextInputWidget({
    Key? key,
    required this.controller,
    required this.placeholder,
    this.isPassword = false,
    this.position = 1,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final _focusNode = useFocusNode();
    final focused = useState(false);
    useEffect(() {
      _focusNode.addListener(() {
        focused.value = _focusNode.hasFocus ? true : false;
      });
    }, const []);
    return Container(
        padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
        margin: EdgeInsets.only(
            bottom: focused.value
                ? position == 0 || position == 1
                    ? 1
                    : 0
                : 0),
        decoration: BoxDecoration(
          color: focused.value
              ? color.state == 'dark'
                  ? primaryText.withOpacity(0.5)
                  : Color(0xFFEFEFE1)
              : color.state == 'dark'
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white,
          border: Border.all(
            color: focused.value
                ? Color(0xFF0C979F).withOpacity(0.8)
                : color.state == 'dark'
                    ? Color(0xFF4B464B)
                    : Color(0xFF0C979F).withOpacity(0.1),
            width: 1,
          ),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(position == 0 ? 4 : 0),
              topLeft: Radius.circular(position == 0 ? 4 : 0),
              bottomRight: Radius.circular(position == 2 ? 4 : 0),
              bottomLeft: Radius.circular(position == 2 ? 4 : 0)),
        ),
        child: TextField(
            focusNode: _focusNode,
            obscureText: isPassword,
            style: TextStyle(
                fontSize: 14,
                color:
                    color.state == 'dark' ? Colors.white : Color(0xFF262626)),
            decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                hintText: placeholder),
            controller: controller));
  }
}
