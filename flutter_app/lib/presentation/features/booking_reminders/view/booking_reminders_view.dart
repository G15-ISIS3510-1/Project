import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/data/models/booking_reminder_model.dart';
import '../viewmodel/booking_reminder_viewmodel.dart';

// lib/presentation/features/booking_reminders/view/booking_reminders_view.dart

import 'package:flutter_app/presentation/features/home/view/home_view.dart'; // 👈 ir a Home

class BookingRemindersView extends StatefulWidget {
  final String userId;
  const BookingRemindersView({Key? key, required this.userId})
    : super(key: key);

  @override
  State<BookingRemindersView> createState() => _BookingRemindersViewState();
}

class _BookingRemindersViewState extends State<BookingRemindersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingReminderViewModel>().loadUpcomingBookings(
        widget.userId,
      );
    });
  }

  void _goToHomeToChooseVehicle(BuildContext context) {
    // Abre Home para que el usuario elija un auto; desde Home se empuja CreateBookingScreen.
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const HomeView()));
  }

  Future<void> _createTestBooking(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock booking not implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
        backgroundColor: Colors.blue[700],
      ),
      body: Consumer<BookingReminderViewModel>(
        builder: (context, viewModel, child) {
          // … tu render actual intacto …
          // (no lo repito por brevedad)
          // Solo asegúrate de seguir llamando a viewModel.loadUpcomingBookings(userId) en pull-to-refresh
          // y mantener _buildSummaryCard / _buildBookingCard como los tienes.
          // ⬇️
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null) {
            // … igual que antes …
          }
          final upcoming = viewModel.upcomingBookings;
          if (upcoming == null || upcoming.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No upcoming bookings', style: t.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Explore available vehicles!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          // … igual que antes …
          return RefreshIndicator(
            onRefresh: () => viewModel.loadUpcomingBookings(widget.userId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(upcoming),
                const SizedBox(height: 16),
                ...upcoming.bookings
                    .cast<UpcomingBookingModel>()
                    .map((b) => _buildBookingCard(context, b))
                    .toList(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'testBookingBtn',
            onPressed: () => _createTestBooking(context),
            backgroundColor: Colors.red[700],
            child: const Icon(Icons.flash_on, color: Colors.white),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'createBookingBtn',
            onPressed: () => _goToHomeToChooseVehicle(context), // 👈 cambio
            backgroundColor: Colors.blue[700],
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // _buildSummaryCard / _buildStatItem / _buildBookingCard se quedan igual que los tenías
}

Widget _buildSummaryCard(upcomingBookings) {
  final List<UpcomingBookingModel> bookings = upcomingBookings.bookings
      .cast<UpcomingBookingModel>();

  final urgentBookings = bookings.where((b) => b.reachedThreshold).length;

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.event,
                label: 'Total',
                value: '${upcomingBookings.totalCount}',
                color: Colors.blue,
              ),
              Container(height: 40, width: 1, color: Colors.grey[300]),
              _buildStatItem(
                icon: Icons.access_time,
                label: 'Upcoming',
                value: '$urgentBookings',
                color: urgentBookings > 0 ? Colors.orange : Colors.green,
              ),
            ],
          ),
          if (urgentBookings > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notification_important,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You have $urgentBookings booking${urgentBookings > 1 ? 's' : ''} starting soon',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _buildStatItem({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Column(
    children: [
      Icon(icon, color: color, size: 32),
      const SizedBox(height: 8),
      Text(
        value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
    ],
  );
}

Widget _buildBookingCard(BuildContext context, booking) {
  final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
  final isUrgent = booking.reachedThreshold;

  return Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: isUrgent ? Colors.orange : Colors.transparent,
        width: 2,
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.orange[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: isUrgent ? Colors.orange[700] : Colors.blue[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle ${booking.vehicleId.substring(0, 8)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${booking.bookingId.substring(0, 12)}...',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.orange[900],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Upcoming',
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateFormat.format(booking.startTs),
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event_busy, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateFormat.format(booking.endTs),
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.orange[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: isUrgent ? Colors.orange[700] : Colors.grey[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Starts in:',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Text(
                    booking.timeRemainingFormatted,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUrgent ? Colors.orange[900] : Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
