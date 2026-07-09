import 'package:flutter/material.dart';

void main() {
  runApp(const CompanyReportApp());
}

class CompanyReportApp extends StatelessWidget {
  const CompanyReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Company Report System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF10B981),
        fontFamily: 'Roboto',
      ),
      home: const ReportListScreen(),
    );
  }
}

// Model dữ liệu báo cáo mô phỏng
class ReportItem {
  final int id;
  final String wasteType;
  final String reporter;
  final String time;
  final String wasteLevel; // Cao, Trung bình, Thấp
  final String status;     // Đã duyệt, Từ chối, Chờ duyệt

  ReportItem({
    required this.id,
    required this.wasteType,
    required this.reporter,
    required this.time,
    required this.wasteLevel,
    required this.status,
  });
}

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  // 1. Tạo danh sách dữ liệu giả lập (30 dòng)
  final List<ReportItem> _allReports = List.generate(30, (index) {
    final levels = ['Cao', 'Trung bình', 'Thấp'];
    final statuses = ['Đã duyệt', 'Từ chối', 'Chờ duyệt'];
    final types = ['Rác thải sinh hoạt', 'Rác thải nhựa', 'Rác thải điện tử', 'Rác thải y tế'];
    
    return ReportItem(
      id: index + 1,
      wasteType: types[index % types.length],
      reporter: 'Nguyễn Văn ${String.fromCharCode(65 + (index % 26))}',
      time: '2024-07-${(index % 28) + 1} 09:15',
      wasteLevel: levels[index % 3],
      status: statuses[index % 3],
    );
  });

  // 2. Logic Phân trang
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  List<ReportItem> get _pagedData {
    int start = (_currentPage - 1) * _itemsPerPage;
    int end = start + _itemsPerPage;
    return _allReports.sublist(start, end > _allReports.length ? _allReports.length : end);
  }

  int get _totalPages => (_allReports.length / _itemsPerPage).ceil();

  // 3. Helper xây dựng Badge (Nhãn)
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getWasteLevelColor(String level) {
    switch (level) {
      case 'Cao': return Colors.red;
      case 'Trung bình': return Colors.orange;
      case 'Thấp': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã duyệt': return const Color(0xFF10B981);
      case 'Từ chối': return Colors.red;
      case 'Chờ duyệt': return Colors.amber;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'DANH SÁCH BÁO CÁO CÔNG TY',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF10B981),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. Khối bảng dữ liệu trong Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981), width: 2.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal, // Chống tràn ngang trên Mobile
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth - 32, // Đảm bảo bảng giãn 100% width
                          ),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(const Color(0xFFF0FDF4)),
                            columnSpacing: 24,
                            horizontalMargin: 16,
                            columns: const [
                              DataColumn(label: Text('STT', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Loại rác', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Người báo cáo', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Thời gian', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Mức độ rác', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _pagedData.asMap().entries.map((entry) {
                              int index = entry.key;
                              ReportItem item = entry.value;
                              int displayStt = ((_currentPage - 1) * _itemsPerPage) + index + 1;
                              
                              return DataRow(cells: [
                                DataCell(Text(displayStt.toString())),
                                DataCell(Text(item.wasteType)),
                                DataCell(Text(item.reporter)),
                                DataCell(Text(item.time)),
                                DataCell(_buildBadge(item.wasteLevel, _getWasteLevelColor(item.wasteLevel))),
                                DataCell(_buildBadge(item.status, _getStatusColor(item.status))),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),

                // 2. Thanh phân trang
                _buildPaginationSection(),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaginationSection() {
    bool isFirstPage = _currentPage == 1;
    bool isLastPage = _currentPage == _totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nút trang trước
        _buildPaginationButton(
          icon: Icons.chevron_left,
          isDisabled: isFirstPage,
          onTap: () {
            if (!isFirstPage) {
              setState(() => _currentPage--);
            }
          },
        ),
        
        const SizedBox(width: 16),

        // Ô số trang hiện tại
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '$_currentPage',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Nút trang kế tiếp
        _buildPaginationButton(
          icon: Icons.chevron_right,
          isDisabled: isLastPage,
          onTap: () {
            if (!isLastPage) {
              setState(() => _currentPage++);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF10B981), size: 28),
        ),
      ),
    );
  }
}
