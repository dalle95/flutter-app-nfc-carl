import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../label.dart';

import '../providers/timbrature.dart';

import '../widgets/timbrature_list.dart';
import '../widgets/loading_indicator.dart';

class TimbraturaListScreen extends StatelessWidget {
  static const routeName = '/timbratura-list';

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshProducts(BuildContext context) async {
      await Provider.of<Timbrature>(context, listen: false)
          .fetchAndSetTimbrature();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(labels.elencoTimbrature),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: FutureBuilder(
          future: Provider.of<Timbrature>(context, listen: false)
              .fetchAndSetTimbrature(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator(labels.caricamento);
            } else {
              if (dataSnapshot.error != null) {
                return RefreshIndicator(
                  onRefresh: () => _refreshProducts(context),
                  child: Container(
                    color: Theme.of(context).colorScheme.secondary,
                    alignment: Alignment.center,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Text(labels.erroreTitolo),
                      ),
                    ),
                  ),
                );
                //Error
              } else {
                return TimbraturaList();
              }
            }
          },
        ),
      ),
    );
  }
}
