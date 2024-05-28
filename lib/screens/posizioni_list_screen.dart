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
    // Funzione per estrarre le posizioni
    Future<void> _refreshBoxes(BuildContext context) async {
      await Provider.of<Boxes>(context, listen: false).fetchAndSetBoxes();
    }

    // Funzione per filtrare le posizioni
    void _filtraBoxes(BuildContext context, bool boolean) {
      Provider.of<Boxes>(context, listen: false).filtraPosizioni(boolean);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(labels.elencoPosizioni),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          PulsanteFiltro(
            funzione: (bool boolean) {
              _filtraBoxes(context, boolean);
            },
          ),
        ],
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

class PulsanteFiltro extends StatefulWidget {
  final Function(bool) funzione;

  const PulsanteFiltro({
    Key? key,
    required this.funzione,
  }) : super(key: key);

  @override
  State<PulsanteFiltro> createState() => _PulsanteFiltroState();
}

class _PulsanteFiltroState extends State<PulsanteFiltro> {
  bool boolean = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          boolean = !boolean;
          widget.funzione(boolean);
        });
      },
      icon: Icon(
        boolean ? Icons.filter_alt_rounded : Icons.filter_alt_off,
      ),
    );
  }
}
