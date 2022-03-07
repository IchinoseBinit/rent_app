import 'package:flutter/material.dart';
import 'package:rent_app/constants/constants.dart';
import 'package:rent_app/screens/profile_screen.dart';
import 'package:rent_app/utils/navigate.dart';
import 'package:rent_app/utils/size_config.dart';
import 'package:rent_app/widgets/curved_body_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  final image =
      "https://resize.indiatvnews.com/en/resize/newbucket/1200_-/2020/07/shiva-1594171271.jpg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome Home!"),
      ),
      drawer: Drawer(
          child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Binit Koirala"),
            accountEmail: const Text(
              "binit@gmail.com",
            ),
            currentAccountPicture: Hero(
              tag: "image-url",
              child: CircleAvatar(
                backgroundImage: NetworkImage(image),
              ),
            ),
            // currentAccountPictureSize: Size.fromHeight(
            //   SizeConfig.height * 5,
            // ),
          ),
          ListTile(
            title: const Text("Profile"),
            trailing: const Icon(
              Icons.arrow_right_outlined,
            ),
            onTap: () => navigate(
              context,
              ProfileScreen(
                imageUrl: image,
              ),
            ),
          )
        ],
      )),
      body: CurvedBodyWidget(
        widget: SingleChildScrollView(
          child: Column(
            children: [
              Text("Rent App"),
            ],
          ),
        ),
      ),
    );
  }
}
