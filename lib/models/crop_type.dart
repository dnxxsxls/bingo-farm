enum CropType {
  carrot, // 당근
  tomato, // 토마토
}

extension CropTypeExtension on CropType {
  String get name {
    switch (this) {
      case CropType.carrot:
        return '당근';
      case CropType.tomato:
        return '토마토';
    }
  }

  int get growthTimeSeconds {
    switch (this) {
      case CropType.carrot:
        return 5;
      case CropType.tomato:
        return 10;
    }
  }

  int get harvestReward {
    switch (this) {
      case CropType.carrot:
        return 10;
      case CropType.tomato:
        return 25;
    }
  }

  int get unlockCost {
    switch (this) {
      case CropType.carrot:
        return 0; // 기본 해금
      case CropType.tomato:
        return 50;
    }
  }
}
