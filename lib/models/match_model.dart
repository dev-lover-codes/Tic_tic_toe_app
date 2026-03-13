enum MatchStatus { waiting, playing, finished }

class MatchPlayer {
  final String uid;
  final String emoji;
  final String? displayName;

  const MatchPlayer({
    required this.uid,
    required this.emoji,
    this.displayName,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'emoji': emoji,
        'displayName': displayName,
      };

  factory MatchPlayer.fromJson(Map<String, dynamic> json) => MatchPlayer(
        uid: json['uid'] as String,
        emoji: json['emoji'] as String,
        displayName: json['displayName'] as String?,
      );
}

class MatchModel {
  final String matchId;
  final MatchPlayer? player1;
  final MatchPlayer? player2;
  final List<String> board; // 9 cells, '' | playerUid
  final String currentTurnUid; // uid of who plays next
  final MatchStatus status;
  final String? winnerUid; // null = draw or not finished

  const MatchModel({
    required this.matchId,
    this.player1,
    this.player2,
    required this.board,
    required this.currentTurnUid,
    required this.status,
    this.winnerUid,
  });

  MatchModel copyWith({
    MatchPlayer? player1,
    MatchPlayer? player2,
    List<String>? board,
    String? currentTurnUid,
    MatchStatus? status,
    String? winnerUid,
  }) {
    return MatchModel(
      matchId: matchId,
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
      board: board ?? this.board,
      currentTurnUid: currentTurnUid ?? this.currentTurnUid,
      status: status ?? this.status,
      winnerUid: winnerUid ?? this.winnerUid,
    );
  }

  static List<String> emptyBoard() => List.filled(9, '');

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'player1': player1?.toJson(),
        'player2': player2?.toJson(),
        'board': board,
        'currentTurnUid': currentTurnUid,
        'status': status.name,
        'winnerUid': winnerUid,
      };

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
        matchId: json['matchId'] as String,
        player1: json['player1'] != null
            ? MatchPlayer.fromJson(json['player1'] as Map<String, dynamic>)
            : null,
        player2: json['player2'] != null
            ? MatchPlayer.fromJson(json['player2'] as Map<String, dynamic>)
            : null,
        board: List<String>.from(json['board'] as List),
        currentTurnUid: json['currentTurnUid'] as String? ?? '',
        status: MatchStatus.values.byName(json['status'] as String? ?? 'waiting'),
        winnerUid: json['winnerUid'] as String?,
      );
}
