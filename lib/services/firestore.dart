import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //get collections of notes
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // add a new data
  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  //READ
  Stream<QuerySnapshot> getNotesStream() {
    final noteStream = notes.orderBy('timestamp', descending: true).snapshots();

    return noteStream;
  }

  //Update
  Future<void> updateNote(String docID, String newNote) {
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  //delte

  Future<void> deletNote(String docID) {
    return notes.doc(docID).delete();
  }
}
