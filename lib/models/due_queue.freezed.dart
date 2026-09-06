// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'due_queue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QueueCounts {

 int get intraday; int get review; int get fresh; int get queued; int get hiddenByLimit;
/// Create a copy of QueueCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueueCountsCopyWith<QueueCounts> get copyWith => _$QueueCountsCopyWithImpl<QueueCounts>(this as QueueCounts, _$identity);

  /// Serializes this QueueCounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QueueCounts;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueCounts&&(identical(other.intraday, _this.intraday) || other.intraday == _this.intraday)&&(identical(other.review, _this.review) || other.review == _this.review)&&(identical(other.fresh, _this.fresh) || other.fresh == _this.fresh)&&(identical(other.queued, _this.queued) || other.queued == _this.queued)&&(identical(other.hiddenByLimit, _this.hiddenByLimit) || other.hiddenByLimit == _this.hiddenByLimit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QueueCounts;
  return Object.hash(runtimeType,_this.intraday,_this.review,_this.fresh,_this.queued,_this.hiddenByLimit);
}

@override
String toString() {
  final _this = this as QueueCounts;
  return 'QueueCounts(intraday: ${_this.intraday}, review: ${_this.review}, fresh: ${_this.fresh}, queued: ${_this.queued}, hiddenByLimit: ${_this.hiddenByLimit})';
}


}

/// @nodoc
abstract mixin class $QueueCountsCopyWith<$Res>  {
  factory $QueueCountsCopyWith(QueueCounts value, $Res Function(QueueCounts) _then) = _$QueueCountsCopyWithImpl;
@useResult
$Res call({
 int intraday, int review, int fresh, int queued, int hiddenByLimit
});




}
/// @nodoc
class _$QueueCountsCopyWithImpl<$Res>
    implements $QueueCountsCopyWith<$Res> {
  _$QueueCountsCopyWithImpl(this._self, this._then);

  final QueueCounts _self;
  final $Res Function(QueueCounts) _then;

/// Create a copy of QueueCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? intraday = null,Object? review = null,Object? fresh = null,Object? queued = null,Object? hiddenByLimit = null,}) {
  return _then(QueueCounts(
intraday: null == intraday ? _self.intraday : intraday // ignore: cast_nullable_to_non_nullable
as int,review: null == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as int,fresh: null == fresh ? _self.fresh : fresh // ignore: cast_nullable_to_non_nullable
as int,queued: null == queued ? _self.queued : queued // ignore: cast_nullable_to_non_nullable
as int,hiddenByLimit: null == hiddenByLimit ? _self.hiddenByLimit : hiddenByLimit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [QueueCounts].
extension QueueCountsPatterns on QueueCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueueCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueueCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueueCounts value)  $default,){
final _that = this;
switch (_that) {
case _QueueCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueueCounts value)?  $default,){
final _that = this;
switch (_that) {
case _QueueCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int intraday,  int review,  int fresh,  int queued,  int hiddenByLimit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueueCounts() when $default != null:
return $default(_that.intraday,_that.review,_that.fresh,_that.queued,_that.hiddenByLimit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int intraday,  int review,  int fresh,  int queued,  int hiddenByLimit)  $default,) {final _that = this;
switch (_that) {
case _QueueCounts():
return $default(_that.intraday,_that.review,_that.fresh,_that.queued,_that.hiddenByLimit);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int intraday,  int review,  int fresh,  int queued,  int hiddenByLimit)?  $default,) {final _that = this;
switch (_that) {
case _QueueCounts() when $default != null:
return $default(_that.intraday,_that.review,_that.fresh,_that.queued,_that.hiddenByLimit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QueueCounts implements QueueCounts {
  const _QueueCounts({this.intraday = 0, this.review = 0, this.fresh = 0, this.queued = 0, this.hiddenByLimit = 0});
  factory _QueueCounts.fromJson(Map<String, dynamic> json) => _$QueueCountsFromJson(json);

@override@JsonKey() final  int intraday;
@override@JsonKey() final  int review;
@override@JsonKey() final  int fresh;
@override@JsonKey() final  int queued;
@override@JsonKey() final  int hiddenByLimit;

/// Create a copy of QueueCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueueCountsCopyWith<_QueueCounts> get copyWith => __$QueueCountsCopyWithImpl<_QueueCounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QueueCountsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueueCounts&&(identical(other.intraday, intraday) || other.intraday == intraday)&&(identical(other.review, review) || other.review == review)&&(identical(other.fresh, fresh) || other.fresh == fresh)&&(identical(other.queued, queued) || other.queued == queued)&&(identical(other.hiddenByLimit, hiddenByLimit) || other.hiddenByLimit == hiddenByLimit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,intraday,review,fresh,queued,hiddenByLimit);
}

@override
String toString() {
    return 'QueueCounts(intraday: $intraday, review: $review, fresh: $fresh, queued: $queued, hiddenByLimit: $hiddenByLimit)';
}


}

/// @nodoc
abstract mixin class _$QueueCountsCopyWith<$Res> implements $QueueCountsCopyWith<$Res> {
  factory _$QueueCountsCopyWith(_QueueCounts value, $Res Function(_QueueCounts) _then) = __$QueueCountsCopyWithImpl;
@override @useResult
$Res call({
 int intraday, int review, int fresh, int queued, int hiddenByLimit
});




}
/// @nodoc
class __$QueueCountsCopyWithImpl<$Res>
    implements _$QueueCountsCopyWith<$Res> {
  __$QueueCountsCopyWithImpl(this._self, this._then);

  final _QueueCounts _self;
  final $Res Function(_QueueCounts) _then;

/// Create a copy of QueueCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? intraday = null,Object? review = null,Object? fresh = null,Object? queued = null,Object? hiddenByLimit = null,}) {
  return _then(_QueueCounts(
intraday: null == intraday ? _self.intraday : intraday // ignore: cast_nullable_to_non_nullable
as int,review: null == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as int,fresh: null == fresh ? _self.fresh : fresh // ignore: cast_nullable_to_non_nullable
as int,queued: null == queued ? _self.queued : queued // ignore: cast_nullable_to_non_nullable
as int,hiddenByLimit: null == hiddenByLimit ? _self.hiddenByLimit : hiddenByLimit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Usage {

 int get newCount; int get reviewCount; int get newLimit; int get reviewLimit; int get newRemaining; int get reviewRemaining;
/// Create a copy of Usage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsageCopyWith<Usage> get copyWith => _$UsageCopyWithImpl<Usage>(this as Usage, _$identity);

  /// Serializes this Usage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Usage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Usage&&(identical(other.newCount, _this.newCount) || other.newCount == _this.newCount)&&(identical(other.reviewCount, _this.reviewCount) || other.reviewCount == _this.reviewCount)&&(identical(other.newLimit, _this.newLimit) || other.newLimit == _this.newLimit)&&(identical(other.reviewLimit, _this.reviewLimit) || other.reviewLimit == _this.reviewLimit)&&(identical(other.newRemaining, _this.newRemaining) || other.newRemaining == _this.newRemaining)&&(identical(other.reviewRemaining, _this.reviewRemaining) || other.reviewRemaining == _this.reviewRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Usage;
  return Object.hash(runtimeType,_this.newCount,_this.reviewCount,_this.newLimit,_this.reviewLimit,_this.newRemaining,_this.reviewRemaining);
}

@override
String toString() {
  final _this = this as Usage;
  return 'Usage(newCount: ${_this.newCount}, reviewCount: ${_this.reviewCount}, newLimit: ${_this.newLimit}, reviewLimit: ${_this.reviewLimit}, newRemaining: ${_this.newRemaining}, reviewRemaining: ${_this.reviewRemaining})';
}


}

/// @nodoc
abstract mixin class $UsageCopyWith<$Res>  {
  factory $UsageCopyWith(Usage value, $Res Function(Usage) _then) = _$UsageCopyWithImpl;
@useResult
$Res call({
 int newCount, int reviewCount, int newLimit, int reviewLimit, int newRemaining, int reviewRemaining
});




}
/// @nodoc
class _$UsageCopyWithImpl<$Res>
    implements $UsageCopyWith<$Res> {
  _$UsageCopyWithImpl(this._self, this._then);

  final Usage _self;
  final $Res Function(Usage) _then;

/// Create a copy of Usage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? newCount = null,Object? reviewCount = null,Object? newLimit = null,Object? reviewLimit = null,Object? newRemaining = null,Object? reviewRemaining = null,}) {
  return _then(Usage(
newCount: null == newCount ? _self.newCount : newCount // ignore: cast_nullable_to_non_nullable
as int,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,newLimit: null == newLimit ? _self.newLimit : newLimit // ignore: cast_nullable_to_non_nullable
as int,reviewLimit: null == reviewLimit ? _self.reviewLimit : reviewLimit // ignore: cast_nullable_to_non_nullable
as int,newRemaining: null == newRemaining ? _self.newRemaining : newRemaining // ignore: cast_nullable_to_non_nullable
as int,reviewRemaining: null == reviewRemaining ? _self.reviewRemaining : reviewRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Usage].
extension UsagePatterns on Usage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Usage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Usage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Usage value)  $default,){
final _that = this;
switch (_that) {
case _Usage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Usage value)?  $default,){
final _that = this;
switch (_that) {
case _Usage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int newCount,  int reviewCount,  int newLimit,  int reviewLimit,  int newRemaining,  int reviewRemaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Usage() when $default != null:
return $default(_that.newCount,_that.reviewCount,_that.newLimit,_that.reviewLimit,_that.newRemaining,_that.reviewRemaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int newCount,  int reviewCount,  int newLimit,  int reviewLimit,  int newRemaining,  int reviewRemaining)  $default,) {final _that = this;
switch (_that) {
case _Usage():
return $default(_that.newCount,_that.reviewCount,_that.newLimit,_that.reviewLimit,_that.newRemaining,_that.reviewRemaining);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int newCount,  int reviewCount,  int newLimit,  int reviewLimit,  int newRemaining,  int reviewRemaining)?  $default,) {final _that = this;
switch (_that) {
case _Usage() when $default != null:
return $default(_that.newCount,_that.reviewCount,_that.newLimit,_that.reviewLimit,_that.newRemaining,_that.reviewRemaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Usage implements Usage {
  const _Usage({this.newCount = 0, this.reviewCount = 0, this.newLimit = 0, this.reviewLimit = 0, this.newRemaining = 0, this.reviewRemaining = 0});
  factory _Usage.fromJson(Map<String, dynamic> json) => _$UsageFromJson(json);

@override@JsonKey() final  int newCount;
@override@JsonKey() final  int reviewCount;
@override@JsonKey() final  int newLimit;
@override@JsonKey() final  int reviewLimit;
@override@JsonKey() final  int newRemaining;
@override@JsonKey() final  int reviewRemaining;

/// Create a copy of Usage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsageCopyWith<_Usage> get copyWith => __$UsageCopyWithImpl<_Usage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Usage&&(identical(other.newCount, newCount) || other.newCount == newCount)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.newLimit, newLimit) || other.newLimit == newLimit)&&(identical(other.reviewLimit, reviewLimit) || other.reviewLimit == reviewLimit)&&(identical(other.newRemaining, newRemaining) || other.newRemaining == newRemaining)&&(identical(other.reviewRemaining, reviewRemaining) || other.reviewRemaining == reviewRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,newCount,reviewCount,newLimit,reviewLimit,newRemaining,reviewRemaining);
}

@override
String toString() {
    return 'Usage(newCount: $newCount, reviewCount: $reviewCount, newLimit: $newLimit, reviewLimit: $reviewLimit, newRemaining: $newRemaining, reviewRemaining: $reviewRemaining)';
}


}

/// @nodoc
abstract mixin class _$UsageCopyWith<$Res> implements $UsageCopyWith<$Res> {
  factory _$UsageCopyWith(_Usage value, $Res Function(_Usage) _then) = __$UsageCopyWithImpl;
@override @useResult
$Res call({
 int newCount, int reviewCount, int newLimit, int reviewLimit, int newRemaining, int reviewRemaining
});




}
/// @nodoc
class __$UsageCopyWithImpl<$Res>
    implements _$UsageCopyWith<$Res> {
  __$UsageCopyWithImpl(this._self, this._then);

  final _Usage _self;
  final $Res Function(_Usage) _then;

/// Create a copy of Usage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? newCount = null,Object? reviewCount = null,Object? newLimit = null,Object? reviewLimit = null,Object? newRemaining = null,Object? reviewRemaining = null,}) {
  return _then(_Usage(
newCount: null == newCount ? _self.newCount : newCount // ignore: cast_nullable_to_non_nullable
as int,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,newLimit: null == newLimit ? _self.newLimit : newLimit // ignore: cast_nullable_to_non_nullable
as int,reviewLimit: null == reviewLimit ? _self.reviewLimit : reviewLimit // ignore: cast_nullable_to_non_nullable
as int,newRemaining: null == newRemaining ? _self.newRemaining : newRemaining // ignore: cast_nullable_to_non_nullable
as int,reviewRemaining: null == reviewRemaining ? _self.reviewRemaining : reviewRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DueQueue {

 List<Card> get cards; Usage get usage; QueueCounts get counts;
/// Create a copy of DueQueue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DueQueueCopyWith<DueQueue> get copyWith => _$DueQueueCopyWithImpl<DueQueue>(this as DueQueue, _$identity);

  /// Serializes this DueQueue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DueQueue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DueQueue&&const DeepCollectionEquality().equals(other.cards, _this.cards)&&(identical(other.usage, _this.usage) || other.usage == _this.usage)&&(identical(other.counts, _this.counts) || other.counts == _this.counts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DueQueue;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.cards),_this.usage,_this.counts);
}

@override
String toString() {
  final _this = this as DueQueue;
  return 'DueQueue(cards: ${_this.cards}, usage: ${_this.usage}, counts: ${_this.counts})';
}


}

/// @nodoc
abstract mixin class $DueQueueCopyWith<$Res>  {
  factory $DueQueueCopyWith(DueQueue value, $Res Function(DueQueue) _then) = _$DueQueueCopyWithImpl;
@useResult
$Res call({
 List<Card> cards, Usage usage, QueueCounts counts
});


$UsageCopyWith<$Res> get usage;$QueueCountsCopyWith<$Res> get counts;

}
/// @nodoc
class _$DueQueueCopyWithImpl<$Res>
    implements $DueQueueCopyWith<$Res> {
  _$DueQueueCopyWithImpl(this._self, this._then);

  final DueQueue _self;
  final $Res Function(DueQueue) _then;

/// Create a copy of DueQueue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cards = null,Object? usage = null,Object? counts = null,}) {
  return _then(DueQueue(
cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as List<Card>,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as Usage,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as QueueCounts,
  ));
}
/// Create a copy of DueQueue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageCopyWith<$Res> get usage {
  
  return $UsageCopyWith<$Res>(_self.usage, (value) {
    return _then(_self.copyWith(usage: value));
  });
}/// Create a copy of DueQueue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueueCountsCopyWith<$Res> get counts {
  
  return $QueueCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [DueQueue].
extension DueQueuePatterns on DueQueue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DueQueue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DueQueue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DueQueue value)  $default,){
final _that = this;
switch (_that) {
case _DueQueue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DueQueue value)?  $default,){
final _that = this;
switch (_that) {
case _DueQueue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Card> cards,  Usage usage,  QueueCounts counts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DueQueue() when $default != null:
return $default(_that.cards,_that.usage,_that.counts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Card> cards,  Usage usage,  QueueCounts counts)  $default,) {final _that = this;
switch (_that) {
case _DueQueue():
return $default(_that.cards,_that.usage,_that.counts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Card> cards,  Usage usage,  QueueCounts counts)?  $default,) {final _that = this;
switch (_that) {
case _DueQueue() when $default != null:
return $default(_that.cards,_that.usage,_that.counts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DueQueue implements DueQueue {
  const _DueQueue({ List<Card> cards = const <Card>[], this.usage = const Usage(), this.counts = const QueueCounts()}): _cards = cards;
  factory _DueQueue.fromJson(Map<String, dynamic> json) => _$DueQueueFromJson(json);

 final  List<Card> _cards;
@override@JsonKey() List<Card> get cards {
  if (_cards is EqualUnmodifiableListView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cards);
}

@override@JsonKey() final  Usage usage;
@override@JsonKey() final  QueueCounts counts;

/// Create a copy of DueQueue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DueQueueCopyWith<_DueQueue> get copyWith => __$DueQueueCopyWithImpl<_DueQueue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DueQueueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DueQueue&&const DeepCollectionEquality().equals(other.cards, _cards)&&(identical(other.usage, usage) || other.usage == usage)&&(identical(other.counts, counts) || other.counts == counts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_cards),usage,counts);
}

@override
String toString() {
    return 'DueQueue(cards: $cards, usage: $usage, counts: $counts)';
}


}

/// @nodoc
abstract mixin class _$DueQueueCopyWith<$Res> implements $DueQueueCopyWith<$Res> {
  factory _$DueQueueCopyWith(_DueQueue value, $Res Function(_DueQueue) _then) = __$DueQueueCopyWithImpl;
@override @useResult
$Res call({
 List<Card> cards, Usage usage, QueueCounts counts
});


@override $UsageCopyWith<$Res> get usage;@override $QueueCountsCopyWith<$Res> get counts;

}
/// @nodoc
class __$DueQueueCopyWithImpl<$Res>
    implements _$DueQueueCopyWith<$Res> {
  __$DueQueueCopyWithImpl(this._self, this._then);

  final _DueQueue _self;
  final $Res Function(_DueQueue) _then;

/// Create a copy of DueQueue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cards = null,Object? usage = null,Object? counts = null,}) {
  return _then(_DueQueue(
cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as List<Card>,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as Usage,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as QueueCounts,
  ));
}

/// Create a copy of DueQueue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageCopyWith<$Res> get usage {
  
  return $UsageCopyWith<$Res>(_self.usage, (value) {
    return _then(_self.copyWith(usage: value));
  });
}/// Create a copy of DueQueue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueueCountsCopyWith<$Res> get counts {
  
  return $QueueCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// @nodoc
mixin _$WordTag {

 int get id; int get wordId; String get scheme; int get level; String get label;
/// Create a copy of WordTag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordTagCopyWith<WordTag> get copyWith => _$WordTagCopyWithImpl<WordTag>(this as WordTag, _$identity);

  /// Serializes this WordTag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WordTag;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordTag&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId)&&(identical(other.scheme, _this.scheme) || other.scheme == _this.scheme)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.label, _this.label) || other.label == _this.label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WordTag;
  return Object.hash(runtimeType,_this.id,_this.wordId,_this.scheme,_this.level,_this.label);
}

@override
String toString() {
  final _this = this as WordTag;
  return 'WordTag(id: ${_this.id}, wordId: ${_this.wordId}, scheme: ${_this.scheme}, level: ${_this.level}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $WordTagCopyWith<$Res>  {
  factory $WordTagCopyWith(WordTag value, $Res Function(WordTag) _then) = _$WordTagCopyWithImpl;
@useResult
$Res call({
 int id, int wordId, String scheme, int level, String label
});




}
/// @nodoc
class _$WordTagCopyWithImpl<$Res>
    implements $WordTagCopyWith<$Res> {
  _$WordTagCopyWithImpl(this._self, this._then);

  final WordTag _self;
  final $Res Function(WordTag) _then;

/// Create a copy of WordTag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? wordId = null,Object? scheme = null,Object? level = null,Object? label = null,}) {
  return _then(WordTag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as int,scheme: null == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WordTag].
extension WordTagPatterns on WordTag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordTag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordTag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordTag value)  $default,){
final _that = this;
switch (_that) {
case _WordTag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordTag value)?  $default,){
final _that = this;
switch (_that) {
case _WordTag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int wordId,  String scheme,  int level,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordTag() when $default != null:
return $default(_that.id,_that.wordId,_that.scheme,_that.level,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int wordId,  String scheme,  int level,  String label)  $default,) {final _that = this;
switch (_that) {
case _WordTag():
return $default(_that.id,_that.wordId,_that.scheme,_that.level,_that.label);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int wordId,  String scheme,  int level,  String label)?  $default,) {final _that = this;
switch (_that) {
case _WordTag() when $default != null:
return $default(_that.id,_that.wordId,_that.scheme,_that.level,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordTag implements WordTag {
  const _WordTag({this.id = 0, this.wordId = 0, this.scheme = '', this.level = 0, this.label = ''});
  factory _WordTag.fromJson(Map<String, dynamic> json) => _$WordTagFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  int wordId;
@override@JsonKey() final  String scheme;
@override@JsonKey() final  int level;
@override@JsonKey() final  String label;

/// Create a copy of WordTag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordTagCopyWith<_WordTag> get copyWith => __$WordTagCopyWithImpl<_WordTag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordTagToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordTag&&(identical(other.id, id) || other.id == id)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.scheme, scheme) || other.scheme == scheme)&&(identical(other.level, level) || other.level == level)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,wordId,scheme,level,label);
}

@override
String toString() {
    return 'WordTag(id: $id, wordId: $wordId, scheme: $scheme, level: $level, label: $label)';
}


}

/// @nodoc
abstract mixin class _$WordTagCopyWith<$Res> implements $WordTagCopyWith<$Res> {
  factory _$WordTagCopyWith(_WordTag value, $Res Function(_WordTag) _then) = __$WordTagCopyWithImpl;
@override @useResult
$Res call({
 int id, int wordId, String scheme, int level, String label
});




}
/// @nodoc
class __$WordTagCopyWithImpl<$Res>
    implements _$WordTagCopyWith<$Res> {
  __$WordTagCopyWithImpl(this._self, this._then);

  final _WordTag _self;
  final $Res Function(_WordTag) _then;

/// Create a copy of WordTag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? wordId = null,Object? scheme = null,Object? level = null,Object? label = null,}) {
  return _then(_WordTag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as int,scheme: null == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$WordBrief {

 int get id; String get headword; int? get rank; String get pos; String get phonetic; String get translation; List<WordTag> get tags;
/// Create a copy of WordBrief
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordBriefCopyWith<WordBrief> get copyWith => _$WordBriefCopyWithImpl<WordBrief>(this as WordBrief, _$identity);

  /// Serializes this WordBrief to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WordBrief;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordBrief&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.headword, _this.headword) || other.headword == _this.headword)&&(identical(other.rank, _this.rank) || other.rank == _this.rank)&&(identical(other.pos, _this.pos) || other.pos == _this.pos)&&(identical(other.phonetic, _this.phonetic) || other.phonetic == _this.phonetic)&&(identical(other.translation, _this.translation) || other.translation == _this.translation)&&const DeepCollectionEquality().equals(other.tags, _this.tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WordBrief;
  return Object.hash(runtimeType,_this.id,_this.headword,_this.rank,_this.pos,_this.phonetic,_this.translation,const DeepCollectionEquality().hash(_this.tags));
}

@override
String toString() {
  final _this = this as WordBrief;
  return 'WordBrief(id: ${_this.id}, headword: ${_this.headword}, rank: ${_this.rank}, pos: ${_this.pos}, phonetic: ${_this.phonetic}, translation: ${_this.translation}, tags: ${_this.tags})';
}


}

/// @nodoc
abstract mixin class $WordBriefCopyWith<$Res>  {
  factory $WordBriefCopyWith(WordBrief value, $Res Function(WordBrief) _then) = _$WordBriefCopyWithImpl;
@useResult
$Res call({
 int id, String headword, int? rank, String pos, String phonetic, String translation, List<WordTag> tags
});




}
/// @nodoc
class _$WordBriefCopyWithImpl<$Res>
    implements $WordBriefCopyWith<$Res> {
  _$WordBriefCopyWithImpl(this._self, this._then);

  final WordBrief _self;
  final $Res Function(WordBrief) _then;

/// Create a copy of WordBrief
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? headword = null,Object? rank = freezed,Object? pos = null,Object? phonetic = null,Object? translation = null,Object? tags = null,}) {
  return _then(WordBrief(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,headword: null == headword ? _self.headword : headword // ignore: cast_nullable_to_non_nullable
as String,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,pos: null == pos ? _self.pos : pos // ignore: cast_nullable_to_non_nullable
as String,phonetic: null == phonetic ? _self.phonetic : phonetic // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<WordTag>,
  ));
}

}


/// Adds pattern-matching-related methods to [WordBrief].
extension WordBriefPatterns on WordBrief {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordBrief value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordBrief() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordBrief value)  $default,){
final _that = this;
switch (_that) {
case _WordBrief():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordBrief value)?  $default,){
final _that = this;
switch (_that) {
case _WordBrief() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String headword,  int? rank,  String pos,  String phonetic,  String translation,  List<WordTag> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordBrief() when $default != null:
return $default(_that.id,_that.headword,_that.rank,_that.pos,_that.phonetic,_that.translation,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String headword,  int? rank,  String pos,  String phonetic,  String translation,  List<WordTag> tags)  $default,) {final _that = this;
switch (_that) {
case _WordBrief():
return $default(_that.id,_that.headword,_that.rank,_that.pos,_that.phonetic,_that.translation,_that.tags);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String headword,  int? rank,  String pos,  String phonetic,  String translation,  List<WordTag> tags)?  $default,) {final _that = this;
switch (_that) {
case _WordBrief() when $default != null:
return $default(_that.id,_that.headword,_that.rank,_that.pos,_that.phonetic,_that.translation,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordBrief implements WordBrief {
  const _WordBrief({this.id = 0, this.headword = '', this.rank, this.pos = '', this.phonetic = '', this.translation = '',  List<WordTag> tags = const <WordTag>[]}): _tags = tags;
  factory _WordBrief.fromJson(Map<String, dynamic> json) => _$WordBriefFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String headword;
@override final  int? rank;
@override@JsonKey() final  String pos;
@override@JsonKey() final  String phonetic;
@override@JsonKey() final  String translation;
 final  List<WordTag> _tags;
@override@JsonKey() List<WordTag> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of WordBrief
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordBriefCopyWith<_WordBrief> get copyWith => __$WordBriefCopyWithImpl<_WordBrief>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordBriefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordBrief&&(identical(other.id, id) || other.id == id)&&(identical(other.headword, headword) || other.headword == headword)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.pos, pos) || other.pos == pos)&&(identical(other.phonetic, phonetic) || other.phonetic == phonetic)&&(identical(other.translation, translation) || other.translation == translation)&&const DeepCollectionEquality().equals(other.tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,headword,rank,pos,phonetic,translation,const DeepCollectionEquality().hash(_tags));
}

@override
String toString() {
    return 'WordBrief(id: $id, headword: $headword, rank: $rank, pos: $pos, phonetic: $phonetic, translation: $translation, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$WordBriefCopyWith<$Res> implements $WordBriefCopyWith<$Res> {
  factory _$WordBriefCopyWith(_WordBrief value, $Res Function(_WordBrief) _then) = __$WordBriefCopyWithImpl;
@override @useResult
$Res call({
 int id, String headword, int? rank, String pos, String phonetic, String translation, List<WordTag> tags
});




}
/// @nodoc
class __$WordBriefCopyWithImpl<$Res>
    implements _$WordBriefCopyWith<$Res> {
  __$WordBriefCopyWithImpl(this._self, this._then);

  final _WordBrief _self;
  final $Res Function(_WordBrief) _then;

/// Create a copy of WordBrief
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? headword = null,Object? rank = freezed,Object? pos = null,Object? phonetic = null,Object? translation = null,Object? tags = null,}) {
  return _then(_WordBrief(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,headword: null == headword ? _self.headword : headword // ignore: cast_nullable_to_non_nullable
as String,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,pos: null == pos ? _self.pos : pos // ignore: cast_nullable_to_non_nullable
as String,phonetic: null == phonetic ? _self.phonetic : phonetic // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<WordTag>,
  ));
}


}


/// @nodoc
mixin _$Card {

 int get id; int get deckId; int? get wordId; String get front; String get back; double get stability; double get difficulty; int get state; int get reps; int get lapses; int get learningSteps; int get interval; String get due; String? get lastReview; String get createdAt; WordBrief? get word;
/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardCopyWith<Card> get copyWith => _$CardCopyWithImpl<Card>(this as Card, _$identity);

  /// Serializes this Card to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Card;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Card&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.deckId, _this.deckId) || other.deckId == _this.deckId)&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId)&&(identical(other.front, _this.front) || other.front == _this.front)&&(identical(other.back, _this.back) || other.back == _this.back)&&(identical(other.stability, _this.stability) || other.stability == _this.stability)&&(identical(other.difficulty, _this.difficulty) || other.difficulty == _this.difficulty)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.reps, _this.reps) || other.reps == _this.reps)&&(identical(other.lapses, _this.lapses) || other.lapses == _this.lapses)&&(identical(other.learningSteps, _this.learningSteps) || other.learningSteps == _this.learningSteps)&&(identical(other.interval, _this.interval) || other.interval == _this.interval)&&(identical(other.due, _this.due) || other.due == _this.due)&&(identical(other.lastReview, _this.lastReview) || other.lastReview == _this.lastReview)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.word, _this.word) || other.word == _this.word));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Card;
  return Object.hash(runtimeType,_this.id,_this.deckId,_this.wordId,_this.front,_this.back,_this.stability,_this.difficulty,_this.state,_this.reps,_this.lapses,_this.learningSteps,_this.interval,_this.due,_this.lastReview,_this.createdAt,_this.word);
}

@override
String toString() {
  final _this = this as Card;
  return 'Card(id: ${_this.id}, deckId: ${_this.deckId}, wordId: ${_this.wordId}, front: ${_this.front}, back: ${_this.back}, stability: ${_this.stability}, difficulty: ${_this.difficulty}, state: ${_this.state}, reps: ${_this.reps}, lapses: ${_this.lapses}, learningSteps: ${_this.learningSteps}, interval: ${_this.interval}, due: ${_this.due}, lastReview: ${_this.lastReview}, createdAt: ${_this.createdAt}, word: ${_this.word})';
}


}

/// @nodoc
abstract mixin class $CardCopyWith<$Res>  {
  factory $CardCopyWith(Card value, $Res Function(Card) _then) = _$CardCopyWithImpl;
@useResult
$Res call({
 int id, int deckId, int? wordId, String front, String back, double stability, double difficulty, int state, int reps, int lapses, int learningSteps, int interval, String due, String? lastReview, String createdAt, WordBrief? word
});


$WordBriefCopyWith<$Res>? get word;

}
/// @nodoc
class _$CardCopyWithImpl<$Res>
    implements $CardCopyWith<$Res> {
  _$CardCopyWithImpl(this._self, this._then);

  final Card _self;
  final $Res Function(Card) _then;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deckId = null,Object? wordId = freezed,Object? front = null,Object? back = null,Object? stability = null,Object? difficulty = null,Object? state = null,Object? reps = null,Object? lapses = null,Object? learningSteps = null,Object? interval = null,Object? due = null,Object? lastReview = freezed,Object? createdAt = null,Object? word = freezed,}) {
  return _then(Card(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as int,wordId: freezed == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as int?,front: null == front ? _self.front : front // ignore: cast_nullable_to_non_nullable
as String,back: null == back ? _self.back : back // ignore: cast_nullable_to_non_nullable
as String,stability: null == stability ? _self.stability : stability // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as double,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,learningSteps: null == learningSteps ? _self.learningSteps : learningSteps // ignore: cast_nullable_to_non_nullable
as int,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,due: null == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as String,lastReview: freezed == lastReview ? _self.lastReview : lastReview // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,word: freezed == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as WordBrief?,
  ));
}
/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordBriefCopyWith<$Res>? get word {
    if (_self.word == null) {
    return null;
  }

  return $WordBriefCopyWith<$Res>(_self.word!, (value) {
    return _then(_self.copyWith(word: value));
  });
}
}


/// Adds pattern-matching-related methods to [Card].
extension CardPatterns on Card {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Card value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Card() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Card value)  $default,){
final _that = this;
switch (_that) {
case _Card():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Card value)?  $default,){
final _that = this;
switch (_that) {
case _Card() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int deckId,  int? wordId,  String front,  String back,  double stability,  double difficulty,  int state,  int reps,  int lapses,  int learningSteps,  int interval,  String due,  String? lastReview,  String createdAt,  WordBrief? word)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Card() when $default != null:
return $default(_that.id,_that.deckId,_that.wordId,_that.front,_that.back,_that.stability,_that.difficulty,_that.state,_that.reps,_that.lapses,_that.learningSteps,_that.interval,_that.due,_that.lastReview,_that.createdAt,_that.word);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int deckId,  int? wordId,  String front,  String back,  double stability,  double difficulty,  int state,  int reps,  int lapses,  int learningSteps,  int interval,  String due,  String? lastReview,  String createdAt,  WordBrief? word)  $default,) {final _that = this;
switch (_that) {
case _Card():
return $default(_that.id,_that.deckId,_that.wordId,_that.front,_that.back,_that.stability,_that.difficulty,_that.state,_that.reps,_that.lapses,_that.learningSteps,_that.interval,_that.due,_that.lastReview,_that.createdAt,_that.word);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int deckId,  int? wordId,  String front,  String back,  double stability,  double difficulty,  int state,  int reps,  int lapses,  int learningSteps,  int interval,  String due,  String? lastReview,  String createdAt,  WordBrief? word)?  $default,) {final _that = this;
switch (_that) {
case _Card() when $default != null:
return $default(_that.id,_that.deckId,_that.wordId,_that.front,_that.back,_that.stability,_that.difficulty,_that.state,_that.reps,_that.lapses,_that.learningSteps,_that.interval,_that.due,_that.lastReview,_that.createdAt,_that.word);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Card implements Card {
  const _Card({this.id = 0, this.deckId = 0, this.wordId, this.front = '', this.back = '', this.stability = 0, this.difficulty = 0, this.state = 0, this.reps = 0, this.lapses = 0, this.learningSteps = 0, this.interval = 0, this.due = '', this.lastReview, this.createdAt = '', this.word});
  factory _Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  int deckId;
@override final  int? wordId;
@override@JsonKey() final  String front;
@override@JsonKey() final  String back;
@override@JsonKey() final  double stability;
@override@JsonKey() final  double difficulty;
@override@JsonKey() final  int state;
@override@JsonKey() final  int reps;
@override@JsonKey() final  int lapses;
@override@JsonKey() final  int learningSteps;
@override@JsonKey() final  int interval;
@override@JsonKey() final  String due;
@override final  String? lastReview;
@override@JsonKey() final  String createdAt;
@override final  WordBrief? word;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardCopyWith<_Card> get copyWith => __$CardCopyWithImpl<_Card>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Card&&(identical(other.id, id) || other.id == id)&&(identical(other.deckId, deckId) || other.deckId == deckId)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.front, front) || other.front == front)&&(identical(other.back, back) || other.back == back)&&(identical(other.stability, stability) || other.stability == stability)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.state, state) || other.state == state)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.lapses, lapses) || other.lapses == lapses)&&(identical(other.learningSteps, learningSteps) || other.learningSteps == learningSteps)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.due, due) || other.due == due)&&(identical(other.lastReview, lastReview) || other.lastReview == lastReview)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.word, word) || other.word == word));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,deckId,wordId,front,back,stability,difficulty,state,reps,lapses,learningSteps,interval,due,lastReview,createdAt,word);
}

@override
String toString() {
    return 'Card(id: $id, deckId: $deckId, wordId: $wordId, front: $front, back: $back, stability: $stability, difficulty: $difficulty, state: $state, reps: $reps, lapses: $lapses, learningSteps: $learningSteps, interval: $interval, due: $due, lastReview: $lastReview, createdAt: $createdAt, word: $word)';
}


}

/// @nodoc
abstract mixin class _$CardCopyWith<$Res> implements $CardCopyWith<$Res> {
  factory _$CardCopyWith(_Card value, $Res Function(_Card) _then) = __$CardCopyWithImpl;
@override @useResult
$Res call({
 int id, int deckId, int? wordId, String front, String back, double stability, double difficulty, int state, int reps, int lapses, int learningSteps, int interval, String due, String? lastReview, String createdAt, WordBrief? word
});


@override $WordBriefCopyWith<$Res>? get word;

}
/// @nodoc
class __$CardCopyWithImpl<$Res>
    implements _$CardCopyWith<$Res> {
  __$CardCopyWithImpl(this._self, this._then);

  final _Card _self;
  final $Res Function(_Card) _then;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deckId = null,Object? wordId = freezed,Object? front = null,Object? back = null,Object? stability = null,Object? difficulty = null,Object? state = null,Object? reps = null,Object? lapses = null,Object? learningSteps = null,Object? interval = null,Object? due = null,Object? lastReview = freezed,Object? createdAt = null,Object? word = freezed,}) {
  return _then(_Card(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as int,wordId: freezed == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as int?,front: null == front ? _self.front : front // ignore: cast_nullable_to_non_nullable
as String,back: null == back ? _self.back : back // ignore: cast_nullable_to_non_nullable
as String,stability: null == stability ? _self.stability : stability // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as double,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,learningSteps: null == learningSteps ? _self.learningSteps : learningSteps // ignore: cast_nullable_to_non_nullable
as int,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,due: null == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as String,lastReview: freezed == lastReview ? _self.lastReview : lastReview // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,word: freezed == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as WordBrief?,
  ));
}

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordBriefCopyWith<$Res>? get word {
    if (_self.word == null) {
    return null;
  }

  return $WordBriefCopyWith<$Res>(_self.word!, (value) {
    return _then(_self.copyWith(word: value));
  });
}
}

// dart format on
