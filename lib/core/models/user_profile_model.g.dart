// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 1;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      tasteSeedMovieIds: (fields[0] as List).cast<int>(),
      tasteSeedTvIds: fields[6] == null ? [] : (fields[6] as List).cast<int>(),
      selectedMoodIds: (fields[1] as List).cast<String>(),
      totalSwipeCount: fields[2] as int,
      onboardingComplete: fields[3] as bool,
      gemsMode: fields[4] as bool,
      swipeGateDismissed: fields[5] as bool,
      allowOldMovies: fields[7] == null ? false : fields[7] as bool,
      hasSeenWalkthrough: fields[8] == null ? false : fields[8] as bool,
      suppressAuthGate: fields[9] == null ? false : fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.tasteSeedMovieIds)
      ..writeByte(1)
      ..write(obj.selectedMoodIds)
      ..writeByte(2)
      ..write(obj.totalSwipeCount)
      ..writeByte(3)
      ..write(obj.onboardingComplete)
      ..writeByte(4)
      ..write(obj.gemsMode)
      ..writeByte(5)
      ..write(obj.swipeGateDismissed)
      ..writeByte(6)
      ..write(obj.tasteSeedTvIds)
      ..writeByte(7)
      ..write(obj.allowOldMovies)
      ..writeByte(8)
      ..write(obj.hasSeenWalkthrough)
      ..writeByte(9)
      ..write(obj.suppressAuthGate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
