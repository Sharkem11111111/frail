import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChessPuzzle {
  final String fen;
  final List<String> moves;
  final String theme;
  final int difficulty;
  final String sideToMove; // 'w' for white, 'b' for black

  ChessPuzzle({
    required this.fen,
    required this.moves,
    required this.theme,
    required this.difficulty,
    required this.sideToMove,
  });
}

class ChessPuzzleDatabase {
  static List<ChessPuzzle> getPuzzles() {
    return [
      // White to move puzzles
      ChessPuzzle(
        fen: "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2",
        moves: ["d4", "exd4", "Qxd4"],
        theme: "Center Control",
        difficulty: 1,
        sideToMove: 'w',
      ),
      ChessPuzzle(
        fen: "rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 2",
        moves: ["exd5", "Qxd5", "Nc3"],
        theme: "Queen Development",
        difficulty: 1,
        sideToMove: 'w',
      ),
      ChessPuzzle(
        fen: "rnbqkb1r/pppp1ppp/5n2/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3",
        moves: ["Nc3", "Bb4", "Nd5"],
        theme: "Knight Fork",
        difficulty: 2,
        sideToMove: 'w',
      ),
      // Black to move puzzle
      ChessPuzzle(
        fen: "r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 4",
        moves: ["d6", "Qh5", "g6"],
        theme: "Defense against attack",
        difficulty: 2,
        sideToMove: 'b',
      ),
      ChessPuzzle(
        fen: "rnbqkbnr/pppp1ppp/8/4p3/3PP3/8/PPP2PPP/RNBQKBNR w KQkq e6 0 3",
        moves: ["Nf3", "Nc6", "Bb5"],
        theme: "Spanish Opening",
        difficulty: 1,
        sideToMove: 'w',
      ),
    ];
  }
}

class ChessPuzzleGame extends StatefulWidget {
  final int timeRemaining;
  final VoidCallback onFinishRest;

  const ChessPuzzleGame({
    super.key,
    required this.timeRemaining,
    required this.onFinishRest,
  });

  @override
  State<ChessPuzzleGame> createState() => _ChessPuzzleGameState();
}

class _ChessPuzzleGameState extends State<ChessPuzzleGame> {
  // Progressive puzzle system
  List<ChessPuzzle> puzzles = [];
  bool isLoadingPuzzles = false;
  int currentPuzzleIndex = 0;
  int userRating = 1200;
  int totalPuzzlesSolved = 0;
  String loadingMessage = "Loading your personalized puzzles...";
  String puzzleSource = "📚 Offline"; // Track current puzzle source
  int totalLichessPuzzles = 0; // Track total Lichess puzzles loaded
  
  // Current puzzle state
  ChessPuzzle? currentPuzzle;
  int currentMoveIndex = 0;
  int puzzlesSolved = 0;
  bool showSolution = false;
  bool puzzleCompleted = false;
  List<List<String>> board = [];
  String selectedSquare = '';
  String currentPlayer = 'w';
  List<String> possibleMoves = [];

  @override
  void initState() {
    super.initState();
    _initializePuzzles();
  }

  Future<void> _initializePuzzles() async {
    try {
      // Load user stats
      final stats = await UserProgressService.getUserStats();
      setState(() {
        userRating = stats['rating'];
        totalPuzzlesSolved = stats['solved'];
      });

      // Try to fetch progressive puzzles
      setState(() {
        isLoadingPuzzles = true;
        loadingMessage = "🌐 Connecting to Lichess (rating $userRating)...";
      });

      final result = await LichessPuzzleService.fetchPuzzles(
        rating: userRating,
        count: 15, // Get more puzzles initially
      );

      setState(() {
        puzzles = result['puzzles'];
        isLoadingPuzzles = false;
        
        // Enhanced source display with clearer feedback
        final lichessCount = (result['lichessCount'] ?? 0) as int;
        final totalPuzzles = puzzles.length;
        totalLichessPuzzles = lichessCount;
        
        if (lichessCount > 0) {
          puzzleSource = "🌐 Mixed Puzzles";
          loadingMessage = "✅ Loaded: $lichessCount Lichess + ${totalPuzzles - lichessCount} enhanced offline";
        } else {
          puzzleSource = "📚 Offline Puzzles";
          loadingMessage = "✅ Loaded $totalPuzzles high-quality offline puzzles";
        }
      });

      if (puzzles.isNotEmpty) {
    _loadNextPuzzle();
      }
      
      // Show source message briefly
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            loadingMessage = "Ready to play!";
          });
        }
      });
    } catch (e) {
      // Fallback to local puzzles
      setState(() {
        puzzles = ChessPuzzleDatabase.getPuzzles();
        isLoadingPuzzles = false;
        loadingMessage = "📚 Using offline puzzles";
      });
      _loadNextPuzzle();
    }
  }

  void _loadNextPuzzle() {
    if (puzzles.isEmpty) {
      puzzles = ChessPuzzleDatabase.getPuzzles();
    }
    
    currentPuzzle = puzzles[currentPuzzleIndex % puzzles.length];
    _parseFEN(currentPuzzle!.fen);
    
    setState(() {
      currentMoveIndex = 0;
      showSolution = false;
      puzzleCompleted = false;
      selectedSquare = '';
      possibleMoves.clear();
      currentPlayer = currentPuzzle!.sideToMove;
    });
    
    // If player is Black, computer (White) should move first
    if (currentPuzzle!.sideToMove == 'b') {
      // Add a small delay so the board renders first, then computer moves
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Temporarily set currentPlayer to 'w' so the opponent move logic triggers
          setState(() {
            currentPlayer = 'w';
          });
          _playOpponentMoveIfNeeded();
        }
      });
    }
  }

  void _parseFEN(String fen) {
    board = List.generate(8, (_) => List.filled(8, ''));
    final fenParts = fen.split(' ');
    final position = fenParts[0];
    final ranks = position.split('/');
    
    // Parse the board position
    for (int rank = 0; rank < 8; rank++) {
      int file = 0;
      for (int i = 0; i < ranks[rank].length; i++) {
        final char = ranks[rank][i];
        if (char.contains(RegExp(r'[1-8]'))) {
          file += int.parse(char);
        } else {
          board[rank][file] = char;
          file++;
        }
      }
    }
    
    // Parse side to move (if available in FEN)
    if (fenParts.length > 1) {
      currentPlayer = fenParts[1]; // 'w' or 'b'
    }
  }

  void _nextPuzzle() async {
    if (puzzleCompleted && currentPuzzle != null) {
      // Update user rating based on performance
      await UserProgressService.updateRatingAfterPuzzle(
        solved: true,
        puzzleRating: currentPuzzle!.difficulty,
      );
      
      // Update display stats
      final newStats = await UserProgressService.getUserStats();
    setState(() {
        userRating = newStats['rating'];
        totalPuzzlesSolved = newStats['solved'];
        currentPuzzleIndex++;
        
        // Load more puzzles if needed
        if (currentPuzzleIndex >= puzzles.length - 2) {
          _loadMorePuzzles();
        }
      });
      
      _loadNextPuzzle();
    }
  }

  Future<void> _loadMorePuzzles() async {
    bool lichessSuccess = false;
    
    try {
      setState(() {
        loadingMessage = "🌐 Fetching more Lichess puzzles...";
      });
      
      // Try Lichess first with retry mechanism
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          final result = await LichessPuzzleService.fetchPuzzles(
            rating: userRating,
            count: 10,
          );
          
          final lichessCount = (result['lichessCount'] ?? 0) as int;
          if (lichessCount > 0) {
            setState(() {
              puzzles.addAll(result['puzzles']);
              totalLichessPuzzles += lichessCount;
              puzzleSource = "🌐 Mixed Puzzles";
              loadingMessage = "✅ Added ${result['puzzles'].length} more puzzles ($lichessCount from Lichess)";
            });
            lichessSuccess = true;
            break;
          }
        } catch (e) {
          print('Lichess attempt $attempt failed: $e');
          if (attempt < 2) {
            setState(() {
              loadingMessage = "🔄 Lichess attempt $attempt failed, retrying...";
            });
            await Future.delayed(const Duration(seconds: 2)); // Wait between retries
          }
        }
      }
      
      // If Lichess failed, use enhanced offline puzzles
      if (!lichessSuccess) {
        setState(() {
          loadingMessage = "📚 Lichess unavailable, adding offline puzzles...";
        });
        
        // Add high-quality offline puzzles
        final offlinePuzzles = ChessPuzzleDatabase.getPuzzles();
        setState(() {
          puzzles.addAll(offlinePuzzles);
          loadingMessage = "✅ Added ${offlinePuzzles.length} offline puzzles";
        });
      }
      
      // Clear loading message after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            loadingMessage = "";
          });
        }
      });
      
    } catch (e) {
      print('Error in _loadMorePuzzles: $e');
      // Final fallback
      setState(() {
        puzzles.addAll(ChessPuzzleDatabase.getPuzzles());
        loadingMessage = "Added fallback puzzles";
      });
    }
  }

  void _showSolution() {
    setState(() {
      showSolution = true;
    });
  }



  void _skipPuzzle() async {
    if (currentPuzzle != null) {
      // Update user rating based on skipping (small penalty)
      await UserProgressService.updateRatingAfterPuzzle(
        solved: false,
        puzzleRating: currentPuzzle!.difficulty,
        isSkipped: true,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.skip_next, color: Colors.orange),
                SizedBox(width: 8),
                Text('Puzzle skipped (-3 rating)'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      currentPuzzleIndex++;
      
      // Load more puzzles if needed
      if (currentPuzzleIndex >= puzzles.length - 2) {
        _loadMorePuzzles();
      }
      
      _loadNextPuzzle();
    }
  }

  void _onSquareTapped(int rank, int file) {
    final square = '${String.fromCharCode(97 + file)}${8 - rank}';
    final piece = board[rank][file];
    
    setState(() {
      if (selectedSquare.isEmpty && piece.isNotEmpty) {
        // Check if it's the correct color to move
        final isWhite = piece == piece.toUpperCase();
        final correctColor = (currentPlayer == 'w' && isWhite) || (currentPlayer == 'b' && !isWhite);
        
        if (!correctColor) {
          final colorName = currentPlayer == 'w' ? 'white' : 'black';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('It\'s $colorName to move!'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 1),
              ),
            );
          }
          return;
        }
        
        selectedSquare = square;
        _generatePossibleMoves(rank, file); // Show all legal moves for this piece
      } else if (selectedSquare.isNotEmpty && selectedSquare != square) {
          _makeMove(selectedSquare, square);
        selectedSquare = '';
        possibleMoves.clear();
      } else {
        selectedSquare = '';
        possibleMoves.clear();
      }
    });
  }

  bool _isValidMove(String from, String to) {
    // Only allow the exact move that's next in the solution
    if (currentPuzzle == null || currentMoveIndex >= currentPuzzle!.moves.length) {
      return false;
    }
    
    final expectedMove = currentPuzzle!.moves[currentMoveIndex];
    final actualMove = _convertToAlgebraicNotation(from, to);
    
    // Try multiple comparison methods since chess notation can vary
    return actualMove == expectedMove || 
           _isSimpleNotationMatch(from, to, expectedMove) ||
           _isCoordinateNotationMatch(from, to, expectedMove);
  }
  
  bool _isSimpleNotationMatch(String from, String to, String expectedMove) {
    // Handle simple notation like "f3", "Nf3", "exd4"
    if (expectedMove == to) return true; // Simple destination match
    
    // Handle pawn moves (no piece prefix)
    if (expectedMove.length == 2 && expectedMove == to) return true;
    
    // Handle piece moves with just destination
    final fromFile = from.codeUnitAt(0) - 97;
    final fromRank = int.parse(from[1]) - 1;
    final boardFromRank = 8 - fromRank - 1;
    final piece = board[boardFromRank][fromFile].toLowerCase();
    
    if (piece != 'p' && expectedMove.length >= 3) {
      final expectedPiece = expectedMove[0].toLowerCase();
      final expectedDest = expectedMove.substring(expectedMove.length - 2);
      return piece == expectedPiece && to == expectedDest;
    }
    
    return false;
  }
  
  bool _isCoordinateNotationMatch(String from, String to, String expectedMove) {
    // Handle coordinate notation like "e2e4"
    final coordinate = from + to;
    return coordinate == expectedMove;
  }

  void _makeMove(String from, String to) {
    // Check if this is the correct move
    if (_isValidMove(from, to)) {
      final fromFile = from.codeUnitAt(0) - 97;
      final toFile = to.codeUnitAt(0) - 97;
      
      // Convert board coordinates (0-7) to chess coordinates (1-8 for ranks)
      final boardFromRank = 8 - int.parse(from[1]);
      final boardToRank = 8 - int.parse(to[1]);
      
      final piece = board[boardFromRank][fromFile];
      
      setState(() {
        // Actually move the piece on the board
        board[boardToRank][toFile] = piece;
        board[boardFromRank][fromFile] = '';
        
        currentMoveIndex++;
        
        // Check if puzzle is solved
        if (currentPuzzle != null && currentMoveIndex >= currentPuzzle!.moves.length) {
          puzzleCompleted = true;
          
          final ratingGain = currentPuzzle!.difficulty > userRating ? 15 : 8;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('Puzzle solved! 🎉 (+$ratingGain rating)'),
                  ],
                ),
                backgroundColor: Colors.green.shade800,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Switch to opponent's turn and play their move
          currentPlayer = currentPlayer == 'w' ? 'b' : 'w';
          _playOpponentMoveIfNeeded();
        }
      });
    } else {
      // Wrong move - show feedback and reset puzzle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect move! Expected: ${currentPuzzle?.moves[currentMoveIndex] ?? 'unknown'}. Resetting puzzle...'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      
      Future.delayed(const Duration(seconds: 1), () {
        _resetPuzzle();
      });
    }
  }

  void _resetPuzzle() {
    if (currentPuzzle == null) return;
    
    setState(() {
      _parseFEN(currentPuzzle!.fen);
      currentMoveIndex = 0;
      selectedSquare = '';
    possibleMoves.clear();
      currentPlayer = currentPuzzle!.sideToMove;
    });
    
    // If player is Black, computer (White) should move first after reset
    if (currentPuzzle!.sideToMove == 'b') {
      // Add a small delay so the board renders first, then computer moves
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Temporarily set currentPlayer to 'w' so the opponent move logic triggers
          setState(() {
            currentPlayer = 'w';
          });
          _playOpponentMoveIfNeeded();
        }
      });
    }
  }
  
  void _playOpponentMoveIfNeeded() {
    // Check if there's another move in the solution and if it's the opponent's turn
    if (currentPuzzle != null && 
        currentMoveIndex < currentPuzzle!.moves.length && 
        currentPlayer != currentPuzzle!.sideToMove) {
      
      // Delay the opponent move to make it feel natural
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && currentPuzzle != null && currentMoveIndex < currentPuzzle!.moves.length) {
          final opponentMove = currentPuzzle!.moves[currentMoveIndex];
          
          // Parse and execute the opponent's move on the board
          final moveCoords = _parseOpponentMove(opponentMove);
          if (moveCoords != null) {
            final fromFile = moveCoords['from']!.codeUnitAt(0) - 97;
            final toFile = moveCoords['to']!.codeUnitAt(0) - 97;
            final boardFromRank = 8 - int.parse(moveCoords['from']![1]);
            final boardToRank = 8 - int.parse(moveCoords['to']![1]);
            
            setState(() {
              // Actually move the opponent's piece on the board
              final piece = board[boardFromRank][fromFile];
              board[boardToRank][toFile] = piece;
              board[boardFromRank][fromFile] = '';
              
              currentMoveIndex++;
              currentPlayer = currentPlayer == 'w' ? 'b' : 'w';
            });
          } else {
            // Fallback: just increment if we can't parse the move
            setState(() {
              currentMoveIndex++;
              currentPlayer = currentPlayer == 'w' ? 'b' : 'w';
            });
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opponent plays: $opponentMove'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      });
    }
  }

  // Parse opponent moves to find from/to coordinates
  Map<String, String>? _parseOpponentMove(String move) {
    // Remove check/checkmate symbols
    final cleanMove = move.replaceAll(RegExp(r'[+#]'), '');
    
    // Handle simple pawn moves like "exd4"
    if (cleanMove.contains('x') && cleanMove.length <= 4) {
      final parts = cleanMove.split('x');
      if (parts.length == 2 && parts[0].length == 1) {
        // Pawn capture like "exd4"
        final fromFile = parts[0];
        final to = parts[1];
        return _findPawnCapture(fromFile, to);
      }
    }
    
    // Handle simple destination moves like "d4"
    if (cleanMove.length == 2 && RegExp(r'^[a-h][1-8]$').hasMatch(cleanMove)) {
      return _findPawnMove(cleanMove);
    }
    
    return null;
  }

  Map<String, String>? _findPawnCapture(String fromFile, String to) {
    final fromFileIndex = fromFile.codeUnitAt(0) - 97;
    final toFile = to.codeUnitAt(0) - 97;
    final toRank = int.parse(to[1]) - 1;
    final boardToRank = 8 - toRank - 1;
    
    // Check for pawn one square back and one file different
    final direction = currentPlayer == 'w' ? 1 : -1;
    final fromBoardRank = boardToRank + direction;
    
    if (fromBoardRank >= 0 && fromBoardRank < 8) {
      final piece = board[fromBoardRank][fromFileIndex];
      if (piece.toLowerCase() == 'p' && 
          ((currentPlayer == 'w' && piece == piece.toUpperCase()) ||
           (currentPlayer == 'b' && piece == piece.toLowerCase()))) {
        final fromRank = 8 - fromBoardRank;
        final from = '${String.fromCharCode(97 + fromFileIndex)}$fromRank';
        return {'from': from, 'to': to};
      }
    }
    
    return null;
  }

  Map<String, String>? _findPawnMove(String to) {
    final toFile = to.codeUnitAt(0) - 97;
    final toRank = int.parse(to[1]) - 1;
    final boardToRank = 8 - toRank - 1;
    
    // Check for pawn one square back
    final direction = currentPlayer == 'w' ? 1 : -1;
    final fromBoardRank = boardToRank + direction;
    
    if (fromBoardRank >= 0 && fromBoardRank < 8) {
      final piece = board[fromBoardRank][toFile];
      if (piece.toLowerCase() == 'p' && 
          ((currentPlayer == 'w' && piece == piece.toUpperCase()) ||
           (currentPlayer == 'b' && piece == piece.toLowerCase()))) {
        final fromRank = 8 - fromBoardRank;
        final from = '${String.fromCharCode(97 + toFile)}$fromRank';
        return {'from': from, 'to': to};
      }
    }
    
    return null;
  }

  // Generate possible moves for a selected piece to show visual indicators
  void _generatePossibleMoves(int rank, int file) {
    possibleMoves.clear();
    final piece = board[rank][file].toLowerCase();
    final isWhite = board[rank][file] == board[rank][file].toUpperCase();
    
    switch (piece) {
      case 'p':
        _generatePawnMoves(rank, file, isWhite);
        break;
      case 'r':
        _generateRookMoves(rank, file, isWhite);
        break;
      case 'n':
        _generateKnightMoves(rank, file, isWhite);
        break;
      case 'b':
        _generateBishopMoves(rank, file, isWhite);
        break;
      case 'q':
        _generateQueenMoves(rank, file, isWhite);
        break;
      case 'k':
        _generateKingMoves(rank, file, isWhite);
        break;
    }
  }
  
  void _generatePawnMoves(int rank, int file, bool isWhite) {
    final direction = isWhite ? -1 : 1; // White moves up (decreasing rank)
    final newRank = rank + direction;
    
    if (newRank >= 0 && newRank < 8) {
      // Forward move
      if (board[newRank][file].isEmpty) {
        _addMove(newRank, file);
        
        // Double move from starting position
        if ((isWhite && rank == 6) || (!isWhite && rank == 1)) {
          final doubleRank = rank + (direction * 2);
          if (doubleRank >= 0 && doubleRank < 8 && board[doubleRank][file].isEmpty) {
            _addMove(doubleRank, file);
          }
        }
      }
      
      // Diagonal captures
      if (file > 0 && board[newRank][file - 1].isNotEmpty && 
          _isOpponentPiece(board[newRank][file - 1], isWhite)) {
        _addMove(newRank, file - 1);
      }
      if (file < 7 && board[newRank][file + 1].isNotEmpty && 
          _isOpponentPiece(board[newRank][file + 1], isWhite)) {
        _addMove(newRank, file + 1);
      }
    }
  }

  void _generateRookMoves(int rank, int file, bool isWhite) {
    // Horizontal and vertical directions
    final directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1] // up, down, left, right
    ];
    
    for (final dir in directions) {
      for (int i = 1; i < 8; i++) {
        final newRank = rank + dir[0] * i;
        final newFile = file + dir[1] * i;
        
        if (newRank < 0 || newRank >= 8 || newFile < 0 || newFile >= 8) break;
        
        final targetPiece = board[newRank][newFile];
        if (targetPiece.isEmpty) {
          _addMove(newRank, newFile);
        } else {
          if (_isOpponentPiece(targetPiece, isWhite)) {
            _addMove(newRank, newFile);
          }
          break; // Can't continue past any piece
        }
      }
    }
  }

  void _generateKnightMoves(int rank, int file, bool isWhite) {
    final knightMoves = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];
    
    for (final move in knightMoves) {
      final newRank = rank + move[0];
      final newFile = file + move[1];
      
      if (newRank >= 0 && newRank < 8 && newFile >= 0 && newFile < 8) {
        final targetPiece = board[newRank][newFile];
        if (targetPiece.isEmpty || _isOpponentPiece(targetPiece, isWhite)) {
          _addMove(newRank, newFile);
        }
      }
    }
  }

  void _generateBishopMoves(int rank, int file, bool isWhite) {
    // Diagonal directions
    final directions = [
      [-1, -1], [-1, 1], [1, -1], [1, 1] // up-left, up-right, down-left, down-right
    ];
    
    for (final dir in directions) {
    for (int i = 1; i < 8; i++) {
        final newRank = rank + dir[0] * i;
        final newFile = file + dir[1] * i;
        
        if (newRank < 0 || newRank >= 8 || newFile < 0 || newFile >= 8) break;
        
        final targetPiece = board[newRank][newFile];
        if (targetPiece.isEmpty) {
          _addMove(newRank, newFile);
        } else {
          if (_isOpponentPiece(targetPiece, isWhite)) {
            _addMove(newRank, newFile);
          }
          break; // Can't continue past any piece
        }
      }
    }
  }

  void _generateQueenMoves(int rank, int file, bool isWhite) {
    _generateRookMoves(rank, file, isWhite);
    _generateBishopMoves(rank, file, isWhite);
  }

  void _generateKingMoves(int rank, int file, bool isWhite) {
    for (int dr = -1; dr <= 1; dr++) {
      for (int df = -1; df <= 1; df++) {
        if (dr == 0 && df == 0) continue;
        final newRank = rank + dr;
        final newFile = file + df;
        
        if (newRank >= 0 && newRank < 8 && newFile >= 0 && newFile < 8) {
          final targetPiece = board[newRank][newFile];
          if (targetPiece.isEmpty || _isOpponentPiece(targetPiece, isWhite)) {
            _addMove(newRank, newFile);
          }
        }
      }
    }
  }

  bool _isOpponentPiece(String piece, bool isWhite) {
    if (piece.isEmpty) return false;
    final pieceIsWhite = piece == piece.toUpperCase();
    return pieceIsWhite != isWhite;
  }

  void _addMove(int rank, int file) {
    final chessRank = 8 - rank;
    final square = '${String.fromCharCode(97 + file)}$chessRank';
    possibleMoves.add(square);
  }

  String _convertToAlgebraicNotation(String from, String to) {
    final fromFile = from.codeUnitAt(0) - 97;
    final toFile = to.codeUnitAt(0) - 97;
    final fromRank = int.parse(from[1]) - 1;
    final toRank = int.parse(to[1]) - 1;
    
    final boardFromRank = 8 - fromRank - 1;
    final piece = board[boardFromRank][fromFile];
    
    if (piece.isEmpty) return '';
    
    final pieceType = piece.toLowerCase();
    String moveNotation = '';
    
    // Add piece prefix (except for pawns)
    if (pieceType != 'p') {
      moveNotation += piece.toUpperCase();
    }
    
    // Check for capture
    final boardToRank = 8 - toRank - 1;
    final targetPiece = board[boardToRank][toFile];
    
    if (targetPiece.isNotEmpty) {
      // Capture
      if (pieceType == 'p') {
        moveNotation += from[0]; // Add file for pawn captures
      }
      moveNotation += 'x';
    }
    
    // Add destination square
    moveNotation += to;
    
    return moveNotation;
  }

  Color _getSquareColor(int rank, int file) {
    final isLight = (rank + file) % 2 == 0;
    return isLight ? const Color(0xFFECEFF1) : const Color(0xFF90A4AE);
  }

  String _getPieceSymbol(String piece) {
    const symbols = {
      'K': '♔', 'Q': '♕', 'R': '♖', 'B': '♗', 'N': '♘', 'P': '♙',
      'k': '♚', 'q': '♛', 'r': '♜', 'b': '♝', 'n': '♞', 'p': '♟',
    };
    return symbols[piece] ?? '';
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingPuzzles || currentPuzzle == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.purple),
            const SizedBox(height: 16),
            Text(
              loadingMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Rating', userRating.toString(), Colors.purple),
                  _buildStatCard('Solved', totalPuzzlesSolved.toString(), Colors.green),
                  _buildStatCard('Difficulty', currentPuzzle?.difficulty.toString() ?? '-', Colors.orange),
                  _buildStatCard('Theme', currentPuzzle?.theme ?? '-', Colors.blue),
                ],
              ),
              const SizedBox(height: 8),
              // Puzzle source indicator (persistent)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    puzzleSource.contains('Mixed') ? Icons.language : Icons.storage,
                    size: 16,
                    color: puzzleSource.contains('Mixed') ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    puzzleSource,
                    style: TextStyle(
                      fontSize: 12,
                      color: puzzleSource.contains('Mixed') ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (totalLichessPuzzles > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        '$totalLichessPuzzles Lichess',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: puzzles.isNotEmpty ? (currentPuzzleIndex + 1) / puzzles.length : 0,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
              const SizedBox(height: 4),
              Text(
                puzzles.isNotEmpty ? 'Puzzle ${currentPuzzleIndex + 1} of ${puzzles.length}' : 'Loading puzzles...',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),

        Column(
          children: [
        Text(
              'Progressive Chess Training',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${currentPlayer == 'w' ? 'White' : 'Black'} to move',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: currentPlayer == 'w' ? Colors.white : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),

        const SizedBox(height: 16),

        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF263238), width: 4),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 64,
                  itemBuilder: (context, index) {
                    final rank = index ~/ 8;
                    final file = index % 8;
                    final piece = board[rank][file];
                    final square = '${String.fromCharCode(97 + file)}${8 - rank}';
                    final isSelected = selectedSquare == square;
                    final isPossibleMove = possibleMoves.contains(square);
                    
                    return GestureDetector(
                      onTap: () => _onSquareTapped(rank, file),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getSquareColor(rank, file),
                          border: isSelected 
                            ? Border.all(color: const Color(0xFF2E7D32), width: 3)
                            : null,
                        ),
                        child: Stack(
                          children: [
                            // Coordinate labels in corners
                            if (file == 0) // Show rank on left edge
                              Positioned(
                                top: 2,
                                left: 2,
                                child: Text(
                                  '${8 - rank}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: (rank + file) % 2 == 0 
                                      ? const Color(0xFF607D8B)
                                      : Colors.white70,
                                  ),
                                ),
                              ),
                            if (rank == 7) // Show file on bottom edge
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Text(
                                  String.fromCharCode(97 + file),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: (rank + file) % 2 == 0 
                                      ? const Color(0xFF607D8B)
                                      : Colors.white70,
                                  ),
                                ),
                              ),
                            // Move indicators
                            if (isPossibleMove && piece.isEmpty)
                              Center(
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            if (isPossibleMove && piece.isNotEmpty)
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF4CAF50),
                                      width: 4,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            // Chess pieces
                            if (piece.isNotEmpty)
                              Center(
                                child: Text(
                                  _getPieceSymbol(piece),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: (piece == piece.toUpperCase()) 
                                      ? Colors.white 
                                      : const Color(0xFF212121),
                                    shadows: (piece == piece.toUpperCase()) ? [
                                      const Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 4,
                                        color: Colors.black87,
                                      ),
                                    ] : [
                                      const Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.white60,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        if (showSolution) ...[
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solution:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentPuzzle?.moves.join(' → ') ?? 'Loading...',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],

        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton.icon(
                        onPressed: _resetPuzzle,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reset', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                  ),
              Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton.icon(
                        onPressed: _skipPuzzle,
                        icon: const Icon(Icons.skip_previous, size: 18),
                        label: const Text('Skip', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton.icon(
                        onPressed: puzzleCompleted ? _nextPuzzle : null,
                        icon: const Icon(Icons.skip_next, size: 18),
                        label: const Text('Next', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                          backgroundColor: puzzleCompleted ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton.icon(
                        onPressed: showSolution ? null : _showSolution,
                        icon: const Icon(Icons.lightbulb, size: 18),
                        label: const Text('Solution', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: showSolution ? Colors.grey : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
            ),
          ),
        ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Add Lichess puzzle service
class LichessPuzzleService {
  static const String baseUrl = 'https://lichess.org/api';
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'FrailApp/1.0'
  };

  static Future<Map<String, dynamic>> fetchPuzzles({
    int rating = 1500,
    int count = 5,
    List<String> themes = const [],
  }) async {
    try {
      List<ChessPuzzle> lichessPuzzles = [];
      int successfulFetches = 0;
      int maxLichessAttempts = 1; // Start with just 1 attempt to test the endpoints
      
      print('🌐 Testing Lichess API endpoints for rating $rating');
      
      // Try to fetch real Lichess puzzles with improved endpoint testing
      for (int i = 0; i < maxLichessAttempts; i++) {
        try {
          final puzzle = await _fetchSinglePuzzle(rating);
          if (puzzle != null) {
            lichessPuzzles.add(puzzle);
            successfulFetches++;
            print('✅ Successfully fetched Lichess puzzle ${i + 1}/${maxLichessAttempts}');
            break; // Stop after first successful fetch to be respectful
          } else {
            print('❌ All Lichess endpoints failed for attempt ${i + 1}/${maxLichessAttempts}');
          }
        } catch (e) {
          print('❌ Error fetching Lichess puzzle ${i + 1}/${maxLichessAttempts}: $e');
        }
        
        // Longer delay between requests to respect rate limits
        if (i < maxLichessAttempts - 1) {
          await Future.delayed(const Duration(milliseconds: 2000));
        }
      }
      
      // Get high-quality fallback puzzles
      final fallbackPuzzles = _getFallbackPuzzles(rating);
      
      if (lichessPuzzles.isNotEmpty) {
        // Mix real Lichess puzzles with fallback puzzles
        List<ChessPuzzle> allPuzzles = [...lichessPuzzles, ...fallbackPuzzles];
        
        print('🎯 Returning ${allPuzzles.length} puzzles ($successfulFetches from Lichess, ${fallbackPuzzles.length} fallback)');
        
        return {
          'puzzles': allPuzzles.take(count).toList(),
          'isLichess': true,
          'lichessCount': successfulFetches,
        };
      } else {
        // No Lichess puzzles available, use enhanced fallback
        print('📚 No Lichess puzzles available, using ${fallbackPuzzles.length} fallback puzzles');
        
        return {
          'puzzles': fallbackPuzzles.take(count).toList(),
          'isLichess': false,
          'lichessCount': 0,
        };
      }
    } catch (e) {
      print('💥 Lichess service error: $e');
      // Return fallback puzzles if API fails
      final fallbackPuzzles = _getFallbackPuzzles(rating);
      return {
        'puzzles': fallbackPuzzles.take(count).toList(),
        'isLichess': false,
        'lichessCount': 0,
      };
    }
  }

  static Future<ChessPuzzle?> _fetchSinglePuzzle(int targetRating) async {
    // Try multiple Lichess API endpoints
    final endpoints = [
      '/api/puzzle/daily',  // Daily puzzle endpoint
      '/api/puzzle',        // Standard puzzle endpoint 
    ];
    
    for (String endpoint in endpoints) {
      try {
        print('🔄 Calling Lichess API: $baseUrl$endpoint');
        
        final response = await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
        ).timeout(const Duration(seconds: 15));

        print('📡 Lichess API response: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('🔍 Raw Lichess response: ${data.toString().substring(0, 200)}...');
          
          final puzzle = _parseLichessPuzzle(data);
          if (puzzle != null) {
            print('✅ Successfully parsed Lichess puzzle from $endpoint (${puzzle.difficulty} rating, ${puzzle.theme})');
            return puzzle;
          } else {
            print('❌ Failed to parse valid puzzle from $endpoint');
          }
        } else if (response.statusCode == 429) {
          print('⚠️ Lichess rate limit hit (429) on $endpoint - will retry later');
          await Future.delayed(const Duration(seconds: 5));
        } else {
          print('❌ Lichess API error on $endpoint: ${response.statusCode}');
          if (response.body.length < 500) {
            print('Response body: ${response.body}');
          }
        }
      } catch (e) {
        print('💥 Lichess API exception on $endpoint: $e');
      }
      
      // Small delay between different endpoint attempts
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return null;
  }

  static ChessPuzzle? _parseLichessPuzzle(Map<String, dynamic> data) {
    try {
      // Handle different response formats from different endpoints
      Map<String, dynamic>? puzzle;
      Map<String, dynamic>? game;
      
      // Check if this is a standard puzzle response
      if (data.containsKey('puzzle') && data.containsKey('game')) {
        puzzle = data['puzzle'];
        game = data['game'];
      }
      // Check if this is a daily puzzle response or direct puzzle data
      else if (data.containsKey('id') && data.containsKey('fen')) {
        puzzle = data;
        game = data;
      }
      // Check if puzzle data is nested differently
      else if (data.containsKey('data')) {
        final nestedData = data['data'];
        if (nestedData is Map<String, dynamic>) {
          puzzle = nestedData['puzzle'] ?? nestedData;
          game = nestedData['game'] ?? nestedData;
        }
      }
      
      if (puzzle == null) {
        print('❌ No puzzle data found in response');
        return null;
      }
      
      // Extract FEN position
      String fen = puzzle['fen'] ?? game?['fen'] ?? "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
      
      // Extract solution moves
      List<String> moves = [];
      if (puzzle['solution'] != null) {
        moves = List<String>.from(puzzle['solution']);
      } else if (puzzle['moves'] != null) {
        moves = List<String>.from(puzzle['moves']);
      }
      
      // Extract rating/difficulty
      int difficulty = puzzle['rating'] ?? puzzle['difficulty'] ?? 1500;
      
      // Extract themes
      String theme = 'tactics';
      if (puzzle['themes'] is List) {
        theme = (puzzle['themes'] as List).join(', ');
      } else if (puzzle['theme'] is String) {
        theme = puzzle['theme'];
      } else if (puzzle['tags'] is List) {
        theme = (puzzle['tags'] as List).join(', ');
      }
      
      if (moves.isEmpty) {
        print('❌ No solution moves found in puzzle');
        return null;
      }
      
      print('✅ Parsed puzzle: FEN=$fen, Moves=${moves.join(" ")}, Rating=$difficulty, Theme=$theme');
      
      return ChessPuzzle(
        fen: fen,
        moves: moves,
        difficulty: difficulty,
        theme: theme,
        sideToMove: _getSideToMoveFromFen(fen),
      );
    } catch (e) {
      print('❌ Error parsing Lichess puzzle: $e');
      return null;
    }
  }
  
  static String _getSideToMoveFromFen(String fen) {
    try {
      return fen.split(' ')[1];
    } catch (e) {
      return 'w';
    }
  }

  static List<ChessPuzzle> _getFallbackPuzzles(int rating) {
    // Enhanced fallback puzzles with progressive difficulty
    final puzzles = <ChessPuzzle>[];
    
    if (rating < 1200) {
      // Beginner puzzles
      puzzles.addAll([
        ChessPuzzle(
          fen: 'r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/3P1N2/PPP2PPP/RNBQK2R b KQkq - 0 4',
          moves: ['f6d5', 'c4f7'],
          difficulty: 800,
          theme: 'fork',
          sideToMove: 'b',
        ),
        ChessPuzzle(
          fen: 'rnbqkbnr/ppp2ppp/4p3/3p4/2PP4/8/PP2PPPP/RNBQKBNR b KQkq c3 0 3',
          moves: ['d5c4'],
          difficulty: 900,
          theme: 'capture',
          sideToMove: 'b',
        ),
      ]);
    } else if (rating < 1600) {
      // Intermediate puzzles
      puzzles.addAll([
        ChessPuzzle(
          fen: 'r1bq1rk1/ppp2ppp/2np1n2/2b1p3/2B1P3/3P1N2/PPP1NPPP/R1BQK2R w KQ - 0 6',
          moves: ['f3g5', 'h7h6', 'g5f7'],
          difficulty: 1400,
          theme: 'fork',
          sideToMove: 'w',
        ),
        ChessPuzzle(
          fen: 'r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQ1RK1 b kq - 0 5',
          moves: ['f6d5', 'c4d5', 'c6d4'],
          difficulty: 1500,
          theme: 'tactics',
          sideToMove: 'b',
        ),
      ]);
    } else {
      // Advanced puzzles
      puzzles.addAll([
        ChessPuzzle(
          fen: 'r2q1rk1/ppp2ppp/2np1n2/2b1p1B1/2B1P3/3P1N2/PPP2PPP/R2Q1RK1 w - - 0 8',
          moves: ['g5f6', 'g7f6', 'd1d5'],
          difficulty: 1800,
          theme: 'sacrifice',
          sideToMove: 'w',
        ),
        ChessPuzzle(
          fen: 'r1bq1rk1/ppp2ppp/2np1n2/4p1B1/1bB1P3/3P1N2/PPP2PPP/R2Q1RK1 b - - 0 7',
          moves: ['b4d2', 'b1d2', 'c6d4'],
          difficulty: 1900,
          theme: 'tactics',
          sideToMove: 'b',
        ),
      ]);
    }
    
    return puzzles;
  }
}

// User progress tracking
class UserProgressService {
  static const String _ratingKey = 'user_puzzle_rating';
  static const String _solvedCountKey = 'puzzles_solved';
  static const String _accuracyKey = 'puzzle_accuracy';

  static Future<int> getUserRating() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_ratingKey) ?? 1200; // Start at beginner level
  }

  static Future<void> setUserRating(int rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ratingKey, rating);
  }

  static Future<void> updateRatingAfterPuzzle({
    required bool solved,
    required int puzzleRating,
    bool isSkipped = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentRating = prefs.getInt(_ratingKey) ?? 1200;
    final totalSolved = prefs.getInt(_solvedCountKey) ?? 0;

    if (solved) {
      // Positive rating change for solving puzzle
      final ratingGain = puzzleRating > currentRating ? 15 : 8;
      await prefs.setInt(_ratingKey, currentRating + ratingGain);
      await prefs.setInt(_solvedCountKey, totalSolved + 1);
    } else if (isSkipped) {
      // Small penalty for skipping (3 points)
      await prefs.setInt(_ratingKey, (currentRating - 3).clamp(800, 3000));
    } else {
      // Larger penalty for failing puzzle
      final ratingLoss = puzzleRating > currentRating ? 12 : 6;
      await prefs.setInt(_ratingKey, (currentRating - ratingLoss).clamp(800, 3000));
    }
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'rating': prefs.getInt(_ratingKey) ?? 1200,
      'solved': prefs.getInt(_solvedCountKey) ?? 0,
      'accuracy': prefs.getDouble(_accuracyKey) ?? 0.0,
    };
  }
}
