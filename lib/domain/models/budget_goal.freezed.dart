// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BudgetGoal _$BudgetGoalFromJson(Map<String, dynamic> json) {
  return _BudgetGoal.fromJson(json);
}

/// @nodoc
mixin _$BudgetGoal {
  int? get id => throw _privateConstructorUsedError;
  double get weeklyBudget => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get remoteId => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  SyncStatus get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this BudgetGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BudgetGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BudgetGoalCopyWith<BudgetGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetGoalCopyWith<$Res> {
  factory $BudgetGoalCopyWith(
    BudgetGoal value,
    $Res Function(BudgetGoal) then,
  ) = _$BudgetGoalCopyWithImpl<$Res, BudgetGoal>;
  @useResult
  $Res call({
    int? id,
    double weeklyBudget,
    DateTime startDate,
    bool isActive,
    String userId,
    String? remoteId,
    DateTime? updatedAt,
    SyncStatus syncStatus,
  });
}

/// @nodoc
class _$BudgetGoalCopyWithImpl<$Res, $Val extends BudgetGoal>
    implements $BudgetGoalCopyWith<$Res> {
  _$BudgetGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BudgetGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? weeklyBudget = null,
    Object? startDate = null,
    Object? isActive = null,
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
            weeklyBudget: null == weeklyBudget
                ? _value.weeklyBudget
                : weeklyBudget // ignore: cast_nullable_to_non_nullable
                      as double,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$BudgetGoalImplCopyWith<$Res>
    implements $BudgetGoalCopyWith<$Res> {
  factory _$$BudgetGoalImplCopyWith(
    _$BudgetGoalImpl value,
    $Res Function(_$BudgetGoalImpl) then,
  ) = __$$BudgetGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    double weeklyBudget,
    DateTime startDate,
    bool isActive,
    String userId,
    String? remoteId,
    DateTime? updatedAt,
    SyncStatus syncStatus,
  });
}

/// @nodoc
class __$$BudgetGoalImplCopyWithImpl<$Res>
    extends _$BudgetGoalCopyWithImpl<$Res, _$BudgetGoalImpl>
    implements _$$BudgetGoalImplCopyWith<$Res> {
  __$$BudgetGoalImplCopyWithImpl(
    _$BudgetGoalImpl _value,
    $Res Function(_$BudgetGoalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BudgetGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? weeklyBudget = null,
    Object? startDate = null,
    Object? isActive = null,
    Object? userId = null,
    Object? remoteId = freezed,
    Object? updatedAt = freezed,
    Object? syncStatus = null,
  }) {
    return _then(
      _$BudgetGoalImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        weeklyBudget: null == weeklyBudget
            ? _value.weeklyBudget
            : weeklyBudget // ignore: cast_nullable_to_non_nullable
                  as double,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$BudgetGoalImpl implements _BudgetGoal {
  const _$BudgetGoalImpl({
    this.id,
    required this.weeklyBudget,
    required this.startDate,
    this.isActive = true,
    this.userId = '',
    this.remoteId,
    this.updatedAt,
    this.syncStatus = SyncStatus.pending,
  });

  factory _$BudgetGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$BudgetGoalImplFromJson(json);

  @override
  final int? id;
  @override
  final double weeklyBudget;
  @override
  final DateTime startDate;
  @override
  @JsonKey()
  final bool isActive;
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
    return 'BudgetGoal(id: $id, weeklyBudget: $weeklyBudget, startDate: $startDate, isActive: $isActive, userId: $userId, remoteId: $remoteId, updatedAt: $updatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.weeklyBudget, weeklyBudget) ||
                other.weeklyBudget == weeklyBudget) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
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
    weeklyBudget,
    startDate,
    isActive,
    userId,
    remoteId,
    updatedAt,
    syncStatus,
  );

  /// Create a copy of BudgetGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetGoalImplCopyWith<_$BudgetGoalImpl> get copyWith =>
      __$$BudgetGoalImplCopyWithImpl<_$BudgetGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BudgetGoalImplToJson(this);
  }
}

abstract class _BudgetGoal implements BudgetGoal {
  const factory _BudgetGoal({
    final int? id,
    required final double weeklyBudget,
    required final DateTime startDate,
    final bool isActive,
    final String userId,
    final String? remoteId,
    final DateTime? updatedAt,
    final SyncStatus syncStatus,
  }) = _$BudgetGoalImpl;

  factory _BudgetGoal.fromJson(Map<String, dynamic> json) =
      _$BudgetGoalImpl.fromJson;

  @override
  int? get id;
  @override
  double get weeklyBudget;
  @override
  DateTime get startDate;
  @override
  bool get isActive;
  @override
  String get userId;
  @override
  String? get remoteId;
  @override
  DateTime? get updatedAt;
  @override
  SyncStatus get syncStatus;

  /// Create a copy of BudgetGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BudgetGoalImplCopyWith<_$BudgetGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
