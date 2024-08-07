import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rent_app/constants/constants.dart';
import 'package:rent_app/providers/user_provider.dart';
import 'package:rent_app/utils/firebase_helper.dart';
import 'package:rent_app/utils/size_config.dart';
import 'package:rent_app/utils/validation_mixin.dart';
import 'package:rent_app/widgets/curved_body_widget.dart';
import 'package:rent_app/widgets/general_alert_dialog.dart';
import 'package:rent_app/widgets/general_text_field.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({required this.imageUrl, Key? key}) : super(key: key);

  final String imageUrl;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final ageController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final profileData = Provider.of<UserProvider>(context).user;
    nameController.text = profileData.name ?? "";
    ageController.text =
        profileData.age != null ? profileData.age.toString() : "";
    addressController.text = profileData.address ?? "";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: CurvedBodyWidget(
          widget: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Hero(
                tag: "image-url",
                child: SizedBox(
                  height: SizeConfig.height * 16,
                  width: SizeConfig.height * 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(SizeConfig.height * 8),
                    child: profileData.image == null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          )
                        : Image.memory(
                            base64Decode(profileData.image!),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.height * 2,
              ),
              Text(
                "Edit your profile",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(
                height: SizeConfig.height * 2,
              ),
              GeneralTextField(
                title: "Name",
                controller: nameController,
                textInputType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validate: (value) => ValidationMixin().validate(value!, "name"),
                onFieldSubmitted: (_) {},
              ),
              SizedBox(
                height: SizeConfig.height * 1.5,
              ),
              GeneralTextField(
                title: "Address",
                controller: addressController,
                textInputType: TextInputType.streetAddress,
                textInputAction: TextInputAction.next,
                validate: (value) =>
                    ValidationMixin().validate(value!, "address"),
                onFieldSubmitted: (_) {},
              ),
              SizedBox(
                height: SizeConfig.height * 1.5,
              ),
              GeneralTextField(
                title: "Age",
                controller: ageController,
                maxLength: 3,
                textInputType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validate: (value) => ValidationMixin().validateAge(
                  value!,
                ),
                onFieldSubmitted: (_) {},
              ),
              SizedBox(
                height: SizeConfig.height * 2,
              ),
              ElevatedButton(
                onPressed: () async {
                  await showBottomSheet(context);
                  // if (map.isNotEmpty) {}
                },
                child: const Text("Choose Image"),
              ),
              SizedBox(
                height: SizeConfig.height * 2,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final map =
                          Provider.of<UserProvider>(context, listen: false)
                              .updateUser(
                        name: nameController.text,
                        address: addressController.text,
                        age: int.parse(ageController.text),
                      );
                      await FirebaseHelper().addOrUpdateContent(
                        context,
                        collectionId: UserConstants.userCollection,
                        whereId: UserConstants.userId,
                        whereValue: profileData.uuid,
                        map: map,
                      );
                      Navigator.pop(context);
                    } catch (ex) {
                      GeneralAlertDialog()
                          .customAlertDialog(context, ex.toString());
                    }
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Future<void> showBottomSheet(BuildContext context) async {
    final imagePicker = ImagePicker();

    await showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: basePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Choose a source",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(
              height: SizeConfig.height * 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildChooseOptions(
                  context,
                  func: () async {
                    final xFile =
                        await imagePicker.pickImage(source: ImageSource.camera);
                    if (xFile != null) {
                      final unit8list = await xFile.readAsBytes();
                      Provider.of<UserProvider>(context, listen: false)
                          .updateUserImage(base64Encode(unit8list));
                    }
                  },
                  iconData: Icons.camera_outlined,
                  label: "Camera",
                ),
                buildChooseOptions(
                  context,
                  func: () {},
                  iconData: Icons.collections_outlined,
                  label: "Gallery",
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Column buildChooseOptions(
    BuildContext context, {
    required Function func,
    required IconData iconData,
    required String label,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: () {
            print("object");
            func();
          },
          color: Theme.of(context).primaryColor,
          iconSize: SizeConfig.height * 6,
          icon: Icon(iconData),
        ),
        Text(label),
      ],
    );
  }
}
