import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../label.dart';

import '../models/timbratura.dart';

class TimbraturaItem extends StatefulWidget {
  final Timbratura? timbratura;

  TimbraturaItem({
    this.timbratura,
    Key? key,
  }) : super(key: key);

  @override
  State<TimbraturaItem> createState() => _TimbraturaItemState();
}

class _TimbraturaItemState extends State<TimbraturaItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            leading: Icon(
              widget.timbratura!.direzione == labels.entrata
                  ? Icons.login
                  : Icons.logout,
              color: Theme.of(context).colorScheme.primary,
              size: 40,
            ),
            title: Text(
              '${labels.data_duepunti} ${DateFormat(labels.formatoData).format(widget.timbratura!.dataTimbratura)} ${labels.ora_duepunti} ${DateFormat.Hm().format(widget.timbratura!.dataTimbratura)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${labels.posizione_duepunti} ${widget.timbratura!.box!.description}'),
                Text(
                    '${labels.direzione_dueounti} ${widget.timbratura!.direzione}'),
                Text('${labels.codice_duepunti} ${widget.timbratura!.code}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
