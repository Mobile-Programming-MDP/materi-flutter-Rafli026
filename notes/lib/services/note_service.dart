import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:NOTES/models/note.dart';
import 'package:path/path.dart' as path;

//Buat class NoteService
//Buat 3 variabel berikut.
//final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//final FirebaseStorage _storage = FirebaseStorage.instance;
//final CollectionReference _notesCollection = FirebaseFirestore.instance.collection('notes');
//Buat method untuk tambah data pakai static futeure void addNote(Note note) async {
//Buat method untuk menampilkan data
//Buat method untuk ubah data
//Buat method untuk hapus data
//Buat method untuk upload image

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _notesCollection = FirebaseFirestore.instance
      .collection('notes');

  static Future<void> addNote(Note note) async {
    Map<String, dynamic> newNote = {
      'title': note.title,
      'description': note.description,
      'imageUrl': note.imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _notesCollection.add(newNote);
  }

  static Stream<List<Note>> getNotes() {
    return _notesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Note(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  static Future<void> updateNote(Note note) async {
    Map<String, dynamic> updatedNote = {
      'title': note.title,
      'description': note.description,
      'imageUrl': note.imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _notesCollection.doc(note.id).update(updatedNote);
  }

  static Future<void> deleteNote(String id) async {
    await _notesCollection.doc(id).delete();
  }

  static Future<String> uploadImage(File imageFile) async {
    String fileName = path.basename(imageFile.path);
    Reference storageRef = _storage.ref().child('note_images/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
