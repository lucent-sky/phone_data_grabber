import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart' as sensors;
import 'package:flutter_rotation_vector_plugin/flutter_rotation_vector_plugin.dart' as rotation;

void main() {
  runApp(const SensorDisplayApp());
}

class SensorDisplayApp extends StatelessWidget {
  const SensorDisplayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SensorDisplayPage(),
    );
  }
}

class SensorDisplayPage extends StatefulWidget {
  const SensorDisplayPage({super.key});

  @override
  State<SensorDisplayPage> createState() => _SensorDisplayPageState();
}

class _SensorDisplayPageState extends State<SensorDisplayPage> {
  sensors.AccelerometerEvent? _accel;
  sensors.GyroscopeEvent? _gyro;
  List<double>? _orientation;

  @override
  void initState() {
    super.initState();

    // sensors_plus data
    sensors.accelerometerEventStream().listen((event) {
      setState(() => _accel = event);
    });

    sensors.gyroscopeEventStream().listen((event) {
      setState(() => _gyro = event);
    });

    // custom plugin rotation vector
    _initRotationVector();
  }

  Future<void> _initRotationVector() async {
    try {
      rotation.FlutterRotationVectorPlugin.rotationVectorStream().listen((event) {
        if (event.length >= 3) {
          setState(() {
            _orientation = [event[0], event[1], event[2]];
          });
        }
      });
    } catch (e) {
      debugPrint('Error getting rotation vector: $e');
    }
  }

  Widget _buildSensorRow(String label, dynamic values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '$label: ${values != null ? (values as Object).toStringAsFixedList() : "N/A"}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flight Sensor Debugger')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSensorRow("Accelerometer", _accel?.vector()),
            _buildSensorRow("Gyroscope", _gyro?.vector()),
            _buildSensorRow("Rotation Vector (X, Y, Z)", _orientation),
          ],
        ),
      ),
    );
  }
}

// Helper extensions
extension VectorFormat on Object {
  String toStringAsFixedList([int precision = 2]) {
    if (this is List<double>) {
      return (this as List<double>)
          .map((v) => v.toStringAsFixed(precision))
          .join(", ");
    }
    if (this is sensors.AccelerometerEvent) {
      var e = this as sensors.AccelerometerEvent;
      return "${e.x.toStringAsFixed(precision)}, ${e.y.toStringAsFixed(precision)}, ${e.z.toStringAsFixed(precision)}";
    }
    if (this is sensors.GyroscopeEvent) {
      var e = this as sensors.GyroscopeEvent;
      return "${e.x.toStringAsFixed(precision)}, ${e.y.toStringAsFixed(precision)}, ${e.z.toStringAsFixed(precision)}";
    }
    return toString();
  }

  List<double> vector() {
    if (this is sensors.AccelerometerEvent) {
      var e = this as sensors.AccelerometerEvent;
      return [e.x, e.y, e.z];
    }
    if (this is sensors.GyroscopeEvent) {
      var e = this as sensors.GyroscopeEvent;
      return [e.x, e.y, e.z];
    }
    return [];
  }
}
