import 'package:flutter/material.dart';
import 'dart:math' as math;

// Chess Puzzle Models
class ChessPuzzle {
  final String id;
  final String fen;
  final List<String> moves;
  final String description;
  final int difficulty; // 1-5 scale
  final String theme;

  ChessPuzzle({
    required this.id,
    required this.fen,
    required this.moves,
    required this.description,
    required this.difficulty,
    required this.theme,
  });
}

class ChessPuzzleDatabase {
  static final List<ChessPuzzle> puzzles = [
    // Beginner Puzzles (Mate in 1)
    ChessPuzzle(
      id: '001',
      fen: 'r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/3P1N2/PPP2PPP/RNBQK2R w KQkq - 0 1',
      moves: ['Bxf7#'],
      description: 'White to play and checkmate in 1',
      difficulty: 1,
      theme: 'Checkmate in One',
    ),
    ChessPuzzle(
      id: '002',
      fen: 'rnbqkb1r/ppp2ppp/5n2/3pp3/2B1P3/3P1N2/PPP2PPP/RNBQK2R w KQkq - 0 1',
      moves: ['Ng5'],
      description: 'Win material with a fork',
      difficulty: 1,
      theme: 'Fork',
    ),
    ChessPuzzle(
      id: '003',
      fen: 'r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQ1RK1 b kq - 0 1',
      moves: ['Bxf2+'],
      description: 'Win material with a discovered attack',
      difficulty: 1,
      theme: 'Discovered Attack',
    ),
    
    // Intermediate Puzzles (Mate in 2)
    ChessPuzzle(
      id: '004',
      fen: '2bqkb1r/2pp1ppp/p1n2n2/1p2p3/3PP3/1BP2N2/PPP2PPP/RNBQK2R w KQk - 0 1',
      moves: ['Bxf7+', 'Kxf7', 'Ng5+'],
      description: 'White to play and mate in 2',
      difficulty: 2,
      theme: 'Mate in Two',
    ),
    ChessPuzzle(
      id: '005',
      fen: 'r1bq1rk1/ppp2ppp/2np1n2/2b1p3/2B1P3/3P1N2/PPP1NPPP/R1BQ1RK1 w - - 0 1',
      moves: ['Ng5', 'h6', 'Nxf7'],
      description: 'Win the exchange',
      difficulty: 2,
      theme: 'Exchange',
    ),
    
    // Advanced Puzzles (Mate in 3+)
    ChessPuzzle(
      id: '006',
      fen: 'r1bqkb1r/pppp1p1p/2n2np1/4p3/2B1P3/3P1N2/PPP2PPP/RNBQK2R w KQkq - 0 1',
      moves: ['Ng5', 'Nh6', 'Qh5'],
      description: 'White to play and mate in 3',
      difficulty: 3,
      theme: 'Mate in Three',
    ),
    ChessPuzzle(
      id: '007',
      fen: 'rnbqk1nr/pppp1ppp/4p3/8/1b2P3/3P1N2/PPP2PPP/RNBQKB1R b KQkq - 0 1',
      moves: ['Bxd2+', 'Qxd2', 'Qh4+'],
      description: 'Black to play and win',
      difficulty: 3,
      theme: 'Queen Hunt',
    ),
    
    // Expert Puzzles
    ChessPuzzle(
      id: '008',
      fen: 'r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1',
      moves: ['Qf7+', 'Kh8', 'Qf8+'],
      description: 'Beautiful mate pattern',
      difficulty: 4,
      theme: 'Back Rank',
    ),
    ChessPuzzle(
      id: '009',
      fen: 'r1bq1rk1/ppp2ppp/2np1n2/2b1p3/2B1P3/3P1N2/PPP1NPPP/R1BQR1K1 w - - 0 1',
      moves: ['Bxf7+', 'Kh8', 'Ng5'],
      description: 'Complex tactical sequence',
      difficulty: 4,
      theme: 'Sacrifice',
    ),
    ChessPuzzle(
      id: '010',
      fen: '4r1k1/5ppp/4p3/3pP3/3P4/1Q6/5PPP/4R1K1 w - - 0 1',
      moves: ['Re8+', 'Rxe8', 'Qb8'],
      description: 'Endgame tactics',
      difficulty: 5,
      theme: 'Endgame',
    ),
  ];

  static ChessPuzzle getRandomPuzzle(int userLevel) {
    // Filter puzzles by difficulty based on user progress
    int targetDifficulty = math.min(1 + (userLevel ~/ 3), 5);
    List<ChessPuzzle> suitablePuzzles = puzzles
        .where((puzzle) => puzzle.difficulty <= targetDifficulty)
        .toList();
    
    if (suitablePuzzles.isEmpty) suitablePuzzles = puzzles;
    
    return suitablePuzzles[math.Random().nextInt(suitablePuzzles.length)];
  }
}

// Chess Puzzle Game Widget
class ChessPuzzleGame extends StatefulWidget {
  final int timeRemaining;
  final VoidCallback onBackToSelection;
  final VoidCallback onFinishRest;

  const ChessPuzzleGame({
    super.key,
    required this.timeRemaining,
    required this.onBackToSelection,
    required this.onFinishRest,
  });

  @override
  State<ChessPuzzleGame> createState() => _ChessPuzzleGameState();
}

class _ChessPuzzleGameState extends State<ChessPuzzleGame> {
  late ChessPuzzle currentPuzzle;
  int currentMoveIndex = 0;
  int puzzlesSolved = 0;
  int totalAttempts = 0;
  bool showSolution = false;
  bool puzzleCompleted = false;
  List<List<String>> board = [];
  String selectedSquare = '';
  String draggedPiece = '';
  String targetSquare = '';
  String currentPlayer = 'w';
  List<String> possibleMoves = [];
  List<String> validMoves = [];

  @override
  void initState() {
    super.initState();
    _loadNewPuzzle();
  }

  void _loadNewPuzzle() {
    setState(() {
      currentPuzzle = ChessPuzzleDatabase.getRandomPuzzle(puzzlesSolved);
      currentMoveIndex = 0;
      showSolution = false;
      puzzleCompleted = false;
      selectedSquare = '';
      _parsePosition(currentPuzzle.fen);
    });
  }

  void _parsePosition(String fen) {
    final parts = fen.split(' ');
    final position = parts[0];
    currentPlayer = parts[1];
    
    board = List.generate(8, (_) => List.filled(8, ''));
    
    int rank = 0;
    int file = 0;
    
    for (int i = 0; i < position.length; i++) {
      final char = position[i];
      if (char == '/') {
        rank++;
        file = 0;
      } else if (char.codeUnitAt(0) >= '1'.codeUnitAt(0) && 
                 char.codeUnitAt(0) <= '8'.codeUnitAt(0)) {
        file += int.parse(char);
      } else {
        board[rank][file] = char;
        file++;
      }
    }
  }

  void _onSquareTapped(int rank, int file) {
    final square = '${String.fromCharCode(97 + file)}${8 - rank}';
    final piece = board[rank][file];
    
    setState(() {
      if (selectedSquare.isEmpty && piece.isNotEmpty) {
        // Select a piece
        selectedSquare = square;
        _generatePossibleMoves(square, piece);
      } else if (selectedSquare.isNotEmpty && selectedSquare != square) {
        // Try to move piece
        if (_isValidMove(selectedSquare, square)) {
          _makeMove(selectedSquare, square);
        }
        selectedSquare = '';
        possibleMoves.clear();
      } else {
        // Deselect
        selectedSquare = '';
        possibleMoves.clear();
      }
    });
  }

  void _generatePossibleMoves(String square, String piece) {
    possibleMoves.clear();
    
    // For puzzle mode, we'll show basic moves for visual feedback
    // This is simplified - a full chess engine would be more complex
    final file = square.codeUnitAt(0) - 97; // a=0, b=1, etc.
    final rank = int.parse(square[1]) - 1; // 1=0, 2=1, etc.
    
    final pieceType = piece.toLowerCase();
    
    switch (pieceType) {
      case 'p': // Pawn
        _generatePawnMoves(rank, file, piece == piece.toUpperCase());
        break;
      case 'r': // Rook
        _generateRookMoves(rank, file);
        break;
      case 'n': // Knight
        _generateKnightMoves(rank, file);
        break;
      case 'b': // Bishop
        _generateBishopMoves(rank, file);
        break;
      case 'q': // Queen
        _generateQueenMoves(rank, file);
        break;
      case 'k': // King
        _generateKingMoves(rank, file);
        break;
    }
  }
  
  void _generatePawnMoves(int rank, int file, bool isWhite) {
    final direction = isWhite ? 1 : -1;
    final newRank = rank + direction;
    
    if (newRank >= 0 && newRank < 8) {
      // Forward move
      if (board[newRank][file].isEmpty) {
        possibleMoves.add('${String.fromCharCode(97 + file)}${newRank + 1}');
      }
      
      // Captures
      if (file > 0 && board[newRank][file - 1].isNotEmpty) {
        possibleMoves.add('${String.fromCharCode(96 + file)}${newRank + 1}');
      }
      if (file < 7 && board[newRank][file + 1].isNotEmpty) {
        possibleMoves.add('${String.fromCharCode(98 + file)}${newRank + 1}');
      }
    }
  }
  
  void _generateRookMoves(int rank, int file) {
    // Horizontal and vertical moves
    for (int i = 0; i < 8; i++) {
      if (i != rank) possibleMoves.add('${String.fromCharCode(97 + file)}${i + 1}');
      if (i != file) possibleMoves.add('${String.fromCharCode(97 + i)}${rank + 1}');
    }
  }
  
  void _generateKnightMoves(int rank, int file) {
    final knightMoves = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];
    
    for (final move in knightMoves) {
      final newRank = rank + move[0];
      final newFile = file + move[1];
      if (newRank >= 0 && newRank < 8 && newFile >= 0 && newFile < 8) {
        possibleMoves.add('${String.fromCharCode(97 + newFile)}${newRank + 1}');
      }
    }
  }
  
  void _generateBishopMoves(int rank, int file) {
    // Diagonal moves
    for (int i = 1; i < 8; i++) {
      if (rank + i < 8 && file + i < 8) possibleMoves.add('${String.fromCharCode(97 + file + i)}${rank + i + 1}');
      if (rank + i < 8 && file - i >= 0) possibleMoves.add('${String.fromCharCode(97 + file - i)}${rank + i + 1}');
      if (rank - i >= 0 && file + i < 8) possibleMoves.add('${String.fromCharCode(97 + file + i)}${rank - i + 1}');
      if (rank - i >= 0 && file - i >= 0) possibleMoves.add('${String.fromCharCode(97 + file - i)}${rank - i + 1}');
    }
  }
  
  void _generateQueenMoves(int rank, int file) {
    _generateRookMoves(rank, file);
    _generateBishopMoves(rank, file);
  }
  
  void _generateKingMoves(int rank, int file) {
    for (int dr = -1; dr <= 1; dr++) {
      for (int df = -1; df <= 1; df++) {
        if (dr == 0 && df == 0) continue;
        final newRank = rank + dr;
        final newFile = file + df;
        if (newRank >= 0 && newRank < 8 && newFile >= 0 && newFile < 8) {
          possibleMoves.add('${String.fromCharCode(97 + newFile)}${newRank + 1}');
        }
      }
    }
  }
  
  bool _isValidMove(String from, String to) {
    // For puzzle mode, we'll check if the move matches the solution
    final expectedMove = currentPuzzle.moves[currentMoveIndex];
    final algebraicMove = _convertToAlgebraic(from, to);
    
    return algebraicMove == expectedMove || 
           possibleMoves.contains(to) ||
           currentPuzzle.moves.any((move) => move.contains(to));
  }
  
  String _convertToAlgebraic(String from, String to) {
    // Simple conversion - a full implementation would be more complex
    return to; // Simplified for puzzle mode
  }
  
  void _makeMove(String from, String to) {
    final fromFile = from.codeUnitAt(0) - 97;
    final fromRank = int.parse(from[1]) - 1;
    final toFile = to.codeUnitAt(0) - 97;
    final toRank = int.parse(to[1]) - 1;
    
    final piece = board[fromRank][fromFile];
    
    setState(() {
      // Make the move
      board[toRank][toFile] = piece;
      board[fromRank][fromFile] = '';
      
      // Check if this completes the puzzle
      currentMoveIndex++;
      if (currentMoveIndex >= currentPuzzle.moves.length) {
        puzzleCompleted = true;
        puzzlesSolved++;
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text('Puzzle solved! 🎉 (${currentPuzzle.theme})'),
              ],
            ),
            backgroundColor: Colors.green.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Show move feedback
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Good move! ${currentMoveIndex}/${currentPuzzle.moves.length}'),
            backgroundColor: Colors.blue.shade600,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _showSolution() {
    setState(() {
      showSolution = true;
      totalAttempts++;
    });
  }

  void _nextPuzzle() {
    if (puzzleCompleted) {
      setState(() {
        puzzlesSolved++;
      });
    }
    _loadNewPuzzle();
  }

  String _getPieceSymbol(String piece) {
    // Chess.com style piece symbols
    const symbols = {
      'K': '♔', 'Q': '♕', 'R': '♖', 'B': '♗', 'N': '♘', 'P': '♙',
      'k': '♚', 'q': '♛', 'r': '♜', 'b': '♝', 'n': '♞', 'p': '♟',
    };
    return symbols[piece] ?? '';
  }

  Color _getSquareColor(int rank, int file) {
    final isLight = (rank + file) % 2 == 0;
    final square = '${String.fromCharCode(97 + file)}${8 - rank}';
    
    // Selected square - bright yellow highlight
    if (selectedSquare == square) {
      return const Color(0xFFFFDB00); // Chess.com yellow
    }
    
    // Possible move squares - green dots/highlights
    if (possibleMoves.contains(square)) {
      return isLight 
        ? const Color(0xFFBFDB91) // Light green on light squares
        : const Color(0xFF9BBF72); // Darker green on dark squares
    }
    
    // Chess.com style colors
    return isLight 
      ? const Color(0xFFF0D9B5) // Light cream/beige
      : const Color(0xFFB58863); // Rich brown
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Game Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBackToSelection,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    'Chess Puzzles',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${widget.timeRemaining}s',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // Stats Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Solved', puzzlesSolved.toString(), Colors.green),
              _buildStatCard('Difficulty', currentPuzzle.difficulty.toString(), Colors.orange),
              _buildStatCard('Theme', currentPuzzle.theme, Colors.blue),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Puzzle Description
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            currentPuzzle.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

                 // Chess Board
         Expanded(
           child: Center(
             child: AspectRatio(
               aspectRatio: 1,
               child: RepaintBoundary(
                 child: Container(
                   margin: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     border: Border.all(color: const Color(0xFF8B4513), width: 4),
                     borderRadius: BorderRadius.circular(8),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withOpacity(0.3),
                         blurRadius: 10,
                         offset: const Offset(0, 4),
                       ),
                     ],
                   ),
                   child: Stack(
                     children: [
                       // Main chess board
                       GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true, // Re-enable for chess squares
                    cacheExtent: 0, // Minimal cache for performance
                    itemBuilder: (context, index) {
                      final rank = index ~/ 8;
                      final file = index % 8;
                      final piece = board[rank][file];
                      final square = '${String.fromCharCode(97 + file)}${8 - rank}';
                      final isSelected = selectedSquare == square;
                      final isPossibleMove = possibleMoves.contains(square);
                      
                      return DragTarget<String>(
                        onAcceptWithDetails: (details) {
                          if (selectedSquare.isNotEmpty) {
                            if (_isValidMove(selectedSquare, square)) {
                              _makeMove(selectedSquare, square);
                            }
                            setState(() {
                              selectedSquare = '';
                              possibleMoves.clear();
                            });
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return GestureDetector(
                            onTap: () => _onSquareTapped(rank, file),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getSquareColor(rank, file),
                                border: isSelected 
                                  ? Border.all(color: const Color(0xFFFFDB00), width: 3)
                                  : null,
                              ),
                              child: Stack(
                                children: [
                                  // Possible move indicators
                                  if (isPossibleMove && piece.isEmpty)
                                    Center(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF9BBF72).withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  if (isPossibleMove && piece.isNotEmpty)
                                    Center(
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFF9BBF72),
                                            width: 3,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  
                                  // Chess piece
                                  if (piece.isNotEmpty)
                                    Center(
                                      child: piece.isNotEmpty 
                                        ? Draggable<String>(
                                            data: piece,
                                            onDragStarted: () {
                                              setState(() {
                                                selectedSquare = square;
                                                _generatePossibleMoves(square, piece);
                                              });
                                            },
                                            onDragCompleted: () {
                                              setState(() {
                                                selectedSquare = '';
                                                possibleMoves.clear();
                                              });
                                            },
                                            feedback: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(25),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.3),
                                                    blurRadius: 10,
                                                    offset: const Offset(2, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _getPieceSymbol(piece),
                                                  style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            childWhenDragging: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(0.3),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                            child: Text(
                                              _getPieceSymbol(piece),
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w600,
                                                color: (piece == piece.toUpperCase()) 
                                                  ? Colors.white 
                                                  : Colors.black,
                                                shadows: (piece == piece.toUpperCase()) ? [
                                                  const Shadow(
                                                    offset: Offset(1, 1),
                                                    blurRadius: 2,
                                                    color: Colors.black54,
                                                  ),
                                                ] : [
                                                  const Shadow(
                                                    offset: Offset(1, 1),
                                                    blurRadius: 2,
                                                    color: Colors.white54,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : null,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                   ),
                   
                   // Coordinate labels
                   ...List.generate(8, (index) => [
                     // File labels (a-h) at bottom
                     Positioned(
                       bottom: 2,
                       left: 12.5 * (index * 8 + 4) + 4,
                       child: Text(
                         String.fromCharCode(97 + index),
                         style: TextStyle(
                           fontSize: 10,
                           fontWeight: FontWeight.bold,
                           color: (index % 2 == 0) 
                             ? const Color(0xFFB58863)
                             : const Color(0xFFF0D9B5),
                         ),
                       ),
                     ),
                     // Rank labels (1-8) at left
                     Positioned(
                       left: 2,
                       top: 12.5 * ((7-index) * 8 + 4) + 4,
                       child: Text(
                         (index + 1).toString(),
                         style: TextStyle(
                           fontSize: 10,
                           fontWeight: FontWeight.bold,
                           color: (index % 2 == 1) 
                             ? const Color(0xFFB58863)
                             : const Color(0xFFF0D9B5),
                         ),
                       ),
                     ),
                   ]).expand((element) => element).toList(),
                 ],
               ),
             ),
           ),
         ),
       ),
       ),

        // Solution Section
        if (showSolution) ...[
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solution:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(currentPuzzle.moves.join(' → ')),
              ],
            ),
          ),
        ],

        // Action Buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (!showSolution && !puzzleCompleted) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showSolution,
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Show Solution'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _nextPuzzle,
                  icon: const Icon(Icons.skip_next),
                  label: Text(showSolution || puzzleCompleted ? 'Next Puzzle' : 'Skip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (widget.timeRemaining <= 10) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onFinishRest,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Continue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Progress Indicator
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: LinearProgressIndicator(
            value: (90 - widget.timeRemaining) / 90,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.timeRemaining > 30 ? Colors.green : 
              widget.timeRemaining > 10 ? Colors.orange : Colors.red,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
} 