import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karyawan/models/karyawan.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Karyawan',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage()
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

Future<List<Karyawan>> leadKaryawan() async {
  final String response = await rootBundle.loadString('assets/karyawan.json');
  final List<dynamic> data = jsonDecode(response);
  return data.map((json) => Karyawan.fromJson(json)).toList();
}







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Karyawan'),
      ),
 
      body: FutureBuilder<List<Karyawan>>(
        future: leadKaryawan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data karyawan'));
          } else {
            final karyawanList = snapshot.data!;
            return ListView.builder(
              itemCount: karyawanList.length,
              itemBuilder: (context, index) {
                final karyawan = karyawanList[index];
                return ListTile(
                  title: Text(karyawan.nama,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Umur: ${karyawan.umur}'),
                      Text('Alamat: ${karyawan.alamat.jalan}, ${karyawan.alamat.kota}, ${karyawan.alamat.provinsi}'),
                      Text('Hobi: ${karyawan.hobi.join(', ')}'),
                    ],
                  )
                );
              },
            );
          }
        },
      ),
    ); 
  }
}

