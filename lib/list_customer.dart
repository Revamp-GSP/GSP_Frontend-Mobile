import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class List_CustomerPage extends StatefulWidget {
  @override
  _List_CustomerPageState createState() => _List_CustomerPageState();
}

class _List_CustomerPageState extends State<List_CustomerPage> {
  late MySqlConnection _connection;
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectToDB();
  }

  Future<void> _connectToDB() async {
    final settings = ConnectionSettings(
      host: 'loyal.jagoanhosting.com',
      port: 3306,
      user: 'dkbmyid_admin',
      password: 'dbbackend!',
      db: 'dkbmyid_lara622',
    );

    try {
      _connection = await MySqlConnection.connect(settings);
      var results = await _connection.query('SELECT * FROM customers');

      // Update cara memperoleh hasil dari query
      results.forEach((row) {
        _customers.add(Map<String, dynamic>.from(row.fields));
      });

      // Assign _customers to _filteredCustomers initially
      _filteredCustomers = List.from(_customers);

      setState(() {});
    } catch (e) {
      print('Error connecting to database: $e');
    }
  }

  @override
  void dispose() {
    _connection.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter the customers based on search text
    _filteredCustomers = _customers.where((customer) {
      final namaPelanggan = customer['nama_pelanggan'].toString().toLowerCase();
      final searchText = _searchController.text.toLowerCase();
      return namaPelanggan.contains(searchText);
    }).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 211, 227),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                child: const Text(
                  'List Customer',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search by Customer Name',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FittedBox(
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Color.fromARGB(255, 252, 252, 252)),
                          columns: [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('ID Pelanggan')),
                            DataColumn(label: Text('Nama Pelanggan')),
                            DataColumn(label: Text('Nama Sebutan')),
                            DataColumn(label: Text('Data Added')),
                            DataColumn(label: Text('Date Update')),
                            DataColumn(label: Text('Created By')),
                            DataColumn(label: Text('Create At')),
                            DataColumn(label: Text('Update At')),
                          ],
                          rows: _filteredCustomers.map((projects) {
                            return DataRow(
                              color: MaterialStateColor.resolveWith((states) =>
                                  Color.fromARGB(255, 244, 223, 188)),
                              cells: [
                                DataCell(Text('${projects['id']}')),
                                DataCell(Text('${projects['id_pelanggan']}')),
                                DataCell(Text('${projects['nama_pelanggan']}')),
                                DataCell(Text('${projects['sebutan']}')),
                                DataCell(Text('${projects['date_added']}')),
                                DataCell(Text('${projects['date_updated']}')),
                                DataCell(Text('${projects['created_by']}')),
                                DataCell(Text('${projects['created_at']}')),
                                DataCell(Text('${projects['updated_at']}')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
