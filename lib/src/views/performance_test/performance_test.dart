import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(PerfTest());
}

class PerfTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PerfTestPage(),
    );
  }
}

class PerfTestPage extends StatefulWidget {
  @override
  _PerfTestPageState createState() => _PerfTestPageState();
}

class _PerfTestPageState extends State<PerfTestPage> {
  final String url =
      'https://wartelsus.mitrakitajaya.com/members/memberslistmobile?_dc=1702436864884&branchID=10&filter_status=false&filter_textSearch=&page=1&start=0&limit=100&sort=LEVE_MEMBERID&dir=ASC';

  final int numberOfIterations = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Test'),
      ),
      body: Center(
        child: FutureBuilder(
          future: stressTestMiddleware(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text('Done!');
            }
          },
        ),
      ),
    );
  }

  Future<void> stressTestMiddleware() async {
    for (int i = 0; i < numberOfIterations; i++) {
      final response = await http.get(Uri.parse(url));
      print(
          'Response ${i + 1}: ${response.statusCode} ${response.reasonPhrase}');

      // Tunggu sejenak untuk memberikan waktu respons
      await Future.delayed(Duration(seconds: 1));
    }
  }
}
