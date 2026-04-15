import 'package:flutter/material.dart';

class MainSecreen extends StatefulWidget {
  const MainSecreen({super.key});

  @override
  State<MainSecreen> createState() => _MainSecreenState();
}

class _MainSecreenState extends State<MainSecreen> {
  int _currentPage = 0;
  List<Widget> listMenu = [Text("home"), Text("about")];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cepu App')),
      body: listMenu[_currentPage],
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                setState(() {
                  _currentPage = 0;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                setState(() {
                  _currentPage = 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}
