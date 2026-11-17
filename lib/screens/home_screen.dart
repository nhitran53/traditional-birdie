import 'package:flutter/material.dart';

import '../models/shuttlecock_match.dart';
import 'juggle_screen.dart';
import 'match_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _teamA = TextEditingController(text: 'Pink Team');
  final _teamB = TextEditingController(text: 'Mint Team');
  int _pointsPerSet = 21;
  int _bestOf = 3;

  @override
  void dispose() {
    _teamA.dispose();
    _teamB.dispose();
    super.dispose();
  }

  void _startMatch() {
    String name(TextEditingController c, String fallback) =>
        c.text.trim().isEmpty ? fallback : c.text.trim();

    final match = ShuttlecockMatch(
      teamNames: [name(_teamA, 'Team 1'), name(_teamB, 'Team 2')],
      pointsPerSet: _pointsPerSet,
      setsToWin: (_bestOf + 1) ~/ 2,
      pointCap: _pointsPerSet + 4,
    );
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => MatchScreen(match: match)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Shuttlecock Score')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: BouncingFeather()),
          Text(
            'Traditional shuttlecock kicking',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Text('Match mode', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _teamA,
            decoration: const InputDecoration(
              labelText: 'Team 1',
              prefixIcon: Icon(Icons.circle, color: Color(0xFFFFB5C2)),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _teamB,
            decoration: const InputDecoration(
              labelText: 'Team 2',
              prefixIcon: Icon(Icons.circle, color: Color(0xFFA8E6CF)),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Points per set', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 11, label: Text('11')),
              ButtonSegment(value: 15, label: Text('15')),
              ButtonSegment(value: 21, label: Text('21')),
            ],
            selected: {_pointsPerSet},
            onSelectionChanged: (s) => setState(() => _pointsPerSet = s.first),
          ),
          const SizedBox(height: 12),
          Text('Match length', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('1 set')),
              ButtonSegment(value: 3, label: Text('Best of 3')),
              ButtonSegment(value: 5, label: Text('Best of 5')),
            ],
            selected: {_bestOf},
            onSelectionChanged: (s) => setState(() => _bestOf = s.first),
          ),
          const SizedBox(height: 8),
          Text(
            'Rally scoring · win by 2 · capped at ${_pointsPerSet + 4}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _startMatch,
            icon: const Icon(Icons.sports_volleyball),
            label: const Text('Start match'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const Divider(height: 48),
          Text('Juggling mode', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text(
            'The schoolyard classic: how many kicks in a row before the shuttlecock drops?',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const JuggleScreen())),
            icon: const Icon(Icons.repeat),
            label: const Text('Start juggling'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}

/// The home-screen mascot: a feather that gently floats up and down.
class BouncingFeather extends StatefulWidget {
  const BouncingFeather({super.key});

  @override
  State<BouncingFeather> createState() => _BouncingFeatherState();
}

class _BouncingFeatherState extends State<BouncingFeather>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_c.value);
        return Transform.translate(
          offset: Offset(0, -14 * t),
          child: Transform.rotate(angle: 0.25 * (t - 0.5), child: child),
        );
      },
      child: const Text('🪶', style: TextStyle(fontSize: 72)),
    );
  }
}
