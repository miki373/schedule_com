import 'package:flutter/material.dart';
import 'package:schedule_com/app/on_not_logged_in.dart';
import 'package:schedule_com/app/on_logged_in.dart';
import 'package:schedule_com/app/utilities/storage.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Future<LoginDetails> getLogin() async {
    SCStorage scStorage = SCStorage();
    LoginDetails loginDetails = await scStorage.getLogin();
    if (loginDetails.isLoggedIn) {
      return loginDetails;
    } else {
      throw 'Not Logged in';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getLogin(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          LoginDetails loginDetails = snapshot.data as LoginDetails;
          return OnLoggedIn(pin: loginDetails.pin, userId: loginDetails.userId,);
        } else if (snapshot.hasError) {
          return const OnNotLoggedIn();
        } else {
          return const Center(
            child: SCSpinner()
          );
        }
      },
    );
  }
}
