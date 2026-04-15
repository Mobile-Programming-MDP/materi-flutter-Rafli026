import 'package:cepu_app/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
      (route) => false,
    );
  }

  Future<String?> getTokenAuth() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? idToken = await user.getIdToken(true);
      return idToken;
    }

    return null;
  }

  String? _idToken = "";
  String? _uid = "";
  String? _email = "";

  Future<void> getFirebaseAuthUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _uid = user.uid;
      _email = user.email;
      await user
          .getIdToken(true)
          .then(
            (value) => {
              setState(() {
                _idToken = value;
              }),
            },
          );
    }
  }

  String generateAvatarUrl(String? fullname) {
    final formattedName = fullname!.trim().replaceAll(' ', '+');
    return 'https://ui-avatars.com/api/?name=$formattedName&color=7F9CF5&background=EBF4FF';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.logout))],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              generateAvatarUrl(
                FirebaseAuth.instance.currentUser?.displayName.toString(),
              ),
              width: 100,
              height: 100,
            ),
            Text("hellow"),
            Text("UID: $_uid"),
            Text("Email: $_email"),
            Text("Token: $_idToken"),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'tambah_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbRef = FirebaseDatabase.instance.ref("narapidana");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Data Narapidana")),
      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text("Belum ada data"));
          }

          final data = snapshot.data!.snapshot.value as Map;
          final list = data.entries.toList();

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index].value;

              return Card(
                child: ListTile(
                  title: Text(item["nama"]),
                  subtitle: Text(
                    "${item["jk"]} | Umur: ${item["umur"]}\nKasus: ${item["kasus"]}",
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TambahPage()),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TambahPage extends StatefulWidget {
  @override
  _TambahPageState createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  final nama = TextEditingController();
  final jk = TextEditingController();
  final umur = TextEditingController();
  final kasus = TextEditingController();

  final dbRef = FirebaseDatabase.instance.ref("narapidana");

  void simpanData() {
    dbRef.push().set({
      "nama": nama.text,
      "jk": jk.text,
      "umur": umur.text,
      "kasus": kasus.text,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Narapidana")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nama,
              decoration: InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: jk,
              decoration: InputDecoration(labelText: "Jenis Kelamin"),
            ),
            TextField(
              controller: umur,
              decoration: InputDecoration(labelText: "Umur"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: kasus,
              decoration: InputDecoration(labelText: "Kasus"),
            ),  
            SizedBox(height: 20),
            ElevatedButton(onPressed: simpanData, child: Text("Simpan")),
          ],
        ),
      ),
    );
  }
}
---firebase narapidana 