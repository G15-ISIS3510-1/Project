import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../../settings/view/profile_settings_view.dart';
import '../viewmodel/visited_places_viewmodel.dart'; // Importar el ViewModel

class VisitedPlacesScreen extends StatelessWidget {
  const VisitedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectar el ViewModel (si no lo haces en la navegación, hazlo aquí)
    final vm = context.watch<VisitedPlacesViewModel>(); 

    return Scaffold(
      appBar: AppBar(
        title: Transform.scale(
          scaleY: 0.82,
          scaleX: 1.0,
          child: const Text(
            'QOVO',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: -7.0,
            ),
          ),
        ),
        centerTitle: true,
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          // Mostrar errores del ViewModel, si existen
          if (vm.error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Error: ${vm.error!}', style: TextStyle(color: Colors.red)),
            ),
            
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: vm.places.map((place) { // Usar la lista del ViewModel
                return _PlaceCard(
                  place: place, // Pasar el objeto VisitedPlace completo
                );
              }).toList(),
            ),
          ),
          _buildBackButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Icon(Icons.mic, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FilterChip(
                label: 'All',
                isSelected: true,
                onTap: () {},
              ),
              _FilterChip(
                label: 'Favorites',
                isSelected: false,
                onTap: () {},
              ),
              _FilterChip(
                label: 'Tagged',
                isSelected: false,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfileSettingsView(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: const Text(
          'Back',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// WIDGET _PlaceCard MODIFICADO PARA USAR EL VIEWMODEL
// ----------------------------------------------------------------------

class _PlaceCard extends StatelessWidget {
  final VisitedPlace place;

  const _PlaceCard({
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.read<VisitedPlacesViewModel>();
    
    return GestureDetector(
      // Llamamos a la función del ViewModel al hacer tap
      onTap: () => vm.launchMap(place.latitude, place.longitude, place.city), 
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.city,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  place.date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(
                Icons.location_on, // Icono de ubicación para indicar que es un mapa
                color: Color(0xFFC0C0C0),
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// WIDGET _FilterChip (Sin cambios)
// ----------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}