import 'package:camerakit_flutter/camerakit_flutter.dart';
import 'package:camerakit_flutter/lens_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hair_ar/login_screen.dart';

import 'constants.dart';
import 'custum_app_bar.dart';
import 'media_result_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.image});

  final String title;
  final String image;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    implements CameraKitFlutterEvents {
  late String _filePath = '';
  late String _fileType = '';
  late List<Lens> lensList = [];
  late final _cameraKitFlutterImpl =
      CameraKitFlutterImpl(cameraKitFlutterEvents: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: widget.title,
        photoUrl: widget.image,
        onSignOut: () async {
          bool result = await signOutFromGoogle();
          if (result) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 200,
                width: 200,
                child: Image.asset("assets/logo.png"),
              ),
              ElevatedButton(
                  onPressed: () {
                    initCameraKit();
                  },
                  child: const Text("Open Hair Fusion")),
              const SizedBox(height: 60)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initCameraKit() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      await _cameraKitFlutterImpl.openCameraKit(
          groupIds: Constants.groupIdList, isHideCloseButton: false);
    } on PlatformException {
      if (kDebugMode) {
        print("Failed to open camera kit");
      }
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  void onCameraKitResult(Map result) {
    setState(() {
      _filePath = result["path"] as String;
      _fileType = result["type"] as String;

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MediaResultWidget(
                filePath: _filePath,
                fileType: _fileType,
              )));
    });
  }

  @override
  void receivedLenses(List<Lens> lensList) {
    print("hiii");
  }
}
