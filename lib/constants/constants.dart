import 'package:flutter/material.dart';
import 'package:rent_app/utils/size_config.dart';

var basePadding = EdgeInsets.symmetric(
  vertical: SizeConfig.height,
  horizontal: SizeConfig.width * 4,
);

class ImageConstants {
  static const _basePath = "assets/images";
  static const logo = "$_basePath/logo.png";
}

class UserConstants {
  static const userCollection = "user";
  static const userId = "uuid";
}

class UtilitiesPriceConstant {
  static const utilityPriceCollection = "utilities-price";
  static const userId = "uuid";
}

class RoomConstant {
  static const roomCollection = "room";
  static const userId = "uuid";
}
