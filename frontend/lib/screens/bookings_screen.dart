import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<dynamic> _bookings = [];
  List<dynamic> _buses = [];
  List<dynamic> _routes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final bookings = await ApiService.getBookings();
      final buses = await ApiService.getBuses();
      final routes = await ApiService.getRoutes();
      setState(() {
        _bookings = bookings ?? [];
        _buses = buses ?? [];
        _routes = routes ?? [];
      });
    } catch (e) {
      setState(() {
        _bookings = [];
        _buses = [];
        _routes = [];
      });
    }
    setState(() => _isLoading = false);
  }

  void _showBookingDialog({Map<String, dynamic>? booking}) {
    final passengerNameController =
        TextEditingController(text: booking?['passenger_name'] ?? '');
    final passengerPhoneController =
        TextEditingController(text: booking?['passenger_phone'] ?? '');
    final seatNumberController =
        TextEditingController(text: booking?['seat_number']?.toString() ?? '');
    String? selectedBusId = booking?['bus_id']?.toString();
    String? selectedRouteId = booking?['route_id']?.toString();
    final isEditing = booking != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Booking' : 'Add New Booking'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passengerNameController,
                  decoration: InputDecoration(
                    labelText: 'Passenger Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passengerPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: seatNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Seat Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedBusId,
                  decoration: InputDecoration(
                    labelText: 'Select Bus',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _buses.map((bus) {
                    return DropdownMenuItem<String>(
                      value: bus['id'].toString(),
                      child: Text('Bus ${bus['bus_number']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedBusId = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRouteId,
                  decoration: InputDecoration(
                    labelText: 'Select Route',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _routes.map((route) {
                    return DropdownMenuItem<String>(
                      value: route['id'].toString(),
                      child: Text(route['route_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedRouteId = value);
                  },
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
                if (selectedBusId == null || selectedRouteId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select bus and route!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Map<String, dynamic> result;
                if (isEditing) {
                  result = await ApiService.updateBooking(
                    booking['id'].toString(),
                    selectedBusId!,
                    selectedRouteId!,
                    passengerNameController.text.trim(),
                    passengerPhoneController.text.trim(),
                    int.tryParse(seatNumberController.text.trim()) ?? 0,
                  );
                } else {
                  result = await ApiService.createBooking(
                    selectedBusId!,
                    selectedRouteId!,
                    passengerNameController.text.trim(),
                    passengerPhoneController.text.trim(),
                    int.tryParse(seatNumberController.text.trim()) ?? 0,
                  );
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  if (result['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing
                            ? 'Booking updated successfully!'
                            : 'Booking added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadData();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Update' : 'Book'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBooking(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking?'),
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
      final result = await ApiService.deleteBooking(id);
      if (mounted && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking deleted successfully!'),
            backgroundColor: Colors.red,
          ),
        );
        _loadData();
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
          'Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookingDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_online, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No bookings found',
                          style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Tap + to add a booking',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
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
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.book_online,
                              color: Colors.orange),
                        ),
                        title: Text(
                          booking['passenger_name'] ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Phone: ${booking['passenger_phone'] ?? 'N/A'}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              'Seat: ${booking['seat_number'] ?? 'N/A'}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _showBookingDialog(booking: booking),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteBooking(booking['id'].toString()),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}