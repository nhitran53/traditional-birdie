import 'package:flutter/material.dart';

import '../models/juggle_session.dart';
import 'match_screen.dart' show PopNumber;

class JuggleScreen extends StatefulWidget {
  const JuggleScreen({super.key});

  @override
  State<JuggleScreen> createState() => _JuggleScreenState();
}

String _cheer(int streak) {
  if (streak == 0) return 'tap for each kick 🦶';
  if (streak < 5) return 'nice start! 🐣';
  if (streak < 10) return 'keep it up! 🌸';
  if (streak < 25) return 'wow, so smooth! 🌈';
  if (streak < 50) return 'on fire!! 🔥';
  return 'legendary kicker 👑';
}

class _JuggleScreenState extends State<JuggleScreen> {
  final _session = JuggleSession();

  Future<void> _addPlayer() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _AddPlayerDialog(),
    );
    if (!mounted) return;
    if (name != null && name.trim().isNotEmpty) {
      setState(() => _session.addPlayer(name.trim()));
    }
  }

  void _drop() {
    final player = _session.active;
    final streak = _session.streak;
    if (streak == 0) return;
    late bool isBest;
    setState(() => isBest = _session.drop());
    if (player == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isBest && streak > 0
                ? '🎉 New best for ${player.name}: $streak kicks!'
                : '${player.name} dropped it at $streak',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = _session.active;

    return Scaffold(
      appBar: AppBar(title: const Text('Juggling mode')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPlayer,
        icon: const Icon(Icons.person_add),
        label: const Text('Player'),
      ),
      body: _session.players.isEmpty
          ? const Center(
              child: Text(
                '🪶\n\nAdd a player to start counting kicks!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    children: [
                      for (var i = 0; i < _session.players.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_session.players[i].name),
                            selected: _session.activeIndex == i,
                            onSelected: (_) =>
                                setState(() => _session.select(i)),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: const Color(0xFFFFE3EC),
                      borderRadius: BorderRadius.circular(32),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => setState(_session.kick),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                active?.name ?? '',
                                style: theme.textTheme.titleLarge,
                              ),
                              PopNumber(
                                value: _session.streak,
                                style: const TextStyle(
                                  fontSize: 120,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                _cheer(_session.streak),
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FilledButton.icon(
                    onPressed: _drop,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A80),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('Oops, dropped!'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Leaderboard',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      for (final (i, p) in _session.leaderboard.indexed)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFFF1B8),
                            child: Text(
                              const ['🥇', '🥈', '🥉'].elementAtOrNull(i) ??
                                  '${i + 1}',
                            ),
                          ),
                          title: Text(p.name),
                          subtitle: Text('${p.attempts} attempts'),
                          trailing: Text(
                            'Best ${p.best}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Owns its own TextEditingController so it is disposed only after the
/// dialog's closing animation finishes.
class _AddPlayerDialog extends StatefulWidget {
  const _AddPlayerDialog();

  @override
  State<_AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<_AddPlayerDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add player'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Name'),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
