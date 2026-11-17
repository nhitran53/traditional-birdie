/// Traditional schoolyard shuttlecock kicking: count consecutive kicks
/// before the shuttlecock touches the ground.
class JugglePlayer {
  JugglePlayer(this.name);

  final String name;
  int best = 0;
  int attempts = 0;
}

class JuggleSession {
  final List<JugglePlayer> players = [];
  int? activeIndex;
  int streak = 0;

  JugglePlayer? get active =>
      activeIndex == null ? null : players[activeIndex!];

  void addPlayer(String name) {
    players.add(JugglePlayer(name));
    activeIndex ??= 0;
  }

  void select(int index) {
    if (index == activeIndex) return;
    if (streak > 0) drop();
    activeIndex = index;
  }

  void kick() {
    if (active == null) return;
    streak++;
  }

  /// Ends the current streak. Returns true if it set a new personal best.
  bool drop() {
    final p = active;
    if (p == null || streak == 0) return false;
    p.attempts++;
    final isBest = streak > p.best;
    if (isBest) p.best = streak;
    streak = 0;
    return isBest;
  }

  List<JugglePlayer> get leaderboard =>
      [...players]..sort((a, b) => b.best.compareTo(a.best));
}
