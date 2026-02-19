// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  int? get id => throw _privateConstructorUsedError;
  bool get dailyReminderEnabled => throw _privateConstructorUsedError;
  String get reminderTime => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get remoteId => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  SyncStatus get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
    AppSettings value,
    $Res Function(AppSettings) then,
  ) = _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call({
    int? id,
    bool dailyReminderEnabled,
    String reminderTime,
    String currency,
    String userId,
    String? remoteId,
    DateTime? updatedAt,
    SyncStatus syncStatus,
  });
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? dailyReminderEnabled = null,
    Object? reminderTime = null,
    Object? currency = null,
    Object? userId = null,
    Object? remoteId = freezed,
    Object? updatedAt = freezed,
    Object? syncStatus = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            dailyReminderEnabled: null == dailyReminderEnabled
                ? _value.dailyReminderEnabled
                : dailyReminderEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            reminderTime: null == reminderTime
                ? _value.reminderTime
                : reminderTime // ignore: cast_nullable_to_non_nullable
                      as String,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            remoteId: freezed == remoteId
                ? _value.remoteId
                : remoteId // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            syncStatus: null == syncStatus
                ? _value.syncStatus
                : syncStatus // ignore: cast_nullable_to_non_nullable
                      as SyncStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
    _$AppSettingsImpl value,
    $Res Function(_$AppSettingsImpl) then,
  ) = __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    bool dailyReminderEnabled,
    String reminderTime,
    String currency,
    String userId,
    String? remoteId,
    DateTime? updatedAt,
    SyncStatus syncStatus,
  });
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
    _$AppSettingsImpl _value,
    $Res Function(_$AppSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? dailyReminderEnabled = null,
    Object? reminderTime = null,
    Object? currency = null,
    Object? userId = null,
    Object? remoteId = freezed,
    Object? updatedAt = freezed,
    Object? syncStatus = null,
  }) {
    return _then(
      _$AppSettingsImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        dailyReminderEnabled: null == dailyReminderEnabled
            ? _value.dailyReminderEnabled
            : dailyReminderEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        reminderTime: null == reminderTime
            ? _value.reminderTime
            : reminderTime // ignore: cast_nullable_to_non_nullable
                  as String,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        remoteId: freezed == remoteId
            ? _value.remoteId
            : remoteId // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        syncStatus: null == syncStatus
            ? _value.syncStatus
            : syncStatus // ignore: cast_nullable_to_non_nullable
                  as SyncStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl({
    this.id,
    this.dailyReminderEnabled = false,
    this.reminderTime = '21:00',
    this.currency = 'NPR',
    this.userId = '',
    this.remoteId,
    this.updatedAt,
    this.syncStatus = SyncStatus.pending,
  });

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey()
  final bool dailyReminderEnabled;
  @override
  @JsonKey()
  final String reminderTime;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final String userId;
  @override
  final String? remoteId;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final SyncStatus syncStatus;

  @override
  String toString() {
    return 'AppSettings(id: $id, dailyReminderEnabled: $dailyReminderEnabled, reminderTime: $reminderTime, currency: $currency, userId: $userId, remoteId: $remoteId, updatedAt: $updatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dailyReminderEnabled, dailyReminderEnabled) ||
                other.dailyReminderEnabled == dailyReminderEnabled) &&
            (identical(other.reminderTime, reminderTime) ||
                other.reminderTime == reminderTime) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.remoteId, remoteId) ||
                other.remoteId == remoteId) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    dailyReminderEnabled,
    reminderTime,
    currency,
    userId,
    remoteId,
    updatedAt,
    syncStatus,
  );

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(this);
  }
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings({
    final int? id,
    final bool dailyReminderEnabled,
    final String reminderTime,
    final String currency,
    final String userId,
    final String? remoteId,
    final DateTime? updatedAt,
    final SyncStatus syncStatus,
  }) = _$AppSettingsImpl;

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  @override
  int? get id;
  @override
  bool get dailyReminderEnabled;
  @override
  String get reminderTime;
  @override
  String get currency;
  @override
  String get userId;
  @override
  String? get remoteId;
  @override
  DateTime? get updatedAt;
  @override
  SyncStatus get syncStatus;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
