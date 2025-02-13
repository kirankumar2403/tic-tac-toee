import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TicTacToeProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TicTacToeScreen(),
      ),
    );
  }
}

class TicTacToeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<TicTacToeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tic-Tac-Toe')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                children: [
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => game.makeMove(index),
                        child: Container(
                          margin: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: Center(
                            child: Text(
                              game.board[index],
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (game.winningLine.isNotEmpty)
                    CustomPaint(
                      size: const Size(300, 300),
                      painter: LinePainter(game.winningLine),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              game.winner.isNotEmpty ? '~~${game.winner} Wins!~~' : 'Turn: ${game.currentPlayer}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: game.resetGame,
              child: const Text('Restart Game'),
            )
          ],
        ),
      ),
    );
  }
}

class TicTacToeProvider extends ChangeNotifier {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String winner = '';
  List<int> winningLine = [];

  void makeMove(int index) {
    if (board[index] == '' && winner.isEmpty) {
      board[index] = currentPlayer;
      if (checkWinner()) {
        winner = currentPlayer;
      } else {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      }
      notifyListeners();
    }
  }

  bool checkWinner() {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    for (var pattern in winPatterns) {
      if (board[pattern[0]] != '' &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        winningLine = pattern;
        return true;
      }
    }
    return false;
  }

  void resetGame() {
    board = List.filled(9, '');
    currentPlayer = 'X';
    winner = '';
    winningLine = [];
    notifyListeners();
  }
}

class LinePainter extends CustomPainter {
  final List<int> winningLine;
  LinePainter(this.winningLine);

  @override
  void paint(Canvas canvas, Size size) {
    if (winningLine.isEmpty) return;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    final startX = (winningLine.first % 3) * cellWidth + cellWidth / 2;
    final startY = (winningLine.first ~/ 3) * cellHeight + cellHeight / 2;
    final endX = (winningLine.last % 3) * cellWidth + cellWidth / 2;
    final endY = (winningLine.last ~/ 3) * cellHeight + cellHeight / 2;

    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, endY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}