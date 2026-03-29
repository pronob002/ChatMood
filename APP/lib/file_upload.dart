import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatMood',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Vibrant Indigo
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF06B6D4), // Vibrant Cyan
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text(
          'ChatMood AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF9333EA)], // Indigo to Purple
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, const Color(0xFFEEF2FF)], // Very subtle blue tint
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(child: FileUploadWidget()),
      ),
    );
  }
}

class FileUploadWidget extends StatefulWidget {
  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  String _filePath = '';
  Map<String, dynamic>? _analysisResult;

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });
    }
  }

  void _uploadFile() async {
    if (_filePath.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoadingPage()),
      );

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://10.0.2.2:8000/upload"),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', _filePath),
      );

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse =
              json.decode(await response.stream.bytesToString());

          if (jsonResponse.containsKey('error')) {
            _showErrorSnackBar('Server error: ${jsonResponse['error']}');
          } else {
            var analysisResult = jsonResponse['result'];

            if (analysisResult != null) {
              setState(() {
                _analysisResult = analysisResult;
              });

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(_analysisResult),
                ),
              );
            }
          }
        } else {
          Navigator.pop(context); 
          _showErrorSnackBar('Upload failed. Try again.');
        }
      } catch (e) {
        Navigator.pop(context);
        _showErrorSnackBar('Connection error. Is the server running?');
      }
    } else {
      _showErrorSnackBar('Select a file to begin.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFEF4444), // Vibrant Red
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String fileName = _filePath.isNotEmpty ? _filePath.split('/').last : '';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                  ).createShader(bounds),
                  child: const Icon(Icons.auto_awesome, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Smart Mood Analysis',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E1B4B)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Upload your chat history and let AI reveal the hidden emotions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _openFileExplorer,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.file_upload_outlined, color: Color(0xFF6366F1)),
                        const SizedBox(height: 8),
                        Text(
                          _filePath.isEmpty ? 'Tap to choose .txt file' : fileName,
                          style: TextStyle(
                            color: _filePath.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF6366F1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _uploadFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                  ),
                  child: const Text('ANALYZE NOW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final Map<String, dynamic>? analysisResult;

  const ResultPage(this.analysisResult, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Analysis Report', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF9333EA)]),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 30),
          const Text(
            'Individual Breakdown',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E1B4B)),
          ),
          const SizedBox(height: 15),
          if (analysisResult != null && analysisResult!.containsKey('percentage_by_author'))
            ...analysisResult!['percentage_by_author'].keys.map((author) {
              return _buildAuthorCard(author, context);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B), // Deep Navy
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1E1B4B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Authors', analysisResult!['total_authors'].toString(), Icons.people_alt, const Color(0xFF818CF8)),
          _buildStatItem('Messages', analysisResult!['total_messages'].toString(), Icons.forum, const Color(0xFF2DD4BF)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color accentColor) {
    return Column(
      children: [
        Icon(icon, color: accentColor, size: 30),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildAuthorCard(String author, BuildContext context) {
    int messageCount = analysisResult!['messages_by_author'][author] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(author, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                child: Text('$messageCount msgs', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5))),
              ),
            ],
          ),
          const SizedBox(height: 25),
          AspectRatio(
            aspectRatio: 1.8,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(author),
                centerSpaceRadius: 35,
                sectionsSpace: 4,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Positive', const Color(0xFF10B981)), // Emerald
              _buildLegendItem('Negative', const Color(0xFFF43F5E)), // Rose
              _buildLegendItem('Neutral', const Color(0xFF3B82F6)),  // Blue
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(String author) {
    var data = analysisResult!['percentage_by_author'][author];
    double pos = (data['positive'] as num).toDouble();
    double neg = (data['negative'] as num).toDouble();
    double neu = (data['neutral'] as num).toDouble();

    return [
      PieChartSectionData(
        color: const Color(0xFF10B981),
        value: pos,
        title: '${pos.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      PieChartSectionData(
        color: const Color(0xFFF43F5E),
        value: neg,
        title: '${neg.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      PieChartSectionData(
        color: const Color(0xFF3B82F6),
        value: neu,
        title: '${neu.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
      ),
    ];
  }
}

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    for (int i = 0; i < 100; i++) {
      await Future.delayed(const Duration(milliseconds: 15));
      if (mounted) setState(() => _progress = (i + 1) / 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            const SizedBox(height: 40),
            Text(
              '${(_progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'DECODING EMOTIONS...',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }
}
