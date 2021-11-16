import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/user_aut_repository.dart';
import 'package:provider/provider.dart';
import 'user_metadata_repository.dart';


class RandomWordsListWidget extends StatefulWidget {
  const RandomWordsListWidget({Key? key}) : super(key: key);

  @override
  _RandomWordsListWidgetState createState() => _RandomWordsListWidgetState();
}

class _RandomWordsListWidgetState extends State<RandomWordsListWidget> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(
              generateWordPairs().take(10),
            );
          }
          final pair = _suggestions[index];

          return ListTile(
            title: Text(
              pair.asPascalCase,
              style: _biggerFont,
            ),
            trailing: Icon(
              context.watch<UserMetaDataRepository>().isAlreadySaved(pair)
                  ? Icons.star
                  : Icons.star_border,
              color:
              context.watch<UserMetaDataRepository>().isAlreadySaved(pair)
                  ? Colors.deepPurple
                  : null,
              semanticLabel:
              context.read<UserMetaDataRepository>().isAlreadySaved(pair)
                  ? 'Remove from saved'
                  : 'Save',
            ),
            onTap: () async {
              if (context.read<UserMetaDataRepository>().isAlreadySaved(pair)) {
                context
                    .read<UserMetaDataRepository>()
                    .removeSuggestion(authRepo.user, pair);
              } else {
                context
                    .read<UserMetaDataRepository>()
                    .addSuggestion(authRepo.user, pair);
              }
            },
          );
        });
  }
}
