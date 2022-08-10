import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getResults({String? search}) async {
  const maxLimit = 100;

  var db = FirebaseFirestore.instance;

  final conscoursSnapShot =
      await db.collection('Results').limit(maxLimit).get();

  final concours = <Map<String, dynamic>>[];

  for (var doc in conscoursSnapShot.docs) {
    concours.add({'id': doc.id, ...doc.data()});
  }

  return concours;
}
