import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserNotificationPage extends StatefulWidget {
  @override
  _UserNotificationPageState createState() => _UserNotificationPageState();
}

class _UserNotificationPageState extends State<UserNotificationPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  Stream<List<QueryDocumentSnapshot>> fetchNotifications() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<Map<String, dynamic>?> fetchCompanyDetails(String companyId) async {
    List<String> serviceCollections = ['fuel', 'tow', 'repair'];
    for (String collection in serviceCollections) {
      var doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(companyId)
          .get();
      if (doc.exists) {
        return doc.data();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Notifications'),
        backgroundColor: const Color.fromARGB(255, 123, 173, 168),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications found.'));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification =
                  notifications[index].data() as Map<String, dynamic>;
              String companyId = notification['companyId'] ?? '';
              String message =
                  notification['message'] ?? 'No message available';
              Timestamp? timestamp = notification['timestamp'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: fetchCompanyDetails(companyId),
                builder: (context, companySnapshot) {
                  if (companySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!companySnapshot.hasData ||
                      companySnapshot.data == null) {
                    return ListTile(
                        title: Text('Error fetching company details'));
                  }

                  var companyData = companySnapshot.data!;
                  String companyName =
                      companyData['companyName'] ?? 'Unknown Company';
                  String companyLogo = companyData['companyLogo'] ?? '';
                  String companyPhone = companyData['phoneNo'] ?? '';
                  String ownerName =
                      companyData['ownerName'] ?? 'Unknown Owner';

                  String formattedTimestamp = timestamp != null
                      ? timestamp.toDate().toLocal().toString()
                      : 'Unknown Timestamp';

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          companyLogo.isNotEmpty
                              ? Center(
                                  child: Image.network(
                                    companyLogo,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : SizedBox(height: 80),
                          SizedBox(height: 16),
                          Text(
                            companyName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(message),
                          SizedBox(height: 8),
                          Text('Timestamp: $formattedTimestamp'),
                          SizedBox(height: 8),
                          Text('Owner Name: $ownerName'),
                          SizedBox(height: 8),
                          Text('Phone: $companyPhone'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
