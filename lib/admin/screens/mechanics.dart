import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RepairPage extends StatefulWidget {
  @override
  _RepairPageState createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String searchQuery = '';
  late Future<List<Map<String, dynamic>>> repairShops;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    repairShops = fetchRepairShops();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch repair shops from Firestore
  Future<List<Map<String, dynamic>>> fetchRepairShops() async {
    try {
      QuerySnapshot querySnapshot =
          await _firebaseFirestore.collection('repair').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'companyName': data['companyName'] ?? 'Unknown',
          'email': data['email'] ?? 'Unknown',
          'phoneNo': data['phoneNo'] ?? 'Unknown',
          'status': data['status'] ?? false,
          'isApproved': data['isApproved'] ?? false,
          'employees': List<Map<String, dynamic>>.from(data['employees'] ?? []),
          'companyLogo': data['companyLogo'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching repair shops: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Repair Stations'),
        backgroundColor: const Color.fromARGB(255, 127, 107, 159),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRepairShopsList('Pending'),
                  _buildRepairShopsList('Accepted'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search bar widget
  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Search by company name',
        prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
      ),
    );
  }

  // Build repair shops list based on approval status
  Widget _buildRepairShopsList(String status) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: repairShops,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No repair shops available'));
        }

        List<Map<String, dynamic>> filteredShops =
            _getFilteredShops(snapshot.data!, status);

        return ListView.builder(
          itemCount: filteredShops.length,
          itemBuilder: (context, index) {
            return _repairShopCard(context, filteredShops[index], status);
          },
        );
      },
    );
  }

  // Filter repair shops based on search query and approval status
  List<Map<String, dynamic>> _getFilteredShops(
      List<Map<String, dynamic>> shops, String status) {
    return shops.where((shop) {
      bool matchesQuery =
          shop['companyName'].toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesStatus = status == 'Pending'
          ? shop['isApproved'] == false
          : shop['isApproved'] == true;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  // Repair shop card widget
  Widget _repairShopCard(
      BuildContext context, Map<String, dynamic> shop, String status) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        leading: shop['companyLogo'] != null &&
                shop['companyLogo'].toString().isNotEmpty
            ? CircleAvatar(backgroundImage: NetworkImage(shop['companyLogo']))
            : Icon(Icons.business, color: Colors.deepPurple),
        title: Text(
          shop['companyName'],
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.deepPurple),
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
                Text(
                  'Phone: ${shop['phoneNo']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Status: ${shop['status'] ? 'Active' : 'Inactive'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Employees: ${shop['employees'].length}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                SizedBox(height: 8),
                ...shop['employees'].map<Widget>((employee) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(employee['employeeName'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Role: ${employee['employeeRole'] ?? 'Unknown'}'),
                          Text(
                              'Phone: ${employee['employeePhoneNo'] ?? 'Unknown'}'),
                        ],
                      ),
                      leading: Icon(Icons.person, color: Colors.deepPurple),
                    ),
                  );
                }).toList(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (status == 'Pending')
                      ElevatedButton(
                        onPressed: () => _acceptRepairShop(shop['id']),
                        child: Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (status == 'Accepted')
                      shop['status']
                          ? ElevatedButton(
                              onPressed: () => _confirmDisableRepairShop(
                                  context, shop['id']),
                              child: Text('Disable'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () =>
                                  _confirmEnableRepairShop(context, shop['id']),
                              child: Text('Enable'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Accept repair shop (set isApproved true)
  void _acceptRepairShop(String shopId) {
    _firebaseFirestore
        .collection('repair')
        .doc(shopId)
        .update({'isApproved': true}).then((_) {
      setState(() {
        repairShops = fetchRepairShops();
      });
    });
  }

  // Confirmation dialog for disabling a repair shop
  void _confirmDisableRepairShop(BuildContext context, String shopId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Disable Repair Shop'),
          content: Text('Are you sure you want to disable this repair shop?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _firebaseFirestore
                      .collection('repair')
                      .doc(shopId)
                      .update({'status': false});
                  repairShops = fetchRepairShops();
                });
                Navigator.pop(context);
              },
              child: Text('Disable'),
            ),
          ],
        );
      },
    );
  }

  // Confirmation dialog for enabling a repair shop
  void _confirmEnableRepairShop(BuildContext context, String shopId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enable Repair Shop'),
          content: Text('Are you sure you want to enable this repair shop?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _firebaseFirestore
                      .collection('repair')
                      .doc(shopId)
                      .update({'status': true});
                  repairShops = fetchRepairShops();
                });
                Navigator.pop(context);
              },
              child: Text('Enable'),
            ),
          ],
        );
      },
    );
  }
}
