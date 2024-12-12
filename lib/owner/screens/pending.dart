import 'package:flutter/material.dart';

class PendingRepairTasks extends StatefulWidget {
  @override
  _PendingRepairTasksPageState createState() => _PendingRepairTasksPageState();
}

class _PendingRepairTasksPageState extends State<PendingRepairTasks> {
  // Mock data for pending repair tasks with registration number, location, requested time
  List<Map<String, String>> taskHistory = [
    {
      'priority': 'High',
      'registrationNumber': 'KL45AJ7865',
      'location': 'Kochi, Kerala',
      'requestedTime': '2024-11-01 10:30 AM', // Requested time
    },
    {
      'priority': 'Medium',
      'registrationNumber': 'KL45AJ7866',
      'location': 'Thrissur, Kerala',
      'requestedTime': '2024-11-05 11:00 AM', // Requested time
    },
    {
      'priority': 'Low',
      'registrationNumber': 'KL45AJ7867',
      'location': 'Kochi, Kerala',
      'requestedTime': '2024-11-10 02:30 PM', // Requested time
    },
    {
      'priority': 'High',
      'registrationNumber': 'KL45AJ7868',
      'location': 'Alappuzha, Kerala',
      'requestedTime': '2024-11-12 01:00 PM', // Requested time
    },
    {
      'priority': 'Medium',
      'registrationNumber': 'KL45AJ7869',
      'location': 'Kochi, Kerala',
      'requestedTime': '2024-11-15 09:30 AM', // Requested time
    },
    {
      'priority': 'Low',
      'registrationNumber': 'KL45AJ7870',
      'location': 'Kottayam, Kerala',
      'requestedTime': '2024-11-17 08:45 AM', // Requested time
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter only Pending Repair tasks
    var pendingRepairTasks = taskHistory;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Repair Tasks'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Pending Repair Tasks Section
            Text('Pending Repair Tasks:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (pendingRepairTasks.isEmpty)
              Text("No pending repair tasks at the moment.",
                  style: TextStyle(fontSize: 16, color: Colors.black45)),
            ...pendingRepairTasks.map((task) => _buildTaskCard(task)),
          ],
        ),
      ),
    );
  }

  // Task card widget
  Widget _buildTaskCard(Map<String, String> task) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Registration Number and Location
            Text('Registration Number: ${task['registrationNumber']}',
                style: TextStyle(fontSize: 14, color: Colors.blue)),
            Text('Location: ${task['location']}',
                style: TextStyle(fontSize: 14, color: Colors.black45)),
            // Priority
            Text('Priority: ${task['priority']}',
                style: TextStyle(fontSize: 14, color: Colors.black45)),
            // Requested Time
            Text(
              'Requested Time: ${task['requestedTime']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
