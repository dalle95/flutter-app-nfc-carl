import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/label.dart';

import '/providers/boxes.dart';

import '../widgets/posizioni_list.dart';
import '/widgets/loading_indicator.dart';

class PosizioneListScreen extends StatelessWidget {
  static const routeName = '/posizioni-list';

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshBoxes(BuildContext context) async {
      await Provider.of<Boxes>(context, listen: false).fetchAndSetBoxes();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(labels.elencoPosizioni),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshBoxes(context),
        child: FutureBuilder(
          future: _refreshBoxes(context),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator(labels.caricamento);
            } else {
              if (dataSnapshot.error != null) {
                return RefreshIndicator(
                  onRefresh: () => _refreshBoxes(context),
                  child: Center(
                    child: Text(labels.erroreTitolo),
                  ),
                );
                //Error
              } else {
                return RefreshIndicator(
                  onRefresh: () => _refreshBoxes(context),
                  child: PosizioneList(),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
