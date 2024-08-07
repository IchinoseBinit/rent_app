import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:rent_app/constants/constants.dart';
import 'package:rent_app/models/firebase_user.dart';
import 'package:rent_app/providers/user_provider.dart';
import 'package:rent_app/screens/finger_print_auth_screen.dart';
import 'package:rent_app/screens/home_screen.dart';
import 'package:rent_app/screens/register_screen.dart';
import 'package:rent_app/utils/size_config.dart';
import 'package:rent_app/utils/validation_mixin.dart';
import 'package:rent_app/widgets/general_alert_dialog.dart';
import 'package:rent_app/widgets/general_text_field.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen(this.canCheckBioMetric, {Key? key}) : super(key: key);

  final bool canCheckBioMetric;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: basePadding,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Image.asset(
                  ImageConstants.logo,
                  width: SizeConfig.width * 40,
                  height: SizeConfig.height * 25,
                ),
                SizedBox(
                  height: SizeConfig.height,
                ),
                GeneralTextField(
                  title: "Email",
                  controller: emailController,
                  textInputType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validate: (value) => ValidationMixin().validateEmail(value!),
                  onFieldSubmitted: (_) {},
                ),
                SizedBox(
                  height: SizeConfig.height * 2,
                ),
                GeneralTextField(
                  title: "Password",
                  isObscure: true,
                  controller: passwordController,
                  textInputType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  validate: (value) =>
                      ValidationMixin().validatePassword(value!),
                  onFieldSubmitted: (_) {
                    _submit(context, false);
                  },
                ),
                SizedBox(height: SizeConfig.height * 2),
                ElevatedButton(
                  onPressed: () {
                    _submit(context, false);
                  },
                  child: const Text("Login"),
                ),
                SizedBox(height: SizeConfig.height * 2),
                canCheckBioMetric
                    ? ElevatedButton.icon(
                        icon: const Icon(
                          Icons.fingerprint_outlined,
                        ),
                        label: const Text("Login via Fingerprint"),
                        onPressed: () {
                          // _submit(context);
                          loginViaFingerprint(context);
                        },
                        // child: const Text("Login"),
                      )
                    : const SizedBox.shrink(),
                const Text("OR"),
                SizedBox(height: SizeConfig.height),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text("Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context, bool isAuthenticated) async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }
      final firebaseAuth = FirebaseAuth.instance;
      GeneralAlertDialog().customLoadingDialog(context);
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      final user = userCredential.user;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final data = await firestore
            .collection(UserConstants.userCollection)
            .where(UserConstants.userId, isEqualTo: user.uid)
            .get();
        var map = {};
        if (data.docs.isEmpty) {
          map = FirebaseUser(
            displayName: user.displayName,
            email: user.email,
            photoUrl: user.photoURL,
            uuid: user.uid,
          ).toJson();
        } else {
          map = data.docs.first.data();
        }
        Provider.of<UserProvider>(context, listen: false).setUser(map);
      }
      Navigator.pop(context);
      if (isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FingerPrintAuthScreen(
              username: emailController.text,
              password: passwordController.text,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      var message = "";
      if (ex.code == "wrong-password") {
        message = "The password is incorrect";
      } else if (ex.code == "user-not-found") {
        message = "The user is not registered";
      }
      await GeneralAlertDialog().customAlertDialog(context, message);
    } catch (ex) {
      Navigator.pop(context);
      await GeneralAlertDialog().customAlertDialog(context, ex.toString());
    }
  }

  void loginViaFingerprint(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final authenticated = await localAuth.authenticate(
        localizedReason: "Place your fingerprint to login",
        options: AuthenticationOptions(
          biometricOnly: true,
        ));
    if (authenticated) {
      const secureStorage = FlutterSecureStorage();
      final email =
          await secureStorage.read(key: SecureStorageConstants.emailKey);
      final password =
          await secureStorage.read(key: SecureStorageConstants.passwordKey);
      if (email != null) {
        emailController.text = email;
        passwordController.text = password!;
        _submit(context, true);
      }
    }
  }
}
