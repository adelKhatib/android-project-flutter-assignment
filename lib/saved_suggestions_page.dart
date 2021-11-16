import 'package:flutter/material.dart';
import 'package:hello_me/user_aut_repository.dart';
import 'package:provider/provider.dart';
import 'user_metadata_repository.dart';

class SavedSuggestionsPage extends StatefulWidget {
  const SavedSuggestionsPage({Key? key}) : super(key: key);

  @override
  _SavedSuggestionsPageState createState() => _SavedSuggestionsPageState();
}

class _SavedSuggestionsPageState extends State<SavedSuggestionsPage> {
  List<Widget> getDividedTiles() {
    final authRepo = context.read<AuthRepository>();
    final _saved = context.read<UserMetaDataRepository>().saved;
    final tiles = _saved.map(
      (pair) {
        return Dismissible(
          key: UniqueKey(),
          background: Container(
            color: Colors.deepPurple,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: const [
                  Icon(Icons.delete, color: Colors.white),
                  Text('Delete Suggestion',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          onDismissed: (_) async {
            context
                .read<UserMetaDataRepository>()
                .removeSuggestion(authRepo.user, pair);
          },
          confirmDismiss: (DismissDirection direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Delete Suggestion"),
                  content: Text('Are you sure you want to delete ' +
                      pair.asPascalCase +
                      ' from your saved suggestions?'),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepPurple,
                      ),
                      child: const Text('Yes'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepPurple,
                      ),
                      child: const Text('No'),
                    ),
                  ],
                );
              },
            );
          },
          child: ListTile(
            title: Text(
              pair.asPascalCase,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        );
      },
    );
    return tiles.isNotEmpty
        ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
        : <Widget>[];
  }

  @override
  Widget build(BuildContext context) {
    final divided = getDividedTiles();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Suggestions'),
      ),
      body: ListView(children: divided),
    );
  }
}
