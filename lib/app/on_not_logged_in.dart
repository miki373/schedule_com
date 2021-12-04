import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schedule_com/app/app.dart';
import 'package:schedule_com/app/on_logged_in.dart';
import 'package:schedule_com/app/utilities/storage.dart';

class OnNotLoggedIn extends StatefulWidget {
  // static const String routeName = 'not-logged-in';
  const OnNotLoggedIn({Key? key}) : super(key: key);

  @override
  _OnNotLoggedInState createState() => _OnNotLoggedInState();
}

class _OnNotLoggedInState extends State<OnNotLoggedIn> {
  TextEditingController userIdController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  dispose() {
    userIdController.dispose();
    pinController.dispose();
    super.dispose();
  }

  Uri _uri(String userId, String pin) => Uri.https('schedule.lehighhanson.com',
      '/MyScheduleOndemand/api/Schedule', {'pin': pin, 'userId': userId});

  Future<int> tryLogin() async {
    http.Response response =
        await http.get(_uri(userIdController.text, pinController.text));
    return response.statusCode;
  }

  void createError(int statusCode) {
    if (statusCode == 401) {
      _showError('Invalid username or password.');
    } else {
      _showError('Network error (code: $statusCode).');
    }
  }

  Future<void> storeCredentials() async {
    String userId = userIdController.text;
    String pin = pinController.text;
    await SCStorage().setLogin(userId: userId, pin: pin);
  }

  void _showError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
      children: [
        const Icon(
          Icons.warning,
          color: Colors.black,
        ),
        const SizedBox(
          width: 16.0,
        ),
        Text(errorMessage),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets.symmetric(vertical: 48.0, horizontal: 32.0),
            children: [
              const Text(
                'Please log in',
                style: TextStyle(fontSize: 24.0),
              ),
              const SizedBox(
                height: 32.0,
              ),
              TextFormField(
                controller: userIdController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Employee id can not be empty.';
                  } else if (value.contains(',') || value.contains('.')) {
                    return 'User id can not contain non numerical characters.';
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Employee Id'),
              ),
              const SizedBox(
                height: 32.0,
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pin can not be empty.';
                  } else if (value.contains(',') || value.contains('.')) {
                    return 'Pin can not contain non numerical characters.';
                  } else {
                    return null;
                  }
                },
                controller: pinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Pin'),
              ),
              const SizedBox(
                height: 32.0,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    FocusScope.of(context).unfocus();
                    int statusCode = await tryLogin();
                    if (statusCode == 200) {
                      await storeCredentials();
                      // Navigator.pushReplacementNamed(context, OnLoggedIn.routeName);
                      // Replace current page with app.dart which will fetch credential data from db
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (BuildContext context) => const App(),
                        ),
                      );
                    } else {
                      createError(statusCode);
                    }
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
