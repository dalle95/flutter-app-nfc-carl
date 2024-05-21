import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../label.dart';

import '../providers/boxes.dart';

import 'posizioni_item.dart';

class PosizioneList extends StatelessWidget {
  PosizioneList();

  @override
  Widget build(BuildContext context) {
    final itemData = Provider.of<Boxes>(context);
    final items = itemData.boxes;

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
                      labels.nessunaPosizione,
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
                itemBuilder: (ctx, i) => PosizioneItem(posizione: items[i]),
              ),
            ),
    );
  }
}
