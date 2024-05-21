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

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: items.isEmpty
          ? Center(
              child: Container(
                color: Theme.of(context).colorScheme.secondary,
                alignment: Alignment.center,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text(
                      labels.nessunaTimbratura,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 5),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, i) => TimbraturaItem(timbratura: items[i]),
              ),
            ),
    );
  }
}
