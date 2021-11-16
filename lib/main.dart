import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/random_word_list.dart';
import 'package:hello_me/saved_suggestions_page.dart';
import 'package:hello_me/snapping_sheet.dart';
import 'package:hello_me/user_aut_repository.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'user_metadata_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                snapshot.error.toString(),
                textDirection: TextDirection.ltr,
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider<AuthRepository>(
            create: (_) => AuthRepository.instance(),
            child: const MyApp(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<AuthRepository, UserMetaDataRepository>(
      create: (_) => UserMetaDataRepository(),
      update: (_, myModel, myNotifier) => myNotifier!..update(myModel),
      child: MaterialApp(
        title: 'Startup Name Generator',
        home: const HomePage(),
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateToSavedSuggestionPage() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) {
        return const SavedSuggestionsPage();
      },
    ));
  }

  void _navigateToLoginPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return const LoginPage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final savedSuggestionsInstance = context.watch<UserMetaDataRepository>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: _navigateToSavedSuggestionPage,
            tooltip: 'Saved Suggestions',
          ),
          IconButton(
            icon: authRepo.isAuthenticated
                ? const Icon(Icons.exit_to_app)
                : const Icon(Icons.login),
            onPressed: () async {
              if (authRepo.isAuthenticated) {
                authRepo.signOut();
                savedSuggestionsInstance.clearSuggestions();

                const snackBar = SnackBar(
                  content: Text('Successfully logged out'),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                _navigateToLoginPage();
              }
            },
            tooltip: 'Saved Suggestions',
          ),
        ],
      ),
      body: Stack(
        children: authRepo.isAuthenticated
            ? const [
                RandomWordsListWidget(),
                HomePageSnappingSheet(),
              ]
            : const [
                RandomWordsListWidget(),
              ],
      ),
    );
  }
}


