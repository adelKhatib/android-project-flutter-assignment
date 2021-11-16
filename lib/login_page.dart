import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/user_aut_repository.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final isAuthenticating = authRepo.status == Status.authenticating;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                  'Welcome to Startup Names Generator, please log in below'),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  labelText: 'Password',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: isAuthenticating
                  ? const Padding(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                child: Center(
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                    backgroundColor: Colors.white,
                    minHeight: 7,
                  ),
                ),
              )
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
                onPressed: () async {
                  final done = await authRepo.signIn(
                      emailController.text, passwordController.text);
                  if (done) {
                    Navigator.of(context).pop();
                  } else {
                    const snackBar = SnackBar(
                      content:
                      Text('There was an error logging into the app'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: const Text('Log in'),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // primary: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
                onPressed: () async {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: Container(
                          height: 300,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Center(
                                child: Container(
                                  padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                  child: const Text(
                                      'Please confirm your password below:',
                                      style: TextStyle(fontSize: 18)),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: Divider(
                                  color: Colors.grey,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Form(
                                  key: _form,
                                  child: TextFormField(
                                    controller: passwordConfirmationController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                      hintText: 'Password',
                                    ),
                                    validator: (String? value) {
                                      return (value != null &&
                                          value != passwordController.text)
                                          ? 'Passwords must match'
                                          : null;
                                    },
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                child: const Text('Confirm'),
                                onPressed: () async {
                                  if (_form.currentState!.validate()) {
                                    await authRepo.signUp(emailController.text,
                                        passwordController.text);
                                    await _firestore
                                        .collection('users')
                                        .doc(authRepo.user!.uid)
                                        .set({
                                      'savedWordPairs': [],
                                      'avatar': ''
                                    });
                                    if (authRepo.isAuthenticated) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    } else {
                                      const snackBar = SnackBar(
                                        content: Text(
                                            'There was an error logging into the app'),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text('New user? Click to sign up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
