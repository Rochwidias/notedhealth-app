import 'package:flutter/material.dart';

/// Privasi & Legal — frame 14: kebijakan singkat + kredit.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privasi & Legal')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: const [
          _H('Kebijakan privasi'),
          _P('• Mode tamu: seluruh data (habit, berat, skor) hanya tersimpan di perangkat ini.'),
          _P('• Login Google (segera hadir): data tersimpan di Cloud Firestore atas nama akunmu, hanya kamu yang bisa akses.'),
          _P('• Tidak ada analitik, tidak ada iklan, data tidak dibagikan ke siapa pun.'),
          _P('• Hapus data kapan saja dari menu Profil — permanen.'),
          _H('Syarat layanan'),
          _P('NotedHealth adalah catatan kebiasaan sehat, BUKAN alat diagnosis medis. Konsultasikan ke tenaga kesehatan untuk keputusan medis.'),
          _H('Kredit'),
          _P('Desain & pengembangan oleh @rochwidias.'),
          _P('Foto: Pexels (Pexels License) · Font: Plus Jakarta Sans & Fredoka (SIL OFL 1.1) · Ikon SVG buatan sendiri.'),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  final String t;
  const _H(this.t);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
    );
  }
}

class _P extends StatelessWidget {
  final String t;
  const _P(this.t);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: const TextStyle(height: 1.5)),
    );
  }
}
