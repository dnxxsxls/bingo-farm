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

  void unlockCrop(CropType crop) {
    if (!_unlockedCrops.contains(crop)) {
      if (spendSilver(crop.unlockCost)) {
        _unlockedCrops.add(crop);
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
      final reward = _tiles[row][col].harvest();
      if (reward > 0) {
        addSilver(reward);
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
}
