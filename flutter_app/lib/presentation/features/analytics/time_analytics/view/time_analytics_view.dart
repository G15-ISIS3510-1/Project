import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/time_analytics_viewmodel.dart';
import '../data/time_repository.dart';

class TimeAnalyticsView extends StatelessWidget {
  const TimeAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimeAnalyticsViewModel(TimeRepository())..load(),
      child: const _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TimeAnalyticsViewModel>();

    const double p24 = 24;
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(p24, p24, p24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close, color: scheme.onSurface),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Icon(Icons.timer_outlined,
                                  color: scheme.primary, size: 26),
                              const SizedBox(width: 8),
                              Text(
                                "Usage Analytics",
                                style: text.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "See how much time you spend inside Qovo.",
                            style: text.bodyMedium?.copyWith(
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Divider(thickness: 2, color: scheme.outlineVariant),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _statCard(
                                  theme: theme,
                                  scheme: scheme,
                                  text: text,
                                  icon: Icons.access_time_filled_rounded,
                                  iconColor: Colors.blueAccent,
                                  label: "Total Time",
                                  value: vm.format(vm.totalSeconds),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _statCard(
                                  theme: theme,
                                  scheme: scheme,
                                  text: text,
                                  icon: Icons.timelapse_rounded,
                                  iconColor: Colors.deepPurpleAccent,
                                  label: "Avg Session\n(Last Week)",
                                  value: vm.format(vm.avgLastWeek.toInt()),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          _sectionCard(
                            theme: theme,
                            scheme: scheme,
                            text: text,
                            title: "Top 5 Views",
                            icon: Icons.trending_up_rounded,
                            iconColor: Colors.green,
                            child: vm.topFive.isEmpty
                                ? Text(
                                    "No data yet.",
                                    style: text.bodyMedium?.copyWith(
                                      color: scheme.onSurface.withOpacity(0.6),
                                    ),
                                  )
                                : Column(
                                    children: vm.topFive.map((e) {
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          radius: 14,
                                          backgroundColor: scheme.primary
                                              .withOpacity(0.08),
                                          child: Icon(
                                            Icons.circle,
                                            size: 10,
                                            color: scheme.primary,
                                          ),
                                        ),
                                        title: Text(
                                          e["view"] ?? "",
                                          style: text.bodyMedium,
                                        ),
                                        trailing: Text(
                                          vm.format(e["duration"] as int),
                                          style: text.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: scheme.onSurface
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),

                          const SizedBox(height: 16),

                          _sectionCard(
                            theme: theme,
                            scheme: scheme,
                            text: text,
                            title: "Bottom 5 Views",
                            icon: Icons.trending_down_rounded,
                            iconColor: Colors.orange,
                            child: vm.bottomFive.isEmpty
                                ? Text(
                                    "No data yet.",
                                    style: text.bodyMedium?.copyWith(
                                      color: scheme.onSurface.withOpacity(0.6),
                                    ),
                                  )
                                : Column(
                                    children: vm.bottomFive.map((e) {
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          radius: 14,
                                          backgroundColor: scheme.error
                                              .withOpacity(0.08),
                                          child: Icon(
                                            Icons.circle,
                                            size: 10,
                                            color: scheme.error,
                                          ),
                                        ),
                                        title: Text(
                                          e["view"] ?? "",
                                          style: text.bodyMedium,
                                        ),
                                        trailing: Text(
                                          vm.format(e["duration"] as int),
                                          style: text.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: scheme.onSurface
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),

                          const SizedBox(height: 16),

                          _sectionCard(
                            theme: theme,
                            scheme: scheme,
                            text: text,
                            title: "Daily History",
                            icon: Icons.calendar_month_rounded,
                            iconColor: Colors.teal,
                            child: vm.history.isEmpty
                                ? Text(
                                    "No usage history stored yet.",
                                    style: text.bodyMedium?.copyWith(
                                      color: scheme.onSurface.withOpacity(0.6),
                                    ),
                                  )
                                : Column(
                                    children: (vm.history.entries.toList()
                                          ..sort((a, b) => b.key.compareTo(a.key)))
                                        .map((e) {
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          e.key,
                                          style: text.bodyMedium,
                                        ),
                                        trailing: Text(
                                          vm.format(e.value),
                                          style: text.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: scheme.onSurface.withOpacity(0.8),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _statCard({
    required ThemeData theme,
    required ColorScheme scheme,
    required TextTheme text,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required ThemeData theme,
    required ColorScheme scheme,
    required TextTheme text,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
