import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/helper/helper_methods.dart';
import 'package:flutter/material.dart';

import 'components/captured_piece.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  int boardSize = 8;

  // 2D List representing the chess board
  late List<List<ChessPiece?>> board;

  // Selected piece
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;

  List<List<int>> validMoves = [];

  // list of captured pieces
  List<ChessPiece> capturedWhitePieces = [];
  List<ChessPiece> capturedBlackPieces = [];

  // Turn to move
  bool isWhiteTurn = true;

  // Kings' initial positions
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    // Initialize an empty board
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'lib/images/pawn.png');
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'lib/images/pawn.png');
    }

    // Rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');
    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');

    // Knights
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');

    // Bishops
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');

    // Queens
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'lib/images/queen.png');
    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/images/queen.png');

    // Kings
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'lib/images/king.png');
    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'lib/images/king.png');

    board = newBoard;
  }

  void pieceSelected(int row, int col) {
    setState(() {
      // first selection, no piece has been selected yet
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }

      // after selecting a piece, user can select other pieces of their own
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      // if a piece is selected and tap on a square that is a valid move, move the piece
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // After selecting a piece, calculate valid moves
      validMoves =
          calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // move forward one square if not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // move 2 square from initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // capture diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.rook:
        // move horizontal and vertical
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves
                    .add([newRow, newCol]); // capture opponent's piece
              }
              break; // blocked by own piece
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.knight:
        // 8 possible knight moves
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // capture opponent's piece
            }
            continue; // own piece is in the way
          }

          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ChessPieceType.bishop:
        var directions = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves
                    .add([newRow, newCol]); // capture opponent's piece
              }
              break; // blocked by own piece
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.queen:
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves
                    .add([newRow, newCol]); // capture opponent's piece
              }
              break; // blocked by own piece
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.king:
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // capture opponent's piece
            }
            continue; // blocked by own piece
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      default:
    }

    return candidateMoves;
  }

  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // filter out all illegal moves from candidateMoves
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }

  void movePiece(int newRow, int newCol) {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        capturedWhitePieces.add(capturedPiece);
      } else {
        capturedBlackPieces.add(capturedPiece);
      }
    }

    // a move that will put your king in check is illegal
    if (selectedPiece!.type == ChessPieceType.king) {
      // update king position
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // moving the piece
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Check if king is in check
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clearing selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // Check if checkmate
    if (isCheckmate(!isWhiteTurn)) {
       showDialog(context: context, builder: (context) => AlertDialog(
         title: const Text("CHECKMATE!"),
         actions: [
           TextButton(onPressed: resetGame, child: const Text("Play Again"))
         ],
       ));
    }

    // Change turn
    isWhiteTurn = !isWhiteTurn;
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;

    // Check if opponent's piece is attacking the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Skip empty squares and pieces of the same color
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j], false);

        // Check if the king's position is in line of sight of opponent's pieces
        if (pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    // save current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];
    List<int>? originalKingPosition;

    if (piece.type == ChessPieceType.king) {
      originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;

      // update king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    bool kingInCheck = isKingInCheck(piece.isWhite);

    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    return !kingInCheck;
  }

  // Checkmate?
  bool isCheckmate (bool isWhiteKing) {
    // if the king is not in check, not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    // if there is at least one legal move, not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty squares and pieces of the same color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
           continue;
        }

        List<List<int>> pieceValidMove = calculateRealValidMoves(i, j, board[i][j], true);
        if (pieceValidMove.isNotEmpty) {
          return false;
        }
      }
    }

    // if none of the above, then checkmate
    return true;
  }

  // reset game
  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    capturedWhitePieces.clear();
    capturedBlackPieces.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      body: Column(
        children: [
          // Captured white pieces
          Expanded(
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: capturedWhitePieces.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => CapturedPiece(
                        imagePath: capturedWhitePieces[index].imagePath,
                        isWhite: true,
                      ))),

          // Check status
          Text(checkStatus ? "CHECK!" : ""),

          // Board
          Expanded(
            flex: 3,
            child: GridView.builder(
                itemCount: boardSize * boardSize,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: boardSize),
                itemBuilder: (context, index) {
                  int row = index ~/ 8;
                  int col = index % 8;

                  bool isSelected = selectedRow == row && selectedCol == col;

                  bool isValidMove = false;

                  for (var position in validMoves) {
                    if (position[0] == row && position[1] == col) {
                      isValidMove = true;
                    }
                  }

                  return Square(
                    isWhite: isWhite(index),
                    piece: board[row][col],
                    isSelected: isSelected,
                    isValidMove: isValidMove,
                    onTap: () => pieceSelected(row, col),
                  );
                }),
          ),

          // Captured black pieces
          Expanded(
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: capturedBlackPieces.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => CapturedPiece(
                        imagePath: capturedBlackPieces[index].imagePath,
                        isWhite: false,
                      ))),
        ],
      ),
    );
  }
}
