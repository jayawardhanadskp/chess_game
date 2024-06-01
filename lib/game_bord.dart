import 'package:chess_game/components/piece.dart';
import 'package:chess_game/components/square.dart';

import 'package:flutter/material.dart';

import 'components/dead_piece.dart';
import 'helper/helper_method.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // a 2-dimensional list representing the chessboard
  // with each position possibly contain a chess piece
  late List<List<ChessPiece?>> board;

  // the current selected pice on the chess bord
  // if no pice is selected, null
  ChessPiece? selectedPiece;

  // the row index of the selected piece
  // default value -1 indicated no piece is currebtly selected
  int selectedRow = -1;

  // the col index of the selected piece
  // default value -1 indicated no piece is currebtly selected
  int selectedCol = -1;

  // a list of values moves for the current selected piece
  // each move is represent as a list with 2 elements : row & col
  List<List<int>> validMoves = [];

  // a list of white pieces that have been taken by the black player
  List<ChessPiece> whitePiecesTaken = [];

  //  a list of black pieces that have been taken by the white player
  List<ChessPiece> blackPiecesTaken = [];

  // a boolean to indicate whose turn it is
  bool isWhitenTurn = true;

  // initialpositio of kings (keep track of this to make)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    _initializeBoard();
    super.initState();
  }

  // INITIALIZE THE BOARD
  void _initializeBoard() {
    // initilize the bord with nulls, meaning no pices in those positions
    List<List<ChessPiece?>> newBord =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // place pawns
    for (int i = 0; i < 8; i++) {
      newBord[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'assets/pawn.png');

      newBord[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'assets/pawn.png');
    }

    // place rooks
    newBord[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'assets/rook.png');
    newBord[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'assets/rook.png');
    newBord[7][0] = ChessPiece(
        type: ChessPieceType.rook, isWhite: true, imagePath: 'assets/rook.png');
    newBord[7][7] = ChessPiece(
        type: ChessPieceType.rook, isWhite: true, imagePath: 'assets/rook.png');

    // place knights
    newBord[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'assets/knight.png');
    newBord[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'assets/knight.png');
    newBord[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'assets/knight.png');
    newBord[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'assets/knight.png');

    // place bishops
    newBord[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'assets/bishop.png');
    newBord[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'assets/bishop.png');
    newBord[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'assets/bishop.png');
    newBord[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'assets/bishop.png');

    // place queens
    newBord[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'assets/queen.png');
    newBord[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'assets/queen.png');

    // place king
    newBord[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'assets/king.png');
    newBord[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'assets/king.png'
    );

    board = newBord;
  }

  // USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // no pierce has selected yet. this is first selection
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhitenTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }

      // theare is a piece already selected,  but user can selected another one of their prases
      else if (board[row][col] != null &&
              board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      // if there is a piece selected and user tap on that is a valid move, move there
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col))  {
        movePiece(row, col);
      }
        // if a pieces is selected, calculate its valid moves
        validMoves =
            calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);

    });
  }

  // CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    // differenet directions based on there color
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawans can move forword if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // pawns can move 2 squares forword if theay are at their initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // pawan can kill diagonally
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
        // horizontal and vertical direction
        var directions = [
          [-1,0], // up
          [1,0], // down
          [0,-1], // left
          [0,1], //right
        ];

        for(var direction in directions) {
          var  i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }   // kill
              break; // block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.knight:
        // all eligible posible L shape the knight can move
        var knightMoves = [
          [-2,-1], // up 2 left 1
          [-2,1], // up 2 right 1
          [-1,-2], // up 1 left 2
          [-1,2], // up 1 right 2
          [1,-2], // down 1 left 2
          [1,2], // down 1 right 2
          [2,-1], // down 2 left 1
          [2,1], // down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
            }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ChessPieceType.bishop:
        var directions = [
          [-1,-1], // up left
          [-1,1], // up right
          [1,-1], // down left
          [1,1], // down right
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
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.queen:
        var directions = [
          [-1,0], // up
          [1,0], // down
          [0,-1], // left
          [0,1], // right
          [-1,-1], // up left
          [-1,1], // up right
          [1,-1], // down left
          [1,1], // down right
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
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // bloacked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.king:
        var directions = [
          [-1,0], // up
          [1,0], // down
          [0,-1], // left
          [0,1], // right
          [-1,-1], // up left
          [-1,1], // up right
          [1,-1], // down left
          [1,1], // down right
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); //capture
            }
            continue; // blocked
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      default:
    }
    return candidateMoves;
  }

  // CALCULATE REAL VALID MOVES
  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimiulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // after genarating all candidate moves, filter out any that would result in a check
    if (checkSimiulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        // this will simiulate the feature move to see if its safe
        if (simulateMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  // MOVE PIECE
  void movePiece(int newRow, int newCol) {
    // if the new spot has an enemy piece
    if (board[newRow][newCol] != null) {
      // add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // check if the piece being moved is a king
    if (selectedPiece!.type == ChessPieceType.king) {
      // update the appropriate king position
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // see if any kings are under attack
    bool wasInCheck = checkStatus;
    if (isKingInCheck(!isWhitenTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // show "CHECK" dialog if king is in check and it wasn't in check before
    if (checkStatus && !wasInCheck) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('CHECK MATE!'),
          actions: [
            // play again button
            TextButton(
              onPressed: resetGame,
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }

    // check if it's checkmate
    if (isCheckMate(!isWhitenTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('CHECK MATE!'),
          actions: [
            // play again button
            TextButton(
              onPressed: resetGame,
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }

    // change turns
    isWhitenTurn = !isWhitenTurn;
  }


  // IS KING IN CHECK?
  bool isKingInCheck(bool isWhiteKing) {
    // get the position of the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if any enemy piece can attack the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip enemy squre and pices of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);

        // check if the kings pisition is in this pice valid moves
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  // SIMIYLATE A FUTURE MOVE TO SEE IF ITS SAFE (DOSENT PUT YOUR OWN KING UNDER THE ATTACK!)
  bool simulateMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    // save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    // if the piece is in the king, save its current and update to the new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      // update the king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      }  else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // check if our own king is under attack
    bool KingInCheck = isKingInCheck(piece.isWhite);

    // restore board to original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    // if the piece was king, restore original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      }  else {
        blackKingPosition = originalKingPosition!;
      }
    }
    // if king is in check = true, means its not a safe move. safe move = false
    return !KingInCheck;
  }

  // IS IT CHECK MATE?
  bool isCheckMate(bool isWhiteKing) {
    // if the king is not in check, then its not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    // if there is at least one legal move for any of the players pieces , then its not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty square and pieces of the other color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
      }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);

        // if pieces has any valid moves, then its not checkmate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // if none of the above codition are met, then thre are no leagal moves left to make
    // its check mate!
    return true;
  }

  // RESET TO NEW GAME
  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          const SizedBox(height: 20,),

          //white pieces taken
          Expanded(
              child: GridView.builder(
                itemCount: whitePiecesTaken.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                    imagePath: whitePiecesTaken[index].imagePath,
                    isWhite: true,
                  ),
              ),
          ),

          // GAME STATUS
          Text(checkStatus ? 'CHECK!' : '', style: const TextStyle(color: Colors.red, fontSize: 20 ),),

          // CHESS BOARD
          Expanded(
            flex: 3,
            child: GridView.builder(
                itemCount: 8 * 8,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                itemBuilder: (context, index) {
                  // get the row and col position of this square
                  int row = index ~/ 8;
                  int col = index % 8;

                  // check if this square is selected
                  bool isSelected = selectedRow == row && selectedCol == col;

                  // check if this square is valid move
                  bool isValidMove = false;
                  for (var position in validMoves) {
                    // compare row & col
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

          // blacked pieces taken
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),


        ],
      ),
    );
  }
}
