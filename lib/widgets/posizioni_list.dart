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
            itemBuilder: (ctx, i) => PosizioneItem(posizione: items[i]),
          );
  }
}
