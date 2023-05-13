import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../label.dart';

import '../providers/auth.dart';

import '../screens/timbrature_list_screen.dart';

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
          title: Text(labels.logout),
          content: Text(labels.disconnessioneMessaggio),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Provider.of<Auth>(context, listen: false).logoout();
              },
              child: Text(labels.conferma),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.background,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(labels.annulla),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.background,
              ),
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
              labels.titoloApp,
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
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
            '${labels.utente_duepunti} $actorName',
            Theme.of(context).colorScheme.secondary,
            Colors.black,
          ),
          const SizedBox(
            height: 10,
          ),
          buildListTile(
            () {
              Navigator.of(context).pushNamed(
                TimbraturaListScreen.routeName,
              );
            },
            Icons.share_arrival_time_outlined,
            labels.elencoTimbrature,
            Theme.of(context).colorScheme.secondary,
            Colors.black,
          ),
          const SizedBox(
            height: 10,
          ),
          buildListTile(
            () {},
            Icons.info,
            labels.infoApp,
            Theme.of(context).colorScheme.secondary,
            Colors.black,
          ),
          const SizedBox(
            height: 10,
          ),
          buildListTile(
            _logout,
            Icons.logout,
            labels.logout,
            Theme.of(context).colorScheme.secondary,
            Colors.black,
          )
        ],
      ),
    );
  }
}
