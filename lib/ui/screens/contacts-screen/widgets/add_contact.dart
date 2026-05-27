// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:felix_wallet_crypto/constant.dart';
import 'package:felix_wallet_crypto/core/providers/contact_provider/contact_provider.dart';
import 'package:felix_wallet_crypto/core/providers/wallet_provider/wallet_provider.dart';
import 'package:felix_wallet_crypto/l10n/transalation.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_button.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_text.dart';
import 'package:felix_wallet_crypto/ui/utils/App_Colors.dart';
import 'package:felix_wallet_crypto/ui/utils/spaces.dart';
import '../../../shared/wallet_text_field.dart';

class AddContact extends StatefulWidget {
  String mode = "CREATE";
  String? address;
  String? name;
  String? id;

  AddContact({Key? key, this.id, this.address, this.name, this.mode = "CREATE"})
    : super(key: key);

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final TextEditingController name = TextEditingController(text: "");

  final TextEditingController address = TextEditingController(text: "");

  final GlobalKey<FormState> _formkey = GlobalKey();

  @override
  void initState() {
    if (widget.address != null) {
      address.text = widget.address!;
    }
    if (widget.name != null) {
      name.text = widget.name!;
    }
    if (widget.id != null) {
      name.text = widget.name!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: _formkey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WalletText(
              localizeKey: widget.mode == "CREATE"
                  ? 'addContact'
                  : 'updateContact',
              size: 22,
            ),
            addHeight(SpacingSize.xs),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.liteGrey.withOpacity(0.5),
                border: Border.all(color: AppColors.liteGrey0.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  WalletTextField(
                    labelLocalizeKey: "name",
                    hint: name.text.isEmpty
                        ? getText(context, key: 'name')
                        : name.text,
                    textFieldType: TextFieldType.input,
                    validator: ((value) {
                      if (value!.isEmpty) {
                        return getText(context, key: 'notEmpty');
                      }
                      return null;
                    }),
                    textEditingController: name,
                  ),
                  addHeight(SpacingSize.xs),
                  WalletTextField(
                    validator: ((value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return "publicAddressNotEmpty";
                      }
                      if (value.length != 42) {
                        return "invalidAddress";
                      }
                      return null;
                    }),
                    hint: address.text.isEmpty
                        ? getText(context, key: 'publicAddress')
                        : address.text,
                    textFieldType: TextFieldType.input,
                    textEditingController: address,
                    labelLocalizeKey: "publicAddress",
                  ),
                ],
              ),
            ),
            addHeight(SpacingSize.s),
            WalletButton(
              localizeKey: widget.mode == "CREATE" ? "add" : "update",
              onPressed: () {
                bool isValid = _formkey.currentState?.validate() ?? false;
                if (isValid && widget.mode == "CREATE") {
                  getContactProvider(context).addContacts(
                    name: name.text,
                    address: address.text,
                    network: getWalletProvider(
                      context,
                    ).activeNetwork.networkName,
                    alreadyExist: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: WalletText(localizeKey: 'contactExist'),
                          backgroundColor: kPrimaryColor,
                        ),
                      );
                    },
                  );
                }
                if (isValid && widget.mode == "UPDATE") {
                  if (isValid) {
                    getContactProvider(context).updateContact(
                      id: widget.id ?? "",
                      name: name.text,
                      address: address.text,
                    );
                  }
                }
                Get.back();
              },
              type: WalletButtonType.gradient,
            ),
          ],
        ),
      ),
    );
  }
}
