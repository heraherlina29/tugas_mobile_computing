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
      title: 'Tugas Mobile Computing',
      theme: ThemeData(
        useMaterial3: true,
        // TEMA WARNA: BIRU
        colorSchemeSeed: Colors.blue,
        // Background aplikasi biru sangat muda
        scaffoldBackgroundColor: const Color(0xFFE3F2FD), // Blue 50 custom
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // Biru Utama
          foregroundColor: Colors.white, // Teks Putih
          elevation: 4,
          centerTitle: true,
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
  // --- Variabel Data ---
  Position? posisi;
  List<double>? accelero;
  List<double>? gyro;
  double arahKompas = 0;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  // --- Logika Sensor (Sama seperti sebelumnya) ---
  void _initSensors() {
    _cekIzinGPS();

    // Accelerometer
    accelerometerEventStream().listen((event) {
      if (mounted) setState(() => accelero = [event.x, event.y, event.z]);
    });

    // Gyroscope
    gyroscopeEventStream().listen((event) {
      if (mounted) setState(() => gyro = [event.x, event.y, event.z]);
    });

    // Magnetometer (Kompas)
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

  // --- TAMPILAN UI (BIRU) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // JUDUL SESUAI REQUEST
        title: const Text("Tugas Mobile Computing", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.computer), // Ikon tambahan biar keren
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // KARTU 1: GPS (Biru Tua/Naval)
            _buildBlueCard(
              icon: Icons.satellite_alt_rounded,
              judul: "GNSS / GPS Data",
              isi: posisi == null 
                  ? "📡 Mencari koordinat satelit..." 
                  : "Latitude   : ${posisi!.latitude.toStringAsFixed(5)}\nLongitude : ${posisi!.longitude.toStringAsFixed(5)}\nAltitude   : ${posisi!.altitude.toStringAsFixed(1)} mdpl\nSpeed      : ${posisi!.speed.toStringAsFixed(1)} m/s",
              warnaHeader: Colors.blue.shade900,
              warnaIcon: Colors.white,
            ),
            
            const SizedBox(height: 16),

            // KARTU 2: IMU (Biru Medium)
            _buildBlueCard(
              icon: Icons.graphic_eq,
              judul: "Inertial Measurement Unit (IMU)",
              isi: "📈 Accelerometer (m/s²):\n"
                   "X: ${accelero?[0].toStringAsFixed(2) ?? '0.00'}  "
                   "Y: ${accelero?[1].toStringAsFixed(2) ?? '0.00'}  "
                   "Z: ${accelero?[2].toStringAsFixed(2) ?? '0.00'}\n\n"
                   "🔄 Gyroscope (rad/s):\n"
                   "X: ${gyro?[0].toStringAsFixed(2) ?? '0.00'}  "
                   "Y: ${gyro?[1].toStringAsFixed(2) ?? '0.00'}  "
                   "Z: ${gyro?[2].toStringAsFixed(2) ?? '0.00'}",
              warnaHeader: Colors.blue.shade700,
              warnaIcon: Colors.white,
            ),

            const SizedBox(height: 16),

            // KARTU 3: KOMPAS (Style Tech)
            Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.blue.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Digital Compass", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                    const Divider(color: Colors.blue),
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Lingkaran Kompas
                        Container(
                          width: 140, height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue.shade100, width: 8),
                            gradient: RadialGradient(colors: [Colors.white, Colors.blue.shade50]),
                            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)]
                          ),
                        ),
                        // Label Arah Mata Angin
                        const Positioned(top: 10, child: Text("N", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                        const Positioned(bottom: 10, child: Text("S", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                        const Positioned(right: 10, child: Text("E", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                        const Positioned(left: 10, child: Text("W", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                        
                        // Jarum Penunjuk
                        Transform.rotate(
                          angle: (arahKompas * (math.pi / 180)),
                          child: Icon(Icons.navigation, size: 90, color: Colors.blue.shade800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${arahKompas.toStringAsFixed(0)}°",
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Kartu Biru
  Widget _buildBlueCard({required IconData icon, required String judul, required String isi, required Color warnaHeader, required Color warnaIcon}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: warnaHeader,
            child: Row(
              children: [
                Icon(icon, color: warnaIcon),
                const SizedBox(width: 10),
                Text(judul, style: TextStyle(color: warnaIcon, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Text(
              isi, 
              style: TextStyle(fontSize: 14, color: Colors.blueGrey[800], height: 1.5, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}