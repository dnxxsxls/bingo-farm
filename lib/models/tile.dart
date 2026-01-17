import 'crop_type.dart';
import 'tile_state.dart';

class Tile {
  TileState state;
  CropType? cropType;
  DateTime? plantedAt;
  
  // 각 성장 단계별 시간
  DateTime? seedTime;
  DateTime? sproutTime;
  DateTime? seedlingTime;
  DateTime? youngplantTime;
  DateTime? harvestTime;

  Tile({
    this.state = TileState.empty,
    this.cropType,
    this.plantedAt,
    this.seedTime,
    this.sproutTime,
    this.seedlingTime,
    this.youngplantTime,
    this.harvestTime,
  });

  void plant(CropType crop) {
    cropType = crop;
    plantedAt = DateTime.now();
    
    // 당근만 단계별로 2.5초씩 대기
    if (crop == CropType.carrot) {
      // 당근: 각 단계마다 2.5초씩 대기
      // seed (0초~2.5초) → sprout (2.5초~5초) → seedling (5초~7.5초) → youngplant (7.5초~10초) → harvest (10초~)
      seedTime = plantedAt!.add(Duration(milliseconds: 2500)); // 2.5초: seed → sprout 전환 시점
      sproutTime = plantedAt!.add(Duration(milliseconds: 5000)); // 5초: sprout → seedling 전환 시점
      seedlingTime = plantedAt!.add(Duration(milliseconds: 7500)); // 7.5초: seedling → youngplant 전환 시점
      youngplantTime = plantedAt!.add(Duration(milliseconds: 10000)); // 10초: youngplant → harvest 전환 시점
      harvestTime = plantedAt!.add(Duration(milliseconds: 10000)); // 10초: harvest 시작 (youngplantTime과 동일)
    } else {
      // 다른 작물: 기존 로직 (전체 시간을 5단계로 나눔)
      final totalTime = crop.growthTimeSeconds;
      final stepTime = totalTime / 5;
      
      seedTime = plantedAt!.add(Duration(seconds: (stepTime * 1).round()));
      sproutTime = plantedAt!.add(Duration(seconds: (stepTime * 2).round()));
      seedlingTime = plantedAt!.add(Duration(seconds: (stepTime * 3).round()));
      youngplantTime = plantedAt!.add(Duration(seconds: (stepTime * 4).round()));
      harvestTime = plantedAt!.add(Duration(seconds: totalTime));
    }
    
    // 심으면 바로 seed 상태로 시작
    state = TileState.seed;
    
    // 상태를 즉시 업데이트하여 현재 시간에 맞는 상태로 설정
    updateState();
  }

  int harvest() {
    if (state == TileState.harvest && cropType != null) {
      final reward = cropType!.harvestReward;
      state = TileState.empty;
      cropType = null;
      plantedAt = null;
      seedTime = null;
      sproutTime = null;
      seedlingTime = null;
      youngplantTime = null;
      harvestTime = null;
      return reward;
    }
    return 0;
  }

  void updateState() {
    if (state == TileState.empty) return;
    if (cropType == null) return;
    
    final now = DateTime.now();
    
    // 각 단계별 시간을 순차적으로 체크하여 상태 전환
    // 시간 구간:
    // - 0초 ~ seedTime: seed 상태
    // - seedTime ~ sproutTime: sprout 상태
    // - sproutTime ~ seedlingTime: seedling 상태
    // - seedlingTime ~ youngplantTime: youngplant 상태
    // - youngplantTime ~ harvestTime: harvest 상태
    
    // 시간 순서대로 체크 (높은 시간부터 낮은 시간 순서)
    // 각 시간에 도달하면 그 시간 이후의 상태로 전환
    // 시간 구간: seed (0~2.5초), sprout (2.5~5초), seedling (5~7.5초), youngplant (7.5~10초), harvest (10초~)
    
    if (harvestTime != null && !now.isBefore(harvestTime!)) {
      // harvestTime (10초) 이후: harvest 상태
      state = TileState.harvest;
    } else if (youngplantTime != null && !now.isBefore(youngplantTime!)) {
      // youngplantTime (10초) 이후이지만 harvestTime보다 작으면: youngplant 상태
      // (harvestTime과 같은 경우는 위에서 처리됨)
      state = TileState.youngplant;
    } else if (seedlingTime != null && !now.isBefore(seedlingTime!)) {
      // seedlingTime (7.5초) 이후: youngplant 상태 (seedling → youngplant)
      state = TileState.youngplant;
    } else if (sproutTime != null && !now.isBefore(sproutTime!)) {
      // sproutTime (5초) 이후: seedling 상태 (sprout → seedling)
      state = TileState.seedling;
    } else if (seedTime != null && !now.isBefore(seedTime!)) {
      // seedTime (2.5초) 이후: sprout 상태 (seed → sprout)
      state = TileState.sprout;
    } else if (plantedAt != null && !now.isBefore(plantedAt!)) {
      // plantedAt 이후 ~ seedTime (2.5초) 전: seed 상태
      state = TileState.seed;
    }
  }

  /// 남은 시간을 초 단위로 반환 (harvest 상태가 아닐 때만 유효)
  int? getRemainingSeconds() {
    if (state == TileState.harvest || cropType == null || harvestTime == null) {
      return null;
    }
    final now = DateTime.now();
    if (now.isBefore(harvestTime!)) {
      return harvestTime!.difference(now).inSeconds;
    }
    return 0;
  }

  /// 남은 시간을 포맷된 문자열로 반환 (예: "5초", "1분 30초")
  String? getRemainingTimeText() {
    final seconds = getRemainingSeconds();
    if (seconds == null) return null;

    if (seconds <= 0) return null;

    if (seconds < 60) {
      return '${seconds}초';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return '${minutes}분';
      } else {
        return '${minutes}분 ${remainingSeconds}초';
      }
    }
  }

  /// 경과 시간을 초 단위로 반환 (심은 후 경과한 시간)
  double getElapsedSeconds() {
    if (plantedAt == null) return 0.0;
    final now = DateTime.now();
    return now.difference(plantedAt!).inMilliseconds / 1000.0;
  }

  /// 경과 시간을 포맷된 문자열로 반환 (예: "2.5초", "10.3초")
  String getElapsedTimeText() {
    final elapsed = getElapsedSeconds();
    return '${elapsed.toStringAsFixed(1)}초';
  }

  /// 현재 상태 이름을 반환
  String getStateName() {
    switch (state) {
      case TileState.empty:
        return 'empty';
      case TileState.seed:
        return 'seed';
      case TileState.sprout:
        return 'sprout';
      case TileState.seedling:
        return 'seedling';
      case TileState.youngplant:
        return 'youngplant';
      case TileState.harvest:
        return 'harvest';
    }
  }
}
