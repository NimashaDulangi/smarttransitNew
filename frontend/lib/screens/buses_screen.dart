import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/fade_in_widget.dart';

class BusesScreen extends StatefulWidget {
  const BusesScreen({super.key});

  @override
  State<BusesScreen> createState() => _BusesScreenState();
}

class _BusesScreenState extends State<BusesScreen> {
  List<dynamic> _buses = [];
  List<dynamic> _filteredBuses = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBuses();
    _searchController.addListener(_filterBuses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBuses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBuses = _buses.where((bus) {
        final busNumber = bus['bus_number'].toString().toLowerCase();
        final capacity = bus['capacity'].toString().toLowerCase();
        final status = bus['status'].toString().toLowerCase();
        return busNumber.contains(query) ||
            capacity.contains(query) ||
            status.contains(query);
      }).toList();
    });
  }

  Future<void> _loadBuses() async {
    setState(() => _isLoading = true);
    try {
      final buses = await ApiService.getBuses();
      setState(() {
        _buses = buses ?? [];
        _filteredBuses = _buses;
      });
    } catch (e) {
      setState(() {
        _buses = [];
        _filteredBuses = [];
      });
    }
    setState(() => _isLoading = false);
  }

  void _showBusDialog({Map<String, dynamic>? bus}) {
    final busNumberController =
        TextEditingController(text: bus?['bus_number'] ?? '');
    final capacityController =
        TextEditingController(text: bus?['capacity']?.toString() ?? '');
    final isEditing = bus != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Bus' : 'Add New Bus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: busNumberController,
              decoration: InputDecoration(
                labelText: 'Bus Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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
                result = await ApiService.updateBus(
                  bus['id'].toString(),
                  busNumberController.text.trim(),
                  int.tryParse(capacityController.text.trim()) ?? 0,
                );
              } else {
                result = await ApiService.createBus(
                  busNumberController.text.trim(),
                  int.tryParse(capacityController.text.trim()) ?? 0,
                );
              }
              if (context.mounted) {
                Navigator.pop(context);
                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing
                          ? 'Bus updated successfully!'
                          : 'Bus added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadBuses();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _deleteBus(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bus'),
        content: const Text('Are you sure you want to delete this bus?'),
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
      final result = await ApiService.deleteBus(id);
      if (mounted && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bus deleted successfully!'),
            backgroundColor: Colors.red,
          ),
        );
        _loadBuses();
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
          'Buses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBuses,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBusDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search buses...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterBuses();
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
                    '${_filteredBuses.length} result(s) found',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const LoadingShimmer()
                : _filteredBuses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.directions_bus,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No buses match your search'
                                  : 'No buses found',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Tap + to add a bus',
                                  style: TextStyle(color: Colors.grey)),
                            ]
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredBuses.length,
                        itemBuilder: (context, index) {
                          final bus = _filteredBuses[index];
                          return FadeInWidget(
                            delay: index * 100,
                            child: Container(
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
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.directions_bus,
                                      color: Colors.blue),
                                ),
                                title: Text(
                                  'Bus ${bus['bus_number'] ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Capacity: ${bus['capacity'] ?? 0} seats',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () =>
                                          _showBusDialog(bus: bus),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deleteBus(bus['id'].toString()),
                                    ),
                                  ],
                                ),
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