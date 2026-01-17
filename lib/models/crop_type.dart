enum CropType {
  carrot, // 당근
  potato, // 감자
  corn, // 옥수수
  tomato, // 토마토
  taro, // 토란
  eggplant, // 가지
  bean, // 콩
  watermelon, // 수박
  pumpkin, // 호박
}

extension CropTypeExtension on CropType {
  String get name {
    switch (this) {
      case CropType.carrot:
        return '당근';
      case CropType.potato:
        return '감자';
      case CropType.corn:
        return '옥수수';
      case CropType.tomato:
        return '토마토';
      case CropType.taro:
        return '토란';
      case CropType.eggplant:
        return '가지';
      case CropType.bean:
        return '콩';
      case CropType.watermelon:
        return '수박';
      case CropType.pumpkin:
        return '호박';
    }
  }

  int get growthTimeSeconds {
    switch (this) {
      case CropType.carrot:
        return 5;
      case CropType.potato:
        return 8;
      case CropType.corn:
        return 12;
      case CropType.tomato:
        return 15;
      case CropType.taro:
        return 20;
      case CropType.eggplant:
        return 25;
      case CropType.bean:
        return 30;
      case CropType.watermelon:
        return 40;
      case CropType.pumpkin:
        return 50;
    }
  }

  int get harvestReward {
    switch (this) {
      case CropType.carrot:
        return 2;
      case CropType.potato:
        return 5;
      case CropType.corn:
        return 10;
      case CropType.tomato:
        return 20;
      case CropType.taro:
        return 30;
      case CropType.eggplant:
        return 40;
      case CropType.bean:
        return 50;
      case CropType.watermelon:
        return 80;
      case CropType.pumpkin:
        return 120;
    }
  }

  /// 다음 작물 타입 반환 (해금 순서)
  CropType? get nextCrop {
    switch (this) {
      case CropType.carrot:
        return CropType.potato;
      case CropType.potato:
        return CropType.corn;
      case CropType.corn:
        return CropType.tomato;
      case CropType.tomato:
        return CropType.taro;
      case CropType.taro:
        return CropType.eggplant;
      case CropType.eggplant:
        return CropType.bean;
      case CropType.bean:
        return CropType.watermelon;
      case CropType.watermelon:
        return CropType.pumpkin;
      case CropType.pumpkin:
        return null; // 마지막 작물
    }
  }

  /// 이전 작물 타입 반환
  CropType? get previousCrop {
    switch (this) {
      case CropType.carrot:
        return null; // 첫 작물
      case CropType.potato:
        return CropType.carrot;
      case CropType.corn:
        return CropType.potato;
      case CropType.tomato:
        return CropType.corn;
      case CropType.taro:
        return CropType.tomato;
      case CropType.eggplant:
        return CropType.taro;
      case CropType.bean:
        return CropType.eggplant;
      case CropType.watermelon:
        return CropType.bean;
      case CropType.pumpkin:
        return CropType.watermelon;
    }
  }

  /// 해금 조건: 이전 작물이 해금되어 있는지 확인
  bool canUnlock(List<CropType> unlockedCrops) {
    if (this == CropType.carrot) {
      return true; // 기본 해금
    }
    final previous = previousCrop;
    return previous != null && unlockedCrops.contains(previous);
  }

  /// 해금 비용 계산 (점진적으로 증가)
  int getUnlockCost() {
    switch (this) {
      case CropType.carrot:
        return 0; // 기본 해금
      case CropType.potato:
        return 10; // 10 은화
      case CropType.corn:
        return 25; // 25 은화
      case CropType.tomato:
        return 50; // 50 은화
      case CropType.taro:
        return 100; // 100 은화
      case CropType.eggplant:
        return 200; // 200 은화
      case CropType.bean:
        return 400; // 400 은화
      case CropType.watermelon:
        return 800; // 800 은화
      case CropType.pumpkin:
        return 1600; // 1600 은화
    }
  }
}
