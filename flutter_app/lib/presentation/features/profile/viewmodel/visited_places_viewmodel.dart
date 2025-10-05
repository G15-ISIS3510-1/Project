import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

// Modelo de datos para un lugar visitado
class VisitedPlace {
  final String city;
  final String date;
  final double latitude;
  final double longitude;

  const VisitedPlace({
    required this.city,
    required this.date,
    required this.latitude,
    required this.longitude,
  });
}

class VisitedPlacesViewModel extends ChangeNotifier {
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  // Datos quemados para este ejemplo. En una app real vendrían de un Repository o API.
  final List<VisitedPlace> _allPlaces = const [
    VisitedPlace(city: 'Bogotá, Colombia', date: 'March 2025', latitude: 4.7110, longitude: -74.0721),
    VisitedPlace(city: 'Tunja, Colombia', date: 'January 2025', latitude: 5.5350, longitude: -73.3677),
    VisitedPlace(city: 'São Paulo, Brasil', date: 'November 2024', latitude: -23.5505, longitude: -46.6333),
    VisitedPlace(city: 'Washington D.C., USA', date: 'October 2024', latitude: 38.9072, longitude: -77.0369),
  ];

  // Lista filtrada que la vista usará
  List<VisitedPlace> _places = [];
  List<VisitedPlace> get places => _places;

  VisitedPlacesViewModel() {
    _places = _allPlaces; // inicializar con todos
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  /// Abre Google Maps con las coordenadas del lugar
  Future<void> launchMap(double lat, double lng, String city) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    _setLoading(true);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _setError('No se pudo abrir el mapa para $city.');
      }
    } catch (e) {
      _setError('Error al abrir el mapa: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Filtro simple por texto
  void filterPlaces(String query) {
    if (query.isEmpty) {
      _places = _allPlaces;
    } else {
      _places = _allPlaces
          .where((p) =>
      p.city.toLowerCase().contains(query.toLowerCase()) ||
          p.date.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
