import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GeneralBottomSheet {
  customBottomSheet(BuildContext context) async {
    final nameController = TextEditingController();
    return await showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 10,
            right: 20,
            left: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Enter room name",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(nameController.text);
                },
                child: const Text("Add"),
              ),
            ],
          ),
        );
      },
    );
  }
}
