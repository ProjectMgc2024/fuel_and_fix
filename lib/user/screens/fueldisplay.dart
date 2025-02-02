/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuel_and_fix/user/screens/fuellist.dart';

class FuelDisplay extends StatefulWidget {
 

  @override
  _FuelDisplayState createState() => _FuelDisplayState();
}

class _FuelDisplayState extends State<FuelDisplay> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final  user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel Stations'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('fuel').where('isApproved', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error loading data'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var fuelStations = snapshot.data!.docs;
          if (fuelStations.isEmpty) {
            return Center(child: Text('No approved fuel stations found'));
          }

          return ListView.builder(
            itemCount: fuelStations.length,
            itemBuilder: (context, index) {
              var fuelStation = fuelStations[index];
              var companyLogo = fuelStation['companyLogo'];
              var companyName = fuelStation['companyName'];
              var email = fuelStation['email'];
              var phoneNo = fuelStation['phoneNo'];

              if (companyLogo == null || companyName == null || email == null || phoneNo == null) {
                print('Missing fields in document: ${fuelStation.id}');
                return SizedBox.shrink();  // Skip document if fields are missing
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    
                    MaterialPageRoute(builder: (context) => FuelList(userId: user,)), // Pass the user ID to FuelList
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          companyLogo,
                          width: 50,  // Adjust the size of the logo
                          height: 50,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                companyName,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              SizedBox(height: 5),
                              Text('Email: $email'),
                              SizedBox(height: 5),
                              Text('Phone: $phoneNo'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/