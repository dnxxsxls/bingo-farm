import 'crop_type.dart';
import 'tile_state.dart';

class Tile {
  TileState state;
  CropType? cropType;
  DateTime? plantedAt;
  DateTime? readyAt;

  Tile({
    this.state = TileState.empty,
    this.cropType,
    this.plantedAt,
    this.readyAt,
  });

  void plant(CropType crop) {
    state = TileState.planted;
    cropType = crop;
    plantedAt = DateTime.now();
    readyAt = plantedAt!.add(Duration(seconds: crop.growthTimeSeconds));
    // 심은 직후 바로 성장 중 상태로 전환
    state = TileState.growing;
  }

  void startGrowing() {
    if (state == TileState.planted) {
      state = TileState.growing;
    }
  }

  void markReady() {
    if (state == TileState.growing) {
      state = TileState.ready;
    }
  }

  int harvest() {
    if (state == TileState.ready && cropType != null) {
      final reward = cropType!.harvestReward;
      state = TileState.empty;
      cropType = null;
      plantedAt = null;
      readyAt = null;
      return reward;
    }
    return 0;
  }

  void updateState() {
    if (state == TileState.growing && readyAt != null) {
      if (DateTime.now().isAfter(readyAt!)) {
        state = TileState.ready;
      }
    }
  }

  /// 남은 시간을 초 단위로 반환 (성장 중일 때만 유효)
  int? getRemainingSeconds() {
    if (state == TileState.growing && readyAt != null) {
      final now = DateTime.now();
      if (now.isBefore(readyAt!)) {
        return readyAt!.difference(now).inSeconds;
      }
      return 0;
    }
    return null;
  }

  /// 남은 시간을 포맷된 문자열로 반환 (예: "5초", "1분 30초")
  String? getRemainingTimeText() {
    final seconds = getRemainingSeconds();
    if (seconds == null) return null;

    if (seconds <= 0) return '준비됨';

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
}
