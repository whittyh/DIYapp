import 'package:diy/main.dart';
import 'package:diy/screens/add_article.dart';
import 'package:diy/screens/home_screen.dart';
import 'package:diy/screens/search_page.dart';
import 'package:flutter/material.dart';

/*
  The class for the drawer. We need to add drawer: AppDrawer(),
  to the scaffold of every page in the app so the user is always
  able to navigate around.
*/
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _createHeader(),
          // Navigates user to the HomeScreen
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Homepage'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          // Navigates user to the SearchScreen
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search DIY Journals'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          // Navigates user to the AddArticle Screen
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Article'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AddArticle()),
              );
            },
          ),
          /*
           Navigates user to the Onboarding Screen. An User can have various @signs. 
           In other @platform app, user can login/logout of their @sign, but we did not implement that 
           feature onto our app.
          */
          ListTile(
              leading: const Icon(Icons.alternate_email_outlined),
              title: const Text('Onboarding'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              }),
        ],
      ),
    );
  }
}

Widget _createHeader() {
  return DrawerHeader(
    margin: EdgeInsets.zero,
    padding: EdgeInsets.zero,
    decoration: BoxDecoration(
      color: Colors.grey[850],
    ),
    child: Stack(
      children: const <Widget>[
        Positioned(
            bottom: 4.0,
            left: 16.0,
            child: Text("Repair. Journal. Share.",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.w500))),
      ],
    ),
  );
}
