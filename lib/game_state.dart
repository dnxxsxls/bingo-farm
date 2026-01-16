import 'package:flutter/foundation.dart';
import 'models/crop_type.dart';
import 'models/tile.dart';
import 'models/tile_state.dart';

class GameState extends ChangeNotifier {
  int _silver = 0;
  final List<CropType> _unlockedCrops = [CropType.carrot];
  CropType? _selectedCrop = CropType.carrot;
  final List<List<Tile>> _tiles = List.generate(
    3,
    (_) => List.generate(3, (_) => Tile()),
  );

  int get silver => _silver;
  List<CropType> get unlockedCrops => _unlockedCrops;
  CropType? get selectedCrop => _selectedCrop;
  List<List<Tile>> get tiles => _tiles;

  void addSilver(int amount) {
    _silver += amount;
    notifyListeners();
  }

  bool spendSilver(int amount) {
    if (_silver >= amount) {
      _silver -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// 작물 해금: 이전 작물을 수확했는지 확인하여 자동 해금
  void tryUnlockNextCrop(CropType harvestedCrop) {
    final nextCrop = harvestedCrop.nextCrop;
    if (nextCrop != null && !_unlockedCrops.contains(nextCrop)) {
      if (nextCrop.canUnlock(_unlockedCrops)) {
        _unlockedCrops.add(nextCrop);
        notifyListeners();
      }
    }
  }

  void selectCrop(CropType crop) {
    if (_unlockedCrops.contains(crop)) {
      _selectedCrop = crop;
      notifyListeners();
    }
  }

  bool canPlant(int row, int col) {
    return _tiles[row][col].state == TileState.empty && _selectedCrop != null;
  }

  void plantCrop(int row, int col) {
    if (canPlant(row, col) && _selectedCrop != null) {
      _tiles[row][col].plant(_selectedCrop!);
      notifyListeners();
    }
  }

  bool canHarvest(int row, int col) {
    return _tiles[row][col].state == TileState.ready;
  }

  void harvestCrop(int row, int col) {
    if (canHarvest(row, col)) {
      final cropType = _tiles[row][col].cropType;
      final reward = _tiles[row][col].harvest();
      if (reward > 0) {
        addSilver(reward);
        // 작물을 수확하면 다음 작물 자동 해금 시도
        if (cropType != null) {
          tryUnlockNextCrop(cropType);
        }
      }
    }
  }

  void updateTiles() {
    bool changed = false;
    for (var row in _tiles) {
      for (var tile in row) {
        final oldState = tile.state;
        tile.updateState();
        if (tile.state != oldState) {
          changed = true;
        }
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  bool isCropUnlocked(CropType crop) {
    return _unlockedCrops.contains(crop);
  }

  /// 다음 해금 가능한 작물 반환
  CropType? getNextUnlockableCrop() {
    for (final crop in CropType.values) {
      if (!_unlockedCrops.contains(crop) && crop.canUnlock(_unlockedCrops)) {
        return crop;
      }
    }
    return null;
  }
}
