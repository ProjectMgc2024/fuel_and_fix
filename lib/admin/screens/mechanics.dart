import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RepairPage extends StatefulWidget {
  @override
  _RepairPageState createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  List<Map<String, dynamic>> repairShops = [];

  @override
  void initState() {
    super.initState();
    _fetchRepairShops();
  }

  Future<void> _fetchRepairShops() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('repair').get();
      repairShops = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
      setState(() {});
    } catch (e) {
      print('Error fetching repair shops: $e');
    }
  }

  Future<void> _deleteRepairShop(String id) async {
    try {
      await FirebaseFirestore.instance.collection('repair').doc(id).delete();
      setState(() {
        repairShops.removeWhere((shop) => shop['id'] == id);
      });
    } catch (e) {
      print('Error deleting repair shop: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Repair stations'),
        backgroundColor: const Color.fromARGB(255, 127, 107, 159),
        centerTitle: true,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('List of Repair Shops',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 15),
              Expanded(
                child: repairShops.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: repairShops.length,
                        itemBuilder: (context, index) {
                          return _repairShopCard(
                            context,
                            repairShops[index]['companyName'] ?? 'Unknown',
                            repairShops[index]['email'] ?? 'Unknown',
                            repairShops[index]['phoneNo'] ?? 'Unknown',
                            repairShops[index]['status'] ?? false,
                            repairShops[index]['employees'] ?? [],
                            repairShops[index]['id'],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _repairShopCard(BuildContext context, String companyName, String email,
      String phoneNo, bool status, List employees, String id) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepPurple,
            backgroundImage: NetworkImage('')),
        title: Text(companyName,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurpleAccent)),
        subtitle: Text(
            'Email: $email\nPhone: $phoneNo\nStatus: ${status ? 'Active' : 'Inactive'}',
            style: TextStyle(color: Colors.black54)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.deepPurple),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditRepairShopPage(
                        repairShopId: id,
                        companyName: companyName,
                        email: email,
                        phoneNo: phoneNo,
                        status: status,
                        employees: employees,
                      ),
                    ));
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete Repair Shop'),
                      content: Text(
                          'Are you sure you want to delete this repair shop?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel')),
                        TextButton(
                            onPressed: () {
                              _deleteRepairShop(id);
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete')),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RepairShopDetailPage(
                    companyName: companyName,
                    email: email,
                    phoneNo: phoneNo,
                    status: status,
                    employees: employees),
              ));
        },
      ),
    );
  }
}

class EditRepairShopPage extends StatefulWidget {
  final String repairShopId, companyName, email, phoneNo;
  final bool status;
  final List employees;

  const EditRepairShopPage({
    required this.repairShopId,
    required this.companyName,
    required this.email,
    required this.phoneNo,
    required this.status,
    required this.employees,
  });

  @override
  _EditRepairShopPageState createState() => _EditRepairShopPageState();
}

class _EditRepairShopPageState extends State<EditRepairShopPage> {
  late TextEditingController _companyNameController,
      _emailController,
      _phoneNoController;
  bool _status = false;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: widget.companyName);
    _emailController = TextEditingController(text: widget.email);
    _phoneNoController = TextEditingController(text: widget.phoneNo);
    _status = widget.status;
  }

  Future<void> _updateRepairShop() async {
    try {
      await FirebaseFirestore.instance
          .collection('repair')
          .doc(widget.repairShopId)
          .update({
        'companyName': _companyNameController.text,
        'email': _emailController.text,
        'phoneNo': _phoneNoController.text,
        'status': _status,
      });
      Navigator.pop(context, {
        'id': widget.repairShopId,
        'companyName': _companyNameController.text,
        'email': _emailController.text,
        'phoneNo': _phoneNoController.text,
        'status': _status,
        'employees': widget.employees,
      });
    } catch (e) {
      print('Error updating repair shop: $e');
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Edit Repair Shop'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
                controller: _companyNameController,
                decoration: InputDecoration(labelText: 'Company Name')),
            SizedBox(height: 15),
            TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 15),
            TextField(
                controller: _phoneNoController,
                decoration: InputDecoration(labelText: 'Phone Number')),
            SizedBox(height: 15),
            Row(
              children: [
                Text('Status:'),
                Switch(
                    value: _status,
                    onChanged: (value) => setState(() => _status = value)),
              ],
            ),
            SizedBox(height: 15),
            ElevatedButton(
                onPressed: _updateRepairShop, child: Text('Save Changes')),
          ],
        ),
      ),
    );
  }
}

class RepairShopDetailPage extends StatelessWidget {
  final String companyName, email, phoneNo;
  final bool status;
  final List employees;

  const RepairShopDetailPage({
    required this.companyName,
    required this.email,
    required this.phoneNo,
    required this.status,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(companyName), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Repair Shop Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Phone: $phoneNo', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Status: ${status ? 'Active' : 'Inactive'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 15),
            Text('Employees:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            employees.isEmpty
                ? Text('No employees available')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return ListTile(
                        title: Text(employee['employeeName'] ?? 'Unknown'),
                        subtitle: Text(
                            'Role: ${employee['employeeRole'] ?? 'Unknown'}\nPhone: ${employee['employeePhoneNo'] ?? 'Unknown'}'),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
