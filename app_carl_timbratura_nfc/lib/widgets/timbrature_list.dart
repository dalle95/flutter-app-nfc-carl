import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../label.dart';

import '../providers/timbrature.dart';

import '../widgets/timbrature_item.dart';

class TimbraturaList extends StatelessWidget {
  TimbraturaList();

  @override
  Widget build(BuildContext context) {
    final itemData = Provider.of<Timbrature>(context);
    final items = itemData.timbrature;

    return items.isEmpty
        ? Center(
            child: Text(
              labels.nessunaTimbratura,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          )
        : ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, i) => TimbraturaItem(items[i]),
          );
  }
}
