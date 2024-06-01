import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late MySqlConnection _connection;
  List<Map<String, dynamic>> _produks = [];
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProduks = [];

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
      await _updateProduks();
    } catch (e) {
      print('Error connecting to database: $e');
    }
  }

  Future<void> _updateProduks() async {
    var results = await _connection.query('SELECT * FROM produks');

    setState(() {
      _produks.clear();
      results.forEach((row) {
        _produks.add(Map<String, dynamic>.from(row.fields));
      });
      _applyFilter();
    });
  }

  void _applyFilter() {
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      _filteredProduks = List.from(_produks);
    } else {
      _filteredProduks = _produks.where((produk) {
        final productName = produk['nama_service'].toString().toLowerCase();
        return productName.contains(searchText);
      }).toList();
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
    // Menghitung seberapa sering setiap service muncul dalam data
    Map<String, int> serviceFrequency = {};
    _produks.forEach((produk) {
      String serviceName = produk['nama_service'];
      serviceFrequency.update(serviceName, (value) => value + 1,
          ifAbsent: () => 1);
    });

    // Membuat list dari data untuk chart
    List<PieChartSectionData> sections = [];
    List<Color> colors = [
      Color(0xFFAED581), // Light Green
      Color(0xFF4FC3F7), // Light Blue
      Color(0xFFFFF176), // Light Yellow
      Color(0xFFBA68C8), // Light Purple
      Color(0xFFFF8A65), // Light Orange
      Color(0xFF81C784), // Green
      Color(0xFF64B5F6), // Blue
      Color(0xFFFFD54F), // Yellow
      Color(0xFFDCE775), // Lemon Green
      Color(0xFF9575CD), // Purple
    ];
    int colorIndex = 0;

    serviceFrequency.forEach((serviceName, frequency) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: frequency.toDouble(),
          title: '$serviceName\n($frequency)',
          radius: 115, // Atur besar kecilnya donut chart di sini
          titleStyle: TextStyle(
            fontSize:
                12, // Atur ukuran font agar tidak melebihi batas donut chart
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 211, 227),
      body: Column(
        children: [
          SizedBox(height: 50),
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
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    GestureDetector(
                      child: const Text(
                        'Products',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 320,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          borderData: FlBorderData(show: false),
                          centerSpaceRadius: 33,
                          sectionsSpace: 1,
                          startDegreeOffset: 180,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                labelText: 'Search by Service Name',
                                prefixIcon:
                                    Icon(Icons.search, color: Colors.grey),
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
                                setState(() {
                                  _applyFilter();
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: FittedBox(
                              child: DataTable(
                                headingRowColor: MaterialStateColor.resolveWith(
                                    (states) =>
                                        Color.fromARGB(255, 252, 252, 252)),
                                columns: [
                                  DataColumn(label: Text('No')),
                                  DataColumn(label: Text('Product')),
                                  DataColumn(label: Text('ID Service')),
                                  const DataColumn(label: Text('Service Name')),
                                  DataColumn(label: Text('Description')),
                                  DataColumn(label: Text('Data Added')),
                                  DataColumn(label: Text('Data Updated')),
                                  DataColumn(label: Text('Created By')),
                                  DataColumn(label: Text('Created At')),
                                  DataColumn(label: Text('Updated At')),
                                ],
                                rows: _filteredProduks.map((produk) {
                                  return DataRow(
                                    color: MaterialStateColor.resolveWith(
                                        (states) =>
                                            Color.fromARGB(255, 244, 223, 188)),
                                    cells: [
                                      DataCell(Text('${produk['id']}')),
                                      DataCell(Text('${produk['produk']}')),
                                      DataCell(Text('${produk['id_service']}')),
                                      DataCell(
                                          Text('${produk['nama_service']}')),
                                      DataCell(Text('${produk['deskripsi']}')),
                                      DataCell(Text('${produk['data_added']}')),
                                      DataCell(
                                          Text('${produk['data_updated']}')),
                                      DataCell(Text('${produk['created_by']}')),
                                      DataCell(Text('${produk['created_at']}')),
                                      DataCell(Text('${produk['updated_at']}')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
