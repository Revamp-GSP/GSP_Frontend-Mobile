import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;

class ToggleTask extends StatelessWidget {
  final String task;
  final bool isOpen;
  final Function(bool) onToggle;

  ToggleTask({
    required this.task,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          onToggle(!isOpen);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Icon(
                isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentTask extends StatelessWidget {
  final List<Map<String, dynamic>> projects;

  ContentTask({required this.projects});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateColor.resolveWith(
            (states) => Color.fromARGB(255, 252, 252, 252)),
        columnSpacing: 20,
        columns: [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Project ID')),
          DataColumn(label: Text('Program Kegiatan')),
          DataColumn(label: Text('Plan Date Start')),
          DataColumn(label: Text('Plan Date End')),
          DataColumn(label: Text('Actual Date Start')),
          DataColumn(label: Text('Actual Date End')),
          DataColumn(label: Text('Dokumen')),
          DataColumn(label: Text('PIC')),
          DataColumn(label: Text('Divisi Terkait')),
          DataColumn(label: Text('Keterangan')),
          DataColumn(label: Text('Created At')),
          DataColumn(label: Text('Update At')),
        ],
        rows: projects
            .map(
              (project) => DataRow(
                color: MaterialStateColor.resolveWith(
                    (states) => Color.fromARGB(255, 244, 223, 188)),
                cells: [
                  DataCell(Text(project['id'].toString())),
                  DataCell(Text(project['project_id'].toString())),
                  DataCell(Text(project['program_kegiatan'].toString())),
                  DataCell(Text(project['plan_date_start'].toString())),
                  DataCell(Text(project['plan_date_end'].toString())),
                  DataCell(Text(project['actual_date_start'].toString())),
                  DataCell(Text(project['actual_date_end'].toString())),
                  DataCell(Text(project['dokumen'].toString())),
                  DataCell(Text(project['pic'].toString())),
                  DataCell(Text(project['divisi_terkait'].toString())),
                  DataCell(Text(project['keterangan'].toString())),
                  DataCell(Text(project['created_at'].toString())),
                  DataCell(Text(project['updated_at'].toString())),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class DetailProjectsPage extends StatefulWidget {
  final int projectId; // Tambahkan parameter projectId
  final String namaPekerjaan;
  final String statusPekerjaan;

  DetailProjectsPage({
    required this.projectId,
    required this.namaPekerjaan,
    required this.statusPekerjaan,
  });

  @override
  _DetailProjectsPageState createState() => _DetailProjectsPageState();
}

class _DetailProjectsPageState extends State<DetailProjectsPage> {
  late mysql.MySqlConnection _connection;
  TextEditingController _searchController = TextEditingController();
  Map<String, bool> _toggleState = {
    'Permintaan Penawaran Harga User': false,
    'Pengiriman Penawaran Harga User': false,
    'Proses Pengadaan': false,
    'Surat Penunjukan Pelaksana Pekerjaan': false,
    'Pembuatan dan Penandatanganan PKS': false,
    'Persiapan Pekerjaan': false,
    'Pelaksanaan Pekerjaan': false,
    'BAPS/BAST/BAUK': false,
    'Invoice': false,
    'Payment': false,
  };

  Map<String, List<Map<String, dynamic>>> _taskProjects = {};
  String? _selectedProjectStatus;

  @override
  void initState() {
    super.initState();
    _connectToDatabase();
  }

  Future<void> _connectToDatabase() async {
    try {
      _connection =
          await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: 'loyal.jagoanhosting.com',
        port: 3306,
        user: 'dkbmyid_admin',
        password: 'dbbackend!',
        db: 'dkbmyid_lara622',
      ));
      print('Terhubung ke database');
      await _fetchTasksData();
    } catch (e) {
      print('Gagal terhubung ke database: $e');
    }
  }

  Future<void> _fetchTasksData() async {
    try {
      final results = await _connection.query(
          'SELECT * FROM tasks WHERE project_id = ?', [widget.projectId]);
      final List<Map<String, dynamic>> tasksData =
          results.map((row) => row.fields).toList();
      setState(() {
        _taskProjects = {'Permintaan Penawaran Harga User': tasksData};
        // Ganti 'Permintaan Penawaran Harga User' dengan key yang sesuai dari _toggleState
      });
    } catch (e) {
      print('Gagal mengambil data dari database: $e');
    }
  }

  String getStatusWithPercentage(String status) {
    switch (status) {
      case 'Postpone':
        return 'Postpone (20%)';
      case 'Follow Up':
        return 'Follow Up (40%)';
      case 'Implementation':
        return 'Implementation (60%)';
      case 'Pembayaran':
        return 'Pembayaran (80%)';
      case 'Selesai':
        return 'Selesai (100%)';
      default:
        return status;
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 211, 227),
      body: SingleChildScrollView(
        child: Column(
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
            SizedBox(height: 20),
            Text(
              'Nama Pekerjaan: ${widget.namaPekerjaan}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Status: ${getStatusWithPercentage(widget.statusPekerjaan)}',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            for (var task in _toggleState.keys)
              Column(
                children: [
                  ToggleTask(
                    task: task,
                    isOpen: _toggleState[task]!,
                    onToggle: (isOpen) {
                      setState(() {
                        _toggleState[task] = isOpen;
                      });
                    },
                  ),
                  if (_toggleState[task]!)
                    ContentTask(
                      projects: _taskProjects[task] ?? [],
                    ),
                ],
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
