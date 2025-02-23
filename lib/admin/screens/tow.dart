import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageTowStation extends StatefulWidget {
  @override
  _ManageTowStationState createState() => _ManageTowStationState();
}

class _ManageTowStationState extends State<ManageTowStation>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> towShops = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchtowShops(); // Fetch the tow shops when the page is loaded
  }

  Future<void> _fetchtowShops() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('tow').get();
      List<Map<String, dynamic>> towList = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      setState(() {
        towShops = towList;
      });
    } catch (e) {
      print('Error fetching tow stations: $e');
    }
  }

  // Toggle the tow shop status between approved and not approved
  Future<void> _toggleTowShopStatus(String id, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('tow').doc(id).update({
        'isApproved': !currentStatus,
      });
      setState(() {
        int index = towShops.indexWhere((shop) => shop['id'] == id);
        if (index != -1) {
          towShops[index]['isApproved'] = !currentStatus;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tow shop status updated successfully'),
          backgroundColor: Colors.greenAccent,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tow Stations'),
        backgroundColor: const Color.fromARGB(255, 131, 119, 149),
        centerTitle: true,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'List of Tow Stations',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTowShopList(context,
                        false), // Pending tow shops (non-approved; closed lock)
                    _buildTowShopList(context,
                        true), // Accepted tow shops (approved; open lock)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTowShopList(BuildContext context, bool isApproved) {
    List<Map<String, dynamic>> filteredShops =
        towShops.where((shop) => shop['isApproved'] == isApproved).toList();

    return filteredShops.isEmpty
        ? Center(child: Text('No tow shops available'))
        : ListView.builder(
            itemCount: filteredShops.length,
            itemBuilder: (context, index) {
              return _towShopCard(
                context,
                filteredShops[index],
                isApproved,
              );
            },
          );
  }

  // Tow Shop Card Widget with a toggle button in the trailing position.
  Widget _towShopCard(
      BuildContext context, Map<String, dynamic> shop, bool isApproved) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        leading: shop['companyLogo'] != null && shop['companyLogo'] != ''
            ? Image.network(
                shop['companyLogo'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : Icon(Icons.local_car_wash, color: Colors.deepPurple),
        title: Text(
          shop['companyName'],
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.deepPurpleAccent),
        ),
        subtitle: Text(
          'Email: ${shop['email']}',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display Phone Number and Company License
                Text(
                  'Phone No: ${shop['phoneNo']}',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Company License: ${shop['companyLicense']}',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Employees:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent),
                ),
                SizedBox(height: 8),
                shop['employees'] != null && shop['employees'].isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...shop['employees'].map<Widget>((employee) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title:
                                    Text(employee['employeeName'] ?? 'Unknown'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Email: ${employee['employeeEmail'] ?? 'N/A'}'),
                                    Text(
                                        'Phone: ${employee['employeePhoneNo'] ?? 'N/A'}'),
                                    Text(
                                        'Role: ${employee['employeeRole'] ?? 'N/A'}'),
                                  ],
                                ),
                                leading: Icon(Icons.person,
                                    color: Colors.deepPurple),
                              ),
                            );
                          }).toList(),
                        ],
                      )
                    : Text('No employees available'),
              ],
            ),
          )
        ],
        trailing: IconButton(
          icon: Icon(
            shop['isApproved'] ? Icons.lock_open : Icons.lock,
            color: Colors.orange,
          ),
          onPressed: () =>
              _toggleTowShopStatus(shop['id'], shop['isApproved'] ?? false),
          tooltip: shop['isApproved'] ? 'Disable Tow Shop' : 'Enable Tow Shop',
        ),
      ),
    );
  }
}
