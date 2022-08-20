import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DocumentSnapshot>> fetchData(
    {required String collection,
    DocumentSnapshot? lastDoc,
    String? orderBy}) async {
  await InternetAddress.lookup('google.com');

  final db = FirebaseFirestore.instance;
  const maxLimit = 100;

  final QuerySnapshot<Map<String, dynamic>> querySnapShoot;

  if (lastDoc == null) {
    querySnapShoot = await db
        .collection(collection)
        .orderBy(orderBy ?? 'publisedDate', descending: true)
        .limit(maxLimit)
        .get();
  } else {
    querySnapShoot = await db
        .collection(collection)
        .orderBy(orderBy ?? 'publisedDate', descending: true)
        .startAfterDocument(lastDoc)
        .limit(maxLimit)
        .get();
  }
  return querySnapShoot.docs;
}
