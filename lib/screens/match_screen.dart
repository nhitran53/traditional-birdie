import 'package:flutter/material.dart';

import '../models/shuttlecock_match.dart';

// Soft pastel team colors with a darker ink for text.
const _teamColors = [Color(0xFFFFB5C2), Color(0xFFA8E6CF)];
const _ink = Color(0xFF4A3B4F);

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key, required this.match});

  final ShuttlecockMatch match;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  ShuttlecockMatch get m => widget.match;

  void _score(int team) {
    if (m.isOver) return;
    late bool setEnded;
    setState(() => setEnded = m.scorePoint(team));

    if (m.isOver) {
      _showWinner();
    } else if (setEnded) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${m.teamNames[team]} wins the set ${m.setResults.last}',
            ),
          ),
        );
    }
  }

  void _undo() => setState(m.undo);

  void _showWinner() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('🏆 Yay! Match over 🎉'),
        content: Text(
          '${m.teamNames[m.winner!]} wins ${m.sets[m.winner!]}–${m.sets[1 - m.winner!]}\n\n'
          'Sets: ${m.setResults.join(', ')}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _undo();
            },
            child: const Text('Undo last point'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pressure = m.pressureLabel();
    return Scaffold(
      appBar: AppBar(
        title: Text(m.isOver ? 'Final' : 'Set ${m.currentSet}'),
        actions: [
          IconButton(
            tooltip: 'Undo last point',
            onPressed: m.canUndo ? _undo : null,
            icon: const Icon(Icons.undo),
          ),
        ],
      ),
      body: Column(
        children: [
          _SetBar(match: m),
          if (pressure != null)
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF1B8),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                pressure,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          for (var t = 0; t < 2; t++)
            Expanded(
              child: _TeamPanel(
                name: m.teamNames[t],
                points: m.points[t],
                color: _teamColors[t],
                serving: m.server == t && !m.isOver,
                onTap: () => _score(t),
              ),
            ),
        ],
      ),
    );
  }
}

class _SetBar extends StatelessWidget {
  const _SetBar({required this.match});

  final ShuttlecockMatch match;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text('Sets  ', style: Theme.of(context).textTheme.labelLarge),
          Text(
            '${match.sets[0]} – ${match.sets[1]}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          Flexible(
            child: Text(
              match.setResults.isEmpty ? '' : match.setResults.join('  ·  '),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamPanel extends StatelessWidget {
  const _TeamPanel({
    required this.name,
    required this.points,
    required this.color,
    required this.serving,
    required this.onTap,
  });

  final String name;
  final int points;
  final Color color;
  final bool serving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Material(
        color: color,
        elevation: 3,
        shadowColor: color,
        borderRadius: BorderRadius.circular(32),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white54,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    FittedBox(
                      child: PopNumber(
                        value: points,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 120,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      'tap to score ✨',
                      style: TextStyle(color: _ink.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              if (serving)
                const Positioned(
                  top: 14,
                  right: 14,
                  child: Chip(
                    avatar: Text('🪶'),
                    label: Text('Serve'),
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    shape: StadiumBorder(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A number that does a little bouncy pop every time it changes.
class PopNumber extends StatelessWidget {
  const PopNumber({super.key, required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.elasticOut,
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: Text('$value', key: ValueKey(value), style: style),
    );
  }
}
