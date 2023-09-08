import 'package:flutter/material.dart';
import 'package:paulonia_cache_image/paulonia_cache_image.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PCacheImage.init();
  runApp(const MyApp());
}

/// {@template my_app}
/// My app
/// {@endtemplate}
class MyApp extends StatelessWidget {
  /// {@macro my_app}
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paulonia Cache Image',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Paulonia Cache Image'),
    );
  }
}

/// {@template my_home_page}
/// My home page
/// {@endtemplate}
class MyHomePage extends StatefulWidget {
  /// {@macro my_home_page}
  const MyHomePage({required this.title, super.key});

  /// The title of the page
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          setState(() {});
        },
        child: const Icon(
          Icons.refresh,
          color: Colors.black,
        ),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('In memory cached network image'),
          ),
          SizedBox(
            height: 250,
            child: Card(
              elevation: 10,
              child: Image(
                image: PCacheImage(
                  'https://i.imgur.com/jhRBVEp.jpg',
                  enableInMemory: true,
                ),
              ),
            ),
          ),
          const ListTile(
            title: Text('Storage cached network image'),
          ),
          SizedBox(
            height: 250,
            child: Card(
              elevation: 10,
              child: Image(
                image: PCacheImage(
                  'https://i.imgur.com/5RhnXjE.jpg',
                ),
              ),
            ),
          ),
          const ListTile(
            title: Text('Not cached image'),
          ),
          SizedBox(
            height: 250,
            child: Card(
              elevation: 10,
              child: Image(
                image: PCacheImage(
                  'https://i.imgur.com/inAkwKw.jpg',
                  enableCache: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
