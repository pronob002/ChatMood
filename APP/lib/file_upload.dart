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
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
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
      appBar: AppBar(
        title: const Text(
          'ChatMood Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
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
          Navigator.pop(context); // Close loading
          _showErrorSnackBar('Upload failed (Status: ${response.statusCode})');
        }
      } catch (e) {
        Navigator.pop(context); // Close loading
        _showErrorSnackBar('Error: Make sure backend is running.');
      }
    } else {
      _showErrorSnackBar('Please select a file first.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    String fileName = _filePath.isNotEmpty ? _filePath.split('/').last : '';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.deepPurple.shade300),
              const SizedBox(height: 16),
              Text('Upload Chat Log', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                'Select a .txt file to analyze the mood of your conversation.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: _openFileExplorer,
                icon: const Icon(Icons.file_open),
                label: const Text('Select Text File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_filePath.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _uploadFile,
                icon: const Icon(Icons.analytics),
                label: const Text('Analyze Mood'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
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
      appBar: AppBar(
        title: const Text('Analysis Insights', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text('Author Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          if (analysisResult != null && analysisResult!.containsKey('percentage_by_author'))
            ...analysisResult!['percentage_by_author'].keys.map((author) {
              return _buildAuthorCard(author, context);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Authors', analysisResult!['total_authors'].toString(), Icons.people),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildStatItem('Messages', analysisResult!['total_messages'].toString(), Icons.message),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildAuthorCard(String author, BuildContext context) {
    int messageCount = analysisResult!['messages_by_author'][author] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(author, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(20)),
                  child: Text('$messageCount messages', style: const TextStyle(fontSize: 12, color: Colors.deepPurple)),
                ),
              ],
            ),
            const Divider(height: 32),
            AspectRatio(
              aspectRatio: 1.7,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(author),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Positive', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem('Negative', Colors.red),
                const SizedBox(width: 16),
                _buildLegendItem('Neutral', Colors.blue),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
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
        color: Colors.green,
        value: pos,
        title: '${pos.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: neg,
        title: '${neg.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: neu,
        title: '${neu.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
    // Reduced the total time significantly (from 50s to ~2s)
    for (int i = 0; i < 100; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (mounted) {
        setState(() {
          _progress = (i + 1) / 100;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                  ),
                ),
                Text('${(_progress * 100).toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Analyzing Your Conversation...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            const Text('Processing sentiments and authors...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
