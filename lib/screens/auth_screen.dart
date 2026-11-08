import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// login and sign up screen so the cart follows you to any device
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>(); // lets us validate and save the form
  var _isLogin = true; // true for log in, false for sign up
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isAuthenticating = false; // shows the spinner while true

  // checks the form and logs in or signs up with firebase
  void _submit() async {
    // stops if the email or password isn't valid
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save(); // stores the typed values in our variables

    // turns on the spinner and locks the buttons
    setState(() {
      _isAuthenticating = true;
    });

    try {
      // logs into an existing account
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        // makes a brand new account
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      }
    } on FirebaseAuthException catch (error) {
      // stops if the screen was closed while waiting
      if (!mounted) {
        return;
      }
      // shows what went wrong at the bottom of the screen
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
      // turns the spinner off so they can try again
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  // builds the login screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20), // space around the card
          // card that holds the login form
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              // the form with email and password
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // keeps the card only as tall as it needs
                  children: [
                    // title that changes between log in and sign up
                    Text(
                      _isLogin ? 'Welcome back' : 'Create an account',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    // email input
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Email'),
                      ),
                      keyboardType: TextInputType.emailAddress, // opens the email keyboard
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      // makes sure it looks like an email
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null; // email is good
                      },
                      // saves the email when the form saves
                      onSaved: (value) {
                        _enteredEmail = value!.trim();
                      },
                    ),
                    // password input
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Password'),
                      ),
                      obscureText: true, // hides the password as you type
                      // firebase needs at least 6 characters
                      validator: (value) {
                        if (value == null || value.trim().length < 6) {
                          return 'Password must be at least 6 characters.';
                        }
                        return null; // password is good
                      },
                      // saves the password when the form saves
                      onSaved: (value) {
                        _enteredPassword = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    // spinner while logging in, otherwise the buttons
                    if (_isAuthenticating)
                      const CircularProgressIndicator(),
                    // log in or sign up button
                    if (!_isAuthenticating)
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(_isLogin ? 'Log In' : 'Sign Up'),
                      ),
                    // switches between log in and sign up
                    if (!_isAuthenticating)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(_isLogin
                            ? 'Create an account'
                            : 'I already have an account'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
