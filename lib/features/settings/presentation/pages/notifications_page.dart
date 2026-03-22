import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';

const _kNotifFriendRequest = 'notif_friend_request';
const _kNotifTodo = 'notif_todo';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notifFriendRequest = true;
  bool _notifTodo = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifFriendRequest = prefs.getBool(_kNotifFriendRequest) ?? true;
      _notifTodo = prefs.getBool(_kNotifTodo) ?? true;
    });
  }

  Future<void> _set(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _ToggleTile(
            label: AppLocalizations.of(context)!.friendRequestNotification,
            value: _notifFriendRequest,
            onChanged: (v) {
              setState(() => _notifFriendRequest = v);
              _set(_kNotifFriendRequest, v);
            },
          ),
          _ToggleTile(
            label: AppLocalizations.of(context)!.todoReminderNotification,
            value: _notifTodo,
            onChanged: (v) {
              setState(() => _notifTodo = v);
              _set(_kNotifTodo, v);
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(18, 4, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w400)),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.textPrimary,
          ),
        ],
      ),
    );
  }
}
