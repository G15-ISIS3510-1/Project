// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles
    with TableInfo<$VehiclesTable, VehiclesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plateMeta = const VerificationMeta('plate');
  @override
  late final GeneratedColumn<String> plate = GeneratedColumn<String>(
    'plate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seatsMeta = const VerificationMeta('seats');
  @override
  late final GeneratedColumn<int> seats = GeneratedColumn<int>(
    'seats',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transmissionMeta = const VerificationMeta(
    'transmission',
  );
  @override
  late final GeneratedColumn<String> transmission = GeneratedColumn<String>(
    'transmission',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fuelTypeMeta = const VerificationMeta(
    'fuelType',
  );
  @override
  late final GeneratedColumn<String> fuelType = GeneratedColumn<String>(
    'fuel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mileageMeta = const VerificationMeta(
    'mileage',
  );
  @override
  late final GeneratedColumn<int> mileage = GeneratedColumn<int>(
    'mileage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    vehicleId,
    ownerId,
    make,
    model,
    year,
    plate,
    seats,
    transmission,
    fuelType,
    mileage,
    status,
    lat,
    lng,
    photoUrl,
    createdAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehiclesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    } else if (isInserting) {
      context.missing(_makeMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('plate')) {
      context.handle(
        _plateMeta,
        plate.isAcceptableOrUnknown(data['plate']!, _plateMeta),
      );
    } else if (isInserting) {
      context.missing(_plateMeta);
    }
    if (data.containsKey('seats')) {
      context.handle(
        _seatsMeta,
        seats.isAcceptableOrUnknown(data['seats']!, _seatsMeta),
      );
    } else if (isInserting) {
      context.missing(_seatsMeta);
    }
    if (data.containsKey('transmission')) {
      context.handle(
        _transmissionMeta,
        transmission.isAcceptableOrUnknown(
          data['transmission']!,
          _transmissionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transmissionMeta);
    }
    if (data.containsKey('fuel_type')) {
      context.handle(
        _fuelTypeMeta,
        fuelType.isAcceptableOrUnknown(data['fuel_type']!, _fuelTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fuelTypeMeta);
    }
    if (data.containsKey('mileage')) {
      context.handle(
        _mileageMeta,
        mileage.isAcceptableOrUnknown(data['mileage']!, _mileageMeta),
      );
    } else if (isInserting) {
      context.missing(_mileageMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {vehicleId};
  @override
  VehiclesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehiclesData(
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      plate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plate'],
      )!,
      seats: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seats'],
      )!,
      transmission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transmission'],
      )!,
      fuelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel_type'],
      )!,
      mileage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mileage'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class VehiclesData extends DataClass implements Insertable<VehiclesData> {
  final String vehicleId;
  final String ownerId;
  final String make;
  final String model;
  final int year;
  final String plate;
  final int seats;
  final String transmission;
  final String fuelType;
  final int mileage;
  final String status;
  final double lat;
  final double lng;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isDeleted;
  const VehiclesData({
    required this.vehicleId,
    required this.ownerId,
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    required this.mileage,
    required this.status,
    required this.lat,
    required this.lng,
    this.photoUrl,
    required this.createdAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['owner_id'] = Variable<String>(ownerId);
    map['make'] = Variable<String>(make);
    map['model'] = Variable<String>(model);
    map['year'] = Variable<int>(year);
    map['plate'] = Variable<String>(plate);
    map['seats'] = Variable<int>(seats);
    map['transmission'] = Variable<String>(transmission);
    map['fuel_type'] = Variable<String>(fuelType);
    map['mileage'] = Variable<int>(mileage);
    map['status'] = Variable<String>(status);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      vehicleId: Value(vehicleId),
      ownerId: Value(ownerId),
      make: Value(make),
      model: Value(model),
      year: Value(year),
      plate: Value(plate),
      seats: Value(seats),
      transmission: Value(transmission),
      fuelType: Value(fuelType),
      mileage: Value(mileage),
      status: Value(status),
      lat: Value(lat),
      lng: Value(lng),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      createdAt: Value(createdAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory VehiclesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehiclesData(
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      make: serializer.fromJson<String>(json['make']),
      model: serializer.fromJson<String>(json['model']),
      year: serializer.fromJson<int>(json['year']),
      plate: serializer.fromJson<String>(json['plate']),
      seats: serializer.fromJson<int>(json['seats']),
      transmission: serializer.fromJson<String>(json['transmission']),
      fuelType: serializer.fromJson<String>(json['fuelType']),
      mileage: serializer.fromJson<int>(json['mileage']),
      status: serializer.fromJson<String>(json['status']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vehicleId': serializer.toJson<String>(vehicleId),
      'ownerId': serializer.toJson<String>(ownerId),
      'make': serializer.toJson<String>(make),
      'model': serializer.toJson<String>(model),
      'year': serializer.toJson<int>(year),
      'plate': serializer.toJson<String>(plate),
      'seats': serializer.toJson<int>(seats),
      'transmission': serializer.toJson<String>(transmission),
      'fuelType': serializer.toJson<String>(fuelType),
      'mileage': serializer.toJson<int>(mileage),
      'status': serializer.toJson<String>(status),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  VehiclesData copyWith({
    String? vehicleId,
    String? ownerId,
    String? make,
    String? model,
    int? year,
    String? plate,
    int? seats,
    String? transmission,
    String? fuelType,
    int? mileage,
    String? status,
    double? lat,
    double? lng,
    Value<String?> photoUrl = const Value.absent(),
    DateTime? createdAt,
    bool? isDeleted,
  }) => VehiclesData(
    vehicleId: vehicleId ?? this.vehicleId,
    ownerId: ownerId ?? this.ownerId,
    make: make ?? this.make,
    model: model ?? this.model,
    year: year ?? this.year,
    plate: plate ?? this.plate,
    seats: seats ?? this.seats,
    transmission: transmission ?? this.transmission,
    fuelType: fuelType ?? this.fuelType,
    mileage: mileage ?? this.mileage,
    status: status ?? this.status,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    createdAt: createdAt ?? this.createdAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  VehiclesData copyWithCompanion(VehiclesCompanion data) {
    return VehiclesData(
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      plate: data.plate.present ? data.plate.value : this.plate,
      seats: data.seats.present ? data.seats.value : this.seats,
      transmission: data.transmission.present
          ? data.transmission.value
          : this.transmission,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      mileage: data.mileage.present ? data.mileage.value : this.mileage,
      status: data.status.present ? data.status.value : this.status,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesData(')
          ..write('vehicleId: $vehicleId, ')
          ..write('ownerId: $ownerId, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('plate: $plate, ')
          ..write('seats: $seats, ')
          ..write('transmission: $transmission, ')
          ..write('fuelType: $fuelType, ')
          ..write('mileage: $mileage, ')
          ..write('status: $status, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    vehicleId,
    ownerId,
    make,
    model,
    year,
    plate,
    seats,
    transmission,
    fuelType,
    mileage,
    status,
    lat,
    lng,
    photoUrl,
    createdAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehiclesData &&
          other.vehicleId == this.vehicleId &&
          other.ownerId == this.ownerId &&
          other.make == this.make &&
          other.model == this.model &&
          other.year == this.year &&
          other.plate == this.plate &&
          other.seats == this.seats &&
          other.transmission == this.transmission &&
          other.fuelType == this.fuelType &&
          other.mileage == this.mileage &&
          other.status == this.status &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt &&
          other.isDeleted == this.isDeleted);
}

class VehiclesCompanion extends UpdateCompanion<VehiclesData> {
  final Value<String> vehicleId;
  final Value<String> ownerId;
  final Value<String> make;
  final Value<String> model;
  final Value<int> year;
  final Value<String> plate;
  final Value<int> seats;
  final Value<String> transmission;
  final Value<String> fuelType;
  final Value<int> mileage;
  final Value<String> status;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String?> photoUrl;
  final Value<DateTime> createdAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const VehiclesCompanion({
    this.vehicleId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.plate = const Value.absent(),
    this.seats = const Value.absent(),
    this.transmission = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.mileage = const Value.absent(),
    this.status = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCompanion.insert({
    required String vehicleId,
    required String ownerId,
    required String make,
    required String model,
    required int year,
    required String plate,
    required int seats,
    required String transmission,
    required String fuelType,
    required int mileage,
    required String status,
    required double lat,
    required double lng,
    this.photoUrl = const Value.absent(),
    required DateTime createdAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : vehicleId = Value(vehicleId),
       ownerId = Value(ownerId),
       make = Value(make),
       model = Value(model),
       year = Value(year),
       plate = Value(plate),
       seats = Value(seats),
       transmission = Value(transmission),
       fuelType = Value(fuelType),
       mileage = Value(mileage),
       status = Value(status),
       lat = Value(lat),
       lng = Value(lng),
       createdAt = Value(createdAt);
  static Insertable<VehiclesData> custom({
    Expression<String>? vehicleId,
    Expression<String>? ownerId,
    Expression<String>? make,
    Expression<String>? model,
    Expression<int>? year,
    Expression<String>? plate,
    Expression<int>? seats,
    Expression<String>? transmission,
    Expression<String>? fuelType,
    Expression<int>? mileage,
    Expression<String>? status,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (ownerId != null) 'owner_id': ownerId,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (plate != null) 'plate': plate,
      if (seats != null) 'seats': seats,
      if (transmission != null) 'transmission': transmission,
      if (fuelType != null) 'fuel_type': fuelType,
      if (mileage != null) 'mileage': mileage,
      if (status != null) 'status': status,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCompanion copyWith({
    Value<String>? vehicleId,
    Value<String>? ownerId,
    Value<String>? make,
    Value<String>? model,
    Value<int>? year,
    Value<String>? plate,
    Value<int>? seats,
    Value<String>? transmission,
    Value<String>? fuelType,
    Value<int>? mileage,
    Value<String>? status,
    Value<double>? lat,
    Value<double>? lng,
    Value<String?>? photoUrl,
    Value<DateTime>? createdAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return VehiclesCompanion(
      vehicleId: vehicleId ?? this.vehicleId,
      ownerId: ownerId ?? this.ownerId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      seats: seats ?? this.seats,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      mileage: mileage ?? this.mileage,
      status: status ?? this.status,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (plate.present) {
      map['plate'] = Variable<String>(plate.value);
    }
    if (seats.present) {
      map['seats'] = Variable<int>(seats.value);
    }
    if (transmission.present) {
      map['transmission'] = Variable<String>(transmission.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
    }
    if (mileage.present) {
      map['mileage'] = Variable<int>(mileage.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('vehicleId: $vehicleId, ')
          ..write('ownerId: $ownerId, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('plate: $plate, ')
          ..write('seats: $seats, ')
          ..write('transmission: $transmission, ')
          ..write('fuelType: $fuelType, ')
          ..write('mileage: $mileage, ')
          ..write('status: $status, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastFetchAtMeta = const VerificationMeta(
    'lastFetchAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetchAt = GeneratedColumn<DateTime>(
    'last_fetch_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCursorMeta = const VerificationMeta(
    'pageCursor',
  );
  @override
  late final GeneratedColumn<String> pageCursor = GeneratedColumn<String>(
    'page_cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, lastFetchAt, etag, pageCursor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('last_fetch_at')) {
      context.handle(
        _lastFetchAtMeta,
        lastFetchAt.isAcceptableOrUnknown(
          data['last_fetch_at']!,
          _lastFetchAtMeta,
        ),
      );
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('page_cursor')) {
      context.handle(
        _pageCursorMeta,
        pageCursor.isAcceptableOrUnknown(data['page_cursor']!, _pageCursorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      lastFetchAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetch_at'],
      ),
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      pageCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_cursor'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String entity;
  final DateTime? lastFetchAt;
  final String? etag;
  final String? pageCursor;
  const SyncStateData({
    required this.entity,
    this.lastFetchAt,
    this.etag,
    this.pageCursor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    if (!nullToAbsent || lastFetchAt != null) {
      map['last_fetch_at'] = Variable<DateTime>(lastFetchAt);
    }
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    if (!nullToAbsent || pageCursor != null) {
      map['page_cursor'] = Variable<String>(pageCursor);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      entity: Value(entity),
      lastFetchAt: lastFetchAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFetchAt),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      pageCursor: pageCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCursor),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      entity: serializer.fromJson<String>(json['entity']),
      lastFetchAt: serializer.fromJson<DateTime?>(json['lastFetchAt']),
      etag: serializer.fromJson<String?>(json['etag']),
      pageCursor: serializer.fromJson<String?>(json['pageCursor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'lastFetchAt': serializer.toJson<DateTime?>(lastFetchAt),
      'etag': serializer.toJson<String?>(etag),
      'pageCursor': serializer.toJson<String?>(pageCursor),
    };
  }

  SyncStateData copyWith({
    String? entity,
    Value<DateTime?> lastFetchAt = const Value.absent(),
    Value<String?> etag = const Value.absent(),
    Value<String?> pageCursor = const Value.absent(),
  }) => SyncStateData(
    entity: entity ?? this.entity,
    lastFetchAt: lastFetchAt.present ? lastFetchAt.value : this.lastFetchAt,
    etag: etag.present ? etag.value : this.etag,
    pageCursor: pageCursor.present ? pageCursor.value : this.pageCursor,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      entity: data.entity.present ? data.entity.value : this.entity,
      lastFetchAt: data.lastFetchAt.present
          ? data.lastFetchAt.value
          : this.lastFetchAt,
      etag: data.etag.present ? data.etag.value : this.etag,
      pageCursor: data.pageCursor.present
          ? data.pageCursor.value
          : this.pageCursor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('entity: $entity, ')
          ..write('lastFetchAt: $lastFetchAt, ')
          ..write('etag: $etag, ')
          ..write('pageCursor: $pageCursor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, lastFetchAt, etag, pageCursor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.entity == this.entity &&
          other.lastFetchAt == this.lastFetchAt &&
          other.etag == this.etag &&
          other.pageCursor == this.pageCursor);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> entity;
  final Value<DateTime?> lastFetchAt;
  final Value<String?> etag;
  final Value<String?> pageCursor;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.entity = const Value.absent(),
    this.lastFetchAt = const Value.absent(),
    this.etag = const Value.absent(),
    this.pageCursor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String entity,
    this.lastFetchAt = const Value.absent(),
    this.etag = const Value.absent(),
    this.pageCursor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entity = Value(entity);
  static Insertable<SyncStateData> custom({
    Expression<String>? entity,
    Expression<DateTime>? lastFetchAt,
    Expression<String>? etag,
    Expression<String>? pageCursor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (lastFetchAt != null) 'last_fetch_at': lastFetchAt,
      if (etag != null) 'etag': etag,
      if (pageCursor != null) 'page_cursor': pageCursor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? entity,
    Value<DateTime?>? lastFetchAt,
    Value<String?>? etag,
    Value<String?>? pageCursor,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      entity: entity ?? this.entity,
      lastFetchAt: lastFetchAt ?? this.lastFetchAt,
      etag: etag ?? this.etag,
      pageCursor: pageCursor ?? this.pageCursor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (lastFetchAt.present) {
      map['last_fetch_at'] = Variable<DateTime>(lastFetchAt.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (pageCursor.present) {
      map['page_cursor'] = Variable<String>(pageCursor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('entity: $entity, ')
          ..write('lastFetchAt: $lastFetchAt, ')
          ..write('etag: $etag, ')
          ..write('pageCursor: $pageCursor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOpsTable extends PendingOps
    with TableInfo<$PendingOpsTable, PendingOpsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headersMeta = const VerificationMeta(
    'headers',
  );
  @override
  late final GeneratedColumn<String> headers = GeneratedColumn<String>(
    'headers',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<Uint8List> body = GeneratedColumn<Uint8List>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correlationIdMeta = const VerificationMeta(
    'correlationId',
  );
  @override
  late final GeneratedColumn<String> correlationId = GeneratedColumn<String>(
    'correlation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    method,
    url,
    headers,
    body,
    kind,
    correlationId,
    attempts,
    nextRetryAt,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOpsData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('headers')) {
      context.handle(
        _headersMeta,
        headers.isAcceptableOrUnknown(data['headers']!, _headersMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('correlation_id')) {
      context.handle(
        _correlationIdMeta,
        correlationId.isAcceptableOrUnknown(
          data['correlation_id']!,
          _correlationIdMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOpsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOpsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      headers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}body'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      correlationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correlation_id'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingOpsTable createAlias(String alias) {
    return $PendingOpsTable(attachedDatabase, alias);
  }
}

class PendingOpsData extends DataClass implements Insertable<PendingOpsData> {
  final int id;
  final String method;
  final String url;
  final String? headers;
  final Uint8List? body;
  final String kind;
  final String? correlationId;
  final int attempts;
  final DateTime? nextRetryAt;
  final String status;
  final DateTime createdAt;
  const PendingOpsData({
    required this.id,
    required this.method,
    required this.url,
    this.headers,
    this.body,
    required this.kind,
    this.correlationId,
    required this.attempts,
    this.nextRetryAt,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['method'] = Variable<String>(method);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || headers != null) {
      map['headers'] = Variable<String>(headers);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<Uint8List>(body);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || correlationId != null) {
      map['correlation_id'] = Variable<String>(correlationId);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingOpsCompanion toCompanion(bool nullToAbsent) {
    return PendingOpsCompanion(
      id: Value(id),
      method: Value(method),
      url: Value(url),
      headers: headers == null && nullToAbsent
          ? const Value.absent()
          : Value(headers),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      kind: Value(kind),
      correlationId: correlationId == null && nullToAbsent
          ? const Value.absent()
          : Value(correlationId),
      attempts: Value(attempts),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory PendingOpsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOpsData(
      id: serializer.fromJson<int>(json['id']),
      method: serializer.fromJson<String>(json['method']),
      url: serializer.fromJson<String>(json['url']),
      headers: serializer.fromJson<String?>(json['headers']),
      body: serializer.fromJson<Uint8List?>(json['body']),
      kind: serializer.fromJson<String>(json['kind']),
      correlationId: serializer.fromJson<String?>(json['correlationId']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'method': serializer.toJson<String>(method),
      'url': serializer.toJson<String>(url),
      'headers': serializer.toJson<String?>(headers),
      'body': serializer.toJson<Uint8List?>(body),
      'kind': serializer.toJson<String>(kind),
      'correlationId': serializer.toJson<String?>(correlationId),
      'attempts': serializer.toJson<int>(attempts),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingOpsData copyWith({
    int? id,
    String? method,
    String? url,
    Value<String?> headers = const Value.absent(),
    Value<Uint8List?> body = const Value.absent(),
    String? kind,
    Value<String?> correlationId = const Value.absent(),
    int? attempts,
    Value<DateTime?> nextRetryAt = const Value.absent(),
    String? status,
    DateTime? createdAt,
  }) => PendingOpsData(
    id: id ?? this.id,
    method: method ?? this.method,
    url: url ?? this.url,
    headers: headers.present ? headers.value : this.headers,
    body: body.present ? body.value : this.body,
    kind: kind ?? this.kind,
    correlationId: correlationId.present
        ? correlationId.value
        : this.correlationId,
    attempts: attempts ?? this.attempts,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingOpsData copyWithCompanion(PendingOpsCompanion data) {
    return PendingOpsData(
      id: data.id.present ? data.id.value : this.id,
      method: data.method.present ? data.method.value : this.method,
      url: data.url.present ? data.url.value : this.url,
      headers: data.headers.present ? data.headers.value : this.headers,
      body: data.body.present ? data.body.value : this.body,
      kind: data.kind.present ? data.kind.value : this.kind,
      correlationId: data.correlationId.present
          ? data.correlationId.value
          : this.correlationId,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOpsData(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('headers: $headers, ')
          ..write('body: $body, ')
          ..write('kind: $kind, ')
          ..write('correlationId: $correlationId, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    method,
    url,
    headers,
    $driftBlobEquality.hash(body),
    kind,
    correlationId,
    attempts,
    nextRetryAt,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOpsData &&
          other.id == this.id &&
          other.method == this.method &&
          other.url == this.url &&
          other.headers == this.headers &&
          $driftBlobEquality.equals(other.body, this.body) &&
          other.kind == this.kind &&
          other.correlationId == this.correlationId &&
          other.attempts == this.attempts &&
          other.nextRetryAt == this.nextRetryAt &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class PendingOpsCompanion extends UpdateCompanion<PendingOpsData> {
  final Value<int> id;
  final Value<String> method;
  final Value<String> url;
  final Value<String?> headers;
  final Value<Uint8List?> body;
  final Value<String> kind;
  final Value<String?> correlationId;
  final Value<int> attempts;
  final Value<DateTime?> nextRetryAt;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const PendingOpsCompanion({
    this.id = const Value.absent(),
    this.method = const Value.absent(),
    this.url = const Value.absent(),
    this.headers = const Value.absent(),
    this.body = const Value.absent(),
    this.kind = const Value.absent(),
    this.correlationId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingOpsCompanion.insert({
    this.id = const Value.absent(),
    required String method,
    required String url,
    this.headers = const Value.absent(),
    this.body = const Value.absent(),
    required String kind,
    this.correlationId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : method = Value(method),
       url = Value(url),
       kind = Value(kind);
  static Insertable<PendingOpsData> custom({
    Expression<int>? id,
    Expression<String>? method,
    Expression<String>? url,
    Expression<String>? headers,
    Expression<Uint8List>? body,
    Expression<String>? kind,
    Expression<String>? correlationId,
    Expression<int>? attempts,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (method != null) 'method': method,
      if (url != null) 'url': url,
      if (headers != null) 'headers': headers,
      if (body != null) 'body': body,
      if (kind != null) 'kind': kind,
      if (correlationId != null) 'correlation_id': correlationId,
      if (attempts != null) 'attempts': attempts,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingOpsCompanion copyWith({
    Value<int>? id,
    Value<String>? method,
    Value<String>? url,
    Value<String?>? headers,
    Value<Uint8List?>? body,
    Value<String>? kind,
    Value<String?>? correlationId,
    Value<int>? attempts,
    Value<DateTime?>? nextRetryAt,
    Value<String>? status,
    Value<DateTime>? createdAt,
  }) {
    return PendingOpsCompanion(
      id: id ?? this.id,
      method: method ?? this.method,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      kind: kind ?? this.kind,
      correlationId: correlationId ?? this.correlationId,
      attempts: attempts ?? this.attempts,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (headers.present) {
      map['headers'] = Variable<String>(headers.value);
    }
    if (body.present) {
      map['body'] = Variable<Uint8List>(body.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (correlationId.present) {
      map['correlation_id'] = Variable<String>(correlationId.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOpsCompanion(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('headers: $headers, ')
          ..write('body: $body, ')
          ..write('kind: $kind, ')
          ..write('correlationId: $correlationId, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VehicleAvailabilityTable extends VehicleAvailability
    with TableInfo<$VehicleAvailabilityTable, VehicleAvailabilityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleAvailabilityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _availabilityIdMeta = const VerificationMeta(
    'availabilityId',
  );
  @override
  late final GeneratedColumn<String> availabilityId = GeneratedColumn<String>(
    'availability_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTsMeta = const VerificationMeta(
    'startTs',
  );
  @override
  late final GeneratedColumn<DateTime> startTs = GeneratedColumn<DateTime>(
    'start_ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTsMeta = const VerificationMeta('endTs');
  @override
  late final GeneratedColumn<DateTime> endTs = GeneratedColumn<DateTime>(
    'end_ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    availabilityId,
    vehicleId,
    startTs,
    endTs,
    type,
    notes,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_availability';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleAvailabilityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('availability_id')) {
      context.handle(
        _availabilityIdMeta,
        availabilityId.isAcceptableOrUnknown(
          data['availability_id']!,
          _availabilityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_availabilityIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('start_ts')) {
      context.handle(
        _startTsMeta,
        startTs.isAcceptableOrUnknown(data['start_ts']!, _startTsMeta),
      );
    } else if (isInserting) {
      context.missing(_startTsMeta);
    }
    if (data.containsKey('end_ts')) {
      context.handle(
        _endTsMeta,
        endTs.isAcceptableOrUnknown(data['end_ts']!, _endTsMeta),
      );
    } else if (isInserting) {
      context.missing(_endTsMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {availabilityId};
  @override
  VehicleAvailabilityData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleAvailabilityData(
      availabilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}availability_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      startTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_ts'],
      )!,
      endTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_ts'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $VehicleAvailabilityTable createAlias(String alias) {
    return $VehicleAvailabilityTable(attachedDatabase, alias);
  }
}

class VehicleAvailabilityData extends DataClass
    implements Insertable<VehicleAvailabilityData> {
  final String availabilityId;
  final String vehicleId;
  final DateTime startTs;
  final DateTime endTs;
  final String type;
  final String? notes;
  final bool isDeleted;
  const VehicleAvailabilityData({
    required this.availabilityId,
    required this.vehicleId,
    required this.startTs,
    required this.endTs,
    required this.type,
    this.notes,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['availability_id'] = Variable<String>(availabilityId);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['start_ts'] = Variable<DateTime>(startTs);
    map['end_ts'] = Variable<DateTime>(endTs);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  VehicleAvailabilityCompanion toCompanion(bool nullToAbsent) {
    return VehicleAvailabilityCompanion(
      availabilityId: Value(availabilityId),
      vehicleId: Value(vehicleId),
      startTs: Value(startTs),
      endTs: Value(endTs),
      type: Value(type),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isDeleted: Value(isDeleted),
    );
  }

  factory VehicleAvailabilityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleAvailabilityData(
      availabilityId: serializer.fromJson<String>(json['availabilityId']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      startTs: serializer.fromJson<DateTime>(json['startTs']),
      endTs: serializer.fromJson<DateTime>(json['endTs']),
      type: serializer.fromJson<String>(json['type']),
      notes: serializer.fromJson<String?>(json['notes']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'availabilityId': serializer.toJson<String>(availabilityId),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'startTs': serializer.toJson<DateTime>(startTs),
      'endTs': serializer.toJson<DateTime>(endTs),
      'type': serializer.toJson<String>(type),
      'notes': serializer.toJson<String?>(notes),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  VehicleAvailabilityData copyWith({
    String? availabilityId,
    String? vehicleId,
    DateTime? startTs,
    DateTime? endTs,
    String? type,
    Value<String?> notes = const Value.absent(),
    bool? isDeleted,
  }) => VehicleAvailabilityData(
    availabilityId: availabilityId ?? this.availabilityId,
    vehicleId: vehicleId ?? this.vehicleId,
    startTs: startTs ?? this.startTs,
    endTs: endTs ?? this.endTs,
    type: type ?? this.type,
    notes: notes.present ? notes.value : this.notes,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  VehicleAvailabilityData copyWithCompanion(VehicleAvailabilityCompanion data) {
    return VehicleAvailabilityData(
      availabilityId: data.availabilityId.present
          ? data.availabilityId.value
          : this.availabilityId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      startTs: data.startTs.present ? data.startTs.value : this.startTs,
      endTs: data.endTs.present ? data.endTs.value : this.endTs,
      type: data.type.present ? data.type.value : this.type,
      notes: data.notes.present ? data.notes.value : this.notes,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleAvailabilityData(')
          ..write('availabilityId: $availabilityId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('startTs: $startTs, ')
          ..write('endTs: $endTs, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    availabilityId,
    vehicleId,
    startTs,
    endTs,
    type,
    notes,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleAvailabilityData &&
          other.availabilityId == this.availabilityId &&
          other.vehicleId == this.vehicleId &&
          other.startTs == this.startTs &&
          other.endTs == this.endTs &&
          other.type == this.type &&
          other.notes == this.notes &&
          other.isDeleted == this.isDeleted);
}

class VehicleAvailabilityCompanion
    extends UpdateCompanion<VehicleAvailabilityData> {
  final Value<String> availabilityId;
  final Value<String> vehicleId;
  final Value<DateTime> startTs;
  final Value<DateTime> endTs;
  final Value<String> type;
  final Value<String?> notes;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const VehicleAvailabilityCompanion({
    this.availabilityId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.startTs = const Value.absent(),
    this.endTs = const Value.absent(),
    this.type = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehicleAvailabilityCompanion.insert({
    required String availabilityId,
    required String vehicleId,
    required DateTime startTs,
    required DateTime endTs,
    required String type,
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : availabilityId = Value(availabilityId),
       vehicleId = Value(vehicleId),
       startTs = Value(startTs),
       endTs = Value(endTs),
       type = Value(type);
  static Insertable<VehicleAvailabilityData> custom({
    Expression<String>? availabilityId,
    Expression<String>? vehicleId,
    Expression<DateTime>? startTs,
    Expression<DateTime>? endTs,
    Expression<String>? type,
    Expression<String>? notes,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (availabilityId != null) 'availability_id': availabilityId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (startTs != null) 'start_ts': startTs,
      if (endTs != null) 'end_ts': endTs,
      if (type != null) 'type': type,
      if (notes != null) 'notes': notes,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehicleAvailabilityCompanion copyWith({
    Value<String>? availabilityId,
    Value<String>? vehicleId,
    Value<DateTime>? startTs,
    Value<DateTime>? endTs,
    Value<String>? type,
    Value<String?>? notes,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return VehicleAvailabilityCompanion(
      availabilityId: availabilityId ?? this.availabilityId,
      vehicleId: vehicleId ?? this.vehicleId,
      startTs: startTs ?? this.startTs,
      endTs: endTs ?? this.endTs,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (availabilityId.present) {
      map['availability_id'] = Variable<String>(availabilityId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (startTs.present) {
      map['start_ts'] = Variable<DateTime>(startTs.value);
    }
    if (endTs.present) {
      map['end_ts'] = Variable<DateTime>(endTs.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleAvailabilityCompanion(')
          ..write('availabilityId: $availabilityId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('startTs: $startTs, ')
          ..write('endTs: $endTs, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, ConversationsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userLowIdMeta = const VerificationMeta(
    'userLowId',
  );
  @override
  late final GeneratedColumn<String> userLowId = GeneratedColumn<String>(
    'user_low_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userHighIdMeta = const VerificationMeta(
    'userHighId',
  );
  @override
  late final GeneratedColumn<String> userHighId = GeneratedColumn<String>(
    'user_high_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>(
        'last_message_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    conversationId,
    userLowId,
    userHighId,
    createdAt,
    lastMessageAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationsData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('user_low_id')) {
      context.handle(
        _userLowIdMeta,
        userLowId.isAcceptableOrUnknown(data['user_low_id']!, _userLowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userLowIdMeta);
    }
    if (data.containsKey('user_high_id')) {
      context.handle(
        _userHighIdMeta,
        userHighId.isAcceptableOrUnknown(
          data['user_high_id']!,
          _userHighIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userHighIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId};
  @override
  ConversationsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationsData(
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      userLowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_low_id'],
      )!,
      userHighId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_high_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_at'],
      ),
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class ConversationsData extends DataClass
    implements Insertable<ConversationsData> {
  final String conversationId;
  final String userLowId;
  final String userHighId;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  const ConversationsData({
    required this.conversationId,
    required this.userLowId,
    required this.userHighId,
    required this.createdAt,
    this.lastMessageAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conversation_id'] = Variable<String>(conversationId);
    map['user_low_id'] = Variable<String>(userLowId);
    map['user_high_id'] = Variable<String>(userHighId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      conversationId: Value(conversationId),
      userLowId: Value(userLowId),
      userHighId: Value(userHighId),
      createdAt: Value(createdAt),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
    );
  }

  factory ConversationsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationsData(
      conversationId: serializer.fromJson<String>(json['conversationId']),
      userLowId: serializer.fromJson<String>(json['userLowId']),
      userHighId: serializer.fromJson<String>(json['userHighId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conversationId': serializer.toJson<String>(conversationId),
      'userLowId': serializer.toJson<String>(userLowId),
      'userHighId': serializer.toJson<String>(userHighId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
    };
  }

  ConversationsData copyWith({
    String? conversationId,
    String? userLowId,
    String? userHighId,
    DateTime? createdAt,
    Value<DateTime?> lastMessageAt = const Value.absent(),
  }) => ConversationsData(
    conversationId: conversationId ?? this.conversationId,
    userLowId: userLowId ?? this.userLowId,
    userHighId: userHighId ?? this.userHighId,
    createdAt: createdAt ?? this.createdAt,
    lastMessageAt: lastMessageAt.present
        ? lastMessageAt.value
        : this.lastMessageAt,
  );
  ConversationsData copyWithCompanion(ConversationsCompanion data) {
    return ConversationsData(
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      userLowId: data.userLowId.present ? data.userLowId.value : this.userLowId,
      userHighId: data.userHighId.present
          ? data.userHighId.value
          : this.userHighId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsData(')
          ..write('conversationId: $conversationId, ')
          ..write('userLowId: $userLowId, ')
          ..write('userHighId: $userHighId, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastMessageAt: $lastMessageAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conversationId,
    userLowId,
    userHighId,
    createdAt,
    lastMessageAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationsData &&
          other.conversationId == this.conversationId &&
          other.userLowId == this.userLowId &&
          other.userHighId == this.userHighId &&
          other.createdAt == this.createdAt &&
          other.lastMessageAt == this.lastMessageAt);
}

class ConversationsCompanion extends UpdateCompanion<ConversationsData> {
  final Value<String> conversationId;
  final Value<String> userLowId;
  final Value<String> userHighId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastMessageAt;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.conversationId = const Value.absent(),
    this.userLowId = const Value.absent(),
    this.userHighId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String conversationId,
    required String userLowId,
    required String userHighId,
    required DateTime createdAt,
    this.lastMessageAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conversationId = Value(conversationId),
       userLowId = Value(userLowId),
       userHighId = Value(userHighId),
       createdAt = Value(createdAt);
  static Insertable<ConversationsData> custom({
    Expression<String>? conversationId,
    Expression<String>? userLowId,
    Expression<String>? userHighId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastMessageAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conversationId != null) 'conversation_id': conversationId,
      if (userLowId != null) 'user_low_id': userLowId,
      if (userHighId != null) 'user_high_id': userHighId,
      if (createdAt != null) 'created_at': createdAt,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<String>? conversationId,
    Value<String>? userLowId,
    Value<String>? userHighId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastMessageAt,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      conversationId: conversationId ?? this.conversationId,
      userLowId: userLowId ?? this.userLowId,
      userHighId: userHighId ?? this.userHighId,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (userLowId.present) {
      map['user_low_id'] = Variable<String>(userLowId.value);
    }
    if (userHighId.present) {
      map['user_high_id'] = Variable<String>(userHighId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('conversationId: $conversationId, ')
          ..write('userLowId: $userLowId, ')
          ..write('userHighId: $userHighId, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessagesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receiverIdMeta = const VerificationMeta(
    'receiverId',
  );
  @override
  late final GeneratedColumn<String> receiverId = GeneratedColumn<String>(
    'receiver_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metaMeta = const VerificationMeta('meta');
  @override
  late final GeneratedColumn<String> meta = GeneratedColumn<String>(
    'meta',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageId,
    conversationId,
    senderId,
    receiverId,
    content,
    meta,
    createdAt,
    readAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessagesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('receiver_id')) {
      context.handle(
        _receiverIdMeta,
        receiverId.isAcceptableOrUnknown(data['receiver_id']!, _receiverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_receiverIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('meta')) {
      context.handle(
        _metaMeta,
        meta.isAcceptableOrUnknown(data['meta']!, _metaMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId};
  @override
  MessagesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessagesData(
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      ),
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      receiverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receiver_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      meta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class MessagesData extends DataClass implements Insertable<MessagesData> {
  final String messageId;
  final String? conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final String? meta;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isDeleted;
  const MessagesData({
    required this.messageId,
    this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.meta,
    required this.createdAt,
    this.readAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<String>(conversationId);
    }
    map['sender_id'] = Variable<String>(senderId);
    map['receiver_id'] = Variable<String>(receiverId);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || meta != null) {
      map['meta'] = Variable<String>(meta);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      messageId: Value(messageId),
      conversationId: conversationId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationId),
      senderId: Value(senderId),
      receiverId: Value(receiverId),
      content: Value(content),
      meta: meta == null && nullToAbsent ? const Value.absent() : Value(meta),
      createdAt: Value(createdAt),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory MessagesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessagesData(
      messageId: serializer.fromJson<String>(json['messageId']),
      conversationId: serializer.fromJson<String?>(json['conversationId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      receiverId: serializer.fromJson<String>(json['receiverId']),
      content: serializer.fromJson<String>(json['content']),
      meta: serializer.fromJson<String?>(json['meta']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'conversationId': serializer.toJson<String?>(conversationId),
      'senderId': serializer.toJson<String>(senderId),
      'receiverId': serializer.toJson<String>(receiverId),
      'content': serializer.toJson<String>(content),
      'meta': serializer.toJson<String?>(meta),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  MessagesData copyWith({
    String? messageId,
    Value<String?> conversationId = const Value.absent(),
    String? senderId,
    String? receiverId,
    String? content,
    Value<String?> meta = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> readAt = const Value.absent(),
    bool? isDeleted,
  }) => MessagesData(
    messageId: messageId ?? this.messageId,
    conversationId: conversationId.present
        ? conversationId.value
        : this.conversationId,
    senderId: senderId ?? this.senderId,
    receiverId: receiverId ?? this.receiverId,
    content: content ?? this.content,
    meta: meta.present ? meta.value : this.meta,
    createdAt: createdAt ?? this.createdAt,
    readAt: readAt.present ? readAt.value : this.readAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  MessagesData copyWithCompanion(MessagesCompanion data) {
    return MessagesData(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      receiverId: data.receiverId.present
          ? data.receiverId.value
          : this.receiverId,
      content: data.content.present ? data.content.value : this.content,
      meta: data.meta.present ? data.meta.value : this.meta,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessagesData(')
          ..write('messageId: $messageId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('receiverId: $receiverId, ')
          ..write('content: $content, ')
          ..write('meta: $meta, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    messageId,
    conversationId,
    senderId,
    receiverId,
    content,
    meta,
    createdAt,
    readAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessagesData &&
          other.messageId == this.messageId &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.receiverId == this.receiverId &&
          other.content == this.content &&
          other.meta == this.meta &&
          other.createdAt == this.createdAt &&
          other.readAt == this.readAt &&
          other.isDeleted == this.isDeleted);
}

class MessagesCompanion extends UpdateCompanion<MessagesData> {
  final Value<String> messageId;
  final Value<String?> conversationId;
  final Value<String> senderId;
  final Value<String> receiverId;
  final Value<String> content;
  final Value<String?> meta;
  final Value<DateTime> createdAt;
  final Value<DateTime?> readAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const MessagesCompanion({
    this.messageId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.receiverId = const Value.absent(),
    this.content = const Value.absent(),
    this.meta = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String messageId,
    this.conversationId = const Value.absent(),
    required String senderId,
    required String receiverId,
    required String content,
    this.meta = const Value.absent(),
    required DateTime createdAt,
    this.readAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : messageId = Value(messageId),
       senderId = Value(senderId),
       receiverId = Value(receiverId),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<MessagesData> custom({
    Expression<String>? messageId,
    Expression<String>? conversationId,
    Expression<String>? senderId,
    Expression<String>? receiverId,
    Expression<String>? content,
    Expression<String>? meta,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? readAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (receiverId != null) 'receiver_id': receiverId,
      if (content != null) 'content': content,
      if (meta != null) 'meta': meta,
      if (createdAt != null) 'created_at': createdAt,
      if (readAt != null) 'read_at': readAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? messageId,
    Value<String?>? conversationId,
    Value<String>? senderId,
    Value<String>? receiverId,
    Value<String>? content,
    Value<String?>? meta,
    Value<DateTime>? createdAt,
    Value<DateTime?>? readAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      meta: meta ?? this.meta,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (receiverId.present) {
      map['receiver_id'] = Variable<String>(receiverId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(meta.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('messageId: $messageId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('receiverId: $receiverId, ')
          ..write('content: $content, ')
          ..write('meta: $meta, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PricingsTable extends Pricings
    with TableInfo<$PricingsTable, PricingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PricingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pricingIdMeta = const VerificationMeta(
    'pricingId',
  );
  @override
  late final GeneratedColumn<String> pricingId = GeneratedColumn<String>(
    'pricing_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyPriceMeta = const VerificationMeta(
    'dailyPrice',
  );
  @override
  late final GeneratedColumn<double> dailyPrice = GeneratedColumn<double>(
    'daily_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minDaysMeta = const VerificationMeta(
    'minDays',
  );
  @override
  late final GeneratedColumn<int> minDays = GeneratedColumn<int>(
    'min_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxDaysMeta = const VerificationMeta(
    'maxDays',
  );
  @override
  late final GeneratedColumn<int> maxDays = GeneratedColumn<int>(
    'max_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    pricingId,
    vehicleId,
    dailyPrice,
    minDays,
    maxDays,
    currency,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pricings';
  @override
  VerificationContext validateIntegrity(
    Insertable<PricingData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pricing_id')) {
      context.handle(
        _pricingIdMeta,
        pricingId.isAcceptableOrUnknown(data['pricing_id']!, _pricingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pricingIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('daily_price')) {
      context.handle(
        _dailyPriceMeta,
        dailyPrice.isAcceptableOrUnknown(data['daily_price']!, _dailyPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_dailyPriceMeta);
    }
    if (data.containsKey('min_days')) {
      context.handle(
        _minDaysMeta,
        minDays.isAcceptableOrUnknown(data['min_days']!, _minDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_minDaysMeta);
    }
    if (data.containsKey('max_days')) {
      context.handle(
        _maxDaysMeta,
        maxDays.isAcceptableOrUnknown(data['max_days']!, _maxDaysMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pricingId};
  @override
  PricingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PricingData(
      pricingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pricing_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      dailyPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daily_price'],
      )!,
      minDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_days'],
      )!,
      maxDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_days'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $PricingsTable createAlias(String alias) {
    return $PricingsTable(attachedDatabase, alias);
  }
}

class PricingData extends DataClass implements Insertable<PricingData> {
  final String pricingId;
  final String vehicleId;
  final double dailyPrice;
  final int minDays;
  final int? maxDays;
  final String currency;
  final bool isDeleted;
  const PricingData({
    required this.pricingId,
    required this.vehicleId,
    required this.dailyPrice,
    required this.minDays,
    this.maxDays,
    required this.currency,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pricing_id'] = Variable<String>(pricingId);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['daily_price'] = Variable<double>(dailyPrice);
    map['min_days'] = Variable<int>(minDays);
    if (!nullToAbsent || maxDays != null) {
      map['max_days'] = Variable<int>(maxDays);
    }
    map['currency'] = Variable<String>(currency);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  PricingsCompanion toCompanion(bool nullToAbsent) {
    return PricingsCompanion(
      pricingId: Value(pricingId),
      vehicleId: Value(vehicleId),
      dailyPrice: Value(dailyPrice),
      minDays: Value(minDays),
      maxDays: maxDays == null && nullToAbsent
          ? const Value.absent()
          : Value(maxDays),
      currency: Value(currency),
      isDeleted: Value(isDeleted),
    );
  }

  factory PricingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PricingData(
      pricingId: serializer.fromJson<String>(json['pricingId']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      dailyPrice: serializer.fromJson<double>(json['dailyPrice']),
      minDays: serializer.fromJson<int>(json['minDays']),
      maxDays: serializer.fromJson<int?>(json['maxDays']),
      currency: serializer.fromJson<String>(json['currency']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pricingId': serializer.toJson<String>(pricingId),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'dailyPrice': serializer.toJson<double>(dailyPrice),
      'minDays': serializer.toJson<int>(minDays),
      'maxDays': serializer.toJson<int?>(maxDays),
      'currency': serializer.toJson<String>(currency),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  PricingData copyWith({
    String? pricingId,
    String? vehicleId,
    double? dailyPrice,
    int? minDays,
    Value<int?> maxDays = const Value.absent(),
    String? currency,
    bool? isDeleted,
  }) => PricingData(
    pricingId: pricingId ?? this.pricingId,
    vehicleId: vehicleId ?? this.vehicleId,
    dailyPrice: dailyPrice ?? this.dailyPrice,
    minDays: minDays ?? this.minDays,
    maxDays: maxDays.present ? maxDays.value : this.maxDays,
    currency: currency ?? this.currency,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  PricingData copyWithCompanion(PricingsCompanion data) {
    return PricingData(
      pricingId: data.pricingId.present ? data.pricingId.value : this.pricingId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      dailyPrice: data.dailyPrice.present
          ? data.dailyPrice.value
          : this.dailyPrice,
      minDays: data.minDays.present ? data.minDays.value : this.minDays,
      maxDays: data.maxDays.present ? data.maxDays.value : this.maxDays,
      currency: data.currency.present ? data.currency.value : this.currency,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PricingData(')
          ..write('pricingId: $pricingId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('dailyPrice: $dailyPrice, ')
          ..write('minDays: $minDays, ')
          ..write('maxDays: $maxDays, ')
          ..write('currency: $currency, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pricingId,
    vehicleId,
    dailyPrice,
    minDays,
    maxDays,
    currency,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PricingData &&
          other.pricingId == this.pricingId &&
          other.vehicleId == this.vehicleId &&
          other.dailyPrice == this.dailyPrice &&
          other.minDays == this.minDays &&
          other.maxDays == this.maxDays &&
          other.currency == this.currency &&
          other.isDeleted == this.isDeleted);
}

class PricingsCompanion extends UpdateCompanion<PricingData> {
  final Value<String> pricingId;
  final Value<String> vehicleId;
  final Value<double> dailyPrice;
  final Value<int> minDays;
  final Value<int?> maxDays;
  final Value<String> currency;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const PricingsCompanion({
    this.pricingId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.dailyPrice = const Value.absent(),
    this.minDays = const Value.absent(),
    this.maxDays = const Value.absent(),
    this.currency = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PricingsCompanion.insert({
    required String pricingId,
    required String vehicleId,
    required double dailyPrice,
    required int minDays,
    this.maxDays = const Value.absent(),
    required String currency,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pricingId = Value(pricingId),
       vehicleId = Value(vehicleId),
       dailyPrice = Value(dailyPrice),
       minDays = Value(minDays),
       currency = Value(currency);
  static Insertable<PricingData> custom({
    Expression<String>? pricingId,
    Expression<String>? vehicleId,
    Expression<double>? dailyPrice,
    Expression<int>? minDays,
    Expression<int>? maxDays,
    Expression<String>? currency,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pricingId != null) 'pricing_id': pricingId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (dailyPrice != null) 'daily_price': dailyPrice,
      if (minDays != null) 'min_days': minDays,
      if (maxDays != null) 'max_days': maxDays,
      if (currency != null) 'currency': currency,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PricingsCompanion copyWith({
    Value<String>? pricingId,
    Value<String>? vehicleId,
    Value<double>? dailyPrice,
    Value<int>? minDays,
    Value<int?>? maxDays,
    Value<String>? currency,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return PricingsCompanion(
      pricingId: pricingId ?? this.pricingId,
      vehicleId: vehicleId ?? this.vehicleId,
      dailyPrice: dailyPrice ?? this.dailyPrice,
      minDays: minDays ?? this.minDays,
      maxDays: maxDays ?? this.maxDays,
      currency: currency ?? this.currency,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pricingId.present) {
      map['pricing_id'] = Variable<String>(pricingId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (dailyPrice.present) {
      map['daily_price'] = Variable<double>(dailyPrice.value);
    }
    if (minDays.present) {
      map['min_days'] = Variable<int>(minDays.value);
    }
    if (maxDays.present) {
      map['max_days'] = Variable<int>(maxDays.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PricingsCompanion(')
          ..write('pricingId: $pricingId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('dailyPrice: $dailyPrice, ')
          ..write('minDays: $minDays, ')
          ..write('maxDays: $maxDays, ')
          ..write('currency: $currency, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookingsTable extends Bookings
    with TableInfo<$BookingsTable, BookingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookingIdMeta = const VerificationMeta(
    'bookingId',
  );
  @override
  late final GeneratedColumn<String> bookingId = GeneratedColumn<String>(
    'booking_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _renterIdMeta = const VerificationMeta(
    'renterId',
  );
  @override
  late final GeneratedColumn<String> renterId = GeneratedColumn<String>(
    'renter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostIdMeta = const VerificationMeta('hostId');
  @override
  late final GeneratedColumn<String> hostId = GeneratedColumn<String>(
    'host_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTsMeta = const VerificationMeta(
    'startTs',
  );
  @override
  late final GeneratedColumn<DateTime> startTs = GeneratedColumn<DateTime>(
    'start_ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTsMeta = const VerificationMeta('endTs');
  @override
  late final GeneratedColumn<DateTime> endTs = GeneratedColumn<DateTime>(
    'end_ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyPriceSnapshotMeta =
      const VerificationMeta('dailyPriceSnapshot');
  @override
  late final GeneratedColumn<double> dailyPriceSnapshot =
      GeneratedColumn<double>(
        'daily_price_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _insuranceDailyCostSnapshotMeta =
      const VerificationMeta('insuranceDailyCostSnapshot');
  @override
  late final GeneratedColumn<double> insuranceDailyCostSnapshot =
      GeneratedColumn<double>(
        'insurance_daily_cost_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feesMeta = const VerificationMeta('fees');
  @override
  late final GeneratedColumn<double> fees = GeneratedColumn<double>(
    'fees',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxesMeta = const VerificationMeta('taxes');
  @override
  late final GeneratedColumn<double> taxes = GeneratedColumn<double>(
    'taxes',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odoStartMeta = const VerificationMeta(
    'odoStart',
  );
  @override
  late final GeneratedColumn<int> odoStart = GeneratedColumn<int>(
    'odo_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _odoEndMeta = const VerificationMeta('odoEnd');
  @override
  late final GeneratedColumn<int> odoEnd = GeneratedColumn<int>(
    'odo_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuelStartMeta = const VerificationMeta(
    'fuelStart',
  );
  @override
  late final GeneratedColumn<int> fuelStart = GeneratedColumn<int>(
    'fuel_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuelEndMeta = const VerificationMeta(
    'fuelEnd',
  );
  @override
  late final GeneratedColumn<int> fuelEnd = GeneratedColumn<int>(
    'fuel_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookingId,
    vehicleId,
    renterId,
    hostId,
    startTs,
    endTs,
    dailyPriceSnapshot,
    insuranceDailyCostSnapshot,
    subtotal,
    fees,
    taxes,
    total,
    currency,
    odoStart,
    odoEnd,
    fuelStart,
    fuelEnd,
    status,
    createdAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookings';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookingsData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('booking_id')) {
      context.handle(
        _bookingIdMeta,
        bookingId.isAcceptableOrUnknown(data['booking_id']!, _bookingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookingIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('renter_id')) {
      context.handle(
        _renterIdMeta,
        renterId.isAcceptableOrUnknown(data['renter_id']!, _renterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_renterIdMeta);
    }
    if (data.containsKey('host_id')) {
      context.handle(
        _hostIdMeta,
        hostId.isAcceptableOrUnknown(data['host_id']!, _hostIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hostIdMeta);
    }
    if (data.containsKey('start_ts')) {
      context.handle(
        _startTsMeta,
        startTs.isAcceptableOrUnknown(data['start_ts']!, _startTsMeta),
      );
    } else if (isInserting) {
      context.missing(_startTsMeta);
    }
    if (data.containsKey('end_ts')) {
      context.handle(
        _endTsMeta,
        endTs.isAcceptableOrUnknown(data['end_ts']!, _endTsMeta),
      );
    } else if (isInserting) {
      context.missing(_endTsMeta);
    }
    if (data.containsKey('daily_price_snapshot')) {
      context.handle(
        _dailyPriceSnapshotMeta,
        dailyPriceSnapshot.isAcceptableOrUnknown(
          data['daily_price_snapshot']!,
          _dailyPriceSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyPriceSnapshotMeta);
    }
    if (data.containsKey('insurance_daily_cost_snapshot')) {
      context.handle(
        _insuranceDailyCostSnapshotMeta,
        insuranceDailyCostSnapshot.isAcceptableOrUnknown(
          data['insurance_daily_cost_snapshot']!,
          _insuranceDailyCostSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('fees')) {
      context.handle(
        _feesMeta,
        fees.isAcceptableOrUnknown(data['fees']!, _feesMeta),
      );
    }
    if (data.containsKey('taxes')) {
      context.handle(
        _taxesMeta,
        taxes.isAcceptableOrUnknown(data['taxes']!, _taxesMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('odo_start')) {
      context.handle(
        _odoStartMeta,
        odoStart.isAcceptableOrUnknown(data['odo_start']!, _odoStartMeta),
      );
    }
    if (data.containsKey('odo_end')) {
      context.handle(
        _odoEndMeta,
        odoEnd.isAcceptableOrUnknown(data['odo_end']!, _odoEndMeta),
      );
    }
    if (data.containsKey('fuel_start')) {
      context.handle(
        _fuelStartMeta,
        fuelStart.isAcceptableOrUnknown(data['fuel_start']!, _fuelStartMeta),
      );
    }
    if (data.containsKey('fuel_end')) {
      context.handle(
        _fuelEndMeta,
        fuelEnd.isAcceptableOrUnknown(data['fuel_end']!, _fuelEndMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookingId};
  @override
  BookingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookingsData(
      bookingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}booking_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      renterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}renter_id'],
      )!,
      hostId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host_id'],
      )!,
      startTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_ts'],
      )!,
      endTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_ts'],
      )!,
      dailyPriceSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daily_price_snapshot'],
      )!,
      insuranceDailyCostSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}insurance_daily_cost_snapshot'],
      ),
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      fees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fees'],
      ),
      taxes: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taxes'],
      ),
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      odoStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odo_start'],
      ),
      odoEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odo_end'],
      ),
      fuelStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fuel_start'],
      ),
      fuelEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fuel_end'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $BookingsTable createAlias(String alias) {
    return $BookingsTable(attachedDatabase, alias);
  }
}

class BookingsData extends DataClass implements Insertable<BookingsData> {
  final String bookingId;
  final String vehicleId;
  final String renterId;
  final String hostId;
  final DateTime startTs;
  final DateTime endTs;
  final double dailyPriceSnapshot;
  final double? insuranceDailyCostSnapshot;
  final double subtotal;
  final double? fees;
  final double? taxes;
  final double total;
  final String currency;
  final int? odoStart;
  final int? odoEnd;
  final int? fuelStart;
  final int? fuelEnd;
  final String status;
  final DateTime createdAt;
  final bool isDeleted;
  const BookingsData({
    required this.bookingId,
    required this.vehicleId,
    required this.renterId,
    required this.hostId,
    required this.startTs,
    required this.endTs,
    required this.dailyPriceSnapshot,
    this.insuranceDailyCostSnapshot,
    required this.subtotal,
    this.fees,
    this.taxes,
    required this.total,
    required this.currency,
    this.odoStart,
    this.odoEnd,
    this.fuelStart,
    this.fuelEnd,
    required this.status,
    required this.createdAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['booking_id'] = Variable<String>(bookingId);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['renter_id'] = Variable<String>(renterId);
    map['host_id'] = Variable<String>(hostId);
    map['start_ts'] = Variable<DateTime>(startTs);
    map['end_ts'] = Variable<DateTime>(endTs);
    map['daily_price_snapshot'] = Variable<double>(dailyPriceSnapshot);
    if (!nullToAbsent || insuranceDailyCostSnapshot != null) {
      map['insurance_daily_cost_snapshot'] = Variable<double>(
        insuranceDailyCostSnapshot,
      );
    }
    map['subtotal'] = Variable<double>(subtotal);
    if (!nullToAbsent || fees != null) {
      map['fees'] = Variable<double>(fees);
    }
    if (!nullToAbsent || taxes != null) {
      map['taxes'] = Variable<double>(taxes);
    }
    map['total'] = Variable<double>(total);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || odoStart != null) {
      map['odo_start'] = Variable<int>(odoStart);
    }
    if (!nullToAbsent || odoEnd != null) {
      map['odo_end'] = Variable<int>(odoEnd);
    }
    if (!nullToAbsent || fuelStart != null) {
      map['fuel_start'] = Variable<int>(fuelStart);
    }
    if (!nullToAbsent || fuelEnd != null) {
      map['fuel_end'] = Variable<int>(fuelEnd);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  BookingsCompanion toCompanion(bool nullToAbsent) {
    return BookingsCompanion(
      bookingId: Value(bookingId),
      vehicleId: Value(vehicleId),
      renterId: Value(renterId),
      hostId: Value(hostId),
      startTs: Value(startTs),
      endTs: Value(endTs),
      dailyPriceSnapshot: Value(dailyPriceSnapshot),
      insuranceDailyCostSnapshot:
          insuranceDailyCostSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(insuranceDailyCostSnapshot),
      subtotal: Value(subtotal),
      fees: fees == null && nullToAbsent ? const Value.absent() : Value(fees),
      taxes: taxes == null && nullToAbsent
          ? const Value.absent()
          : Value(taxes),
      total: Value(total),
      currency: Value(currency),
      odoStart: odoStart == null && nullToAbsent
          ? const Value.absent()
          : Value(odoStart),
      odoEnd: odoEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(odoEnd),
      fuelStart: fuelStart == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelStart),
      fuelEnd: fuelEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelEnd),
      status: Value(status),
      createdAt: Value(createdAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory BookingsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookingsData(
      bookingId: serializer.fromJson<String>(json['bookingId']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      renterId: serializer.fromJson<String>(json['renterId']),
      hostId: serializer.fromJson<String>(json['hostId']),
      startTs: serializer.fromJson<DateTime>(json['startTs']),
      endTs: serializer.fromJson<DateTime>(json['endTs']),
      dailyPriceSnapshot: serializer.fromJson<double>(
        json['dailyPriceSnapshot'],
      ),
      insuranceDailyCostSnapshot: serializer.fromJson<double?>(
        json['insuranceDailyCostSnapshot'],
      ),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      fees: serializer.fromJson<double?>(json['fees']),
      taxes: serializer.fromJson<double?>(json['taxes']),
      total: serializer.fromJson<double>(json['total']),
      currency: serializer.fromJson<String>(json['currency']),
      odoStart: serializer.fromJson<int?>(json['odoStart']),
      odoEnd: serializer.fromJson<int?>(json['odoEnd']),
      fuelStart: serializer.fromJson<int?>(json['fuelStart']),
      fuelEnd: serializer.fromJson<int?>(json['fuelEnd']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookingId': serializer.toJson<String>(bookingId),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'renterId': serializer.toJson<String>(renterId),
      'hostId': serializer.toJson<String>(hostId),
      'startTs': serializer.toJson<DateTime>(startTs),
      'endTs': serializer.toJson<DateTime>(endTs),
      'dailyPriceSnapshot': serializer.toJson<double>(dailyPriceSnapshot),
      'insuranceDailyCostSnapshot': serializer.toJson<double?>(
        insuranceDailyCostSnapshot,
      ),
      'subtotal': serializer.toJson<double>(subtotal),
      'fees': serializer.toJson<double?>(fees),
      'taxes': serializer.toJson<double?>(taxes),
      'total': serializer.toJson<double>(total),
      'currency': serializer.toJson<String>(currency),
      'odoStart': serializer.toJson<int?>(odoStart),
      'odoEnd': serializer.toJson<int?>(odoEnd),
      'fuelStart': serializer.toJson<int?>(fuelStart),
      'fuelEnd': serializer.toJson<int?>(fuelEnd),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  BookingsData copyWith({
    String? bookingId,
    String? vehicleId,
    String? renterId,
    String? hostId,
    DateTime? startTs,
    DateTime? endTs,
    double? dailyPriceSnapshot,
    Value<double?> insuranceDailyCostSnapshot = const Value.absent(),
    double? subtotal,
    Value<double?> fees = const Value.absent(),
    Value<double?> taxes = const Value.absent(),
    double? total,
    String? currency,
    Value<int?> odoStart = const Value.absent(),
    Value<int?> odoEnd = const Value.absent(),
    Value<int?> fuelStart = const Value.absent(),
    Value<int?> fuelEnd = const Value.absent(),
    String? status,
    DateTime? createdAt,
    bool? isDeleted,
  }) => BookingsData(
    bookingId: bookingId ?? this.bookingId,
    vehicleId: vehicleId ?? this.vehicleId,
    renterId: renterId ?? this.renterId,
    hostId: hostId ?? this.hostId,
    startTs: startTs ?? this.startTs,
    endTs: endTs ?? this.endTs,
    dailyPriceSnapshot: dailyPriceSnapshot ?? this.dailyPriceSnapshot,
    insuranceDailyCostSnapshot: insuranceDailyCostSnapshot.present
        ? insuranceDailyCostSnapshot.value
        : this.insuranceDailyCostSnapshot,
    subtotal: subtotal ?? this.subtotal,
    fees: fees.present ? fees.value : this.fees,
    taxes: taxes.present ? taxes.value : this.taxes,
    total: total ?? this.total,
    currency: currency ?? this.currency,
    odoStart: odoStart.present ? odoStart.value : this.odoStart,
    odoEnd: odoEnd.present ? odoEnd.value : this.odoEnd,
    fuelStart: fuelStart.present ? fuelStart.value : this.fuelStart,
    fuelEnd: fuelEnd.present ? fuelEnd.value : this.fuelEnd,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  BookingsData copyWithCompanion(BookingsCompanion data) {
    return BookingsData(
      bookingId: data.bookingId.present ? data.bookingId.value : this.bookingId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      renterId: data.renterId.present ? data.renterId.value : this.renterId,
      hostId: data.hostId.present ? data.hostId.value : this.hostId,
      startTs: data.startTs.present ? data.startTs.value : this.startTs,
      endTs: data.endTs.present ? data.endTs.value : this.endTs,
      dailyPriceSnapshot: data.dailyPriceSnapshot.present
          ? data.dailyPriceSnapshot.value
          : this.dailyPriceSnapshot,
      insuranceDailyCostSnapshot: data.insuranceDailyCostSnapshot.present
          ? data.insuranceDailyCostSnapshot.value
          : this.insuranceDailyCostSnapshot,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      fees: data.fees.present ? data.fees.value : this.fees,
      taxes: data.taxes.present ? data.taxes.value : this.taxes,
      total: data.total.present ? data.total.value : this.total,
      currency: data.currency.present ? data.currency.value : this.currency,
      odoStart: data.odoStart.present ? data.odoStart.value : this.odoStart,
      odoEnd: data.odoEnd.present ? data.odoEnd.value : this.odoEnd,
      fuelStart: data.fuelStart.present ? data.fuelStart.value : this.fuelStart,
      fuelEnd: data.fuelEnd.present ? data.fuelEnd.value : this.fuelEnd,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookingsData(')
          ..write('bookingId: $bookingId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('renterId: $renterId, ')
          ..write('hostId: $hostId, ')
          ..write('startTs: $startTs, ')
          ..write('endTs: $endTs, ')
          ..write('dailyPriceSnapshot: $dailyPriceSnapshot, ')
          ..write('insuranceDailyCostSnapshot: $insuranceDailyCostSnapshot, ')
          ..write('subtotal: $subtotal, ')
          ..write('fees: $fees, ')
          ..write('taxes: $taxes, ')
          ..write('total: $total, ')
          ..write('currency: $currency, ')
          ..write('odoStart: $odoStart, ')
          ..write('odoEnd: $odoEnd, ')
          ..write('fuelStart: $fuelStart, ')
          ..write('fuelEnd: $fuelEnd, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    bookingId,
    vehicleId,
    renterId,
    hostId,
    startTs,
    endTs,
    dailyPriceSnapshot,
    insuranceDailyCostSnapshot,
    subtotal,
    fees,
    taxes,
    total,
    currency,
    odoStart,
    odoEnd,
    fuelStart,
    fuelEnd,
    status,
    createdAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookingsData &&
          other.bookingId == this.bookingId &&
          other.vehicleId == this.vehicleId &&
          other.renterId == this.renterId &&
          other.hostId == this.hostId &&
          other.startTs == this.startTs &&
          other.endTs == this.endTs &&
          other.dailyPriceSnapshot == this.dailyPriceSnapshot &&
          other.insuranceDailyCostSnapshot == this.insuranceDailyCostSnapshot &&
          other.subtotal == this.subtotal &&
          other.fees == this.fees &&
          other.taxes == this.taxes &&
          other.total == this.total &&
          other.currency == this.currency &&
          other.odoStart == this.odoStart &&
          other.odoEnd == this.odoEnd &&
          other.fuelStart == this.fuelStart &&
          other.fuelEnd == this.fuelEnd &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.isDeleted == this.isDeleted);
}

class BookingsCompanion extends UpdateCompanion<BookingsData> {
  final Value<String> bookingId;
  final Value<String> vehicleId;
  final Value<String> renterId;
  final Value<String> hostId;
  final Value<DateTime> startTs;
  final Value<DateTime> endTs;
  final Value<double> dailyPriceSnapshot;
  final Value<double?> insuranceDailyCostSnapshot;
  final Value<double> subtotal;
  final Value<double?> fees;
  final Value<double?> taxes;
  final Value<double> total;
  final Value<String> currency;
  final Value<int?> odoStart;
  final Value<int?> odoEnd;
  final Value<int?> fuelStart;
  final Value<int?> fuelEnd;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const BookingsCompanion({
    this.bookingId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.renterId = const Value.absent(),
    this.hostId = const Value.absent(),
    this.startTs = const Value.absent(),
    this.endTs = const Value.absent(),
    this.dailyPriceSnapshot = const Value.absent(),
    this.insuranceDailyCostSnapshot = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.fees = const Value.absent(),
    this.taxes = const Value.absent(),
    this.total = const Value.absent(),
    this.currency = const Value.absent(),
    this.odoStart = const Value.absent(),
    this.odoEnd = const Value.absent(),
    this.fuelStart = const Value.absent(),
    this.fuelEnd = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookingsCompanion.insert({
    required String bookingId,
    required String vehicleId,
    required String renterId,
    required String hostId,
    required DateTime startTs,
    required DateTime endTs,
    required double dailyPriceSnapshot,
    this.insuranceDailyCostSnapshot = const Value.absent(),
    required double subtotal,
    this.fees = const Value.absent(),
    this.taxes = const Value.absent(),
    required double total,
    required String currency,
    this.odoStart = const Value.absent(),
    this.odoEnd = const Value.absent(),
    this.fuelStart = const Value.absent(),
    this.fuelEnd = const Value.absent(),
    required String status,
    required DateTime createdAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bookingId = Value(bookingId),
       vehicleId = Value(vehicleId),
       renterId = Value(renterId),
       hostId = Value(hostId),
       startTs = Value(startTs),
       endTs = Value(endTs),
       dailyPriceSnapshot = Value(dailyPriceSnapshot),
       subtotal = Value(subtotal),
       total = Value(total),
       currency = Value(currency),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<BookingsData> custom({
    Expression<String>? bookingId,
    Expression<String>? vehicleId,
    Expression<String>? renterId,
    Expression<String>? hostId,
    Expression<DateTime>? startTs,
    Expression<DateTime>? endTs,
    Expression<double>? dailyPriceSnapshot,
    Expression<double>? insuranceDailyCostSnapshot,
    Expression<double>? subtotal,
    Expression<double>? fees,
    Expression<double>? taxes,
    Expression<double>? total,
    Expression<String>? currency,
    Expression<int>? odoStart,
    Expression<int>? odoEnd,
    Expression<int>? fuelStart,
    Expression<int>? fuelEnd,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookingId != null) 'booking_id': bookingId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (renterId != null) 'renter_id': renterId,
      if (hostId != null) 'host_id': hostId,
      if (startTs != null) 'start_ts': startTs,
      if (endTs != null) 'end_ts': endTs,
      if (dailyPriceSnapshot != null)
        'daily_price_snapshot': dailyPriceSnapshot,
      if (insuranceDailyCostSnapshot != null)
        'insurance_daily_cost_snapshot': insuranceDailyCostSnapshot,
      if (subtotal != null) 'subtotal': subtotal,
      if (fees != null) 'fees': fees,
      if (taxes != null) 'taxes': taxes,
      if (total != null) 'total': total,
      if (currency != null) 'currency': currency,
      if (odoStart != null) 'odo_start': odoStart,
      if (odoEnd != null) 'odo_end': odoEnd,
      if (fuelStart != null) 'fuel_start': fuelStart,
      if (fuelEnd != null) 'fuel_end': fuelEnd,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookingsCompanion copyWith({
    Value<String>? bookingId,
    Value<String>? vehicleId,
    Value<String>? renterId,
    Value<String>? hostId,
    Value<DateTime>? startTs,
    Value<DateTime>? endTs,
    Value<double>? dailyPriceSnapshot,
    Value<double?>? insuranceDailyCostSnapshot,
    Value<double>? subtotal,
    Value<double?>? fees,
    Value<double?>? taxes,
    Value<double>? total,
    Value<String>? currency,
    Value<int?>? odoStart,
    Value<int?>? odoEnd,
    Value<int?>? fuelStart,
    Value<int?>? fuelEnd,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return BookingsCompanion(
      bookingId: bookingId ?? this.bookingId,
      vehicleId: vehicleId ?? this.vehicleId,
      renterId: renterId ?? this.renterId,
      hostId: hostId ?? this.hostId,
      startTs: startTs ?? this.startTs,
      endTs: endTs ?? this.endTs,
      dailyPriceSnapshot: dailyPriceSnapshot ?? this.dailyPriceSnapshot,
      insuranceDailyCostSnapshot:
          insuranceDailyCostSnapshot ?? this.insuranceDailyCostSnapshot,
      subtotal: subtotal ?? this.subtotal,
      fees: fees ?? this.fees,
      taxes: taxes ?? this.taxes,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      odoStart: odoStart ?? this.odoStart,
      odoEnd: odoEnd ?? this.odoEnd,
      fuelStart: fuelStart ?? this.fuelStart,
      fuelEnd: fuelEnd ?? this.fuelEnd,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookingId.present) {
      map['booking_id'] = Variable<String>(bookingId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (renterId.present) {
      map['renter_id'] = Variable<String>(renterId.value);
    }
    if (hostId.present) {
      map['host_id'] = Variable<String>(hostId.value);
    }
    if (startTs.present) {
      map['start_ts'] = Variable<DateTime>(startTs.value);
    }
    if (endTs.present) {
      map['end_ts'] = Variable<DateTime>(endTs.value);
    }
    if (dailyPriceSnapshot.present) {
      map['daily_price_snapshot'] = Variable<double>(dailyPriceSnapshot.value);
    }
    if (insuranceDailyCostSnapshot.present) {
      map['insurance_daily_cost_snapshot'] = Variable<double>(
        insuranceDailyCostSnapshot.value,
      );
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (fees.present) {
      map['fees'] = Variable<double>(fees.value);
    }
    if (taxes.present) {
      map['taxes'] = Variable<double>(taxes.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (odoStart.present) {
      map['odo_start'] = Variable<int>(odoStart.value);
    }
    if (odoEnd.present) {
      map['odo_end'] = Variable<int>(odoEnd.value);
    }
    if (fuelStart.present) {
      map['fuel_start'] = Variable<int>(fuelStart.value);
    }
    if (fuelEnd.present) {
      map['fuel_end'] = Variable<int>(fuelEnd.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookingsCompanion(')
          ..write('bookingId: $bookingId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('renterId: $renterId, ')
          ..write('hostId: $hostId, ')
          ..write('startTs: $startTs, ')
          ..write('endTs: $endTs, ')
          ..write('dailyPriceSnapshot: $dailyPriceSnapshot, ')
          ..write('insuranceDailyCostSnapshot: $insuranceDailyCostSnapshot, ')
          ..write('subtotal: $subtotal, ')
          ..write('fees: $fees, ')
          ..write('taxes: $taxes, ')
          ..write('total: $total, ')
          ..write('currency: $currency, ')
          ..write('odoStart: $odoStart, ')
          ..write('odoEnd: $odoEnd, ')
          ..write('fuelStart: $fuelStart, ')
          ..write('fuelEnd: $fuelEnd, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KvsTable extends Kvs with TableInfo<$KvsTable, KvEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kMeta = const VerificationMeta('k');
  @override
  late final GeneratedColumn<String> k = GeneratedColumn<String>(
    'k',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vMeta = const VerificationMeta('v');
  @override
  late final GeneratedColumn<String> v = GeneratedColumn<String>(
    'v',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [k, v, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kvs';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('k')) {
      context.handle(_kMeta, k.isAcceptableOrUnknown(data['k']!, _kMeta));
    } else if (isInserting) {
      context.missing(_kMeta);
    }
    if (data.containsKey('v')) {
      context.handle(_vMeta, v.isAcceptableOrUnknown(data['v']!, _vMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {k};
  @override
  KvEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvEntry(
      k: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}k'],
      )!,
      v: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}v'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $KvsTable createAlias(String alias) {
    return $KvsTable(attachedDatabase, alias);
  }
}

class KvEntry extends DataClass implements Insertable<KvEntry> {
  final String k;
  final String? v;
  final DateTime updatedAt;
  const KvEntry({required this.k, this.v, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['k'] = Variable<String>(k);
    if (!nullToAbsent || v != null) {
      map['v'] = Variable<String>(v);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  KvsCompanion toCompanion(bool nullToAbsent) {
    return KvsCompanion(
      k: Value(k),
      v: v == null && nullToAbsent ? const Value.absent() : Value(v),
      updatedAt: Value(updatedAt),
    );
  }

  factory KvEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvEntry(
      k: serializer.fromJson<String>(json['k']),
      v: serializer.fromJson<String?>(json['v']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'k': serializer.toJson<String>(k),
      'v': serializer.toJson<String?>(v),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  KvEntry copyWith({
    String? k,
    Value<String?> v = const Value.absent(),
    DateTime? updatedAt,
  }) => KvEntry(
    k: k ?? this.k,
    v: v.present ? v.value : this.v,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  KvEntry copyWithCompanion(KvsCompanion data) {
    return KvEntry(
      k: data.k.present ? data.k.value : this.k,
      v: data.v.present ? data.v.value : this.v,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvEntry(')
          ..write('k: $k, ')
          ..write('v: $v, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(k, v, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvEntry &&
          other.k == this.k &&
          other.v == this.v &&
          other.updatedAt == this.updatedAt);
}

class KvsCompanion extends UpdateCompanion<KvEntry> {
  final Value<String> k;
  final Value<String?> v;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const KvsCompanion({
    this.k = const Value.absent(),
    this.v = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvsCompanion.insert({
    required String k,
    this.v = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : k = Value(k);
  static Insertable<KvEntry> custom({
    Expression<String>? k,
    Expression<String>? v,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (k != null) 'k': k,
      if (v != null) 'v': v,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvsCompanion copyWith({
    Value<String>? k,
    Value<String?>? v,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return KvsCompanion(
      k: k ?? this.k,
      v: v ?? this.v,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (k.present) {
      map['k'] = Variable<String>(k.value);
    }
    if (v.present) {
      map['v'] = Variable<String>(v.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvsCompanion(')
          ..write('k: $k, ')
          ..write('v: $v, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnalyticsDemandTableTable extends AnalyticsDemandTable
    with TableInfo<$AnalyticsDemandTableTable, AnalyticsDemandEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalyticsDemandTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    true,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _latZoneMeta = const VerificationMeta(
    'latZone',
  );
  @override
  late final GeneratedColumn<double> latZone = GeneratedColumn<double>(
    'lat_zone',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonZoneMeta = const VerificationMeta(
    'lonZone',
  );
  @override
  late final GeneratedColumn<double> lonZone = GeneratedColumn<double>(
    'lon_zone',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rentalsMeta = const VerificationMeta(
    'rentals',
  );
  @override
  late final GeneratedColumn<int> rentals = GeneratedColumn<int>(
    'rentals',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    latZone,
    lonZone,
    rentals,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analytics_demand_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnalyticsDemandEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lat_zone')) {
      context.handle(
        _latZoneMeta,
        latZone.isAcceptableOrUnknown(data['lat_zone']!, _latZoneMeta),
      );
    } else if (isInserting) {
      context.missing(_latZoneMeta);
    }
    if (data.containsKey('lon_zone')) {
      context.handle(
        _lonZoneMeta,
        lonZone.isAcceptableOrUnknown(data['lon_zone']!, _lonZoneMeta),
      );
    } else if (isInserting) {
      context.missing(_lonZoneMeta);
    }
    if (data.containsKey('rentals')) {
      context.handle(
        _rentalsMeta,
        rentals.isAcceptableOrUnknown(data['rentals']!, _rentalsMeta),
      );
    } else if (isInserting) {
      context.missing(_rentalsMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalyticsDemandEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalyticsDemandEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      ),
      latZone: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat_zone'],
      )!,
      lonZone: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon_zone'],
      )!,
      rentals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rentals'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $AnalyticsDemandTableTable createAlias(String alias) {
    return $AnalyticsDemandTableTable(attachedDatabase, alias);
  }
}

class AnalyticsDemandEntity extends DataClass
    implements Insertable<AnalyticsDemandEntity> {
  final int? id;
  final double latZone;
  final double lonZone;
  final int rentals;
  final DateTime lastUpdated;
  const AnalyticsDemandEntity({
    this.id,
    required this.latZone,
    required this.lonZone,
    required this.rentals,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['lat_zone'] = Variable<double>(latZone);
    map['lon_zone'] = Variable<double>(lonZone);
    map['rentals'] = Variable<int>(rentals);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  AnalyticsDemandTableCompanion toCompanion(bool nullToAbsent) {
    return AnalyticsDemandTableCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      latZone: Value(latZone),
      lonZone: Value(lonZone),
      rentals: Value(rentals),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory AnalyticsDemandEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalyticsDemandEntity(
      id: serializer.fromJson<int?>(json['id']),
      latZone: serializer.fromJson<double>(json['latZone']),
      lonZone: serializer.fromJson<double>(json['lonZone']),
      rentals: serializer.fromJson<int>(json['rentals']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'latZone': serializer.toJson<double>(latZone),
      'lonZone': serializer.toJson<double>(lonZone),
      'rentals': serializer.toJson<int>(rentals),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  AnalyticsDemandEntity copyWith({
    Value<int?> id = const Value.absent(),
    double? latZone,
    double? lonZone,
    int? rentals,
    DateTime? lastUpdated,
  }) => AnalyticsDemandEntity(
    id: id.present ? id.value : this.id,
    latZone: latZone ?? this.latZone,
    lonZone: lonZone ?? this.lonZone,
    rentals: rentals ?? this.rentals,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  AnalyticsDemandEntity copyWithCompanion(AnalyticsDemandTableCompanion data) {
    return AnalyticsDemandEntity(
      id: data.id.present ? data.id.value : this.id,
      latZone: data.latZone.present ? data.latZone.value : this.latZone,
      lonZone: data.lonZone.present ? data.lonZone.value : this.lonZone,
      rentals: data.rentals.present ? data.rentals.value : this.rentals,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsDemandEntity(')
          ..write('id: $id, ')
          ..write('latZone: $latZone, ')
          ..write('lonZone: $lonZone, ')
          ..write('rentals: $rentals, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, latZone, lonZone, rentals, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalyticsDemandEntity &&
          other.id == this.id &&
          other.latZone == this.latZone &&
          other.lonZone == this.lonZone &&
          other.rentals == this.rentals &&
          other.lastUpdated == this.lastUpdated);
}

class AnalyticsDemandTableCompanion
    extends UpdateCompanion<AnalyticsDemandEntity> {
  final Value<int?> id;
  final Value<double> latZone;
  final Value<double> lonZone;
  final Value<int> rentals;
  final Value<DateTime> lastUpdated;
  const AnalyticsDemandTableCompanion({
    this.id = const Value.absent(),
    this.latZone = const Value.absent(),
    this.lonZone = const Value.absent(),
    this.rentals = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  AnalyticsDemandTableCompanion.insert({
    this.id = const Value.absent(),
    required double latZone,
    required double lonZone,
    required int rentals,
    this.lastUpdated = const Value.absent(),
  }) : latZone = Value(latZone),
       lonZone = Value(lonZone),
       rentals = Value(rentals);
  static Insertable<AnalyticsDemandEntity> custom({
    Expression<int>? id,
    Expression<double>? latZone,
    Expression<double>? lonZone,
    Expression<int>? rentals,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (latZone != null) 'lat_zone': latZone,
      if (lonZone != null) 'lon_zone': lonZone,
      if (rentals != null) 'rentals': rentals,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  AnalyticsDemandTableCompanion copyWith({
    Value<int?>? id,
    Value<double>? latZone,
    Value<double>? lonZone,
    Value<int>? rentals,
    Value<DateTime>? lastUpdated,
  }) {
    return AnalyticsDemandTableCompanion(
      id: id ?? this.id,
      latZone: latZone ?? this.latZone,
      lonZone: lonZone ?? this.lonZone,
      rentals: rentals ?? this.rentals,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (latZone.present) {
      map['lat_zone'] = Variable<double>(latZone.value);
    }
    if (lonZone.present) {
      map['lon_zone'] = Variable<double>(lonZone.value);
    }
    if (rentals.present) {
      map['rentals'] = Variable<int>(rentals.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsDemandTableCompanion(')
          ..write('id: $id, ')
          ..write('latZone: $latZone, ')
          ..write('lonZone: $lonZone, ')
          ..write('rentals: $rentals, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

class $AnalyticsExtendedTableTable extends AnalyticsExtendedTable
    with TableInfo<$AnalyticsExtendedTableTable, AnalyticsExtendedEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalyticsExtendedTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    true,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _latZoneMeta = const VerificationMeta(
    'latZone',
  );
  @override
  late final GeneratedColumn<double> latZone = GeneratedColumn<double>(
    'lat_zone',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonZoneMeta = const VerificationMeta(
    'lonZone',
  );
  @override
  late final GeneratedColumn<double> lonZone = GeneratedColumn<double>(
    'lon_zone',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourSlotMeta = const VerificationMeta(
    'hourSlot',
  );
  @override
  late final GeneratedColumn<int> hourSlot = GeneratedColumn<int>(
    'hour_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fuelTypeMeta = const VerificationMeta(
    'fuelType',
  );
  @override
  late final GeneratedColumn<String> fuelType = GeneratedColumn<String>(
    'fuel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transmissionMeta = const VerificationMeta(
    'transmission',
  );
  @override
  late final GeneratedColumn<String> transmission = GeneratedColumn<String>(
    'transmission',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rentalsMeta = const VerificationMeta(
    'rentals',
  );
  @override
  late final GeneratedColumn<int> rentals = GeneratedColumn<int>(
    'rentals',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    latZone,
    lonZone,
    hourSlot,
    make,
    year,
    fuelType,
    transmission,
    rentals,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analytics_extended_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnalyticsExtendedEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lat_zone')) {
      context.handle(
        _latZoneMeta,
        latZone.isAcceptableOrUnknown(data['lat_zone']!, _latZoneMeta),
      );
    } else if (isInserting) {
      context.missing(_latZoneMeta);
    }
    if (data.containsKey('lon_zone')) {
      context.handle(
        _lonZoneMeta,
        lonZone.isAcceptableOrUnknown(data['lon_zone']!, _lonZoneMeta),
      );
    } else if (isInserting) {
      context.missing(_lonZoneMeta);
    }
    if (data.containsKey('hour_slot')) {
      context.handle(
        _hourSlotMeta,
        hourSlot.isAcceptableOrUnknown(data['hour_slot']!, _hourSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_hourSlotMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    } else if (isInserting) {
      context.missing(_makeMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('fuel_type')) {
      context.handle(
        _fuelTypeMeta,
        fuelType.isAcceptableOrUnknown(data['fuel_type']!, _fuelTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fuelTypeMeta);
    }
    if (data.containsKey('transmission')) {
      context.handle(
        _transmissionMeta,
        transmission.isAcceptableOrUnknown(
          data['transmission']!,
          _transmissionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transmissionMeta);
    }
    if (data.containsKey('rentals')) {
      context.handle(
        _rentalsMeta,
        rentals.isAcceptableOrUnknown(data['rentals']!, _rentalsMeta),
      );
    } else if (isInserting) {
      context.missing(_rentalsMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalyticsExtendedEntity map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalyticsExtendedEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      ),
      latZone: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat_zone'],
      )!,
      lonZone: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon_zone'],
      )!,
      hourSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour_slot'],
      )!,
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      fuelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel_type'],
      )!,
      transmission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transmission'],
      )!,
      rentals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rentals'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $AnalyticsExtendedTableTable createAlias(String alias) {
    return $AnalyticsExtendedTableTable(attachedDatabase, alias);
  }
}

class AnalyticsExtendedEntity extends DataClass
    implements Insertable<AnalyticsExtendedEntity> {
  final int? id;
  final double latZone;
  final double lonZone;
  final int hourSlot;
  final String make;
  final int year;
  final String fuelType;
  final String transmission;
  final int rentals;
  final DateTime lastUpdated;
  const AnalyticsExtendedEntity({
    this.id,
    required this.latZone,
    required this.lonZone,
    required this.hourSlot,
    required this.make,
    required this.year,
    required this.fuelType,
    required this.transmission,
    required this.rentals,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['lat_zone'] = Variable<double>(latZone);
    map['lon_zone'] = Variable<double>(lonZone);
    map['hour_slot'] = Variable<int>(hourSlot);
    map['make'] = Variable<String>(make);
    map['year'] = Variable<int>(year);
    map['fuel_type'] = Variable<String>(fuelType);
    map['transmission'] = Variable<String>(transmission);
    map['rentals'] = Variable<int>(rentals);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  AnalyticsExtendedTableCompanion toCompanion(bool nullToAbsent) {
    return AnalyticsExtendedTableCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      latZone: Value(latZone),
      lonZone: Value(lonZone),
      hourSlot: Value(hourSlot),
      make: Value(make),
      year: Value(year),
      fuelType: Value(fuelType),
      transmission: Value(transmission),
      rentals: Value(rentals),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory AnalyticsExtendedEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalyticsExtendedEntity(
      id: serializer.fromJson<int?>(json['id']),
      latZone: serializer.fromJson<double>(json['latZone']),
      lonZone: serializer.fromJson<double>(json['lonZone']),
      hourSlot: serializer.fromJson<int>(json['hourSlot']),
      make: serializer.fromJson<String>(json['make']),
      year: serializer.fromJson<int>(json['year']),
      fuelType: serializer.fromJson<String>(json['fuelType']),
      transmission: serializer.fromJson<String>(json['transmission']),
      rentals: serializer.fromJson<int>(json['rentals']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'latZone': serializer.toJson<double>(latZone),
      'lonZone': serializer.toJson<double>(lonZone),
      'hourSlot': serializer.toJson<int>(hourSlot),
      'make': serializer.toJson<String>(make),
      'year': serializer.toJson<int>(year),
      'fuelType': serializer.toJson<String>(fuelType),
      'transmission': serializer.toJson<String>(transmission),
      'rentals': serializer.toJson<int>(rentals),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  AnalyticsExtendedEntity copyWith({
    Value<int?> id = const Value.absent(),
    double? latZone,
    double? lonZone,
    int? hourSlot,
    String? make,
    int? year,
    String? fuelType,
    String? transmission,
    int? rentals,
    DateTime? lastUpdated,
  }) => AnalyticsExtendedEntity(
    id: id.present ? id.value : this.id,
    latZone: latZone ?? this.latZone,
    lonZone: lonZone ?? this.lonZone,
    hourSlot: hourSlot ?? this.hourSlot,
    make: make ?? this.make,
    year: year ?? this.year,
    fuelType: fuelType ?? this.fuelType,
    transmission: transmission ?? this.transmission,
    rentals: rentals ?? this.rentals,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  AnalyticsExtendedEntity copyWithCompanion(
    AnalyticsExtendedTableCompanion data,
  ) {
    return AnalyticsExtendedEntity(
      id: data.id.present ? data.id.value : this.id,
      latZone: data.latZone.present ? data.latZone.value : this.latZone,
      lonZone: data.lonZone.present ? data.lonZone.value : this.lonZone,
      hourSlot: data.hourSlot.present ? data.hourSlot.value : this.hourSlot,
      make: data.make.present ? data.make.value : this.make,
      year: data.year.present ? data.year.value : this.year,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      transmission: data.transmission.present
          ? data.transmission.value
          : this.transmission,
      rentals: data.rentals.present ? data.rentals.value : this.rentals,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsExtendedEntity(')
          ..write('id: $id, ')
          ..write('latZone: $latZone, ')
          ..write('lonZone: $lonZone, ')
          ..write('hourSlot: $hourSlot, ')
          ..write('make: $make, ')
          ..write('year: $year, ')
          ..write('fuelType: $fuelType, ')
          ..write('transmission: $transmission, ')
          ..write('rentals: $rentals, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    latZone,
    lonZone,
    hourSlot,
    make,
    year,
    fuelType,
    transmission,
    rentals,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalyticsExtendedEntity &&
          other.id == this.id &&
          other.latZone == this.latZone &&
          other.lonZone == this.lonZone &&
          other.hourSlot == this.hourSlot &&
          other.make == this.make &&
          other.year == this.year &&
          other.fuelType == this.fuelType &&
          other.transmission == this.transmission &&
          other.rentals == this.rentals &&
          other.lastUpdated == this.lastUpdated);
}

class AnalyticsExtendedTableCompanion
    extends UpdateCompanion<AnalyticsExtendedEntity> {
  final Value<int?> id;
  final Value<double> latZone;
  final Value<double> lonZone;
  final Value<int> hourSlot;
  final Value<String> make;
  final Value<int> year;
  final Value<String> fuelType;
  final Value<String> transmission;
  final Value<int> rentals;
  final Value<DateTime> lastUpdated;
  const AnalyticsExtendedTableCompanion({
    this.id = const Value.absent(),
    this.latZone = const Value.absent(),
    this.lonZone = const Value.absent(),
    this.hourSlot = const Value.absent(),
    this.make = const Value.absent(),
    this.year = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.transmission = const Value.absent(),
    this.rentals = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  AnalyticsExtendedTableCompanion.insert({
    this.id = const Value.absent(),
    required double latZone,
    required double lonZone,
    required int hourSlot,
    required String make,
    required int year,
    required String fuelType,
    required String transmission,
    required int rentals,
    this.lastUpdated = const Value.absent(),
  }) : latZone = Value(latZone),
       lonZone = Value(lonZone),
       hourSlot = Value(hourSlot),
       make = Value(make),
       year = Value(year),
       fuelType = Value(fuelType),
       transmission = Value(transmission),
       rentals = Value(rentals);
  static Insertable<AnalyticsExtendedEntity> custom({
    Expression<int>? id,
    Expression<double>? latZone,
    Expression<double>? lonZone,
    Expression<int>? hourSlot,
    Expression<String>? make,
    Expression<int>? year,
    Expression<String>? fuelType,
    Expression<String>? transmission,
    Expression<int>? rentals,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (latZone != null) 'lat_zone': latZone,
      if (lonZone != null) 'lon_zone': lonZone,
      if (hourSlot != null) 'hour_slot': hourSlot,
      if (make != null) 'make': make,
      if (year != null) 'year': year,
      if (fuelType != null) 'fuel_type': fuelType,
      if (transmission != null) 'transmission': transmission,
      if (rentals != null) 'rentals': rentals,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  AnalyticsExtendedTableCompanion copyWith({
    Value<int?>? id,
    Value<double>? latZone,
    Value<double>? lonZone,
    Value<int>? hourSlot,
    Value<String>? make,
    Value<int>? year,
    Value<String>? fuelType,
    Value<String>? transmission,
    Value<int>? rentals,
    Value<DateTime>? lastUpdated,
  }) {
    return AnalyticsExtendedTableCompanion(
      id: id ?? this.id,
      latZone: latZone ?? this.latZone,
      lonZone: lonZone ?? this.lonZone,
      hourSlot: hourSlot ?? this.hourSlot,
      make: make ?? this.make,
      year: year ?? this.year,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      rentals: rentals ?? this.rentals,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (latZone.present) {
      map['lat_zone'] = Variable<double>(latZone.value);
    }
    if (lonZone.present) {
      map['lon_zone'] = Variable<double>(lonZone.value);
    }
    if (hourSlot.present) {
      map['hour_slot'] = Variable<int>(hourSlot.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
    }
    if (transmission.present) {
      map['transmission'] = Variable<String>(transmission.value);
    }
    if (rentals.present) {
      map['rentals'] = Variable<int>(rentals.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsExtendedTableCompanion(')
          ..write('id: $id, ')
          ..write('latZone: $latZone, ')
          ..write('lonZone: $lonZone, ')
          ..write('hourSlot: $hourSlot, ')
          ..write('make: $make, ')
          ..write('year: $year, ')
          ..write('fuelType: $fuelType, ')
          ..write('transmission: $transmission, ')
          ..write('rentals: $rentals, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

class $OwnerIncomeTableTable extends OwnerIncomeTable
    with TableInfo<$OwnerIncomeTableTable, OwnerIncomeEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnerIncomeTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    true,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyIncomeMeta = const VerificationMeta(
    'monthlyIncome',
  );
  @override
  late final GeneratedColumn<double> monthlyIncome = GeneratedColumn<double>(
    'monthly_income',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    monthlyIncome,
    month,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owner_income_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<OwnerIncomeEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('monthly_income')) {
      context.handle(
        _monthlyIncomeMeta,
        monthlyIncome.isAcceptableOrUnknown(
          data['monthly_income']!,
          _monthlyIncomeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyIncomeMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OwnerIncomeEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnerIncomeEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      monthlyIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_income'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $OwnerIncomeTableTable createAlias(String alias) {
    return $OwnerIncomeTableTable(attachedDatabase, alias);
  }
}

class OwnerIncomeEntity extends DataClass
    implements Insertable<OwnerIncomeEntity> {
  final int? id;
  final String ownerId;
  final double monthlyIncome;
  final String month;
  final DateTime lastUpdated;
  const OwnerIncomeEntity({
    this.id,
    required this.ownerId,
    required this.monthlyIncome,
    required this.month,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['owner_id'] = Variable<String>(ownerId);
    map['monthly_income'] = Variable<double>(monthlyIncome);
    map['month'] = Variable<String>(month);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  OwnerIncomeTableCompanion toCompanion(bool nullToAbsent) {
    return OwnerIncomeTableCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      ownerId: Value(ownerId),
      monthlyIncome: Value(monthlyIncome),
      month: Value(month),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory OwnerIncomeEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnerIncomeEntity(
      id: serializer.fromJson<int?>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      monthlyIncome: serializer.fromJson<double>(json['monthlyIncome']),
      month: serializer.fromJson<String>(json['month']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'monthlyIncome': serializer.toJson<double>(monthlyIncome),
      'month': serializer.toJson<String>(month),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  OwnerIncomeEntity copyWith({
    Value<int?> id = const Value.absent(),
    String? ownerId,
    double? monthlyIncome,
    String? month,
    DateTime? lastUpdated,
  }) => OwnerIncomeEntity(
    id: id.present ? id.value : this.id,
    ownerId: ownerId ?? this.ownerId,
    monthlyIncome: monthlyIncome ?? this.monthlyIncome,
    month: month ?? this.month,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  OwnerIncomeEntity copyWithCompanion(OwnerIncomeTableCompanion data) {
    return OwnerIncomeEntity(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      monthlyIncome: data.monthlyIncome.present
          ? data.monthlyIncome.value
          : this.monthlyIncome,
      month: data.month.present ? data.month.value : this.month,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnerIncomeEntity(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('monthlyIncome: $monthlyIncome, ')
          ..write('month: $month, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ownerId, monthlyIncome, month, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnerIncomeEntity &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.monthlyIncome == this.monthlyIncome &&
          other.month == this.month &&
          other.lastUpdated == this.lastUpdated);
}

class OwnerIncomeTableCompanion extends UpdateCompanion<OwnerIncomeEntity> {
  final Value<int?> id;
  final Value<String> ownerId;
  final Value<double> monthlyIncome;
  final Value<String> month;
  final Value<DateTime> lastUpdated;
  const OwnerIncomeTableCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.monthlyIncome = const Value.absent(),
    this.month = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  OwnerIncomeTableCompanion.insert({
    this.id = const Value.absent(),
    required String ownerId,
    required double monthlyIncome,
    required String month,
    this.lastUpdated = const Value.absent(),
  }) : ownerId = Value(ownerId),
       monthlyIncome = Value(monthlyIncome),
       month = Value(month);
  static Insertable<OwnerIncomeEntity> custom({
    Expression<int>? id,
    Expression<String>? ownerId,
    Expression<double>? monthlyIncome,
    Expression<String>? month,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (monthlyIncome != null) 'monthly_income': monthlyIncome,
      if (month != null) 'month': month,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  OwnerIncomeTableCompanion copyWith({
    Value<int?>? id,
    Value<String>? ownerId,
    Value<double>? monthlyIncome,
    Value<String>? month,
    Value<DateTime>? lastUpdated,
  }) {
    return OwnerIncomeTableCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      month: month ?? this.month,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (monthlyIncome.present) {
      map['monthly_income'] = Variable<double>(monthlyIncome.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnerIncomeTableCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('monthlyIncome: $monthlyIncome, ')
          ..write('month: $month, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $PendingOpsTable pendingOps = $PendingOpsTable(this);
  late final $VehicleAvailabilityTable vehicleAvailability =
      $VehicleAvailabilityTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $PricingsTable pricings = $PricingsTable(this);
  late final $BookingsTable bookings = $BookingsTable(this);
  late final $KvsTable kvs = $KvsTable(this);
  late final $AnalyticsDemandTableTable analyticsDemandTable =
      $AnalyticsDemandTableTable(this);
  late final $AnalyticsExtendedTableTable analyticsExtendedTable =
      $AnalyticsExtendedTableTable(this);
  late final $OwnerIncomeTableTable ownerIncomeTable = $OwnerIncomeTableTable(
    this,
  );
  late final VehiclesDao vehiclesDao = VehiclesDao(this as AppDatabase);
  late final InfraDao infraDao = InfraDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehicles,
    syncState,
    pendingOps,
    vehicleAvailability,
    conversations,
    messages,
    pricings,
    bookings,
    kvs,
    analyticsDemandTable,
    analyticsExtendedTable,
    ownerIncomeTable,
  ];
}

typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      required String vehicleId,
      required String ownerId,
      required String make,
      required String model,
      required int year,
      required String plate,
      required int seats,
      required String transmission,
      required String fuelType,
      required int mileage,
      required String status,
      required double lat,
      required double lng,
      Value<String?> photoUrl,
      required DateTime createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<String> vehicleId,
      Value<String> ownerId,
      Value<String> make,
      Value<String> model,
      Value<int> year,
      Value<String> plate,
      Value<int> seats,
      Value<String> transmission,
      Value<String> fuelType,
      Value<int> mileage,
      Value<String> status,
      Value<double> lat,
      Value<double> lng,
      Value<String?> photoUrl,
      Value<DateTime> createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seats => $composableBuilder(
    column: $table.seats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transmission => $composableBuilder(
    column: $table.transmission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mileage => $composableBuilder(
    column: $table.mileage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seats => $composableBuilder(
    column: $table.seats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transmission => $composableBuilder(
    column: $table.transmission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mileage => $composableBuilder(
    column: $table.mileage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get plate =>
      $composableBuilder(column: $table.plate, builder: (column) => column);

  GeneratedColumn<int> get seats =>
      $composableBuilder(column: $table.seats, builder: (column) => column);

  GeneratedColumn<String> get transmission => $composableBuilder(
    column: $table.transmission,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<int> get mileage =>
      $composableBuilder(column: $table.mileage, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          VehiclesData,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (
            VehiclesData,
            BaseReferences<_$AppDatabase, $VehiclesTable, VehiclesData>,
          ),
          VehiclesData,
          PrefetchHooks Function()
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> vehicleId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> make = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> plate = const Value.absent(),
                Value<int> seats = const Value.absent(),
                Value<String> transmission = const Value.absent(),
                Value<String> fuelType = const Value.absent(),
                Value<int> mileage = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion(
                vehicleId: vehicleId,
                ownerId: ownerId,
                make: make,
                model: model,
                year: year,
                plate: plate,
                seats: seats,
                transmission: transmission,
                fuelType: fuelType,
                mileage: mileage,
                status: status,
                lat: lat,
                lng: lng,
                photoUrl: photoUrl,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String vehicleId,
                required String ownerId,
                required String make,
                required String model,
                required int year,
                required String plate,
                required int seats,
                required String transmission,
                required String fuelType,
                required int mileage,
                required String status,
                required double lat,
                required double lng,
                Value<String?> photoUrl = const Value.absent(),
                required DateTime createdAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion.insert(
                vehicleId: vehicleId,
                ownerId: ownerId,
                make: make,
                model: model,
                year: year,
                plate: plate,
                seats: seats,
                transmission: transmission,
                fuelType: fuelType,
                mileage: mileage,
                status: status,
                lat: lat,
                lng: lng,
                photoUrl: photoUrl,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      VehiclesData,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (
        VehiclesData,
        BaseReferences<_$AppDatabase, $VehiclesTable, VehiclesData>,
      ),
      VehiclesData,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String entity,
      Value<DateTime?> lastFetchAt,
      Value<String?> etag,
      Value<String?> pageCursor,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> entity,
      Value<DateTime?> lastFetchAt,
      Value<String?> etag,
      Value<String?> pageCursor,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetchAt => $composableBuilder(
    column: $table.lastFetchAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageCursor => $composableBuilder(
    column: $table.pageCursor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetchAt => $composableBuilder(
    column: $table.lastFetchAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageCursor => $composableBuilder(
    column: $table.pageCursor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFetchAt => $composableBuilder(
    column: $table.lastFetchAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<String> get pageCursor => $composableBuilder(
    column: $table.pageCursor,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<DateTime?> lastFetchAt = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String?> pageCursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                entity: entity,
                lastFetchAt: lastFetchAt,
                etag: etag,
                pageCursor: pageCursor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                Value<DateTime?> lastFetchAt = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String?> pageCursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                entity: entity,
                lastFetchAt: lastFetchAt,
                etag: etag,
                pageCursor: pageCursor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$PendingOpsTableCreateCompanionBuilder =
    PendingOpsCompanion Function({
      Value<int> id,
      required String method,
      required String url,
      Value<String?> headers,
      Value<Uint8List?> body,
      required String kind,
      Value<String?> correlationId,
      Value<int> attempts,
      Value<DateTime?> nextRetryAt,
      Value<String> status,
      Value<DateTime> createdAt,
    });
typedef $$PendingOpsTableUpdateCompanionBuilder =
    PendingOpsCompanion Function({
      Value<int> id,
      Value<String> method,
      Value<String> url,
      Value<String?> headers,
      Value<Uint8List?> body,
      Value<String> kind,
      Value<String?> correlationId,
      Value<int> attempts,
      Value<DateTime?> nextRetryAt,
      Value<String> status,
      Value<DateTime> createdAt,
    });

class $$PendingOpsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correlationId => $composableBuilder(
    column: $table.correlationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correlationId => $composableBuilder(
    column: $table.correlationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get headers =>
      $composableBuilder(column: $table.headers, builder: (column) => column);

  GeneratedColumn<Uint8List> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get correlationId => $composableBuilder(
    column: $table.correlationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingOpsTable,
          PendingOpsData,
          $$PendingOpsTableFilterComposer,
          $$PendingOpsTableOrderingComposer,
          $$PendingOpsTableAnnotationComposer,
          $$PendingOpsTableCreateCompanionBuilder,
          $$PendingOpsTableUpdateCompanionBuilder,
          (
            PendingOpsData,
            BaseReferences<_$AppDatabase, $PendingOpsTable, PendingOpsData>,
          ),
          PendingOpsData,
          PrefetchHooks Function()
        > {
  $$PendingOpsTableTableManager(_$AppDatabase db, $PendingOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> headers = const Value.absent(),
                Value<Uint8List?> body = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> correlationId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingOpsCompanion(
                id: id,
                method: method,
                url: url,
                headers: headers,
                body: body,
                kind: kind,
                correlationId: correlationId,
                attempts: attempts,
                nextRetryAt: nextRetryAt,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String method,
                required String url,
                Value<String?> headers = const Value.absent(),
                Value<Uint8List?> body = const Value.absent(),
                required String kind,
                Value<String?> correlationId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingOpsCompanion.insert(
                id: id,
                method: method,
                url: url,
                headers: headers,
                body: body,
                kind: kind,
                correlationId: correlationId,
                attempts: attempts,
                nextRetryAt: nextRetryAt,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingOpsTable,
      PendingOpsData,
      $$PendingOpsTableFilterComposer,
      $$PendingOpsTableOrderingComposer,
      $$PendingOpsTableAnnotationComposer,
      $$PendingOpsTableCreateCompanionBuilder,
      $$PendingOpsTableUpdateCompanionBuilder,
      (
        PendingOpsData,
        BaseReferences<_$AppDatabase, $PendingOpsTable, PendingOpsData>,
      ),
      PendingOpsData,
      PrefetchHooks Function()
    >;
typedef $$VehicleAvailabilityTableCreateCompanionBuilder =
    VehicleAvailabilityCompanion Function({
      required String availabilityId,
      required String vehicleId,
      required DateTime startTs,
      required DateTime endTs,
      required String type,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$VehicleAvailabilityTableUpdateCompanionBuilder =
    VehicleAvailabilityCompanion Function({
      Value<String> availabilityId,
      Value<String> vehicleId,
      Value<DateTime> startTs,
      Value<DateTime> endTs,
      Value<String> type,
      Value<String?> notes,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$VehicleAvailabilityTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleAvailabilityTable> {
  $$VehicleAvailabilityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get availabilityId => $composableBuilder(
    column: $table.availabilityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTs => $composableBuilder(
    column: $table.startTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTs => $composableBuilder(
    column: $table.endTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehicleAvailabilityTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleAvailabilityTable> {
  $$VehicleAvailabilityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get availabilityId => $composableBuilder(
    column: $table.availabilityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTs => $composableBuilder(
    column: $table.startTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTs => $composableBuilder(
    column: $table.endTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehicleAvailabilityTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleAvailabilityTable> {
  $$VehicleAvailabilityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get availabilityId => $composableBuilder(
    column: $table.availabilityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<DateTime> get startTs =>
      $composableBuilder(column: $table.startTs, builder: (column) => column);

  GeneratedColumn<DateTime> get endTs =>
      $composableBuilder(column: $table.endTs, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$VehicleAvailabilityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleAvailabilityTable,
          VehicleAvailabilityData,
          $$VehicleAvailabilityTableFilterComposer,
          $$VehicleAvailabilityTableOrderingComposer,
          $$VehicleAvailabilityTableAnnotationComposer,
          $$VehicleAvailabilityTableCreateCompanionBuilder,
          $$VehicleAvailabilityTableUpdateCompanionBuilder,
          (
            VehicleAvailabilityData,
            BaseReferences<
              _$AppDatabase,
              $VehicleAvailabilityTable,
              VehicleAvailabilityData
            >,
          ),
          VehicleAvailabilityData,
          PrefetchHooks Function()
        > {
  $$VehicleAvailabilityTableTableManager(
    _$AppDatabase db,
    $VehicleAvailabilityTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleAvailabilityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleAvailabilityTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VehicleAvailabilityTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> availabilityId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<DateTime> startTs = const Value.absent(),
                Value<DateTime> endTs = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleAvailabilityCompanion(
                availabilityId: availabilityId,
                vehicleId: vehicleId,
                startTs: startTs,
                endTs: endTs,
                type: type,
                notes: notes,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String availabilityId,
                required String vehicleId,
                required DateTime startTs,
                required DateTime endTs,
                required String type,
                Value<String?> notes = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleAvailabilityCompanion.insert(
                availabilityId: availabilityId,
                vehicleId: vehicleId,
                startTs: startTs,
                endTs: endTs,
                type: type,
                notes: notes,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehicleAvailabilityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleAvailabilityTable,
      VehicleAvailabilityData,
      $$VehicleAvailabilityTableFilterComposer,
      $$VehicleAvailabilityTableOrderingComposer,
      $$VehicleAvailabilityTableAnnotationComposer,
      $$VehicleAvailabilityTableCreateCompanionBuilder,
      $$VehicleAvailabilityTableUpdateCompanionBuilder,
      (
        VehicleAvailabilityData,
        BaseReferences<
          _$AppDatabase,
          $VehicleAvailabilityTable,
          VehicleAvailabilityData
        >,
      ),
      VehicleAvailabilityData,
      PrefetchHooks Function()
    >;
typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      required String conversationId,
      required String userLowId,
      required String userHighId,
      required DateTime createdAt,
      Value<DateTime?> lastMessageAt,
      Value<int> rowid,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<String> conversationId,
      Value<String> userLowId,
      Value<String> userHighId,
      Value<DateTime> createdAt,
      Value<DateTime?> lastMessageAt,
      Value<int> rowid,
    });

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userLowId => $composableBuilder(
    column: $table.userLowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userHighId => $composableBuilder(
    column: $table.userHighId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userLowId => $composableBuilder(
    column: $table.userLowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userHighId => $composableBuilder(
    column: $table.userHighId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userLowId =>
      $composableBuilder(column: $table.userLowId, builder: (column) => column);

  GeneratedColumn<String> get userHighId => $composableBuilder(
    column: $table.userHighId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          ConversationsData,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (
            ConversationsData,
            BaseReferences<
              _$AppDatabase,
              $ConversationsTable,
              ConversationsData
            >,
          ),
          ConversationsData,
          PrefetchHooks Function()
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> conversationId = const Value.absent(),
                Value<String> userLowId = const Value.absent(),
                Value<String> userHighId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                conversationId: conversationId,
                userLowId: userLowId,
                userHighId: userHighId,
                createdAt: createdAt,
                lastMessageAt: lastMessageAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String conversationId,
                required String userLowId,
                required String userHighId,
                required DateTime createdAt,
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                conversationId: conversationId,
                userLowId: userLowId,
                userHighId: userHighId,
                createdAt: createdAt,
                lastMessageAt: lastMessageAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      ConversationsData,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (
        ConversationsData,
        BaseReferences<_$AppDatabase, $ConversationsTable, ConversationsData>,
      ),
      ConversationsData,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String messageId,
      Value<String?> conversationId,
      required String senderId,
      required String receiverId,
      required String content,
      Value<String?> meta,
      required DateTime createdAt,
      Value<DateTime?> readAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> messageId,
      Value<String?> conversationId,
      Value<String> senderId,
      Value<String> receiverId,
      Value<String> content,
      Value<String?> meta,
      Value<DateTime> createdAt,
      Value<DateTime?> readAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiverId => $composableBuilder(
    column: $table.receiverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiverId => $composableBuilder(
    column: $table.receiverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get receiverId => $composableBuilder(
    column: $table.receiverId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get meta =>
      $composableBuilder(column: $table.meta, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          MessagesData,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (
            MessagesData,
            BaseReferences<_$AppDatabase, $MessagesTable, MessagesData>,
          ),
          MessagesData,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> messageId = const Value.absent(),
                Value<String?> conversationId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> receiverId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> meta = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                messageId: messageId,
                conversationId: conversationId,
                senderId: senderId,
                receiverId: receiverId,
                content: content,
                meta: meta,
                createdAt: createdAt,
                readAt: readAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageId,
                Value<String?> conversationId = const Value.absent(),
                required String senderId,
                required String receiverId,
                required String content,
                Value<String?> meta = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> readAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                messageId: messageId,
                conversationId: conversationId,
                senderId: senderId,
                receiverId: receiverId,
                content: content,
                meta: meta,
                createdAt: createdAt,
                readAt: readAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      MessagesData,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (
        MessagesData,
        BaseReferences<_$AppDatabase, $MessagesTable, MessagesData>,
      ),
      MessagesData,
      PrefetchHooks Function()
    >;
typedef $$PricingsTableCreateCompanionBuilder =
    PricingsCompanion Function({
      required String pricingId,
      required String vehicleId,
      required double dailyPrice,
      required int minDays,
      Value<int?> maxDays,
      required String currency,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$PricingsTableUpdateCompanionBuilder =
    PricingsCompanion Function({
      Value<String> pricingId,
      Value<String> vehicleId,
      Value<double> dailyPrice,
      Value<int> minDays,
      Value<int?> maxDays,
      Value<String> currency,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$PricingsTableFilterComposer
    extends Composer<_$AppDatabase, $PricingsTable> {
  $$PricingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pricingId => $composableBuilder(
    column: $table.pricingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyPrice => $composableBuilder(
    column: $table.dailyPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minDays => $composableBuilder(
    column: $table.minDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxDays => $composableBuilder(
    column: $table.maxDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PricingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PricingsTable> {
  $$PricingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pricingId => $composableBuilder(
    column: $table.pricingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyPrice => $composableBuilder(
    column: $table.dailyPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minDays => $composableBuilder(
    column: $table.minDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxDays => $composableBuilder(
    column: $table.maxDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PricingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PricingsTable> {
  $$PricingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pricingId =>
      $composableBuilder(column: $table.pricingId, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<double> get dailyPrice => $composableBuilder(
    column: $table.dailyPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minDays =>
      $composableBuilder(column: $table.minDays, builder: (column) => column);

  GeneratedColumn<int> get maxDays =>
      $composableBuilder(column: $table.maxDays, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$PricingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PricingsTable,
          PricingData,
          $$PricingsTableFilterComposer,
          $$PricingsTableOrderingComposer,
          $$PricingsTableAnnotationComposer,
          $$PricingsTableCreateCompanionBuilder,
          $$PricingsTableUpdateCompanionBuilder,
          (
            PricingData,
            BaseReferences<_$AppDatabase, $PricingsTable, PricingData>,
          ),
          PricingData,
          PrefetchHooks Function()
        > {
  $$PricingsTableTableManager(_$AppDatabase db, $PricingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PricingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PricingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PricingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pricingId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<double> dailyPrice = const Value.absent(),
                Value<int> minDays = const Value.absent(),
                Value<int?> maxDays = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PricingsCompanion(
                pricingId: pricingId,
                vehicleId: vehicleId,
                dailyPrice: dailyPrice,
                minDays: minDays,
                maxDays: maxDays,
                currency: currency,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pricingId,
                required String vehicleId,
                required double dailyPrice,
                required int minDays,
                Value<int?> maxDays = const Value.absent(),
                required String currency,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PricingsCompanion.insert(
                pricingId: pricingId,
                vehicleId: vehicleId,
                dailyPrice: dailyPrice,
                minDays: minDays,
                maxDays: maxDays,
                currency: currency,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PricingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PricingsTable,
      PricingData,
      $$PricingsTableFilterComposer,
      $$PricingsTableOrderingComposer,
      $$PricingsTableAnnotationComposer,
      $$PricingsTableCreateCompanionBuilder,
      $$PricingsTableUpdateCompanionBuilder,
      (PricingData, BaseReferences<_$AppDatabase, $PricingsTable, PricingData>),
      PricingData,
      PrefetchHooks Function()
    >;
typedef $$BookingsTableCreateCompanionBuilder =
    BookingsCompanion Function({
      required String bookingId,
      required String vehicleId,
      required String renterId,
      required String hostId,
      required DateTime startTs,
      required DateTime endTs,
      required double dailyPriceSnapshot,
      Value<double?> insuranceDailyCostSnapshot,
      required double subtotal,
      Value<double?> fees,
      Value<double?> taxes,
      required double total,
      required String currency,
      Value<int?> odoStart,
      Value<int?> odoEnd,
      Value<int?> fuelStart,
      Value<int?> fuelEnd,
      required String status,
      required DateTime createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$BookingsTableUpdateCompanionBuilder =
    BookingsCompanion Function({
      Value<String> bookingId,
      Value<String> vehicleId,
      Value<String> renterId,
      Value<String> hostId,
      Value<DateTime> startTs,
      Value<DateTime> endTs,
      Value<double> dailyPriceSnapshot,
      Value<double?> insuranceDailyCostSnapshot,
      Value<double> subtotal,
      Value<double?> fees,
      Value<double?> taxes,
      Value<double> total,
      Value<String> currency,
      Value<int?> odoStart,
      Value<int?> odoEnd,
      Value<int?> fuelStart,
      Value<int?> fuelEnd,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$BookingsTableFilterComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookingId => $composableBuilder(
    column: $table.bookingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get renterId => $composableBuilder(
    column: $table.renterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostId => $composableBuilder(
    column: $table.hostId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTs => $composableBuilder(
    column: $table.startTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTs => $composableBuilder(
    column: $table.endTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyPriceSnapshot => $composableBuilder(
    column: $table.dailyPriceSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get insuranceDailyCostSnapshot => $composableBuilder(
    column: $table.insuranceDailyCostSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxes => $composableBuilder(
    column: $table.taxes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odoStart => $composableBuilder(
    column: $table.odoStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odoEnd => $composableBuilder(
    column: $table.odoEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fuelStart => $composableBuilder(
    column: $table.fuelStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fuelEnd => $composableBuilder(
    column: $table.fuelEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookingId => $composableBuilder(
    column: $table.bookingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get renterId => $composableBuilder(
    column: $table.renterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostId => $composableBuilder(
    column: $table.hostId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTs => $composableBuilder(
    column: $table.startTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTs => $composableBuilder(
    column: $table.endTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyPriceSnapshot => $composableBuilder(
    column: $table.dailyPriceSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get insuranceDailyCostSnapshot => $composableBuilder(
    column: $table.insuranceDailyCostSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxes => $composableBuilder(
    column: $table.taxes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odoStart => $composableBuilder(
    column: $table.odoStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odoEnd => $composableBuilder(
    column: $table.odoEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fuelStart => $composableBuilder(
    column: $table.fuelStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fuelEnd => $composableBuilder(
    column: $table.fuelEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookingId =>
      $composableBuilder(column: $table.bookingId, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get renterId =>
      $composableBuilder(column: $table.renterId, builder: (column) => column);

  GeneratedColumn<String> get hostId =>
      $composableBuilder(column: $table.hostId, builder: (column) => column);

  GeneratedColumn<DateTime> get startTs =>
      $composableBuilder(column: $table.startTs, builder: (column) => column);

  GeneratedColumn<DateTime> get endTs =>
      $composableBuilder(column: $table.endTs, builder: (column) => column);

  GeneratedColumn<double> get dailyPriceSnapshot => $composableBuilder(
    column: $table.dailyPriceSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get insuranceDailyCostSnapshot => $composableBuilder(
    column: $table.insuranceDailyCostSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get fees =>
      $composableBuilder(column: $table.fees, builder: (column) => column);

  GeneratedColumn<double> get taxes =>
      $composableBuilder(column: $table.taxes, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get odoStart =>
      $composableBuilder(column: $table.odoStart, builder: (column) => column);

  GeneratedColumn<int> get odoEnd =>
      $composableBuilder(column: $table.odoEnd, builder: (column) => column);

  GeneratedColumn<int> get fuelStart =>
      $composableBuilder(column: $table.fuelStart, builder: (column) => column);

  GeneratedColumn<int> get fuelEnd =>
      $composableBuilder(column: $table.fuelEnd, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$BookingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookingsTable,
          BookingsData,
          $$BookingsTableFilterComposer,
          $$BookingsTableOrderingComposer,
          $$BookingsTableAnnotationComposer,
          $$BookingsTableCreateCompanionBuilder,
          $$BookingsTableUpdateCompanionBuilder,
          (
            BookingsData,
            BaseReferences<_$AppDatabase, $BookingsTable, BookingsData>,
          ),
          BookingsData,
          PrefetchHooks Function()
        > {
  $$BookingsTableTableManager(_$AppDatabase db, $BookingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookingId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> renterId = const Value.absent(),
                Value<String> hostId = const Value.absent(),
                Value<DateTime> startTs = const Value.absent(),
                Value<DateTime> endTs = const Value.absent(),
                Value<double> dailyPriceSnapshot = const Value.absent(),
                Value<double?> insuranceDailyCostSnapshot =
                    const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double?> fees = const Value.absent(),
                Value<double?> taxes = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> odoStart = const Value.absent(),
                Value<int?> odoEnd = const Value.absent(),
                Value<int?> fuelStart = const Value.absent(),
                Value<int?> fuelEnd = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingsCompanion(
                bookingId: bookingId,
                vehicleId: vehicleId,
                renterId: renterId,
                hostId: hostId,
                startTs: startTs,
                endTs: endTs,
                dailyPriceSnapshot: dailyPriceSnapshot,
                insuranceDailyCostSnapshot: insuranceDailyCostSnapshot,
                subtotal: subtotal,
                fees: fees,
                taxes: taxes,
                total: total,
                currency: currency,
                odoStart: odoStart,
                odoEnd: odoEnd,
                fuelStart: fuelStart,
                fuelEnd: fuelEnd,
                status: status,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookingId,
                required String vehicleId,
                required String renterId,
                required String hostId,
                required DateTime startTs,
                required DateTime endTs,
                required double dailyPriceSnapshot,
                Value<double?> insuranceDailyCostSnapshot =
                    const Value.absent(),
                required double subtotal,
                Value<double?> fees = const Value.absent(),
                Value<double?> taxes = const Value.absent(),
                required double total,
                required String currency,
                Value<int?> odoStart = const Value.absent(),
                Value<int?> odoEnd = const Value.absent(),
                Value<int?> fuelStart = const Value.absent(),
                Value<int?> fuelEnd = const Value.absent(),
                required String status,
                required DateTime createdAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingsCompanion.insert(
                bookingId: bookingId,
                vehicleId: vehicleId,
                renterId: renterId,
                hostId: hostId,
                startTs: startTs,
                endTs: endTs,
                dailyPriceSnapshot: dailyPriceSnapshot,
                insuranceDailyCostSnapshot: insuranceDailyCostSnapshot,
                subtotal: subtotal,
                fees: fees,
                taxes: taxes,
                total: total,
                currency: currency,
                odoStart: odoStart,
                odoEnd: odoEnd,
                fuelStart: fuelStart,
                fuelEnd: fuelEnd,
                status: status,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookingsTable,
      BookingsData,
      $$BookingsTableFilterComposer,
      $$BookingsTableOrderingComposer,
      $$BookingsTableAnnotationComposer,
      $$BookingsTableCreateCompanionBuilder,
      $$BookingsTableUpdateCompanionBuilder,
      (
        BookingsData,
        BaseReferences<_$AppDatabase, $BookingsTable, BookingsData>,
      ),
      BookingsData,
      PrefetchHooks Function()
    >;
typedef $$KvsTableCreateCompanionBuilder =
    KvsCompanion Function({
      required String k,
      Value<String?> v,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$KvsTableUpdateCompanionBuilder =
    KvsCompanion Function({
      Value<String> k,
      Value<String?> v,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$KvsTableFilterComposer extends Composer<_$AppDatabase, $KvsTable> {
  $$KvsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get k => $composableBuilder(
    column: $table.k,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get v => $composableBuilder(
    column: $table.v,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KvsTableOrderingComposer extends Composer<_$AppDatabase, $KvsTable> {
  $$KvsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get k => $composableBuilder(
    column: $table.k,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get v => $composableBuilder(
    column: $table.v,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KvsTableAnnotationComposer extends Composer<_$AppDatabase, $KvsTable> {
  $$KvsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get k =>
      $composableBuilder(column: $table.k, builder: (column) => column);

  GeneratedColumn<String> get v =>
      $composableBuilder(column: $table.v, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$KvsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KvsTable,
          KvEntry,
          $$KvsTableFilterComposer,
          $$KvsTableOrderingComposer,
          $$KvsTableAnnotationComposer,
          $$KvsTableCreateCompanionBuilder,
          $$KvsTableUpdateCompanionBuilder,
          (KvEntry, BaseReferences<_$AppDatabase, $KvsTable, KvEntry>),
          KvEntry,
          PrefetchHooks Function()
        > {
  $$KvsTableTableManager(_$AppDatabase db, $KvsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KvsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KvsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KvsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> k = const Value.absent(),
                Value<String?> v = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  KvsCompanion(k: k, v: v, updatedAt: updatedAt, rowid: rowid),
          createCompanionCallback:
              ({
                required String k,
                Value<String?> v = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KvsCompanion.insert(
                k: k,
                v: v,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KvsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KvsTable,
      KvEntry,
      $$KvsTableFilterComposer,
      $$KvsTableOrderingComposer,
      $$KvsTableAnnotationComposer,
      $$KvsTableCreateCompanionBuilder,
      $$KvsTableUpdateCompanionBuilder,
      (KvEntry, BaseReferences<_$AppDatabase, $KvsTable, KvEntry>),
      KvEntry,
      PrefetchHooks Function()
    >;
typedef $$AnalyticsDemandTableTableCreateCompanionBuilder =
    AnalyticsDemandTableCompanion Function({
      Value<int?> id,
      required double latZone,
      required double lonZone,
      required int rentals,
      Value<DateTime> lastUpdated,
    });
typedef $$AnalyticsDemandTableTableUpdateCompanionBuilder =
    AnalyticsDemandTableCompanion Function({
      Value<int?> id,
      Value<double> latZone,
      Value<double> lonZone,
      Value<int> rentals,
      Value<DateTime> lastUpdated,
    });

class $$AnalyticsDemandTableTableFilterComposer
    extends Composer<_$AppDatabase, $AnalyticsDemandTableTable> {
  $$AnalyticsDemandTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latZone => $composableBuilder(
    column: $table.latZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lonZone => $composableBuilder(
    column: $table.lonZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rentals => $composableBuilder(
    column: $table.rentals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnalyticsDemandTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalyticsDemandTableTable> {
  $$AnalyticsDemandTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latZone => $composableBuilder(
    column: $table.latZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lonZone => $composableBuilder(
    column: $table.lonZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rentals => $composableBuilder(
    column: $table.rentals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnalyticsDemandTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalyticsDemandTableTable> {
  $$AnalyticsDemandTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latZone =>
      $composableBuilder(column: $table.latZone, builder: (column) => column);

  GeneratedColumn<double> get lonZone =>
      $composableBuilder(column: $table.lonZone, builder: (column) => column);

  GeneratedColumn<int> get rentals =>
      $composableBuilder(column: $table.rentals, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$AnalyticsDemandTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnalyticsDemandTableTable,
          AnalyticsDemandEntity,
          $$AnalyticsDemandTableTableFilterComposer,
          $$AnalyticsDemandTableTableOrderingComposer,
          $$AnalyticsDemandTableTableAnnotationComposer,
          $$AnalyticsDemandTableTableCreateCompanionBuilder,
          $$AnalyticsDemandTableTableUpdateCompanionBuilder,
          (
            AnalyticsDemandEntity,
            BaseReferences<
              _$AppDatabase,
              $AnalyticsDemandTableTable,
              AnalyticsDemandEntity
            >,
          ),
          AnalyticsDemandEntity,
          PrefetchHooks Function()
        > {
  $$AnalyticsDemandTableTableTableManager(
    _$AppDatabase db,
    $AnalyticsDemandTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalyticsDemandTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnalyticsDemandTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AnalyticsDemandTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int?> id = const Value.absent(),
                Value<double> latZone = const Value.absent(),
                Value<double> lonZone = const Value.absent(),
                Value<int> rentals = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => AnalyticsDemandTableCompanion(
                id: id,
                latZone: latZone,
                lonZone: lonZone,
                rentals: rentals,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int?> id = const Value.absent(),
                required double latZone,
                required double lonZone,
                required int rentals,
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => AnalyticsDemandTableCompanion.insert(
                id: id,
                latZone: latZone,
                lonZone: lonZone,
                rentals: rentals,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnalyticsDemandTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnalyticsDemandTableTable,
      AnalyticsDemandEntity,
      $$AnalyticsDemandTableTableFilterComposer,
      $$AnalyticsDemandTableTableOrderingComposer,
      $$AnalyticsDemandTableTableAnnotationComposer,
      $$AnalyticsDemandTableTableCreateCompanionBuilder,
      $$AnalyticsDemandTableTableUpdateCompanionBuilder,
      (
        AnalyticsDemandEntity,
        BaseReferences<
          _$AppDatabase,
          $AnalyticsDemandTableTable,
          AnalyticsDemandEntity
        >,
      ),
      AnalyticsDemandEntity,
      PrefetchHooks Function()
    >;
typedef $$AnalyticsExtendedTableTableCreateCompanionBuilder =
    AnalyticsExtendedTableCompanion Function({
      Value<int?> id,
      required double latZone,
      required double lonZone,
      required int hourSlot,
      required String make,
      required int year,
      required String fuelType,
      required String transmission,
      required int rentals,
      Value<DateTime> lastUpdated,
    });
typedef $$AnalyticsExtendedTableTableUpdateCompanionBuilder =
    AnalyticsExtendedTableCompanion Function({
      Value<int?> id,
      Value<double> latZone,
      Value<double> lonZone,
      Value<int> hourSlot,
      Value<String> make,
      Value<int> year,
      Value<String> fuelType,
      Value<String> transmission,
      Value<int> rentals,
      Value<DateTime> lastUpdated,
    });

class $$AnalyticsExtendedTableTableFilterComposer
    extends Composer<_$AppDatabase, $AnalyticsExtendedTableTable> {
  $$AnalyticsExtendedTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latZone => $composableBuilder(
    column: $table.latZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lonZone => $composableBuilder(
    column: $table.lonZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hourSlot => $composableBuilder(
    column: $table.hourSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transmission => $composableBuilder(
    column: $table.transmission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rentals => $composableBuilder(
    column: $table.rentals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnalyticsExtendedTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalyticsExtendedTableTable> {
  $$AnalyticsExtendedTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latZone => $composableBuilder(
    column: $table.latZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lonZone => $composableBuilder(
    column: $table.lonZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hourSlot => $composableBuilder(
    column: $table.hourSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transmission => $composableBuilder(
    column: $table.transmission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rentals => $composableBuilder(
    column: $table.rentals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnalyticsExtendedTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalyticsExtendedTableTable> {
  $$AnalyticsExtendedTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latZone =>
      $composableBuilder(column: $table.latZone, builder: (column) => column);

  GeneratedColumn<double> get lonZone =>
      $composableBuilder(column: $table.lonZone, builder: (column) => column);

  GeneratedColumn<int> get hourSlot =>
      $composableBuilder(column: $table.hourSlot, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<String> get transmission => $composableBuilder(
    column: $table.transmission,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rentals =>
      $composableBuilder(column: $table.rentals, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$AnalyticsExtendedTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnalyticsExtendedTableTable,
          AnalyticsExtendedEntity,
          $$AnalyticsExtendedTableTableFilterComposer,
          $$AnalyticsExtendedTableTableOrderingComposer,
          $$AnalyticsExtendedTableTableAnnotationComposer,
          $$AnalyticsExtendedTableTableCreateCompanionBuilder,
          $$AnalyticsExtendedTableTableUpdateCompanionBuilder,
          (
            AnalyticsExtendedEntity,
            BaseReferences<
              _$AppDatabase,
              $AnalyticsExtendedTableTable,
              AnalyticsExtendedEntity
            >,
          ),
          AnalyticsExtendedEntity,
          PrefetchHooks Function()
        > {
  $$AnalyticsExtendedTableTableTableManager(
    _$AppDatabase db,
    $AnalyticsExtendedTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalyticsExtendedTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AnalyticsExtendedTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AnalyticsExtendedTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int?> id = const Value.absent(),
                Value<double> latZone = const Value.absent(),
                Value<double> lonZone = const Value.absent(),
                Value<int> hourSlot = const Value.absent(),
                Value<String> make = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> fuelType = const Value.absent(),
                Value<String> transmission = const Value.absent(),
                Value<int> rentals = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => AnalyticsExtendedTableCompanion(
                id: id,
                latZone: latZone,
                lonZone: lonZone,
                hourSlot: hourSlot,
                make: make,
                year: year,
                fuelType: fuelType,
                transmission: transmission,
                rentals: rentals,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int?> id = const Value.absent(),
                required double latZone,
                required double lonZone,
                required int hourSlot,
                required String make,
                required int year,
                required String fuelType,
                required String transmission,
                required int rentals,
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => AnalyticsExtendedTableCompanion.insert(
                id: id,
                latZone: latZone,
                lonZone: lonZone,
                hourSlot: hourSlot,
                make: make,
                year: year,
                fuelType: fuelType,
                transmission: transmission,
                rentals: rentals,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnalyticsExtendedTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnalyticsExtendedTableTable,
      AnalyticsExtendedEntity,
      $$AnalyticsExtendedTableTableFilterComposer,
      $$AnalyticsExtendedTableTableOrderingComposer,
      $$AnalyticsExtendedTableTableAnnotationComposer,
      $$AnalyticsExtendedTableTableCreateCompanionBuilder,
      $$AnalyticsExtendedTableTableUpdateCompanionBuilder,
      (
        AnalyticsExtendedEntity,
        BaseReferences<
          _$AppDatabase,
          $AnalyticsExtendedTableTable,
          AnalyticsExtendedEntity
        >,
      ),
      AnalyticsExtendedEntity,
      PrefetchHooks Function()
    >;
typedef $$OwnerIncomeTableTableCreateCompanionBuilder =
    OwnerIncomeTableCompanion Function({
      Value<int?> id,
      required String ownerId,
      required double monthlyIncome,
      required String month,
      Value<DateTime> lastUpdated,
    });
typedef $$OwnerIncomeTableTableUpdateCompanionBuilder =
    OwnerIncomeTableCompanion Function({
      Value<int?> id,
      Value<String> ownerId,
      Value<double> monthlyIncome,
      Value<String> month,
      Value<DateTime> lastUpdated,
    });

class $$OwnerIncomeTableTableFilterComposer
    extends Composer<_$AppDatabase, $OwnerIncomeTableTable> {
  $$OwnerIncomeTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OwnerIncomeTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OwnerIncomeTableTable> {
  $$OwnerIncomeTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OwnerIncomeTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OwnerIncomeTableTable> {
  $$OwnerIncomeTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$OwnerIncomeTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OwnerIncomeTableTable,
          OwnerIncomeEntity,
          $$OwnerIncomeTableTableFilterComposer,
          $$OwnerIncomeTableTableOrderingComposer,
          $$OwnerIncomeTableTableAnnotationComposer,
          $$OwnerIncomeTableTableCreateCompanionBuilder,
          $$OwnerIncomeTableTableUpdateCompanionBuilder,
          (
            OwnerIncomeEntity,
            BaseReferences<
              _$AppDatabase,
              $OwnerIncomeTableTable,
              OwnerIncomeEntity
            >,
          ),
          OwnerIncomeEntity,
          PrefetchHooks Function()
        > {
  $$OwnerIncomeTableTableTableManager(
    _$AppDatabase db,
    $OwnerIncomeTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnerIncomeTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnerIncomeTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnerIncomeTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<double> monthlyIncome = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => OwnerIncomeTableCompanion(
                id: id,
                ownerId: ownerId,
                monthlyIncome: monthlyIncome,
                month: month,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int?> id = const Value.absent(),
                required String ownerId,
                required double monthlyIncome,
                required String month,
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => OwnerIncomeTableCompanion.insert(
                id: id,
                ownerId: ownerId,
                monthlyIncome: monthlyIncome,
                month: month,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OwnerIncomeTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OwnerIncomeTableTable,
      OwnerIncomeEntity,
      $$OwnerIncomeTableTableFilterComposer,
      $$OwnerIncomeTableTableOrderingComposer,
      $$OwnerIncomeTableTableAnnotationComposer,
      $$OwnerIncomeTableTableCreateCompanionBuilder,
      $$OwnerIncomeTableTableUpdateCompanionBuilder,
      (
        OwnerIncomeEntity,
        BaseReferences<
          _$AppDatabase,
          $OwnerIncomeTableTable,
          OwnerIncomeEntity
        >,
      ),
      OwnerIncomeEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$PendingOpsTableTableManager get pendingOps =>
      $$PendingOpsTableTableManager(_db, _db.pendingOps);
  $$VehicleAvailabilityTableTableManager get vehicleAvailability =>
      $$VehicleAvailabilityTableTableManager(_db, _db.vehicleAvailability);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$PricingsTableTableManager get pricings =>
      $$PricingsTableTableManager(_db, _db.pricings);
  $$BookingsTableTableManager get bookings =>
      $$BookingsTableTableManager(_db, _db.bookings);
  $$KvsTableTableManager get kvs => $$KvsTableTableManager(_db, _db.kvs);
  $$AnalyticsDemandTableTableTableManager get analyticsDemandTable =>
      $$AnalyticsDemandTableTableTableManager(_db, _db.analyticsDemandTable);
  $$AnalyticsExtendedTableTableTableManager get analyticsExtendedTable =>
      $$AnalyticsExtendedTableTableTableManager(
        _db,
        _db.analyticsExtendedTable,
      );
  $$OwnerIncomeTableTableTableManager get ownerIncomeTable =>
      $$OwnerIncomeTableTableTableManager(_db, _db.ownerIncomeTable);
}
