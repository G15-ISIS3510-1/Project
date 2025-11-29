import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/app/utils/date_format.dart';

import '../../analytics/time_analytics/data/time_tracker.dart';
import '../../analytics/time_analytics/data/time_storage.dart';
import '../viewmodel/booking_reminder_viewmodel.dart';
import 'package:flutter_app/presentation/features/home/view/home_view.dart';

class BookingRemindersView extends StatefulWidget {
  final String userId;
  const BookingRemindersView({super.key, required this.userId});

  @override
  State<BookingRemindersView> createState() => _BookingRemindersViewState();
}

class _BookingRemindersViewState extends State<BookingRemindersView> {
  @override
  void initState() {
    super.initState();
    TimeTracker.start("booking_reminders_view");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<BookingReminderViewModel>()
          .loadUpcomingBookings(widget.userId);
    });
  }

  @override
  void dispose() {
    final r = TimeTracker.stop();
    if (r != null) TimeStorage.save(r);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: Colors.blue[700],
      ),

      body: Selector<BookingReminderViewModel, bool>(
        selector: (_, vm) => vm.isLoading,
        builder: (_, isLoading, __) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _RemindersContent(userId: widget.userId);
        },
      ),

      floatingActionButton: const _FABActions(),
    );
  }
}

class _RemindersContent extends StatelessWidget {
  final String userId;
  const _RemindersContent({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Selector<BookingReminderViewModel, String?>(
      selector: (_, vm) => vm.errorMessage,
      builder: (_, error, __) {
        if (error != null) {
          return Center(child: Text(error, style: const TextStyle(color: Colors.red)));
        }

        final vm = context.watch<BookingReminderViewModel>();
        final upcoming = vm.upcomingBookings;

        if (upcoming == null || upcoming.bookings.isEmpty) {
          return const _EmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => vm.loadUpcomingBookings(userId),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(upcoming: upcoming),
              const SizedBox(height: 16),
              SizedBox(
                height: 12,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcoming.bookings.length,
                itemBuilder: (_, i) =>
                    _BookingCard(booking: upcoming.bookings[i]),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("No upcoming bookings", style: t.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text("Explore available vehicles!",
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _FABActions extends StatelessWidget {
  const _FABActions();

  @override
  Widget build(BuildContext context) {
    void goToHome() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    }

    void createMock() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mock booking not implemented")),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "mock",
          backgroundColor: Colors.red[700],
          onPressed: createMock,
          child: const Icon(Icons.flash_on),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          heroTag: "create",
          backgroundColor: Colors.blue[700],
          onPressed: goToHome,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final dynamic upcoming;

  const _SummaryCard({required this.upcoming});

  @override
  Widget build(BuildContext context) {
    final bookings = upcoming.bookings;
    final urgent =
        bookings.where((b) => b.reachedThreshold).length;

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
                _StatItem(
                  icon: Icons.event,
                  label: "Total",
                  value: "${upcoming.totalCount}",
                  color: Colors.blue,
                ),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                _StatItem(
                  icon: Icons.access_time,
                  label: "Upcoming",
                  value: "$urgent",
                  color: urgent > 0 ? Colors.orange : Colors.green,
                ),
              ],
            ),
            if (urgent > 0) ...[
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
                        "You have $urgent booking${urgent > 1 ? 's' : ''} starting soon",
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final dynamic booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final urgent = booking.reachedThreshold;

    return RepaintBoundary(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: urgent ? Colors.orange : Colors.transparent,
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
                _buildTop(context, urgent),
                const Divider(height: 24),
                _buildDates(),
                const SizedBox(height: 16),
                _buildCountdown(urgent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTop(BuildContext context, bool urgent) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: urgent ? Colors.orange[50] : Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.directions_car,
            color: urgent ? Colors.orange[700] : Colors.blue[700],
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vehicle ${booking.vehicleId.substring(0, 8)}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "ID: ${booking.bookingId.substring(0, 12)}...",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (urgent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange[900], size: 14),
                const SizedBox(width: 4),
                Text("Upcoming",
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          )
      ],
    );
  }

  Widget _buildDates() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                formatDateTime(booking.startTs),
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
                formatDateTime(booking.endTs),
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountdown(bool urgent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: urgent ? Colors.orange[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.timer,
                  color: urgent ? Colors.orange[700] : Colors.grey[700],
                  size: 20),
              const SizedBox(width: 8),
              const Text("Starts in:",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          Text(
            booking.timeRemainingFormatted,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: urgent ? Colors.orange[900] : Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }
}
