import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/match_model.dart';

class MatchmakingService {
  static const _queueCol = 'matchmaking';
  static const _matchesCol = 'matches';

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // ── Join queue / find a match ────────────────────────────────────────────
  /// Tries to find a waiting opponent. If found, creates a match and returns
  /// its ID. Otherwise, creates a queue entry and returns null (caller
  /// should then listen to the queue entry for a match assignment).
  Future<String> findOrCreateMatch(String myEmoji) async {
    final uid = _uid!;

    // Look for someone waiting (not us)
    final query = await _db
        .collection(_queueCol)
        .where('status', isEqualTo: 'waiting')
        .where('uid', isNotEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // Pair with them
      final opponentDoc = query.docs.first;
      final opponentData = opponentDoc.data();
      final opponentUid = opponentData['uid'] as String;
      final opponentEmoji = opponentData['emoji'] as String;

      final matchRef = _db.collection(_matchesCol).doc();
      final match = MatchModel(
        matchId: matchRef.id,
        player1: MatchPlayer(uid: opponentUid, emoji: opponentEmoji),
        player2: MatchPlayer(uid: uid, emoji: myEmoji),
        board: MatchModel.emptyBoard(),
        currentTurnUid: opponentUid, // opponent goes first
        status: MatchStatus.playing,
      );

      final batch = _db.batch();
      batch.set(matchRef, match.toJson());
      // Update both queue entries
      batch.update(opponentDoc.reference, {
        'status': 'matched',
        'matchId': matchRef.id,
      });
      batch.set(_db.collection(_queueCol).doc(uid), {
        'uid': uid,
        'emoji': myEmoji,
        'status': 'matched',
        'matchId': matchRef.id,
      });
      await batch.commit();
      return matchRef.id;
    } else {
      // Put ourselves in the queue
      await _db.collection(_queueCol).doc(uid).set({
        'uid': uid,
        'emoji': myEmoji,
        'status': 'waiting',
        'matchId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Return empty string – caller polls queue entry for matchId
      return '';
    }
  }

  /// Stream that emits the matchId once we have been paired.
  Stream<String?> watchQueueEntry() {
    final uid = _uid!;
    return _db.collection(_queueCol).doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!;
      if (data['status'] == 'matched') {
        return data['matchId'] as String?;
      }
      return null;
    });
  }

  /// Stream of the live match document.
  Stream<MatchModel> watchMatch(String matchId) {
    return _db.collection(_matchesCol).doc(matchId).snapshots().map(
          (snap) => MatchModel.fromJson(snap.data()!),
        );
  }

  /// Make a move: place myEmoji at boardIndex, check win/draw.
  Future<void> makeMove({
    required String matchId,
    required int boardIndex,
    required MatchPlayer me,
    required MatchPlayer opponent,
    required List<String> currentBoard,
  }) async {
    final newBoard = List<String>.from(currentBoard)..[boardIndex] = me.uid;

    final winner = _checkWinner(newBoard);
    final isDraw = winner == null && !newBoard.contains('');

    final Map<String, dynamic> update = {
      'board': newBoard,
      'currentTurnUid': opponent.uid,
    };

    if (winner != null) {
      update['status'] = MatchStatus.finished.name;
      update['winnerUid'] = me.uid;
    } else if (isDraw) {
      update['status'] = MatchStatus.finished.name;
      update['winnerUid'] = null;
    }

    await _db.collection(_matchesCol).doc(matchId).update(update);
  }

  /// Clean up queue entry (call on cancel or game end).
  Future<void> leaveQueue() async {
    final uid = _uid;
    if (uid != null) {
      await _db.collection(_queueCol).doc(uid).delete();
    }
  }

  static const _lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];

  static String? _checkWinner(List<String> board) {
    for (final line in _lines) {
      final a = board[line[0]], b = board[line[1]], c = board[line[2]];
      if (a.isNotEmpty && a == b && b == c) return a;
    }
    return null;
  }
}
