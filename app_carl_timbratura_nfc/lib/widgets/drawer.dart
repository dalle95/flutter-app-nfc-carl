import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../label.dart';

import '../providers/auth.dart';

import '../screens/timbrature_list_screen.dart';

class MainDrawer extends StatefulWidget {
  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  // Definizione variabile per estrarre informazioni app
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  // Funzione per estrarre le informazioni app
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget buildListTile(Function()? tapHandler, IconData icon, String text,
      Color iconColor, Color textColor,
      [String subTitle = '']) {
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
      subtitle: Text(subTitle),
    );
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
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
            alignment: Alignment.centerLeft,
            color: Theme.of(context).appBarTheme.backgroundColor,
            padding: const EdgeInsets.only(top: 40, left: 20),
            width: double.infinity,
            height: 130,
            child: SizedBox(
              width: 150,
              height: 70,
              child: FittedBox(
                fit: BoxFit.cover,
                child:
                    Image.asset('assets/images/Logo_Injenia_Maggioli_IT.png'),
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
            Theme.of(context).colorScheme.primary,
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
            Theme.of(context).colorScheme.primary,
            Colors.black,
          ),
          const SizedBox(
            height: 10,
          ),
          buildListTile(
            _logout,
            Icons.logout,
            labels.logout,
            Theme.of(context).colorScheme.primary,
            Colors.black,
          ),
          Expanded(child: SizedBox()),
          buildListTile(
            () {},
            Icons.info,
            labels.infoApp,
            Theme.of(context).colorScheme.primary,
            Colors.black,
            'Versione ${_packageInfo.version}',
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
