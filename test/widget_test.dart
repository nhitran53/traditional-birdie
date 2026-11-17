import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traditional_birdie/main.dart';
import 'package:traditional_birdie/models/shuttlecock_match.dart';
import 'package:traditional_birdie/models/juggle_session.dart';

ShuttlecockMatch newMatch({int points = 21, int sets = 2, int? cap = 25}) =>
    ShuttlecockMatch(teamNames: ['A', 'B'], pointsPerSet: points, setsToWin: sets, pointCap: cap);

void scoreTimes(ShuttlecockMatch m, int team, int n) {
  for (var i = 0; i < n; i++) {
    m.scorePoint(team);
  }
}

void main() {
  group('ShuttlecockMatch', () {
    test('rally winner scores and serves', () {
      final m = newMatch();
      m.scorePoint(1);
      expect(m.points, [0, 1]);
      expect(m.server, 1);
    });

    test('set needs a 2-point lead', () {
      final m = newMatch();
      scoreTimes(m, 0, 20);
      scoreTimes(m, 1, 20);
      m.scorePoint(0); // 21-20, not over
      expect(m.sets, [0, 0]);
      m.scorePoint(0); // 22-20
      expect(m.sets, [1, 0]);
      expect(m.setResults, ['22–20']);
      expect(m.points, [0, 0]);
    });

    test('point cap ends a deuce', () {
      final m = newMatch();
      for (var i = 0; i < 24; i++) {
        m.scorePoint(0);
        m.scorePoint(1);
      }
      expect(m.points, [24, 24]);
      m.scorePoint(1); // 24-25 hits cap
      expect(m.sets, [0, 1]);
    });

    test('match ends after setsToWin and ignores further points', () {
      final m = newMatch(points: 11);
      scoreTimes(m, 0, 11);
      scoreTimes(m, 0, 11);
      expect(m.winner, 0);
      m.scorePoint(1);
      expect(m.points, [0, 0]);
    });

    test('undo reverts a set-winning point', () {
      final m = newMatch(points: 11);
      scoreTimes(m, 0, 11);
      expect(m.sets, [1, 0]);
      m.undo();
      expect(m.sets, [0, 0]);
      expect(m.points, [10, 0]);
      expect(m.setResults, isEmpty);
    });

    test('pressure label shows set and match point', () {
      final m = newMatch(points: 11);
      scoreTimes(m, 0, 10);
      expect(m.pressureLabel(), 'Set point: A');
      m.scorePoint(0); // A wins set 1
      scoreTimes(m, 1, 10);
      expect(m.pressureLabel(), 'Set point: B');
      scoreTimes(m, 0, 10); // 10-10 deuce: nobody is one rally away
      expect(m.pressureLabel(), isNull);
      m.scorePoint(0); // 11-10
      expect(m.pressureLabel(), 'Match point: A');
    });
  });

  group('JuggleSession', () {
    test('tracks streaks and personal bests', () {
      final s = JuggleSession()
        ..addPlayer('Lan')
        ..addPlayer('Bao');
      for (var i = 0; i < 7; i++) {
        s.kick();
      }
      expect(s.drop(), isTrue);
      s.select(1);
      s.kick();
      s.drop();
      expect(s.leaderboard.map((p) => p.best), [7, 1]);
    });
  });

  testWidgets('home screen shows both modes', (tester) async {
    await tester.pumpWidget(const TraditionalBirdieApp());
    expect(find.text('Match mode'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Start juggling'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Juggling mode'), findsOneWidget);
  });
}
