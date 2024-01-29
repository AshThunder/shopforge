import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shopforge/pages/components/form/dropdown_with_label_modal.dart';
import 'package:shopforge/pages/components/form/text_input_with_label.dart';
import 'package:shopforge/utils/data/countries.dart';

class ShippingFields extends StatelessWidget {
  const ShippingFields({
    Key? key,
    required this.sfname,
    required this.checkError,
    required this.slname,
    required this.saddress1,
    required this.scity,
    required this.sstate,
    required this.spostalcode,
    required this.scountry,
  }) : super(key: key);

  final TextEditingController sfname;
  final ValueNotifier<bool> checkError;
  final TextEditingController slname;
  final TextEditingController saddress1;
  final TextEditingController scity;
  final TextEditingController sstate;
  final TextEditingController spostalcode;
  final TextEditingController scountry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: ColumnSuper(
        innerDistance: 20,
        children: [
          TextInputWithLabel(
            controller: sfname,
            placeholder: "First Name",
            hasError:
                checkError.value && sfname.text.length == 0 ? true : false,
          ),
          TextInputWithLabel(
            controller: slname,
            placeholder: "Last Name",
            hasError:
                checkError.value && slname.text.length == 0 ? true : false,
          ),
          TextInputWithLabel(
            controller: saddress1,
            placeholder: "Address 1",
            hasError:
                checkError.value && saddress1.text.length == 0 ? true : false,
          ),
          TextInputWithLabel(
            controller: scity,
            placeholder: "City",
            hasError: checkError.value && scity.text.length == 0 ? true : false,
          ),
          TextInputWithLabel(
            controller: sstate,
            placeholder: "State",
            hasError:
                checkError.value && sstate.text.length == 0 ? true : false,
          ),
          TextInputWithLabel(
            controller: spostalcode,
            placeholder: "Postcode/ZIP (optional)",
          ),
          DropDownWithLabelModal(
              items: COUNTRIES,
              currentValue: scountry.text,
              controller: (value) => {scountry.text = value},
              placeholder: "Country"),
        ],
      ),
    );
  }
}
