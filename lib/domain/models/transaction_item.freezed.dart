// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TransactionItem _$TransactionItemFromJson(Map<String, dynamic> json) {
  return _TransactionItem.fromJson(json);
}

/// @nodoc
mixin _$TransactionItem {
  int? get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get remoteId => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  SyncStatus get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this TransactionItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransactionItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionItemCopyWith<TransactionItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionItemCopyWith<$Res> {
  factory $TransactionItemCopyWith(
    TransactionItem value,
    $Res Function(TransactionItem) then,
  ) = _$TransactionItemCopyWithImpl<$Res, TransactionItem>;
  @useResult
  $Res call({
    int? id,
    String title,
    double amount,
    TransactionType type,
    String category,
    String? note,
    DateTime createdAt,
    String userId,
    String? remoteId,
    DateTime? updatedAt,
    bool isDeleted,
    SyncStatus syncStatus,
  });
}

/// @nodoc
class _$TransactionItemCopyWithImpl<$Res, $Val extends TransactionItem>
    implements $TransactionItemCopyWith<$Res> {
  _$TransactionItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? amount = null,
    Object? type = null,
    Object? category = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? userId = null,
    Object? remoteId = freezed,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
    Object? syncStatus = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TransactionType,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$TransactionItemImplCopyWith<$Res>
    implements $TransactionItemCopyWith<$Res> {
  factory _$$TransactionItemImplCopyWith(
    _$TransactionItemImpl value,
    $Res Function(_$TransactionItemImpl) then,
  ) = __$$TransactionItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String title,
    double amount,
    TransactionType type,
    String category,
    String? note,
    DateTime createdAt,
    String userId,
    String? remoteId,
    DateTime? updatedAt,
    bool isDeleted,
    SyncStatus syncStatus,
  });
}

/// @nodoc
class __$$TransactionItemImplCopyWithImpl<$Res>
    extends _$TransactionItemCopyWithImpl<$Res, _$TransactionItemImpl>
    implements _$$TransactionItemImplCopyWith<$Res> {
  __$$TransactionItemImplCopyWithImpl(
    _$TransactionItemImpl _value,
    $Res Function(_$TransactionItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransactionItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? amount = null,
    Object? type = null,
    Object? category = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? userId = null,
    Object? remoteId = freezed,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
    Object? syncStatus = null,
  }) {
    return _then(
      _$TransactionItemImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TransactionType,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$TransactionItemImpl implements _TransactionItem {
  const _$TransactionItemImpl({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    required this.createdAt,
    this.userId = '',
    this.remoteId,
    this.updatedAt,
    this.isDeleted = false,
    this.syncStatus = SyncStatus.pending,
  });

  factory _$TransactionItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionItemImplFromJson(json);

  @override
  final int? id;
  @override
  final String title;
  @override
  final double amount;
  @override
  final TransactionType type;
  @override
  final String category;
  @override
  final String? note;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final String userId;
  @override
  final String? remoteId;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  @JsonKey()
  final SyncStatus syncStatus;

  @override
  String toString() {
    return 'TransactionItem(id: $id, title: $title, amount: $amount, type: $type, category: $category, note: $note, createdAt: $createdAt, userId: $userId, remoteId: $remoteId, updatedAt: $updatedAt, isDeleted: $isDeleted, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.remoteId, remoteId) ||
                other.remoteId == remoteId) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    amount,
    type,
    category,
    note,
    createdAt,
    userId,
    remoteId,
    updatedAt,
    isDeleted,
    syncStatus,
  );

  /// Create a copy of TransactionItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionItemImplCopyWith<_$TransactionItemImpl> get copyWith =>
      __$$TransactionItemImplCopyWithImpl<_$TransactionItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionItemImplToJson(this);
  }
}

abstract class _TransactionItem implements TransactionItem {
  const factory _TransactionItem({
    final int? id,
    required final String title,
    required final double amount,
    required final TransactionType type,
    required final String category,
    final String? note,
    required final DateTime createdAt,
    final String userId,
    final String? remoteId,
    final DateTime? updatedAt,
    final bool isDeleted,
    final SyncStatus syncStatus,
  }) = _$TransactionItemImpl;

  factory _TransactionItem.fromJson(Map<String, dynamic> json) =
      _$TransactionItemImpl.fromJson;

  @override
  int? get id;
  @override
  String get title;
  @override
  double get amount;
  @override
  TransactionType get type;
  @override
  String get category;
  @override
  String? get note;
  @override
  DateTime get createdAt;
  @override
  String get userId;
  @override
  String? get remoteId;
  @override
  DateTime? get updatedAt;
  @override
  bool get isDeleted;
  @override
  SyncStatus get syncStatus;

  /// Create a copy of TransactionItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionItemImplCopyWith<_$TransactionItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
