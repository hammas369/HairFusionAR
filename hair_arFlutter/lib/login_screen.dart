import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hair_ar/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier userCredential = ValueNotifier('');
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign In"),
          backgroundColor: const Color.fromRGBO(236, 207, 251, 1),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: ValueListenableBuilder(
              valueListenable: userCredential,
              builder: (context, value, child) {
                if ((userCredential.value == '' ||
                    userCredential.value == null)) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 200,
                          width: 200,
                          child: Image.asset("assets/logo.png"),
                        ),
                        Center(
                          child: SizedBox(
                            height: 50,
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: SignInButton(
                                Buttons.Google,
                                onPressed: () async {
                                  userCredential.value =
                                      await signInWithGoogle();
                                  if (userCredential.value != null) {
                                    print(userCredential.value.user!.email);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60)
                      ],
                    ),
                  );
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => MyHomePage(
                                title: userCredential.value.user!.displayName
                                    .toString(),
                                image: userCredential.value.user!.photoURL
                                    .toString(),
                              )),
                    );
                  });
                  return Container();
                }
              }),
        ));
  }

  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      print('exception->$e');
    }
  }
}
