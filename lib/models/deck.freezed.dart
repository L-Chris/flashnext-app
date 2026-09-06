// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deck.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Deck {

 int get id; String get name; String get description; String get createdAt; int get dueCount; QueueCounts get counts; Usage get usage;
/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeckCopyWith<Deck> get copyWith => _$DeckCopyWithImpl<Deck>(this as Deck, _$identity);

  /// Serializes this Deck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Deck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Deck&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.dueCount, _this.dueCount) || other.dueCount == _this.dueCount)&&(identical(other.counts, _this.counts) || other.counts == _this.counts)&&(identical(other.usage, _this.usage) || other.usage == _this.usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Deck;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.createdAt,_this.dueCount,_this.counts,_this.usage);
}

@override
String toString() {
  final _this = this as Deck;
  return 'Deck(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, createdAt: ${_this.createdAt}, dueCount: ${_this.dueCount}, counts: ${_this.counts}, usage: ${_this.usage})';
}


}

/// @nodoc
abstract mixin class $DeckCopyWith<$Res>  {
  factory $DeckCopyWith(Deck value, $Res Function(Deck) _then) = _$DeckCopyWithImpl;
@useResult
$Res call({
 int id, String name, String description, String createdAt, int dueCount, QueueCounts counts, Usage usage
});


$QueueCountsCopyWith<$Res> get counts;$UsageCopyWith<$Res> get usage;

}
/// @nodoc
class _$DeckCopyWithImpl<$Res>
    implements $DeckCopyWith<$Res> {
  _$DeckCopyWithImpl(this._self, this._then);

  final Deck _self;
  final $Res Function(Deck) _then;

/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? createdAt = null,Object? dueCount = null,Object? counts = null,Object? usage = null,}) {
  return _then(Deck(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,dueCount: null == dueCount ? _self.dueCount : dueCount // ignore: cast_nullable_to_non_nullable
as int,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as QueueCounts,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as Usage,
  ));
}
/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueueCountsCopyWith<$Res> get counts {
  
  return $QueueCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageCopyWith<$Res> get usage {
  
  return $UsageCopyWith<$Res>(_self.usage, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}


/// Adds pattern-matching-related methods to [Deck].
extension DeckPatterns on Deck {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Deck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Deck() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Deck value)  $default,){
final _that = this;
switch (_that) {
case _Deck():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Deck value)?  $default,){
final _that = this;
switch (_that) {
case _Deck() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String description,  String createdAt,  int dueCount,  QueueCounts counts,  Usage usage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Deck() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.createdAt,_that.dueCount,_that.counts,_that.usage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String description,  String createdAt,  int dueCount,  QueueCounts counts,  Usage usage)  $default,) {final _that = this;
switch (_that) {
case _Deck():
return $default(_that.id,_that.name,_that.description,_that.createdAt,_that.dueCount,_that.counts,_that.usage);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String description,  String createdAt,  int dueCount,  QueueCounts counts,  Usage usage)?  $default,) {final _that = this;
switch (_that) {
case _Deck() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.createdAt,_that.dueCount,_that.counts,_that.usage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Deck implements Deck {
  const _Deck({this.id = 0, this.name = '', this.description = '', this.createdAt = '', this.dueCount = 0, this.counts = const QueueCounts(), this.usage = const Usage()});
  factory _Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  String createdAt;
@override@JsonKey() final  int dueCount;
@override@JsonKey() final  QueueCounts counts;
@override@JsonKey() final  Usage usage;

/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeckCopyWith<_Deck> get copyWith => __$DeckCopyWithImpl<_Deck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Deck&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.dueCount, dueCount) || other.dueCount == dueCount)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.usage, usage) || other.usage == usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,createdAt,dueCount,counts,usage);
}

@override
String toString() {
    return 'Deck(id: $id, name: $name, description: $description, createdAt: $createdAt, dueCount: $dueCount, counts: $counts, usage: $usage)';
}


}

/// @nodoc
abstract mixin class _$DeckCopyWith<$Res> implements $DeckCopyWith<$Res> {
  factory _$DeckCopyWith(_Deck value, $Res Function(_Deck) _then) = __$DeckCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String description, String createdAt, int dueCount, QueueCounts counts, Usage usage
});


@override $QueueCountsCopyWith<$Res> get counts;@override $UsageCopyWith<$Res> get usage;

}
/// @nodoc
class __$DeckCopyWithImpl<$Res>
    implements _$DeckCopyWith<$Res> {
  __$DeckCopyWithImpl(this._self, this._then);

  final _Deck _self;
  final $Res Function(_Deck) _then;

/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? createdAt = null,Object? dueCount = null,Object? counts = null,Object? usage = null,}) {
  return _then(_Deck(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,dueCount: null == dueCount ? _self.dueCount : dueCount // ignore: cast_nullable_to_non_nullable
as int,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as QueueCounts,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as Usage,
  ));
}

/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueueCountsCopyWith<$Res> get counts {
  
  return $QueueCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageCopyWith<$Res> get usage {
  
  return $UsageCopyWith<$Res>(_self.usage, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}

// dart format on
