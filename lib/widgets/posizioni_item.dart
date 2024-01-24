import 'package:flutter/material.dart';

import '../label.dart';

import '../models/box.dart';

import '../screens/posizione_detail_screen.dart';

class PosizioneItem extends StatefulWidget {
  final Box? posizione;

  PosizioneItem({
    this.posizione,
    Key? key,
  }) : super(key: key);

  @override
  State<PosizioneItem> createState() => _PosizioneItemState();
}

class _PosizioneItemState extends State<PosizioneItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(PosizioneDetailScreen.routeName, arguments: {
          'box': widget.posizione,
        });
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            leading: Icon(
              widget.posizione!.tag != null
                  ? Icons.my_location_sharp
                  : Icons.location_searching,
              color: Theme.of(context).colorScheme.primary,
              size: 40,
            ),
            title: Text(
              widget.posizione!.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${labels.codice_duepunti} ${widget.posizione!.code}'),
                Text(
                    '${labels.stato_duepunti} ${widget.posizione!.statusCode}'),
                Text(
                    '${labels.tagId_duepunti} ${widget.posizione!.tag != null ? widget.posizione!.tag!.nfcId ?? 'Nessuno' : 'Nessuno'}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
