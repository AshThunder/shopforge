import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shopforge/pages/components/form/dropdown_with_label_modal.dart';
import 'package:shopforge/pages/components/form/text_input_with_label.dart';
import 'package:shopforge/utils/data/countries.dart';

class BillingFields extends StatelessWidget {
  const BillingFields({
    Key? key,
    required this.bfname,
    required this.checkError,
    required this.blname,
    required this.baddress1,
    required this.bcity,
    required this.bstate,
    required this.bpostalcode,
    required this.bcountry,
    required this.bemail,
    required this.bphone,
  }) : super(key: key);

  final TextEditingController bfname;
  final ValueNotifier<bool> checkError;
  final TextEditingController blname;
  final TextEditingController baddress1;
  final TextEditingController bcity;
  final TextEditingController bstate;
  final TextEditingController bpostalcode;
  final TextEditingController bcountry;
  final TextEditingController bemail;
  final TextEditingController bphone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: ColumnSuper(
        innerDistance: 20,
        children: [
          TextInputWithLabel(
            controller: bfname,
            placeholder: "First Name",
            hasError:
                checkError.value && bfname.text.length == 0 ? true : false,
          ),
          TextInputWithLabel(
            controller: blname,
            placeholder: "Last Name",
            hasError:
                checkError.value && blname.text.length == 0 ? true : false,
          ),
          TextInputWithLabel(
            controller: baddress1,
            placeholder: "Address 1",
            hasError:
                checkError.value && baddress1.text.length == 0 ? true : false,
          ),
          TextInputWithLabel(
            controller: bcity,
            placeholder: "City",
            hasError: checkError.value && bcity.text.length == 0 ? true : false,
          ),
          TextInputWithLabel(
            controller: bstate,
            placeholder: "State",
            hasError:
                checkError.value && bstate.text.length == 0 ? true : false,
          ),
          TextInputWithLabel(
            controller: bpostalcode,
            placeholder: "Postcode/ZIP (optional)",
          ),
          DropDownWithLabelModal(
              items: COUNTRIES,
              currentValue: bcountry.text,
              controller: (value) => {bcountry.text = value},
              placeholder: "Country"),
          TextInputWithLabel(
            controller: bemail,
            placeholder: "Email Address",
            hasError:
                checkError.value && bemail.text.length == 0 ? true : false,
          ),
          TextInputWithLabel(
            controller: bphone,
            placeholder: "Phone number",
            hasError:
                checkError.value && bphone.text.length == 0 ? true : false,
          ),
        ],
      ),
    );
  }
}
