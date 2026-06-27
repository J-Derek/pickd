// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TvModelAdapter extends TypeAdapter<TvModel> {
  @override
  final int typeId = 2;

  @override
  TvModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TvModel(
      id: fields[0] as int,
      name: fields[1] as String,
      posterPath: fields[2] as String?,
      backdropPath: fields[3] as String?,
      overview: fields[4] as String,
      firstAirDate: fields[5] as String?,
      voteAverage: fields[6] as double,
      popularity: fields[7] as double,
      genreIds: (fields[8] as List).cast<int>(),
      trailerKey: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TvModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.backdropPath)
      ..writeByte(4)
      ..write(obj.overview)
      ..writeByte(5)
      ..write(obj.firstAirDate)
      ..writeByte(6)
      ..write(obj.voteAverage)
      ..writeByte(7)
      ..write(obj.popularity)
      ..writeByte(8)
      ..write(obj.genreIds)
      ..writeByte(9)
      ..write(obj.trailerKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TvModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
