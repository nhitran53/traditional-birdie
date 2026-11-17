/// Scoring logic for a competitive shuttlecock-kicking match.
///
/// Rally scoring: whoever wins the rally gets the point and serves next.
/// A set is won by reaching [pointsPerSet] with a 2-point lead, or by
/// reaching [pointCap] first (if a cap is set). First to [setsToWin] sets
/// wins the match.
class ShuttlecockMatch {
  ShuttlecockMatch({
    required this.teamNames,
    this.pointsPerSet = 21,
    this.setsToWin = 2,
    this.pointCap = 25,
  }) : assert(teamNames.length == 2);

  final List<String> teamNames;
  final int pointsPerSet;
  final int setsToWin;
  final int? pointCap;

  List<int> points = [0, 0];
  List<int> sets = [0, 0];

  /// Index of the team that serves next (0 or 1).
  int server = 0;

  /// Final scores of completed sets, e.g. "21–18".
  final List<String> setResults = [];

  /// Index of the winning team, or null while the match is in progress.
  int? winner;

  final List<_Snapshot> _history = [];

  bool get canUndo => _history.isNotEmpty;
  bool get isOver => winner != null;
  int get currentSet => sets[0] + sets[1] + (isOver ? 0 : 1);

  /// Adds a rally point to [team]. Returns true if this point ended a set.
  bool scorePoint(int team) {
    if (isOver) return false;
    _history.add(_Snapshot.of(this));

    points[team]++;
    server = team;

    if (_setWonBy(team)) {
      sets[team]++;
      setResults.add('${points[0]}–${points[1]}');
      points = [0, 0];
      if (sets[team] >= setsToWin) winner = team;
      return true;
    }
    return false;
  }

  bool _setWonBy(int team) {
    final mine = points[team];
    final theirs = points[1 - team];
    if (pointCap != null && mine >= pointCap!) return true;
    return mine >= pointsPerSet && mine - theirs >= 2;
  }

  /// Reverts the most recent point.
  void undo() {
    if (_history.isEmpty) return;
    _history.removeLast().restore(this);
  }

  /// "Set point: X" / "Match point: X" if the next rally could end the set.
  String? pressureLabel() {
    if (isOver) return null;
    for (var t = 0; t < 2; t++) {
      final saved = _Snapshot.of(this);
      points[t]++;
      final wouldWin = _setWonBy(t);
      saved.restore(this);
      if (wouldWin) {
        final label = sets[t] + 1 >= setsToWin ? 'Match point' : 'Set point';
        return '$label: ${teamNames[t]}';
      }
    }
    return null;
  }
}

class _Snapshot {
  _Snapshot.of(ShuttlecockMatch m)
      : points = List.of(m.points),
        sets = List.of(m.sets),
        server = m.server,
        setResultCount = m.setResults.length,
        winner = m.winner;

  final List<int> points;
  final List<int> sets;
  final int server;
  final int setResultCount;
  final int? winner;

  void restore(ShuttlecockMatch m) {
    m.points = List.of(points);
    m.sets = List.of(sets);
    m.server = server;
    m.setResults.removeRange(setResultCount, m.setResults.length);
    m.winner = winner;
  }
}
