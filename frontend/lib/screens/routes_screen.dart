import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/loading_shimmer.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  List<dynamic> _routes = [];
  List<dynamic> _filteredRoutes = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRoutes();
    _searchController.addListener(_filterRoutes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRoutes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRoutes = _routes.where((route) {
        final routeName = route['route_name'].toString().toLowerCase();
        final startLocation = route['start_location'].toString().toLowerCase();
        final endLocation = route['end_location'].toString().toLowerCase();
        return routeName.contains(query) ||
            startLocation.contains(query) ||
            endLocation.contains(query);
      }).toList();
    });
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);
    try {
      final routes = await ApiService.getRoutes();
      setState(() {
        _routes = routes ?? [];
        _filteredRoutes = _routes;
      });
    } catch (e) {
      setState(() {
        _routes = [];
        _filteredRoutes = [];
      });
    }
    setState(() => _isLoading = false);
  }

  void _showRouteDialog({Map<String, dynamic>? route}) {
    final routeNameController =
        TextEditingController(text: route?['route_name'] ?? '');
    final startLocationController =
        TextEditingController(text: route?['start_location'] ?? '');
    final endLocationController =
        TextEditingController(text: route?['end_location'] ?? '');
    final distanceController =
        TextEditingController(text: route?['distance_km']?.toString() ?? '');
    final isEditing = route != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Route' : 'Add New Route'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: routeNameController,
                decoration: InputDecoration(
                  labelText: 'Route Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: startLocationController,
                decoration: InputDecoration(
                  labelText: 'Start Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: endLocationController,
                decoration: InputDecoration(
                  labelText: 'End Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: distanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Distance (km)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> result;
              if (isEditing) {
                result = await ApiService.updateRoute(
                  route['id'].toString(),
                  routeNameController.text.trim(),
                  startLocationController.text.trim(),
                  endLocationController.text.trim(),
                  double.tryParse(distanceController.text.trim()) ?? 0,
                );
              } else {
                result = await ApiService.createRoute(
                  routeNameController.text.trim(),
                  startLocationController.text.trim(),
                  endLocationController.text.trim(),
                  double.tryParse(distanceController.text.trim()) ?? 0,
                );
              }
              if (context.mounted) {
                Navigator.pop(context);
                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing
                          ? 'Route updated successfully!'
                          : 'Route added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadRoutes();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _deleteRoute(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: const Text('Are you sure you want to delete this route?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.deleteRoute(id);
      if (mounted && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route deleted successfully!'),
            backgroundColor: Colors.red,
          ),
        );
        _loadRoutes();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Routes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoutes,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRouteDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search routes...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterRoutes();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_filteredRoutes.length} result(s) found',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const LoadingShimmer()
                : _filteredRoutes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.route,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No routes match your search'
                                  : 'No routes found',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Tap + to add a route',
                                  style: TextStyle(color: Colors.grey)),
                            ]
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRoutes.length,
                        itemBuilder: (context, index) {
                          final route = _filteredRoutes[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.route,
                                    color: Colors.green),
                              ),
                              title: Text(
                                route['route_name'] ?? 'N/A',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${route['start_location']} → ${route['end_location']}',
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${route['distance_km']} km',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showRouteDialog(route: route),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _deleteRoute(route['id'].toString()),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}