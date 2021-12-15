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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.lightBlue[800]),
      home: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                  "https://cdn.wallpapersafari.com/83/71/Ht2RxY.jpg"),
            ),
          ),
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
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                        "CS410 MVP completed by:\nWhitney Hamnett, Katherine Elia, and Daniel Goncalves",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
