import 'package:flutter/material.dart';

class ServiceProviderProfilePage extends StatefulWidget {
  @override
  _ServiceProviderProfilePageState createState() =>
      _ServiceProviderProfilePageState();
}

class _ServiceProviderProfilePageState
    extends State<ServiceProviderProfilePage> {
  // Sample list of service providers with employee profiles
  List<ServiceProvider> serviceProviders = [
    ServiceProvider(
      name: 'John Doe',
      companyName: 'HP Station',
      phoneNumber: '+123 456 7890',
      email: 'johndoe@superfuel.com',
      serviceArea: 'Downtown, City',
      operatingHours: '24/7',
      certifications: 'Certified Fuel Technician',
      pricing: 'Competitive pricing based on distance and fuel type',
      profileImageUrl: 'asset/img3.jpeg',
      employees: [
        Employee(
          name: 'Alice Brown',
          jobTitle: 'Station Manager',
          phoneNumber: '+123 111 2222',
          profileImageUrl: 'asset/employee1.jpeg',
        ),
        Employee(
          name: 'Bob Green',
          jobTitle: 'Fuel Technician',
          phoneNumber: '+123 333 4444',
          profileImageUrl: 'asset/employee2.jpeg',
        ),
      ],
    ),
    ServiceProvider(
      name: 'Jane Smith',
      companyName: 'Indian Oil Fuel Station',
      phoneNumber: '+321 654 9870',
      email: 'janesmith@fueltech.com',
      serviceArea: 'Uptown, City',
      operatingHours: 'Mon-Fri 8 AM - 6 PM',
      certifications: 'Certified Fuel Technician, Electric Charging Specialist',
      pricing: 'Prices vary by location and fuel type',
      profileImageUrl: 'asset/img3.jpeg',
      employees: [
        Employee(
          name: 'Sarah Williams',
          jobTitle: 'Fuel Technician',
          phoneNumber: '+321 555 6666',
          profileImageUrl: 'asset/employee3.jpeg',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Providers'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: serviceProviders.length,
          itemBuilder: (context, index) {
            final provider = serviceProviders[index];
            return _buildProviderCard(context, provider);
          },
        ),
      ),
    );
  }

  // Helper function to build each provider card
  Widget _buildProviderCard(BuildContext context, ServiceProvider provider) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderDetailPage(provider: provider),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(provider.profileImageUrl),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.companyName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(provider.serviceArea),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.deepPurple),
            ],
          ),
        ),
      ),
    );
  }
}

// A page to show the details of a specific provider
class ProviderDetailPage extends StatelessWidget {
  final ServiceProvider provider;

  ProviderDetailPage({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(provider.companyName),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProviderPage(provider: provider),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Picture Section
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(provider.profileImageUrl),
              ),
            ),
            SizedBox(height: 16),

            // Provider Information
            _buildInfoRow('Provider Name:', provider.name),
            _buildInfoRow('Phone Number:', provider.phoneNumber),
            _buildInfoRow('Email:', provider.email),
            _buildInfoRow('Service Area:', provider.serviceArea),
            _buildInfoRow('Operating Hours:', provider.operatingHours),
            _buildInfoRow('Certifications:', provider.certifications),
            _buildInfoRow('Pricing:', provider.pricing),

            // Employee Information
            SizedBox(height: 20),
            Text(
              'Employees at this Station:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ...provider.employees.map(
                (employee) => _buildEmployeeCard(context, employee, provider)),
          ],
        ),
      ),
    );
  }

  // Helper function to build info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Helper function to build employee card
  Widget _buildEmployeeCard(
      BuildContext context, Employee employee, ServiceProvider provider) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(employee.profileImageUrl),
        ),
        title: Text(employee.name),
        subtitle: Text(employee.jobTitle),
        trailing: Text(employee.phoneNumber),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditEmployeePage(employee: employee, provider: provider),
            ),
          );
        },
      ),
    );
  }
}

// Edit Provider Profile Page
class EditProviderPage extends StatefulWidget {
  final ServiceProvider provider;

  EditProviderPage({required this.provider});

  @override
  _EditProviderPageState createState() => _EditProviderPageState();
}

class _EditProviderPageState extends State<EditProviderPage> {
  late TextEditingController nameController;
  late TextEditingController companyController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController serviceAreaController;
  late TextEditingController operatingHoursController;
  late TextEditingController certificationsController;
  late TextEditingController pricingController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.provider.name);
    companyController =
        TextEditingController(text: widget.provider.companyName);
    phoneController = TextEditingController(text: widget.provider.phoneNumber);
    emailController = TextEditingController(text: widget.provider.email);
    serviceAreaController =
        TextEditingController(text: widget.provider.serviceArea);
    operatingHoursController =
        TextEditingController(text: widget.provider.operatingHours);
    certificationsController =
        TextEditingController(text: widget.provider.certifications);
    pricingController = TextEditingController(text: widget.provider.pricing);
  }

  @override
  void dispose() {
    nameController.dispose();
    companyController.dispose();
    phoneController.dispose();
    emailController.dispose();
    serviceAreaController.dispose();
    operatingHoursController.dispose();
    certificationsController.dispose();
    pricingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Provider'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('Provider Name', nameController),
            _buildTextField('Company Name', companyController),
            _buildTextField('Phone Number', phoneController),
            _buildTextField('Email', emailController),
            _buildTextField('Service Area', serviceAreaController),
            _buildTextField('Operating Hours', operatingHoursController),
            _buildTextField('Certifications', certificationsController),
            _buildTextField('Pricing', pricingController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.provider.name = nameController.text;
                  widget.provider.companyName = companyController.text;
                  widget.provider.phoneNumber = phoneController.text;
                  widget.provider.email = emailController.text;
                  widget.provider.serviceArea = serviceAreaController.text;
                  widget.provider.operatingHours =
                      operatingHoursController.text;
                  widget.provider.certifications =
                      certificationsController.text;
                  widget.provider.pricing = pricingController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

// Edit Employee Profile Page
class EditEmployeePage extends StatefulWidget {
  final Employee employee;
  final ServiceProvider provider;

  EditEmployeePage({required this.employee, required this.provider});

  @override
  _EditEmployeePageState createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  late TextEditingController nameController;
  late TextEditingController jobTitleController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.employee.name);
    jobTitleController = TextEditingController(text: widget.employee.jobTitle);
    phoneController = TextEditingController(text: widget.employee.phoneNumber);
  }

  @override
  void dispose() {
    nameController.dispose();
    jobTitleController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Employee'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('Employee Name', nameController),
            _buildTextField('Job Title', jobTitleController),
            _buildTextField('Phone Number', phoneController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.employee.name = nameController.text;
                  widget.employee.jobTitle = jobTitleController.text;
                  widget.employee.phoneNumber = phoneController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

// Model for ServiceProvider
class ServiceProvider {
  String name;
  String companyName;
  String phoneNumber;
  String email;
  String serviceArea;
  String operatingHours;
  String certifications;
  String pricing;
  String profileImageUrl;
  List<Employee> employees;

  ServiceProvider({
    required this.name,
    required this.companyName,
    required this.phoneNumber,
    required this.email,
    required this.serviceArea,
    required this.operatingHours,
    required this.certifications,
    required this.pricing,
    required this.profileImageUrl,
    required this.employees,
  });
}

// Model for Employee
class Employee {
  String name;
  String jobTitle;
  String phoneNumber;
  String profileImageUrl;

  Employee({
    required this.name,
    required this.jobTitle,
    required this.phoneNumber,
    required this.profileImageUrl,
  });
}
