import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

import '../forms/auth_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

// Per gestire i log
var logger = Logger();

bool isConfigured = false;

class _AuthScreenState extends State<AuthScreen> {
  String? username;
  var dati;

  @override
  void initState() {
    // Per settare l'username
    username = Provider.of<Auth>(
      context,
      listen: false,
    ).username;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.secondary),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: SizedBox(
                      child: AuthForm(username: username),
                      height: deviceSize.height * 0.55,
                      width: deviceSize.width * 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
