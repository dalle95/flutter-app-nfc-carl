import 'package:app_carl_timbratura_nfc/url_ambiente.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../label.dart';

import '../error_handling/http_exception.dart';
import '../providers/auth.dart';

import '../widgets/loading_indicator.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

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
                    child: const AuthCard(),
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

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final Map<String, String> _authData = {
    'username': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  // Dialogo messaggio di errore
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(labels.erroreTitolo),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(labels.conferma),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.background,
            ),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      // Log user in
      await Provider.of<Auth>(context, listen: false).login(
        ambiente.url,
        _authData['username']!,
        _authData['password']!,
      );
    } on HttpException catch (error) {
      // Errore durante il log in
      _showErrorDialog(error.toString());
    } catch (error) {
      var errorMessage = labels.erroreAutenticazione;
      throw errorMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 8.0,
      child: Container(
        height: 300,
        constraints: const BoxConstraints(minHeight: 230),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text(
                    labels.titoloApp,
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: labels.login,
                        contentPadding: EdgeInsets.zero),
                    keyboardType: TextInputType.name,
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return labels.erroreNomeNullo;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['username'] = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: labels.password,
                    ),
                    obscureText: true,
                    textAlign: TextAlign.center,
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return labels.errorePasswordNulla;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value!;
                    },
                    onFieldSubmitted: (_) {
                      _submit();
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (_isLoading)
                    LoadingIndicator(labels.caricamento)
                  else
                    SizedBox(
                      height: deviceSize.height * 0.07,
                      width: deviceSize.width * 0.4,
                      child: ElevatedButton(
                        child: Text(
                          labels.connessione,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          //minimumSize: sizeButton,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
