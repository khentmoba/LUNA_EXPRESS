import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../providers/property_provider.dart';

class ManageRoomsScreen extends StatefulWidget {
  final PropertyModel property;

  const ManageRoomsScreen({super.key, required this.property});

  @override
  State<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends State<ManageRoomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadRooms(widget.property.propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rooms'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1B16),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Property header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF5287B2).withValues(alpha: 0.1),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5287B2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home_work, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.property.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1B16),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.property.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${propertyProvider.rooms.length} rooms',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5287B2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Vacancy summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildSummaryCard(
                  'Vacant',
                  propertyProvider.rooms.where((r) => r.status == RoomStatus.vacant).length.toString(),
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildSummaryCard(
                  'Occupied',
                  propertyProvider.rooms.where((r) => r.status == RoomStatus.occupied).length.toString(),
                  Colors.red,
                ),
                const SizedBox(width: 16),
                _buildSummaryCard(
                  'Total',
                  propertyProvider.rooms.length.toString(),
                  const Color(0xFF5287B2),
                ),
              ],
            ),
          ),

          // Room list
          Expanded(
            child: propertyProvider.rooms.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: propertyProvider.rooms.length,
                    itemBuilder: (context, index) {
                      final room = propertyProvider.rooms[index];
                      return _RoomCard(
                        room: room,
                        propertyId: widget.property.propertyId,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRoomDialog(context),
        backgroundColor: const Color(0xFF5287B2),
        icon: const Icon(Icons.add),
        label: const Text('Add Room'),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No rooms added yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add rooms to manage vacancies',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    final capacityController = TextEditingController(text: '1');
    final rateController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  hintText: 'Number of tenants',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rateController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Rate (₱)',
                  hintText: 'e.g., 5000',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g., With AC, own bathroom',
                ),
                maxLines: 2,
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
              final provider = context.read<PropertyProvider>();
              final capacity = int.tryParse(capacityController.text) ?? 1;
              final rate = int.tryParse(rateController.text) ?? 0;

              final success = await provider.addRoom(
                propertyId: widget.property.propertyId,
                capacity: capacity,
                monthlyRate: rate,
                description: descController.text.isEmpty ? null : descController.text,
              );

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Room added successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5287B2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;
  final String propertyId;

  const _RoomCard({required this.room, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    final isVacant = room.status == RoomStatus.vacant;
    final provider = context.read<PropertyProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isVacant ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isVacant ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Room ${room.roomId.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red[700])),
                        ],
                      ),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Room?'),
                            content: const Text('This action cannot be undone.'),
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

                        if (confirmed == true && context.mounted) {
                          await provider.deleteRoom(propertyId, room.roomId);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (room.description != null)
              Text(
                room.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Capacity: ${room.capacity}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    if (room.currentOccupants != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${room.currentOccupants}/${room.capacity} occupied)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isVacant ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                if (room.monthlyRate != null)
                  Text(
                    '₱${room.monthlyRate}/mo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5287B2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isVacant ? 'Available for booking' : 'Currently occupied',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isVacant ? Colors.green : Colors.red,
                  ),
                ),
                Switch(
                  value: isVacant,
                  onChanged: (value) async {
                    final newStatus = value ? RoomStatus.vacant : RoomStatus.occupied;
                    await provider.updateRoomStatus(propertyId, room.roomId, newStatus);
                  },
                  activeThumbColor: Colors.green,
                  activeTrackColor: Colors.green.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
