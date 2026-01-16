import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game.dart';
import 'game_state.dart';
import 'models/crop_type.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tile Farm',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;
  late TileFarmGame game;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    game = TileFarmGame(gameState: gameState);
    gameState.addListener(_onGameStateChanged);

    // 1초마다 타일 상태 업데이트
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      gameState.updateTiles();
      game.refreshTiles();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    gameState.removeListener(_onGameStateChanged);
    gameState.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    setState(() {
      // 게임 상태 변경 시 타일 업데이트
      game.refreshTiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // 상단: 은화 표시
            _buildSilverDisplay(),
            // 중앙: 게임 보드
            Expanded(
              child: GameWidget<TileFarmGame>.controlled(gameFactory: () => game),
            ),
            // 하단: 상점/업그레이드 버튼
            _buildShopSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSilverDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.brown.shade300, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monetization_on, color: Colors.amber.shade700, size: 32),
          const SizedBox(width: 8),
          Text(
            '은화: ${gameState.silver}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          top: BorderSide(color: Colors.brown.shade300, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 작물 선택
          _buildCropSelection(),
          const SizedBox(height: 16),
          // 작물 해금 버튼
          _buildUnlockButtons(),
        ],
      ),
    );
  }

  Widget _buildCropSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '작물 선택:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: CropType.values.map((crop) {
            final isUnlocked = gameState.isCropUnlocked(crop);
            final isSelected = gameState.selectedCrop == crop;
            return ElevatedButton(
              onPressed: isUnlocked
                  ? () => gameState.selectCrop(crop)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Colors.green.shade400
                    : (isUnlocked ? Colors.green.shade200 : Colors.grey.shade300),
                foregroundColor: isSelected ? Colors.white : Colors.black87,
              ),
              child: Text(crop.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUnlockButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '작물 해금:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: CropType.values.where((crop) => !gameState.isCropUnlocked(crop)).map((crop) {
            return ElevatedButton(
              onPressed: gameState.silver >= crop.unlockCost
                  ? () => gameState.unlockCrop(crop)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: gameState.silver >= crop.unlockCost
                    ? Colors.blue.shade200
                    : Colors.grey.shade300,
                foregroundColor: Colors.black87,
              ),
              child: Text('${crop.name} 해금 (${crop.unlockCost} 은화)'),
            );
          }).toList(),
        ),
      ],
    );
  }
}
