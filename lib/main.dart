import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AnimeApp());
}

class AnimeApp extends StatelessWidget {
  const AnimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anime Browser',
      theme: ThemeData(useMaterial3: true),
      home: const AnimeListPage(),
    );
  }
}

/// =======================
/// หน้า 1: รายการอนิเมะ
/// =======================
class AnimeListPage extends StatefulWidget {
  const AnimeListPage({super.key});

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  List animeList = [];
  bool loading = true;

  Future<void> fetchAnimeList() async {
    final url =
        Uri.parse('https://api.jikan.moe/v4/anime?page=1&limit=10');

    final response = await http.get(url);
    final json = jsonDecode(response.body);

    setState(() {
      animeList = json['data'];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAnimeList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime List'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: animeList.length,
              itemBuilder: (context, index) {
                final anime = animeList[index];
                return ListTile(
                  leading: Image.network(
                    anime['images']['jpg']['image_url'],
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                  title: Text(anime['title']),
                  subtitle: Text(
                    '⭐ ${anime['score'] ?? '-'}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AnimeDetailPage(anime: anime),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

/// =======================
/// หน้า 2: รายละเอียด
/// =======================
class AnimeDetailPage extends StatelessWidget {
  final Map anime;

  const AnimeDetailPage({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(anime['title']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🖼 รูปเต็ม ไม่ครอป
            Center(
              child: Image.network(
                anime['images']['jpg']['large_image_url'],
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),

            /// 📌 ชื่อ
            Text(
              anime['title'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// 📖 เรื่องย่อ (หน้า/หลังเท่ากัน อ่านง่าย)
            Text(
              anime['synopsis'] ?? 'ไม่มีข้อมูล',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 16),

            /// ℹ รายละเอียดเพิ่ม
            Text('⭐ คะแนน: ${anime['score'] ?? '-'}'),
            Text('🎬 ตอน: ${anime['episodes'] ?? '-'}'),
            Text('📅 ปีที่ฉาย: ${anime['year'] ?? '-'}'),
          ],
        ),
      ),
    );
  }
}
