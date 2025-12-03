import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensor Pink App',
      theme: ThemeData(
        useMaterial3: true,
        // GANTI WARNA UTAMA JADI PINK
        colorSchemeSeed: Colors.pink, 
        // Latar belakang aplikasi jadi agak pink muda
        scaffoldBackgroundColor: Colors.pink[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink, // AppBar jadi Pink Tua
          foregroundColor: Colors.white, // Teks di AppBar jadi Putih
          elevation: 4,
        ),
      ),
      home: const HalamanSensor(),
    );
  }
}

class HalamanSensor extends StatefulWidget {
  const HalamanSensor({super.key});

  @override
  State<HalamanSensor> createState() => _HalamanSensorState();
}

class _HalamanSensorState extends State<HalamanSensor> {
  // --- Variabel Data (Tidak Berubah) ---
  Position? posisi;
  List<double>? accelero;
  List<double>? gyro;
  double arahKompas = 0;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  // --- Logika Sensor (Tidak Berubah) ---
  void _initSensors() {
    _cekIzinGPS();
    accelerometerEventStream().listen((event) {
      if (mounted) setState(() => accelero = [event.x, event.y, event.z]);
    });
    gyroscopeEventStream().listen((event) {
      if (mounted) setState(() => gyro = [event.x, event.y, event.z]);
    });
    magnetometerEventStream().listen((event) {
      double heading = math.atan2(event.y, event.x) * (180 / math.pi);
      if (heading > 0) heading -= 360;
      if (mounted) setState(() => arahKompas = heading * -1);
    });
  }

  Future<void> _cekIzinGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    Geolocator.getPositionStream().listen((Position p) {
      if (mounted) setState(() => posisi = p);
    });
  }

  // --- TAMPILAN UI (BAGIAN YANG DIUBAH JADI PINK) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌸 Tugas Sensor Pink 🌸", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // KARTU GPS (PINK TUA)
            _buildPinkCard(
              icon: Icons.location_on_rounded,
              judul: "Lokasi GPS",
              isi: posisi == null 
                ? "Sedang mencari sinyal..." 
                : "Lat: ${posisi!.latitude.toStringAsFixed(4)}\nLong: ${posisi!.longitude.toStringAsFixed(4)}\nAlt: ${posisi!.altitude.toStringAsFixed(1)} m",
              warnaHeader: Colors.pink[400]!, // Pink agak tua
              warnaIcon: Colors.white,
            ),
            
            const SizedBox(height: 20),

            // KARTU SENSOR GERAK (PINK SEDANG)
            _buildPinkCard(
              icon: Icons.sensors_rounded,
              judul: "Sensor Gerak",
              isi: "📍 Accelerometer:\nX:${accelero?[0].toStringAsFixed(1) ?? '-'} Y:${accelero?[1].toStringAsFixed(1) ?? '-'} Z:${accelero?[2].toStringAsFixed(1) ?? '-'}\n\n🔄 Gyroscope:\nX:${gyro?[0].toStringAsFixed(1) ?? '-'} Y:${gyro?[1].toStringAsFixed(1) ?? '-'} Z:${gyro?[2].toStringAsFixed(1) ?? '-'}",
              warnaHeader: Colors.pink[300]!, // Pink sedang
              warnaIcon: Colors.white,
            ),

            const SizedBox(height: 20),

            // KARTU KOMPAS (PINK MUDA / AKSEN)
            Card(
              elevation: 5,
              shadowColor: Colors.pinkAccent.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.pink.shade200, width: 2)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("🧭 Kompas Digital", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink[700])),
                    const Divider(color: Colors.pinkAccent),
                    const SizedBox(height: 15),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Lingkaran latar belakang kompas
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.pink.shade100, width: 4),
                            gradient: LinearGradient(
                              colors: [Colors.pink.shade50, Colors.white],
                              begin: Alignment.topLeft, end: Alignment.bottomRight
                            )
                          ),
                        ),
                        // Jarum Kompas yang berputar
                        Transform.rotate(
                          angle: (arahKompas * (math.pi / 180)),
                          child: Icon(Icons.navigation_rounded, size: 80, color: Colors.pinkAccent[400]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text("${arahKompas.toStringAsFixed(0)}°", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pink[800])),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget Kustom untuk Kartu Pink
  Widget _buildPinkCard({required IconData icon, required String judul, required String isi, required Color warnaHeader, required Color warnaIcon}) {
    return Card(
      elevation: 5,
      shadowColor: warnaHeader.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias, // Supaya sudut header ikut melengkung
      child: Column(
        children: [
          // Header Kartu (Warna Pink Tua)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(color: warnaHeader),
            child: Row(
              children: [
                Icon(icon, color: warnaIcon, size: 28),
                const SizedBox(width: 12),
                Text(judul, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: warnaIcon)),
              ],
            ),
          ),
          // Isi Kartu (Warna Putih)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Text(isi, style: TextStyle(fontSize: 15, color: Colors.pink[900], height: 1.4)),
          ),
        ],
      ),
    );
  }
}