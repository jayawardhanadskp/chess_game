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

  @override
  void initState() {
    _initializeBoard();
    super.initState();
  }

  // initialize board
  void _initializeBoard() {
    // initilize the bord with nulls, meaning no pices in those positions
    List<List<ChessPiece?>> newBord =
        List.generate(8, (index)  => List.generate(8, (index) => null));

    // place pawns
    for (int i = 0; i < 8; i++) {
      newBord[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'assets/pawn.png'
      );

      newBord[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'assets/pawn.png'
      );
    }

    // place rooks
    newBord[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'assets/rook.png'
    );
    newBord[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'assets/rook.png'
    );newBord[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'assets/rook.png'
    );newBord[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'assets/rook.png'
    );

    // place knights
    newBord[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'assets/knight.png'
    );newBord[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'assets/knight.png'
    );newBord[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'assets/knight.png'
    );newBord[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'assets/knight.png'
    );

    // place bishops
    newBord[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'assets/bishop.png'
    );
    newBord[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'assets/bishop.png'
    );
    newBord[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'assets/bishop.png'
    );newBord[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'assets/bishop.png'
    );

    // place queens
    newBord[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'assets/queen.png'
    );
    newBord[7][4] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'assets/queen.png'
    );

    // place king
    newBord[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'assets/king.png'
    );
    newBord[7][3] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'assets/king.png'
    );

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
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GridView.builder(
          itemCount: 8 * 8,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
          itemBuilder: (context, index) {

            // get the row and col position of this square
            int row = index ~/ 8;
            int col = index % 8;

            // check if this square is sekected
            bool isSelected = selectedRow == row && selectedCol == col;

            return Square(
              isWhite: isWhite(index),
              piece: board[row][col],
              isSelected: isSelected,
              onTap: () => pieceSelected(row, col),
            );
          }),
    );
  }
}
