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

  /// 작물 해금: 은화를 지불하여 해금
  void unlockCrop(CropType crop) {
    if (!_unlockedCrops.contains(crop)) {
      if (crop.canUnlock(_unlockedCrops)) {
        final cost = crop.getUnlockCost();
        if (spendSilver(cost)) {
          _unlockedCrops.add(crop);
          notifyListeners();
        }
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
      // 심은 직후 상태 즉시 업데이트 (updateState는 plant 내부에서 호출되지만, 확실히 하기 위해)
      _tiles[row][col].updateState();
      notifyListeners();
    }
  }

  bool canHarvest(int row, int col) {
    return _tiles[row][col].state == TileState.harvest;
  }

  void harvestCrop(int row, int col) {
    if (canHarvest(row, col)) {
      final reward = _tiles[row][col].harvest();
      if (reward > 0) {
        addSilver(reward);
      }
      notifyListeners(); // 수확 후 상태 변경 알림
    }
  }

  /// 타일 상태를 업데이트하고 변경 여부를 반환
  bool updateTiles() {
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
    return changed;
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

  /// 작물 해금 비용 반환
  int getUnlockCost(CropType crop) {
    return crop.getUnlockCost();
  }
}
