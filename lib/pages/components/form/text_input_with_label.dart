import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/utils/Providers.dart';

class TextInputWithLabel extends HookWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool isPassword, hasError;
  TextInputWithLabel({
    Key? key,
    required this.controller,
    required this.placeholder,
    this.isPassword = false,
    this.hasError = false,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 4),
            Text(
              "$placeholder",
              style: TextStyle(
                  color:
                      color.state == 'dark' ? darkModeText : Color(0xFF545454)),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
            padding: EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: focused.value
                  ? color.state == 'dark'
                      ? primaryText.withOpacity(0.5)
                      : Color(0xFFEFEFE1)
                  : color.state == 'dark'
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white,
              border: Border.all(
                color: hasError
                    ? Colors.redAccent
                    : focused.value
                        ? Color(0xFF0C979F).withOpacity(0.8)
                        : color.state == 'dark'
                            ? Color(0xFF4B464B)
                            : Color(0xFF0C979F).withOpacity(0.1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextFormField(
                focusNode: _focusNode,
                obscureText: isPassword,
                style: TextStyle(
                    fontSize: 14,
                    color: color.state == 'dark'
                        ? Colors.white
                        : Color(0xFF262626)),
                decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    hintText: ""),
                controller: controller)),
      ],
    );
  }
}
