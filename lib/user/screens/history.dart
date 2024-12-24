import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late CollectionReference users;

  @override
  void initState() {
    super.initState();
    // Initialize the collection reference for users
    users = FirebaseFirestore.instance.collection('user');
  }

  // Function to fetch the owner's name using the service value
  Future<String> getOwnerName(String service) async {
    try {
      // Fetch the owner document from the respective service collection
      var serviceCollection = FirebaseFirestore.instance.collection(service);
      var ownerDoc = await serviceCollection.doc('owner').get();

      // Check if the document exists and return the owner's name
      if (ownerDoc.exists) {
        return ownerDoc['ownerName'] ?? 'Owner not found';
      } else {
        return 'Owner not found';
      }
    } catch (e) {
      print('Error fetching owner: $e');
      return 'Owner not found';
    }
  }

  // Function to fetch the additional details for non-fuel services
  Future<Map<String, dynamic>> getServiceDetails(String service) async {
    try {
      // Fetch the service document from the respective service collection
      var serviceDoc = await FirebaseFirestore.instance
          .collection(service)
          .doc(service)
          .get();

      // Check if the document exists and return the relevant details
      if (serviceDoc.exists) {
        return {
          'ownerId': serviceDoc['ownerId'] ?? 'N/A',
          'paymentAmount': serviceDoc['paymentAmount'] ?? 0,
          'paymentId': serviceDoc['paymentId'] ?? 'N/A',
          'time': serviceDoc['time'] ?? 'N/A',
          'description': serviceDoc['description'] ?? 'No description available'
        };
      } else {
        return {
          'ownerId': 'N/A',
          'paymentAmount': 0,
          'paymentId': 'N/A',
          'time': 'N/A',
          'description': 'No description available'
        };
      }
    } catch (e) {
      print('Error fetching service details: $e');
      return {
        'ownerId': 'N/A',
        'paymentAmount': 0,
        'paymentId': 'N/A',
        'time': 'N/A',
        'description': 'No description available'
      };
    }
  }

  // Method to get the current user ID from Firebase Authentication
  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user
        ?.uid; // Returns the user ID or null if the user is not logged in
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserId = getCurrentUserId();

    if (currentUserId == null) {
      // If the user is not logged in, return a message
      return Scaffold(
        appBar: AppBar(title: Text('Order History')),
        body: Center(child: Text('Please log in to view your orders.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Order History')),
      body: FutureBuilder<QuerySnapshot>(
        future: users.doc(currentUserId).collection('orders').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var fuelType = order['fuelType'];
              var litres = order['litres'];
              var paymentAmount = order['paymentAmount'];
              var service = order['service'];
              var time = order['time'];

              // Display the order details only if the service is "fuel"
              if (service == 'fuel') {
                return FutureBuilder<String>(
                  future:
                      getOwnerName(service), // Use service as collection name
                  builder: (context, ownerSnapshot) {
                    if (ownerSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Loading...'),
                      );
                    }

                    return ListTile(
                      title: Text('Service: $service'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fuel Type: $fuelType'),
                          Text('Litres: $litres'),
                          Text('Payment: ₹$paymentAmount'),
                          Text('Time: $time'),
                          Text('Owner: ${ownerSnapshot.data ?? 'N/A'}'),
                        ],
                      ),
                    );
                  },
                );
              } else {
                // Fetch additional service details for non-fuel orders
                return FutureBuilder<Map<String, dynamic>>(
                  future: getServiceDetails(service),
                  builder: (context, serviceSnapshot) {
                    if (serviceSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Loading service details...'),
                      );
                    }

                    var serviceDetails = serviceSnapshot.data ?? {};

                    return ListTile(
                      title: Text('Service: $service'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OwnerId: ${serviceDetails['ownerId']}'),
                          Text(
                              'Payment Amount: ₹${serviceDetails['paymentAmount']}'),
                          Text('PaymentId: ${serviceDetails['paymentId']}'),
                          Text('Service: $service'),
                          Text('Time: ${serviceDetails['time']}'),
                          Text('Description: ${serviceDetails['description']}'),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
