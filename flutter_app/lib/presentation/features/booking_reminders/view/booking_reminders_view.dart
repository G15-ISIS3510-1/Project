import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../booking/viewmodel/booking_viewmodel.dart';
import '../../booking/view/create_booking_view.dart';
import 'package:flutter_app/data/models/booking_reminder_model.dart';
import '../viewmodel/booking_reminder_viewmodel.dart';


class BookingRemindersView extends StatefulWidget {
  final String userId;

  const BookingRemindersView({Key? key, required this.userId}) : super(key: key);

  @override
  State<BookingRemindersView> createState() => _BookingRemindersViewState();
}

class _BookingRemindersViewState extends State<BookingRemindersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingReminderViewModel>().loadUpcomingBookings(widget.userId);
    });
  }

  void _navigateToCreateBooking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider(
            create: (_) => BookingViewModel(),
            child: const CreateBookingScreen(),
          );
        },
      ),
    ).then((_) {
      context.read<BookingReminderViewModel>().loadUpcomingBookings(widget.userId);
    });
  }

  Future<void> _createTestBooking(BuildContext context) async {
    final viewModel = context.read<BookingReminderViewModel>();

    final now = DateTime.now();
    final startTs = now.add(const Duration(minutes: 5));
    final endTs = startTs.add(const Duration(days: 2));
    final timeRemaining = startTs.difference(now);

    final double hoursUntilStart = timeRemaining.inHours.toDouble();

    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      return "${twoDigits(d.inHours)}h ${twoDigits(d.inMinutes.remainder(60))}m";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating a MOCK booking...')),
    );

    try {
      final currentBookingsData = viewModel.upcomingBookings;

      final List<UpcomingBookingModel> typedUpdatedList =
      (currentBookingsData?.bookings?.isNotEmpty == true
          ? currentBookingsData!.bookings.map((b) => b as UpcomingBookingModel).toList()
          : []
      );

      final newMockBooking = UpcomingBookingModel(
        bookingId: 'MOCK-${now.microsecondsSinceEpoch}',
        vehicleId: 'MOCK-VEHICLE-A${now.hour}${now.minute}',
        startTs: startTs,
        endTs: endTs,

        reachedThreshold: hoursUntilStart < 48,
        timeRemainingFormatted: formatDuration(timeRemaining),
        hoursUntilStart: hoursUntilStart,

      );

      typedUpdatedList.insert(0, newMockBooking);

      final newUpcomingList = UpcomingBookingsListModel(
        bookings: typedUpdatedList,
        totalCount: typedUpdatedList.length,
        userId: widget.userId,
        hoursAhead: 48,
      );

      viewModel.setMockUpcomingBookings(newUpcomingList);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MOCK booking generated.')),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while creating MOCK: ${e.toString()}', maxLines: 2)),
      );
    }
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
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load bookings',
                    style: t.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      viewModel.clearError();
                      viewModel.loadUpcomingBookings(widget.userId);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final upcomingBookings = viewModel.upcomingBookings;

          if (upcomingBookings == null || upcomingBookings.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming bookings',
                    style: t.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore available vehicles!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final List<UpcomingBookingModel> bookings =
          upcomingBookings.bookings.cast<UpcomingBookingModel>();

          return RefreshIndicator(
            onRefresh: () => viewModel.loadUpcomingBookings(widget.userId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(upcomingBookings),
                const SizedBox(height: 16),
                ...bookings.map((booking) {
                  return _buildBookingCard(context, booking);
                }).toList(),
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
            onPressed: () => _navigateToCreateBooking(context),
            backgroundColor: Colors.blue[700],
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(upcomingBookings) {
    final List<UpcomingBookingModel> bookings =
    upcomingBookings.bookings.cast<UpcomingBookingModel>();

    final urgentBookings = bookings
        .where((b) => b.reachedThreshold)
        .length;

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
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                ),
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
                    Icon(Icons.notification_important,
                        color: Colors.orange[700], size: 20),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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
                          Icon(Icons.access_time,
                              color: Colors.orange[900], size: 14),
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
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
}