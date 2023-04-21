import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../widgets/bt_flat_button.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile(
    Function()? tapHandler,
    IconData icon,
    String text,
    Color iconColor,
    Color textColor,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        size: 25,
        color: iconColor,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dialogo Logout
    void _logout() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Disconnettersi dall\'applicazione?'),
          actions: [
            FlatButton(
              () {
                Navigator.of(ctx).pop();
                Provider.of<Auth>(context, listen: false).logoout();
              },
              const Text('Conferma'),
              Theme.of(ctx).colorScheme.background,
            ),
            FlatButton(
              () {
                Navigator.of(ctx).pop();
              },
              const Text('Annulla'),
              Theme.of(ctx).colorScheme.background,
            ),
          ],
        ),
      );
    }

    final actorName = Provider.of<Auth>(context, listen: false).user!.nome;

    // Drawer
    return Drawer(
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            height: 120,
            child: Text(
              'Timbratore',
              style: TextStyle(
                color: Theme.of(context).backgroundColor,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          buildListTile(
            () {},
            Icons.account_circle_rounded,
            'Utente: $actorName',
            Theme.of(context).colorScheme.secondary,
            Colors.black,
          ),
          const SizedBox(
            height: 10,
          ),
          buildListTile(
            () {},
            Icons.info,
            'Informazioni App',
            Theme.of(context).colorScheme.secondary,
            Colors.black,
          ),
          const SizedBox(
            height: 10,
          ),
          buildListTile(
            _logout,
            Icons.logout,
            'Logout',
            Theme.of(context).colorScheme.secondary,
            Colors.black,
          )
        ],
      ),
    );
  }
}
