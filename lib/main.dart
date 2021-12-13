import 'dart:async';

import 'package:diy/screens/add_article.dart';
import 'package:diy/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show Onboarding;
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;

Future<void> main() async {
  await AtEnv.load();
  runApp(const MyApp());
}

Future<AtClientPreference> loadAtClientPreference() async {
  var dir = await getApplicationSupportDirectory();
  return AtClientPreference()
        ..rootDomain = AtEnv.rootDomain
        ..namespace = AtEnv.appNamespace
        ..hiveStoragePath = dir.path
        ..commitLogPath = dir.path
        ..isLocalStoreRequired = true
      // TODO set the rest of your AtClientPreference here
      ;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // * load the AtClientPreference in the background
  Future<AtClientPreference> futurePreference = loadAtClientPreference();
  AtClientPreference? atClientPreference;

  final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);
  @override
  Widget build(BuildContext context) {
    print(AtEnv.appNamespace);
    return MaterialApp(
      // * The onboarding screen (first screen)
      theme: ThemeData(
          scaffoldBackgroundColor: const Color(0x00000000),
          primaryColor: Colors.lightBlue[800]),
      routes: {'/add-guide': (context) => const AddArticle()},
      home: Scaffold(
          body: SingleChildScrollView(
        child: Builder(
          builder: (context) => Center(
              child: Column(
            children: [
              const Padding(
                  padding: EdgeInsets.fromLTRB(0, 40, 0, 25),
                  child: Text("@DIY\nJournal. Repair. Share.",
                      style: TextStyle(
                          fontSize: 26, color: Colors.white, height: 1.4),
                      textAlign: TextAlign.center)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.grey[850]),
                onPressed: () async {
                  var preference = await futurePreference;
                  setState(() {
                    atClientPreference = preference;
                  });
                  Onboarding(
                    context: context,
                    atClientPreference: atClientPreference!,
                    domain: AtEnv.rootDomain,
                    rootEnvironment: AtEnv.rootEnvironment,
                    appAPIKey: AtEnv.appApiKey,
                    onboard: (value, atsign) {
                      _logger.finer('Successfully onboarded $atsign');
                    },
                    onError: (error) {
                      _logger.severe('Onboarding throws $error error');
                    },
                    nextScreen: const HomeScreen(),
                  );
                },
                child: const Text('Onboard an @sign',
                    style: TextStyle(color: Colors.white)),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Image.network(
                      "https://cdn.wallpapersafari.com/83/71/Ht2RxY.jpg")),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                    "cs410 MVP completed by:\nWhitney Hamnett, Katherine Elia, and Daniel Goncalves",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              )
            ],
          )),
        ),
      )),
    );
  }
}
