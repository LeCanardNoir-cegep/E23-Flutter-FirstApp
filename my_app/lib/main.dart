//import 'dart:js';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  Map<WordPair, bool> allWords ={};

  void getNext() {
    current = WordPair.random();
    allWords[current] = favorites.contains(current);
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    allWords[current] = favorites.contains(current);
    notifyListeners();
  }

  int selectedIndex = 0;
  void selectIndex(int value){
    selectedIndex = value;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch(selectedIndex){
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritePage();
        break;
      default:
        throw UnimplementedError("no widget");
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth > 600,
                    selectedIndex: selectedIndex,
                    destinations: [
                      NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text("Home")
                      ),
                      NavigationRailDestination(
                          icon: Icon(Icons.favorite),
                          label: Text("Favorite")
                      )
                    ],
                    onDestinationSelected: (value) {
                      selectedIndex = value;
                      setState(() {});
                    },
                  )
              ),
              Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: page,
                  )
              )
            ],
          )
        );
      }
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _specialWord(pair.first, pair.second, style)
      ),
    );
  }
}

RichText _specialWord(String first, String second, TextStyle style){
  var firstWord = "${first[0].toUpperCase()}${first.substring(1)}";
  var secondWord = "${second[0].toUpperCase()}${second.substring(1)}";

  return RichText(
    text: TextSpan(
        style: style,
        children: [
          TextSpan(text: firstWord, style: TextStyle(fontWeight: FontWeight.w100)),
          TextSpan(text: secondWord, style: TextStyle(fontWeight: FontWeight.w500))
        ]
    ),
  );
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var allWords = appState.allWords.entries.toList().reversed.toList();

    var theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(color: theme.colorScheme.onPrimary,);


    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 2,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  stops: [0.1,0.5,0.9]
                ).createShader(bounds);
              },
              child: ListView.builder(
                  reverse: true,
                  primary: true,
                  itemCount: allWords.length,
                  itemBuilder: (context, index) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(allWords[index].value) Icon(Icons.favorite, color: Colors.white54,),
                      SizedBox(width: 10,),
                      _specialWord(allWords[index].key.first, allWords[index].key.second, style)
                    ],
                  )
              ),
            )
        ),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BigCard(pair: pair),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        appState.toggleFavorite();
                      },
                      icon: Icon(icon),
                      label: Text('Next')),
                  SizedBox(width: 10,),
                  ElevatedButton(
                      onPressed: () {
                        appState.getNext();
                      },
                      child: Text('Next')),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}


class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(color: theme.colorScheme.onPrimaryContainer);
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites.reversed.toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.all(20), child: Text("You have ${favorites.length} ${favorites.length > 1 ? "favorites" : "favorite"}:", style: Theme.of(context).textTheme.headlineLarge,),),
        Expanded(
          child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: favorites.length,
              itemBuilder: (context, index) => ListTile(
                title: _specialWord(favorites[index].first, favorites[index].second, style),
                leading: Icon(Icons.favorite),
                iconColor: Theme.of(context).colorScheme.primary,
                tileColor: Theme.of(context).colorScheme.primary,
              ),
          ),
        )
      ],
    );
  }
}
