import 'package:chess_game/components/piece.dart';
import 'package:chess_game/components/square.dart';
import 'package:chess_game/values/colors.dart';
import 'package:flutter/material.dart';

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

    // place random pieace in middle to test
    newBord[3][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'assets/queen.png'

    );

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
    newBord[7][4] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'assets/queen.png');

    // place king
    newBord[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'assets/king.png');
    newBord[7][3] = ChessPiece(
        type: ChessPieceType.king, isWhite: true, imagePath: 'assets/king.png');

    board = newBord;
  }

  // USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // selected a piece if there is a piece in thet position
      if (board[row][col] != null) {
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
            calculateRawValidMoves(selectedRow, selectedCol, selectedPiece);
      
    });
  }

  // CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    // differenet directions based on there color
    int direction = piece!.isWhite ? -1 : 1;

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
            board[row + direction][col - 1]!.isWhite) {
          candidateMoves.add([row = direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite) {
          candidateMoves.add([row = direction, col - 1]);
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

  // MOVE PIECE
  void movePiece (int newRow, int newCol) {
    // move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GridView.builder(
          itemCount: 8 * 8,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8),
          itemBuilder: (context, index) {
            // get the row and col position of this square
            int row = index ~/ 8;
            int col = index % 8;

            // check if this square is sekected
            bool isSelected = selectedRow == row && selectedCol == col;

            // cheack if this square is valid move
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
    );
  }
}
