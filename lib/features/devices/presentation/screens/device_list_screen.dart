import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../domain/entities/device_session_entity.dart';
import '../../providers/device_providers.dart';
import '../state/device_list_state.dart';

class DeviceListScreen extends ConsumerStatefulWidget {
  const DeviceListScreen({super.key});

  @override
  ConsumerState<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends ConsumerState<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceListControllerProvider.notifier).loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final devicesState = ref.watch(deviceListControllerProvider);

    ref.listen(deviceListControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        showSnackbar(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          l10n.settings.devices,
          style: theme.title2.override(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        leading: FFIconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref
                  .read(deviceListControllerProvider.notifier)
                  .loadDevices(refresh: true);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _DeviceListBody(state: devicesState),
    );
  }
}

class _DeviceListBody extends ConsumerWidget {
  const _DeviceListBody({required this.state});

  final DeviceListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);

    if (state.isLoading && state.devices.isEmpty) {
      return Center(child: FFLoadingIndicator(color: theme.primaryColor));
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(deviceListControllerProvider.notifier).loadDevices(
                refresh: true,
              ),
      color: theme.primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _DeviceListHeader(state: state),
          if (state.hasError && state.devices.isEmpty)
            _DeviceListError(
              message: state.errorMessage ?? 'Failed to load devices',
              onRetry: () {
                ref
                    .read(deviceListControllerProvider.notifier)
                    .loadDevices(refresh: true);
              },
            )
          else if (state.devices.isEmpty)
            const _DeviceListEmpty(),
          ...state.devices
              .map((device) => _DeviceSessionCard(device: device)),
        ],
      ),
    );
  }
}

class _DeviceListHeader extends StatelessWidget {
  const _DeviceListHeader({required this.state});

  final DeviceListState state;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final count = state.devices.length;
    final updatedAt = state.lastUpdated != null
        ? DateFormat('MMM d, HH:mm').format(state.lastUpdated!.toLocal())
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Sessions',
          style: theme.subtitle1.override(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count device${count == 1 ? '' : 's'} linked to your account.',
          style: theme.bodyText2.override(color: theme.secondaryText),
        ),
        if (updatedAt != null) ...[
          const SizedBox(height: 2),
          Text(
            'Last updated $updatedAt',
            style: theme.bodyText2.override(color: theme.secondaryText),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DeviceListError extends StatelessWidget {
  const _DeviceListError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load devices',
            style: theme.subtitle1.override(
              color: theme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.bodyText2.override(color: theme.error),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceListEmpty extends StatelessWidget {
  const _DeviceListEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.secondaryText.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.devices_other, size: 52, color: theme.secondaryText),
          const SizedBox(height: 12),
          Text(
            'No devices found',
            style: theme.subtitle1.override(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You have not signed in from any device yet.',
            textAlign: TextAlign.center,
            style: theme.bodyText2.override(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _DeviceSessionCard extends StatelessWidget {
  const _DeviceSessionCard({required this.device});

  final DeviceSessionEntity device;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: _platformColor(device.platform, theme).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _platformColor(device.platform, theme).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _platformIcon(device.platform),
                  color: _platformColor(device.platform, theme),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.deviceName ?? device.platform.label,
                      style: theme.subtitle1.override(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      device.deviceModel ?? device.deviceId,
                      style: theme.bodyText2.override(color: theme.secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                label: device.status.label,
                color: _statusColor(device.status, theme),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                icon: Icons.security,
                label: device.isTrusted ? 'Trusted device' : 'Untrusted',
                color: device.isTrusted ? theme.success : theme.warning,
              ),
              _Chip(
                icon: Icons.verified_user,
                label: 'Login count ${device.loginCount}',
                color: theme.primaryColor,
              ),
              if (device.fcmTokenStatus != FcmTokenStatus.other)
                _Chip(
                  icon: Icons.notifications_active_outlined,
                  label: 'FCM ${device.fcmTokenStatus.label}',
                  color: theme.info,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.public,
            label: 'IP Address',
            value: device.lastIpAddress ?? 'Unknown',
          ),
          _InfoRow(
            icon: Icons.access_time,
            label: 'Last active',
            value: device.lastActiveAt != null
                ? dateFormat.format(device.lastActiveAt!.toLocal())
                : 'Not available',
          ),
          _InfoRow(
            icon: Icons.login,
            label: 'First login',
            value: dateFormat.format(device.firstLoginAt.toLocal()),
          ),
          if (device.lastLocation != null)
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Last location',
              value:
                  '${device.lastLocation!.latitude.toStringAsFixed(4)}, ${device.lastLocation!.longitude.toStringAsFixed(4)}',
            ),
          if (device.lastUserAgent != null) ...[
            const SizedBox(height: 12),
            Text(
              'User Agent',
              style: theme.bodyText2.override(
                color: theme.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              device.lastUserAgent!,
              style: theme.bodyText2,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.bodyText2.override(
                    color: theme.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: theme.bodyText1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

IconData _platformIcon(DevicePlatform platform) {
  switch (platform) {
    case DevicePlatform.web:
      return Icons.desktop_windows;
    case DevicePlatform.android:
      return Icons.android;
    case DevicePlatform.ios:
      return Icons.phone_iphone;
    case DevicePlatform.mac:
      return Icons.laptop_mac;
    case DevicePlatform.windows:
      return Icons.laptop_windows;
    case DevicePlatform.linux:
      return Icons.laptop;
    case DevicePlatform.other:
      return Icons.devices_other;
  }
}

Color _platformColor(DevicePlatform platform, FlutterFlowTheme theme) {
  switch (platform) {
    case DevicePlatform.web:
      return theme.primaryColor;
    case DevicePlatform.android:
      return theme.success;
    case DevicePlatform.ios:
      return theme.info;
    case DevicePlatform.mac:
      return theme.tertiaryColor;
    case DevicePlatform.windows:
      return theme.warning;
    case DevicePlatform.linux:
      return theme.secondaryColor;
    case DevicePlatform.other:
      return theme.secondaryText;
  }
}

Color _statusColor(DeviceStatus status, FlutterFlowTheme theme) {
  switch (status) {
    case DeviceStatus.active:
      return theme.success;
    case DeviceStatus.revoked:
      return theme.error;
    case DeviceStatus.inactive:
      return theme.secondaryText;
    case DeviceStatus.expired:
      return theme.warning;
    case DeviceStatus.other:
      return theme.secondaryText;
  }
}

