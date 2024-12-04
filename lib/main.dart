import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dále driver helper',
      theme: ThemeData.dark(), // Dark theme
      home: MyHomePage(title: 'Dále driver helper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  double _earningsPerKm = 0;
  double _earningsPerHour = 0;
  String _notificationText = '';
  double _tripCostArs = 0;
  double _tripDistanceKm = 0;
  double _tripDurationHours = 0;
  double _tripCostPerKm = 0;
  double _tripCostPerHour = 0;
  bool _appEnabled = false;

  Color _costPerKmColor = Colors.black;
  Color _costPerHourColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Ganancias por km (ARS)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese un valor';
                }
                return null;
              },
              onSaved: (value) {
                _earningsPerKm = double.parse(value!);
              },
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Ganancias por hora (ARS)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese un valor';
                }
                return null;
              },
              onSaved: (value) {
                _earningsPerHour = double.parse(value!);
              },
            ),
            SwitchListTile(
              title: Text('Ativar'),
              value: _appEnabled,
              onChanged: (value) {
                setState(() {
                  _appEnabled = value;
                });
              },
            ),
            Visibility(
              visible: _appEnabled,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Texto da notificação'),
                    onChanged: (value) {
                      setState(() {
                        _notificationText = value;
                        _extractTripData();
                      });
                    },
                  ),
                  Text('Costo del viaje: ${_tripCostArs.toStringAsFixed(2)} ARS'),
                  Text('Distancia del viaje: ${_tripDistanceKm.toStringAsFixed(2)} km'),
                  Text('Duración del viaje: ${_tripDurationHours.toStringAsFixed(2)} horas'),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _calculateResults();
                      }
                    },
                    child: Text('Calcular'),
                  ),
                  Text(
                    'Costo por km: ${_tripCostPerKm.toStringAsFixed(2)} ARS',
                    style: TextStyle(color: _costPerKmColor),
                  ),
                  Text(
                    'Costo por hora: ${_tripCostPerHour.toStringAsFixed(2)} ARS',
                    style: TextStyle(color: _costPerHourColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _extractTripData() {
    final regex = RegExp(r'(\d+\.?\d*) ARS.*?(\d+) min \(([\d.]+) km\).*?Viaje: (\d+) min \(([\d.]+) km\)');
    final match = regex.firstMatch(_notificationText);

    if (match != null) {
      _tripCostArs = double.parse(match.group(1)!);
      final timeToPassenger = int.parse(match.group(2)!);
      final distToPassenger = double.parse(match.group(3)!);
      final tripDurationMinutes = int.parse(match.group(4)!);
      _tripDistanceKm = double.parse(match.group(5)!);
      _tripDurationHours = tripDurationMinutes / 60;
    } else {
      _tripCostArs = 0;
      _tripDistanceKm = 0;
      _tripDurationHours = 0;
    }
    setState(() {});
  }

  void _calculateResults() {
    _tripCostPerKm = _tripCostArs / _tripDistanceKm;
    _tripCostPerHour = _tripCostArs / _tripDurationHours;

    _costPerKmColor = _tripCostPerKm >= _earningsPerKm ? Colors.green : Colors.red;
    _costPerHourColor = _tripCostPerHour >= _earningsPerHour ? Colors.green : Colors.red;

    setState(() {});
  }
}
