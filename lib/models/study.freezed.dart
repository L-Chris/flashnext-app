// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeckSettings {

 int get deckId; int get newPerDay; int get reviewPerDay; String get timezone; int get rolloverHour; int get version; bool get audioAutoplay; bool get showNewCardAnswerImmediately;@JsonKey(includeIfNull: true) int? get autoRevealAnswerSeconds;
/// Create a copy of DeckSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeckSettingsCopyWith<DeckSettings> get copyWith => _$DeckSettingsCopyWithImpl<DeckSettings>(this as DeckSettings, _$identity);

  /// Serializes this DeckSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeckSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeckSettings&&(identical(other.deckId, _this.deckId) || other.deckId == _this.deckId)&&(identical(other.newPerDay, _this.newPerDay) || other.newPerDay == _this.newPerDay)&&(identical(other.reviewPerDay, _this.reviewPerDay) || other.reviewPerDay == _this.reviewPerDay)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.rolloverHour, _this.rolloverHour) || other.rolloverHour == _this.rolloverHour)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.audioAutoplay, _this.audioAutoplay) || other.audioAutoplay == _this.audioAutoplay)&&(identical(other.showNewCardAnswerImmediately, _this.showNewCardAnswerImmediately) || other.showNewCardAnswerImmediately == _this.showNewCardAnswerImmediately)&&(identical(other.autoRevealAnswerSeconds, _this.autoRevealAnswerSeconds) || other.autoRevealAnswerSeconds == _this.autoRevealAnswerSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeckSettings;
  return Object.hash(runtimeType,_this.deckId,_this.newPerDay,_this.reviewPerDay,_this.timezone,_this.rolloverHour,_this.version,_this.audioAutoplay,_this.showNewCardAnswerImmediately,_this.autoRevealAnswerSeconds);
}

@override
String toString() {
  final _this = this as DeckSettings;
  return 'DeckSettings(deckId: ${_this.deckId}, newPerDay: ${_this.newPerDay}, reviewPerDay: ${_this.reviewPerDay}, timezone: ${_this.timezone}, rolloverHour: ${_this.rolloverHour}, version: ${_this.version}, audioAutoplay: ${_this.audioAutoplay}, showNewCardAnswerImmediately: ${_this.showNewCardAnswerImmediately}, autoRevealAnswerSeconds: ${_this.autoRevealAnswerSeconds})';
}


}

/// @nodoc
abstract mixin class $DeckSettingsCopyWith<$Res>  {
  factory $DeckSettingsCopyWith(DeckSettings value, $Res Function(DeckSettings) _then) = _$DeckSettingsCopyWithImpl;
@useResult
$Res call({
 int deckId, int newPerDay, int reviewPerDay, String timezone, int rolloverHour, int version, bool audioAutoplay, bool showNewCardAnswerImmediately,@JsonKey(includeIfNull: true) int? autoRevealAnswerSeconds
});




}
/// @nodoc
class _$DeckSettingsCopyWithImpl<$Res>
    implements $DeckSettingsCopyWith<$Res> {
  _$DeckSettingsCopyWithImpl(this._self, this._then);

  final DeckSettings _self;
  final $Res Function(DeckSettings) _then;

/// Create a copy of DeckSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deckId = null,Object? newPerDay = null,Object? reviewPerDay = null,Object? timezone = null,Object? rolloverHour = null,Object? version = null,Object? audioAutoplay = null,Object? showNewCardAnswerImmediately = null,Object? autoRevealAnswerSeconds = freezed,}) {
  return _then(DeckSettings(
deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as int,newPerDay: null == newPerDay ? _self.newPerDay : newPerDay // ignore: cast_nullable_to_non_nullable
as int,reviewPerDay: null == reviewPerDay ? _self.reviewPerDay : reviewPerDay // ignore: cast_nullable_to_non_nullable
as int,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,rolloverHour: null == rolloverHour ? _self.rolloverHour : rolloverHour // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,audioAutoplay: null == audioAutoplay ? _self.audioAutoplay : audioAutoplay // ignore: cast_nullable_to_non_nullable
as bool,showNewCardAnswerImmediately: null == showNewCardAnswerImmediately ? _self.showNewCardAnswerImmediately : showNewCardAnswerImmediately // ignore: cast_nullable_to_non_nullable
as bool,autoRevealAnswerSeconds: freezed == autoRevealAnswerSeconds ? _self.autoRevealAnswerSeconds : autoRevealAnswerSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeckSettings].
extension DeckSettingsPatterns on DeckSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeckSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeckSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeckSettings value)  $default,){
final _that = this;
switch (_that) {
case _DeckSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeckSettings value)?  $default,){
final _that = this;
switch (_that) {
case _DeckSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int deckId,  int newPerDay,  int reviewPerDay,  String timezone,  int rolloverHour,  int version,  bool audioAutoplay,  bool showNewCardAnswerImmediately, @JsonKey(includeIfNull: true)  int? autoRevealAnswerSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeckSettings() when $default != null:
return $default(_that.deckId,_that.newPerDay,_that.reviewPerDay,_that.timezone,_that.rolloverHour,_that.version,_that.audioAutoplay,_that.showNewCardAnswerImmediately,_that.autoRevealAnswerSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int deckId,  int newPerDay,  int reviewPerDay,  String timezone,  int rolloverHour,  int version,  bool audioAutoplay,  bool showNewCardAnswerImmediately, @JsonKey(includeIfNull: true)  int? autoRevealAnswerSeconds)  $default,) {final _that = this;
switch (_that) {
case _DeckSettings():
return $default(_that.deckId,_that.newPerDay,_that.reviewPerDay,_that.timezone,_that.rolloverHour,_that.version,_that.audioAutoplay,_that.showNewCardAnswerImmediately,_that.autoRevealAnswerSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int deckId,  int newPerDay,  int reviewPerDay,  String timezone,  int rolloverHour,  int version,  bool audioAutoplay,  bool showNewCardAnswerImmediately, @JsonKey(includeIfNull: true)  int? autoRevealAnswerSeconds)?  $default,) {final _that = this;
switch (_that) {
case _DeckSettings() when $default != null:
return $default(_that.deckId,_that.newPerDay,_that.reviewPerDay,_that.timezone,_that.rolloverHour,_that.version,_that.audioAutoplay,_that.showNewCardAnswerImmediately,_that.autoRevealAnswerSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeckSettings extends DeckSettings {
  const _DeckSettings({required this.deckId, this.newPerDay = 20, this.reviewPerDay = 500, this.timezone = 'Asia/Shanghai', this.rolloverHour = 4, this.version = 0, this.audioAutoplay = false, this.showNewCardAnswerImmediately = false, @JsonKey(includeIfNull: true) this.autoRevealAnswerSeconds}): super._();
  factory _DeckSettings.fromJson(Map<String, dynamic> json) => _$DeckSettingsFromJson(json);

@override final  int deckId;
@override@JsonKey() final  int newPerDay;
@override@JsonKey() final  int reviewPerDay;
@override@JsonKey() final  String timezone;
@override@JsonKey() final  int rolloverHour;
@override@JsonKey() final  int version;
@override@JsonKey() final  bool audioAutoplay;
@override@JsonKey() final  bool showNewCardAnswerImmediately;
@override@JsonKey(includeIfNull: true) final  int? autoRevealAnswerSeconds;

/// Create a copy of DeckSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeckSettingsCopyWith<_DeckSettings> get copyWith => __$DeckSettingsCopyWithImpl<_DeckSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeckSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeckSettings&&(identical(other.deckId, deckId) || other.deckId == deckId)&&(identical(other.newPerDay, newPerDay) || other.newPerDay == newPerDay)&&(identical(other.reviewPerDay, reviewPerDay) || other.reviewPerDay == reviewPerDay)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.rolloverHour, rolloverHour) || other.rolloverHour == rolloverHour)&&(identical(other.version, version) || other.version == version)&&(identical(other.audioAutoplay, audioAutoplay) || other.audioAutoplay == audioAutoplay)&&(identical(other.showNewCardAnswerImmediately, showNewCardAnswerImmediately) || other.showNewCardAnswerImmediately == showNewCardAnswerImmediately)&&(identical(other.autoRevealAnswerSeconds, autoRevealAnswerSeconds) || other.autoRevealAnswerSeconds == autoRevealAnswerSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,deckId,newPerDay,reviewPerDay,timezone,rolloverHour,version,audioAutoplay,showNewCardAnswerImmediately,autoRevealAnswerSeconds);
}

@override
String toString() {
    return 'DeckSettings(deckId: $deckId, newPerDay: $newPerDay, reviewPerDay: $reviewPerDay, timezone: $timezone, rolloverHour: $rolloverHour, version: $version, audioAutoplay: $audioAutoplay, showNewCardAnswerImmediately: $showNewCardAnswerImmediately, autoRevealAnswerSeconds: $autoRevealAnswerSeconds)';
}


}

/// @nodoc
abstract mixin class _$DeckSettingsCopyWith<$Res> implements $DeckSettingsCopyWith<$Res> {
  factory _$DeckSettingsCopyWith(_DeckSettings value, $Res Function(_DeckSettings) _then) = __$DeckSettingsCopyWithImpl;
@override @useResult
$Res call({
 int deckId, int newPerDay, int reviewPerDay, String timezone, int rolloverHour, int version, bool audioAutoplay, bool showNewCardAnswerImmediately,@JsonKey(includeIfNull: true) int? autoRevealAnswerSeconds
});




}
/// @nodoc
class __$DeckSettingsCopyWithImpl<$Res>
    implements _$DeckSettingsCopyWith<$Res> {
  __$DeckSettingsCopyWithImpl(this._self, this._then);

  final _DeckSettings _self;
  final $Res Function(_DeckSettings) _then;

/// Create a copy of DeckSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deckId = null,Object? newPerDay = null,Object? reviewPerDay = null,Object? timezone = null,Object? rolloverHour = null,Object? version = null,Object? audioAutoplay = null,Object? showNewCardAnswerImmediately = null,Object? autoRevealAnswerSeconds = freezed,}) {
  return _then(_DeckSettings(
deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as int,newPerDay: null == newPerDay ? _self.newPerDay : newPerDay // ignore: cast_nullable_to_non_nullable
as int,reviewPerDay: null == reviewPerDay ? _self.reviewPerDay : reviewPerDay // ignore: cast_nullable_to_non_nullable
as int,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,rolloverHour: null == rolloverHour ? _self.rolloverHour : rolloverHour // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,audioAutoplay: null == audioAutoplay ? _self.audioAutoplay : audioAutoplay // ignore: cast_nullable_to_non_nullable
as bool,showNewCardAnswerImmediately: null == showNewCardAnswerImmediately ? _self.showNewCardAnswerImmediately : showNewCardAnswerImmediately // ignore: cast_nullable_to_non_nullable
as bool,autoRevealAnswerSeconds: freezed == autoRevealAnswerSeconds ? _self.autoRevealAnswerSeconds : autoRevealAnswerSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ReviewOptions {

 bool get audioAutoplay; bool get showNewCardAnswerImmediately; int? get autoRevealAnswerSeconds; int get settingsVersion;
/// Create a copy of ReviewOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewOptionsCopyWith<ReviewOptions> get copyWith => _$ReviewOptionsCopyWithImpl<ReviewOptions>(this as ReviewOptions, _$identity);

  /// Serializes this ReviewOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReviewOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewOptions&&(identical(other.audioAutoplay, _this.audioAutoplay) || other.audioAutoplay == _this.audioAutoplay)&&(identical(other.showNewCardAnswerImmediately, _this.showNewCardAnswerImmediately) || other.showNewCardAnswerImmediately == _this.showNewCardAnswerImmediately)&&(identical(other.autoRevealAnswerSeconds, _this.autoRevealAnswerSeconds) || other.autoRevealAnswerSeconds == _this.autoRevealAnswerSeconds)&&(identical(other.settingsVersion, _this.settingsVersion) || other.settingsVersion == _this.settingsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReviewOptions;
  return Object.hash(runtimeType,_this.audioAutoplay,_this.showNewCardAnswerImmediately,_this.autoRevealAnswerSeconds,_this.settingsVersion);
}

@override
String toString() {
  final _this = this as ReviewOptions;
  return 'ReviewOptions(audioAutoplay: ${_this.audioAutoplay}, showNewCardAnswerImmediately: ${_this.showNewCardAnswerImmediately}, autoRevealAnswerSeconds: ${_this.autoRevealAnswerSeconds}, settingsVersion: ${_this.settingsVersion})';
}


}

/// @nodoc
abstract mixin class $ReviewOptionsCopyWith<$Res>  {
  factory $ReviewOptionsCopyWith(ReviewOptions value, $Res Function(ReviewOptions) _then) = _$ReviewOptionsCopyWithImpl;
@useResult
$Res call({
 bool audioAutoplay, bool showNewCardAnswerImmediately, int? autoRevealAnswerSeconds, int settingsVersion
});




}
/// @nodoc
class _$ReviewOptionsCopyWithImpl<$Res>
    implements $ReviewOptionsCopyWith<$Res> {
  _$ReviewOptionsCopyWithImpl(this._self, this._then);

  final ReviewOptions _self;
  final $Res Function(ReviewOptions) _then;

/// Create a copy of ReviewOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? audioAutoplay = null,Object? showNewCardAnswerImmediately = null,Object? autoRevealAnswerSeconds = freezed,Object? settingsVersion = null,}) {
  return _then(ReviewOptions(
audioAutoplay: null == audioAutoplay ? _self.audioAutoplay : audioAutoplay // ignore: cast_nullable_to_non_nullable
as bool,showNewCardAnswerImmediately: null == showNewCardAnswerImmediately ? _self.showNewCardAnswerImmediately : showNewCardAnswerImmediately // ignore: cast_nullable_to_non_nullable
as bool,autoRevealAnswerSeconds: freezed == autoRevealAnswerSeconds ? _self.autoRevealAnswerSeconds : autoRevealAnswerSeconds // ignore: cast_nullable_to_non_nullable
as int?,settingsVersion: null == settingsVersion ? _self.settingsVersion : settingsVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewOptions].
extension ReviewOptionsPatterns on ReviewOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewOptions value)  $default,){
final _that = this;
switch (_that) {
case _ReviewOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewOptions value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool audioAutoplay,  bool showNewCardAnswerImmediately,  int? autoRevealAnswerSeconds,  int settingsVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewOptions() when $default != null:
return $default(_that.audioAutoplay,_that.showNewCardAnswerImmediately,_that.autoRevealAnswerSeconds,_that.settingsVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool audioAutoplay,  bool showNewCardAnswerImmediately,  int? autoRevealAnswerSeconds,  int settingsVersion)  $default,) {final _that = this;
switch (_that) {
case _ReviewOptions():
return $default(_that.audioAutoplay,_that.showNewCardAnswerImmediately,_that.autoRevealAnswerSeconds,_that.settingsVersion);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool audioAutoplay,  bool showNewCardAnswerImmediately,  int? autoRevealAnswerSeconds,  int settingsVersion)?  $default,) {final _that = this;
switch (_that) {
case _ReviewOptions() when $default != null:
return $default(_that.audioAutoplay,_that.showNewCardAnswerImmediately,_that.autoRevealAnswerSeconds,_that.settingsVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewOptions implements ReviewOptions {
  const _ReviewOptions({this.audioAutoplay = false, this.showNewCardAnswerImmediately = false, this.autoRevealAnswerSeconds, this.settingsVersion = 0});
  factory _ReviewOptions.fromJson(Map<String, dynamic> json) => _$ReviewOptionsFromJson(json);

@override@JsonKey() final  bool audioAutoplay;
@override@JsonKey() final  bool showNewCardAnswerImmediately;
@override final  int? autoRevealAnswerSeconds;
@override@JsonKey() final  int settingsVersion;

/// Create a copy of ReviewOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewOptionsCopyWith<_ReviewOptions> get copyWith => __$ReviewOptionsCopyWithImpl<_ReviewOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewOptions&&(identical(other.audioAutoplay, audioAutoplay) || other.audioAutoplay == audioAutoplay)&&(identical(other.showNewCardAnswerImmediately, showNewCardAnswerImmediately) || other.showNewCardAnswerImmediately == showNewCardAnswerImmediately)&&(identical(other.autoRevealAnswerSeconds, autoRevealAnswerSeconds) || other.autoRevealAnswerSeconds == autoRevealAnswerSeconds)&&(identical(other.settingsVersion, settingsVersion) || other.settingsVersion == settingsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,audioAutoplay,showNewCardAnswerImmediately,autoRevealAnswerSeconds,settingsVersion);
}

@override
String toString() {
    return 'ReviewOptions(audioAutoplay: $audioAutoplay, showNewCardAnswerImmediately: $showNewCardAnswerImmediately, autoRevealAnswerSeconds: $autoRevealAnswerSeconds, settingsVersion: $settingsVersion)';
}


}

/// @nodoc
abstract mixin class _$ReviewOptionsCopyWith<$Res> implements $ReviewOptionsCopyWith<$Res> {
  factory _$ReviewOptionsCopyWith(_ReviewOptions value, $Res Function(_ReviewOptions) _then) = __$ReviewOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool audioAutoplay, bool showNewCardAnswerImmediately, int? autoRevealAnswerSeconds, int settingsVersion
});




}
/// @nodoc
class __$ReviewOptionsCopyWithImpl<$Res>
    implements _$ReviewOptionsCopyWith<$Res> {
  __$ReviewOptionsCopyWithImpl(this._self, this._then);

  final _ReviewOptions _self;
  final $Res Function(_ReviewOptions) _then;

/// Create a copy of ReviewOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? audioAutoplay = null,Object? showNewCardAnswerImmediately = null,Object? autoRevealAnswerSeconds = freezed,Object? settingsVersion = null,}) {
  return _then(_ReviewOptions(
audioAutoplay: null == audioAutoplay ? _self.audioAutoplay : audioAutoplay // ignore: cast_nullable_to_non_nullable
as bool,showNewCardAnswerImmediately: null == showNewCardAnswerImmediately ? _self.showNewCardAnswerImmediately : showNewCardAnswerImmediately // ignore: cast_nullable_to_non_nullable
as bool,autoRevealAnswerSeconds: freezed == autoRevealAnswerSeconds ? _self.autoRevealAnswerSeconds : autoRevealAnswerSeconds // ignore: cast_nullable_to_non_nullable
as int?,settingsVersion: null == settingsVersion ? _self.settingsVersion : settingsVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CardPresentation {

 bool get audioAutoplay; int? get answerRevealAfterMs; int get settingsVersion;
/// Create a copy of CardPresentation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardPresentationCopyWith<CardPresentation> get copyWith => _$CardPresentationCopyWithImpl<CardPresentation>(this as CardPresentation, _$identity);

  /// Serializes this CardPresentation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CardPresentation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardPresentation&&(identical(other.audioAutoplay, _this.audioAutoplay) || other.audioAutoplay == _this.audioAutoplay)&&(identical(other.answerRevealAfterMs, _this.answerRevealAfterMs) || other.answerRevealAfterMs == _this.answerRevealAfterMs)&&(identical(other.settingsVersion, _this.settingsVersion) || other.settingsVersion == _this.settingsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CardPresentation;
  return Object.hash(runtimeType,_this.audioAutoplay,_this.answerRevealAfterMs,_this.settingsVersion);
}

@override
String toString() {
  final _this = this as CardPresentation;
  return 'CardPresentation(audioAutoplay: ${_this.audioAutoplay}, answerRevealAfterMs: ${_this.answerRevealAfterMs}, settingsVersion: ${_this.settingsVersion})';
}


}

/// @nodoc
abstract mixin class $CardPresentationCopyWith<$Res>  {
  factory $CardPresentationCopyWith(CardPresentation value, $Res Function(CardPresentation) _then) = _$CardPresentationCopyWithImpl;
@useResult
$Res call({
 bool audioAutoplay, int? answerRevealAfterMs, int settingsVersion
});




}
/// @nodoc
class _$CardPresentationCopyWithImpl<$Res>
    implements $CardPresentationCopyWith<$Res> {
  _$CardPresentationCopyWithImpl(this._self, this._then);

  final CardPresentation _self;
  final $Res Function(CardPresentation) _then;

/// Create a copy of CardPresentation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? audioAutoplay = null,Object? answerRevealAfterMs = freezed,Object? settingsVersion = null,}) {
  return _then(CardPresentation(
audioAutoplay: null == audioAutoplay ? _self.audioAutoplay : audioAutoplay // ignore: cast_nullable_to_non_nullable
as bool,answerRevealAfterMs: freezed == answerRevealAfterMs ? _self.answerRevealAfterMs : answerRevealAfterMs // ignore: cast_nullable_to_non_nullable
as int?,settingsVersion: null == settingsVersion ? _self.settingsVersion : settingsVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CardPresentation].
extension CardPresentationPatterns on CardPresentation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardPresentation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardPresentation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardPresentation value)  $default,){
final _that = this;
switch (_that) {
case _CardPresentation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardPresentation value)?  $default,){
final _that = this;
switch (_that) {
case _CardPresentation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool audioAutoplay,  int? answerRevealAfterMs,  int settingsVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardPresentation() when $default != null:
return $default(_that.audioAutoplay,_that.answerRevealAfterMs,_that.settingsVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool audioAutoplay,  int? answerRevealAfterMs,  int settingsVersion)  $default,) {final _that = this;
switch (_that) {
case _CardPresentation():
return $default(_that.audioAutoplay,_that.answerRevealAfterMs,_that.settingsVersion);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool audioAutoplay,  int? answerRevealAfterMs,  int settingsVersion)?  $default,) {final _that = this;
switch (_that) {
case _CardPresentation() when $default != null:
return $default(_that.audioAutoplay,_that.answerRevealAfterMs,_that.settingsVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardPresentation implements CardPresentation {
  const _CardPresentation({this.audioAutoplay = false, this.answerRevealAfterMs, this.settingsVersion = 0});
  factory _CardPresentation.fromJson(Map<String, dynamic> json) => _$CardPresentationFromJson(json);

@override@JsonKey() final  bool audioAutoplay;
@override final  int? answerRevealAfterMs;
@override@JsonKey() final  int settingsVersion;

/// Create a copy of CardPresentation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardPresentationCopyWith<_CardPresentation> get copyWith => __$CardPresentationCopyWithImpl<_CardPresentation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardPresentationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardPresentation&&(identical(other.audioAutoplay, audioAutoplay) || other.audioAutoplay == audioAutoplay)&&(identical(other.answerRevealAfterMs, answerRevealAfterMs) || other.answerRevealAfterMs == answerRevealAfterMs)&&(identical(other.settingsVersion, settingsVersion) || other.settingsVersion == settingsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,audioAutoplay,answerRevealAfterMs,settingsVersion);
}

@override
String toString() {
    return 'CardPresentation(audioAutoplay: $audioAutoplay, answerRevealAfterMs: $answerRevealAfterMs, settingsVersion: $settingsVersion)';
}


}

/// @nodoc
abstract mixin class _$CardPresentationCopyWith<$Res> implements $CardPresentationCopyWith<$Res> {
  factory _$CardPresentationCopyWith(_CardPresentation value, $Res Function(_CardPresentation) _then) = __$CardPresentationCopyWithImpl;
@override @useResult
$Res call({
 bool audioAutoplay, int? answerRevealAfterMs, int settingsVersion
});




}
/// @nodoc
class __$CardPresentationCopyWithImpl<$Res>
    implements _$CardPresentationCopyWith<$Res> {
  __$CardPresentationCopyWithImpl(this._self, this._then);

  final _CardPresentation _self;
  final $Res Function(_CardPresentation) _then;

/// Create a copy of CardPresentation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? audioAutoplay = null,Object? answerRevealAfterMs = freezed,Object? settingsVersion = null,}) {
  return _then(_CardPresentation(
audioAutoplay: null == audioAutoplay ? _self.audioAutoplay : audioAutoplay // ignore: cast_nullable_to_non_nullable
as bool,answerRevealAfterMs: freezed == answerRevealAfterMs ? _self.answerRevealAfterMs : answerRevealAfterMs // ignore: cast_nullable_to_non_nullable
as int?,settingsVersion: null == settingsVersion ? _self.settingsVersion : settingsVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CardMedia {

 String get mediaId; String get id; String get side; int get position; String get mimeType; int get bytes; String get originalName; String get createdAt; String get url;
/// Create a copy of CardMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardMediaCopyWith<CardMedia> get copyWith => _$CardMediaCopyWithImpl<CardMedia>(this as CardMedia, _$identity);

  /// Serializes this CardMedia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CardMedia;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardMedia&&(identical(other.mediaId, _this.mediaId) || other.mediaId == _this.mediaId)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.side, _this.side) || other.side == _this.side)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.mimeType, _this.mimeType) || other.mimeType == _this.mimeType)&&(identical(other.bytes, _this.bytes) || other.bytes == _this.bytes)&&(identical(other.originalName, _this.originalName) || other.originalName == _this.originalName)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CardMedia;
  return Object.hash(runtimeType,_this.mediaId,_this.id,_this.side,_this.position,_this.mimeType,_this.bytes,_this.originalName,_this.createdAt,_this.url);
}

@override
String toString() {
  final _this = this as CardMedia;
  return 'CardMedia(mediaId: ${_this.mediaId}, id: ${_this.id}, side: ${_this.side}, position: ${_this.position}, mimeType: ${_this.mimeType}, bytes: ${_this.bytes}, originalName: ${_this.originalName}, createdAt: ${_this.createdAt}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $CardMediaCopyWith<$Res>  {
  factory $CardMediaCopyWith(CardMedia value, $Res Function(CardMedia) _then) = _$CardMediaCopyWithImpl;
@useResult
$Res call({
 String mediaId, String id, String side, int position, String mimeType, int bytes, String originalName, String createdAt, String url
});




}
/// @nodoc
class _$CardMediaCopyWithImpl<$Res>
    implements $CardMediaCopyWith<$Res> {
  _$CardMediaCopyWithImpl(this._self, this._then);

  final CardMedia _self;
  final $Res Function(CardMedia) _then;

/// Create a copy of CardMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaId = null,Object? id = null,Object? side = null,Object? position = null,Object? mimeType = null,Object? bytes = null,Object? originalName = null,Object? createdAt = null,Object? url = null,}) {
  return _then(CardMedia(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CardMedia].
extension CardMediaPatterns on CardMedia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardMedia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardMedia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardMedia value)  $default,){
final _that = this;
switch (_that) {
case _CardMedia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardMedia value)?  $default,){
final _that = this;
switch (_that) {
case _CardMedia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mediaId,  String id,  String side,  int position,  String mimeType,  int bytes,  String originalName,  String createdAt,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardMedia() when $default != null:
return $default(_that.mediaId,_that.id,_that.side,_that.position,_that.mimeType,_that.bytes,_that.originalName,_that.createdAt,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mediaId,  String id,  String side,  int position,  String mimeType,  int bytes,  String originalName,  String createdAt,  String url)  $default,) {final _that = this;
switch (_that) {
case _CardMedia():
return $default(_that.mediaId,_that.id,_that.side,_that.position,_that.mimeType,_that.bytes,_that.originalName,_that.createdAt,_that.url);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mediaId,  String id,  String side,  int position,  String mimeType,  int bytes,  String originalName,  String createdAt,  String url)?  $default,) {final _that = this;
switch (_that) {
case _CardMedia() when $default != null:
return $default(_that.mediaId,_that.id,_that.side,_that.position,_that.mimeType,_that.bytes,_that.originalName,_that.createdAt,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardMedia implements CardMedia {
  const _CardMedia({required this.mediaId, this.id = '', this.side = 'front', this.position = 0, this.mimeType = '', this.bytes = 0, this.originalName = '', this.createdAt = '', required this.url});
  factory _CardMedia.fromJson(Map<String, dynamic> json) => _$CardMediaFromJson(json);

@override final  String mediaId;
@override@JsonKey() final  String id;
@override@JsonKey() final  String side;
@override@JsonKey() final  int position;
@override@JsonKey() final  String mimeType;
@override@JsonKey() final  int bytes;
@override@JsonKey() final  String originalName;
@override@JsonKey() final  String createdAt;
@override final  String url;

/// Create a copy of CardMedia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardMediaCopyWith<_CardMedia> get copyWith => __$CardMediaCopyWithImpl<_CardMedia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardMediaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardMedia&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.id, id) || other.id == id)&&(identical(other.side, side) || other.side == side)&&(identical(other.position, position) || other.position == position)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.bytes, bytes) || other.bytes == bytes)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mediaId,id,side,position,mimeType,bytes,originalName,createdAt,url);
}

@override
String toString() {
    return 'CardMedia(mediaId: $mediaId, id: $id, side: $side, position: $position, mimeType: $mimeType, bytes: $bytes, originalName: $originalName, createdAt: $createdAt, url: $url)';
}


}

/// @nodoc
abstract mixin class _$CardMediaCopyWith<$Res> implements $CardMediaCopyWith<$Res> {
  factory _$CardMediaCopyWith(_CardMedia value, $Res Function(_CardMedia) _then) = __$CardMediaCopyWithImpl;
@override @useResult
$Res call({
 String mediaId, String id, String side, int position, String mimeType, int bytes, String originalName, String createdAt, String url
});




}
/// @nodoc
class __$CardMediaCopyWithImpl<$Res>
    implements _$CardMediaCopyWith<$Res> {
  __$CardMediaCopyWithImpl(this._self, this._then);

  final _CardMedia _self;
  final $Res Function(_CardMedia) _then;

/// Create a copy of CardMedia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaId = null,Object? id = null,Object? side = null,Object? position = null,Object? mimeType = null,Object? bytes = null,Object? originalName = null,Object? createdAt = null,Object? url = null,}) {
  return _then(_CardMedia(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ContentDiagnostic {

 String get message; int get offset; int get line; int get column;
/// Create a copy of ContentDiagnostic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentDiagnosticCopyWith<ContentDiagnostic> get copyWith => _$ContentDiagnosticCopyWithImpl<ContentDiagnostic>(this as ContentDiagnostic, _$identity);

  /// Serializes this ContentDiagnostic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContentDiagnostic;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentDiagnostic&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.offset, _this.offset) || other.offset == _this.offset)&&(identical(other.line, _this.line) || other.line == _this.line)&&(identical(other.column, _this.column) || other.column == _this.column));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContentDiagnostic;
  return Object.hash(runtimeType,_this.message,_this.offset,_this.line,_this.column);
}

@override
String toString() {
  final _this = this as ContentDiagnostic;
  return 'ContentDiagnostic(message: ${_this.message}, offset: ${_this.offset}, line: ${_this.line}, column: ${_this.column})';
}


}

/// @nodoc
abstract mixin class $ContentDiagnosticCopyWith<$Res>  {
  factory $ContentDiagnosticCopyWith(ContentDiagnostic value, $Res Function(ContentDiagnostic) _then) = _$ContentDiagnosticCopyWithImpl;
@useResult
$Res call({
 String message, int offset, int line, int column
});




}
/// @nodoc
class _$ContentDiagnosticCopyWithImpl<$Res>
    implements $ContentDiagnosticCopyWith<$Res> {
  _$ContentDiagnosticCopyWithImpl(this._self, this._then);

  final ContentDiagnostic _self;
  final $Res Function(ContentDiagnostic) _then;

/// Create a copy of ContentDiagnostic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? offset = null,Object? line = null,Object? column = null,}) {
  return _then(ContentDiagnostic(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,column: null == column ? _self.column : column // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentDiagnostic].
extension ContentDiagnosticPatterns on ContentDiagnostic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentDiagnostic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentDiagnostic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentDiagnostic value)  $default,){
final _that = this;
switch (_that) {
case _ContentDiagnostic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentDiagnostic value)?  $default,){
final _that = this;
switch (_that) {
case _ContentDiagnostic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  int offset,  int line,  int column)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentDiagnostic() when $default != null:
return $default(_that.message,_that.offset,_that.line,_that.column);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  int offset,  int line,  int column)  $default,) {final _that = this;
switch (_that) {
case _ContentDiagnostic():
return $default(_that.message,_that.offset,_that.line,_that.column);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  int offset,  int line,  int column)?  $default,) {final _that = this;
switch (_that) {
case _ContentDiagnostic() when $default != null:
return $default(_that.message,_that.offset,_that.line,_that.column);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentDiagnostic implements ContentDiagnostic {
  const _ContentDiagnostic({this.message = '公式无法渲染', this.offset = 0, this.line = 1, this.column = 1});
  factory _ContentDiagnostic.fromJson(Map<String, dynamic> json) => _$ContentDiagnosticFromJson(json);

@override@JsonKey() final  String message;
@override@JsonKey() final  int offset;
@override@JsonKey() final  int line;
@override@JsonKey() final  int column;

/// Create a copy of ContentDiagnostic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentDiagnosticCopyWith<_ContentDiagnostic> get copyWith => __$ContentDiagnosticCopyWithImpl<_ContentDiagnostic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentDiagnosticToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentDiagnostic&&(identical(other.message, message) || other.message == message)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.line, line) || other.line == line)&&(identical(other.column, column) || other.column == column));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,message,offset,line,column);
}

@override
String toString() {
    return 'ContentDiagnostic(message: $message, offset: $offset, line: $line, column: $column)';
}


}

/// @nodoc
abstract mixin class _$ContentDiagnosticCopyWith<$Res> implements $ContentDiagnosticCopyWith<$Res> {
  factory _$ContentDiagnosticCopyWith(_ContentDiagnostic value, $Res Function(_ContentDiagnostic) _then) = __$ContentDiagnosticCopyWithImpl;
@override @useResult
$Res call({
 String message, int offset, int line, int column
});




}
/// @nodoc
class __$ContentDiagnosticCopyWithImpl<$Res>
    implements _$ContentDiagnosticCopyWith<$Res> {
  __$ContentDiagnosticCopyWithImpl(this._self, this._then);

  final _ContentDiagnostic _self;
  final $Res Function(_ContentDiagnostic) _then;

/// Create a copy of ContentDiagnostic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? offset = null,Object? line = null,Object? column = null,}) {
  return _then(_ContentDiagnostic(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,column: null == column ? _self.column : column // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RenderedSide {

 String get html; List<ContentDiagnostic> get errors;
/// Create a copy of RenderedSide
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RenderedSideCopyWith<RenderedSide> get copyWith => _$RenderedSideCopyWithImpl<RenderedSide>(this as RenderedSide, _$identity);

  /// Serializes this RenderedSide to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RenderedSide;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RenderedSide&&(identical(other.html, _this.html) || other.html == _this.html)&&const DeepCollectionEquality().equals(other.errors, _this.errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RenderedSide;
  return Object.hash(runtimeType,_this.html,const DeepCollectionEquality().hash(_this.errors));
}

@override
String toString() {
  final _this = this as RenderedSide;
  return 'RenderedSide(html: ${_this.html}, errors: ${_this.errors})';
}


}

/// @nodoc
abstract mixin class $RenderedSideCopyWith<$Res>  {
  factory $RenderedSideCopyWith(RenderedSide value, $Res Function(RenderedSide) _then) = _$RenderedSideCopyWithImpl;
@useResult
$Res call({
 String html, List<ContentDiagnostic> errors
});




}
/// @nodoc
class _$RenderedSideCopyWithImpl<$Res>
    implements $RenderedSideCopyWith<$Res> {
  _$RenderedSideCopyWithImpl(this._self, this._then);

  final RenderedSide _self;
  final $Res Function(RenderedSide) _then;

/// Create a copy of RenderedSide
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? html = null,Object? errors = null,}) {
  return _then(RenderedSide(
html: null == html ? _self.html : html // ignore: cast_nullable_to_non_nullable
as String,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<ContentDiagnostic>,
  ));
}

}


/// Adds pattern-matching-related methods to [RenderedSide].
extension RenderedSidePatterns on RenderedSide {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RenderedSide value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RenderedSide() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RenderedSide value)  $default,){
final _that = this;
switch (_that) {
case _RenderedSide():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RenderedSide value)?  $default,){
final _that = this;
switch (_that) {
case _RenderedSide() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String html,  List<ContentDiagnostic> errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RenderedSide() when $default != null:
return $default(_that.html,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String html,  List<ContentDiagnostic> errors)  $default,) {final _that = this;
switch (_that) {
case _RenderedSide():
return $default(_that.html,_that.errors);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String html,  List<ContentDiagnostic> errors)?  $default,) {final _that = this;
switch (_that) {
case _RenderedSide() when $default != null:
return $default(_that.html,_that.errors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RenderedSide implements RenderedSide {
  const _RenderedSide({this.html = '',  List<ContentDiagnostic> errors = const <ContentDiagnostic>[]}): _errors = errors;
  factory _RenderedSide.fromJson(Map<String, dynamic> json) => _$RenderedSideFromJson(json);

@override@JsonKey() final  String html;
 final  List<ContentDiagnostic> _errors;
@override@JsonKey() List<ContentDiagnostic> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of RenderedSide
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RenderedSideCopyWith<_RenderedSide> get copyWith => __$RenderedSideCopyWithImpl<_RenderedSide>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RenderedSideToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RenderedSide&&(identical(other.html, html) || other.html == html)&&const DeepCollectionEquality().equals(other.errors, _errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,html,const DeepCollectionEquality().hash(_errors));
}

@override
String toString() {
    return 'RenderedSide(html: $html, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$RenderedSideCopyWith<$Res> implements $RenderedSideCopyWith<$Res> {
  factory _$RenderedSideCopyWith(_RenderedSide value, $Res Function(_RenderedSide) _then) = __$RenderedSideCopyWithImpl;
@override @useResult
$Res call({
 String html, List<ContentDiagnostic> errors
});




}
/// @nodoc
class __$RenderedSideCopyWithImpl<$Res>
    implements _$RenderedSideCopyWith<$Res> {
  __$RenderedSideCopyWithImpl(this._self, this._then);

  final _RenderedSide _self;
  final $Res Function(_RenderedSide) _then;

/// Create a copy of RenderedSide
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? html = null,Object? errors = null,}) {
  return _then(_RenderedSide(
html: null == html ? _self.html : html // ignore: cast_nullable_to_non_nullable
as String,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<ContentDiagnostic>,
  ));
}


}


/// @nodoc
mixin _$ContentRenderer {

 String get name; String get version; String get cssUrl;
/// Create a copy of ContentRenderer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentRendererCopyWith<ContentRenderer> get copyWith => _$ContentRendererCopyWithImpl<ContentRenderer>(this as ContentRenderer, _$identity);

  /// Serializes this ContentRenderer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContentRenderer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentRenderer&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.cssUrl, _this.cssUrl) || other.cssUrl == _this.cssUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContentRenderer;
  return Object.hash(runtimeType,_this.name,_this.version,_this.cssUrl);
}

@override
String toString() {
  final _this = this as ContentRenderer;
  return 'ContentRenderer(name: ${_this.name}, version: ${_this.version}, cssUrl: ${_this.cssUrl})';
}


}

/// @nodoc
abstract mixin class $ContentRendererCopyWith<$Res>  {
  factory $ContentRendererCopyWith(ContentRenderer value, $Res Function(ContentRenderer) _then) = _$ContentRendererCopyWithImpl;
@useResult
$Res call({
 String name, String version, String cssUrl
});




}
/// @nodoc
class _$ContentRendererCopyWithImpl<$Res>
    implements $ContentRendererCopyWith<$Res> {
  _$ContentRendererCopyWithImpl(this._self, this._then);

  final ContentRenderer _self;
  final $Res Function(ContentRenderer) _then;

/// Create a copy of ContentRenderer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? version = null,Object? cssUrl = null,}) {
  return _then(ContentRenderer(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,cssUrl: null == cssUrl ? _self.cssUrl : cssUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentRenderer].
extension ContentRendererPatterns on ContentRenderer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentRenderer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentRenderer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentRenderer value)  $default,){
final _that = this;
switch (_that) {
case _ContentRenderer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentRenderer value)?  $default,){
final _that = this;
switch (_that) {
case _ContentRenderer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String version,  String cssUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentRenderer() when $default != null:
return $default(_that.name,_that.version,_that.cssUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String version,  String cssUrl)  $default,) {final _that = this;
switch (_that) {
case _ContentRenderer():
return $default(_that.name,_that.version,_that.cssUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String version,  String cssUrl)?  $default,) {final _that = this;
switch (_that) {
case _ContentRenderer() when $default != null:
return $default(_that.name,_that.version,_that.cssUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentRenderer implements ContentRenderer {
  const _ContentRenderer({this.name = '', this.version = '', this.cssUrl = '/api/content/assets/katex.min.css'});
  factory _ContentRenderer.fromJson(Map<String, dynamic> json) => _$ContentRendererFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String version;
@override@JsonKey() final  String cssUrl;

/// Create a copy of ContentRenderer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentRendererCopyWith<_ContentRenderer> get copyWith => __$ContentRendererCopyWithImpl<_ContentRenderer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentRendererToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentRenderer&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.cssUrl, cssUrl) || other.cssUrl == cssUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,version,cssUrl);
}

@override
String toString() {
    return 'ContentRenderer(name: $name, version: $version, cssUrl: $cssUrl)';
}


}

/// @nodoc
abstract mixin class _$ContentRendererCopyWith<$Res> implements $ContentRendererCopyWith<$Res> {
  factory _$ContentRendererCopyWith(_ContentRenderer value, $Res Function(_ContentRenderer) _then) = __$ContentRendererCopyWithImpl;
@override @useResult
$Res call({
 String name, String version, String cssUrl
});




}
/// @nodoc
class __$ContentRendererCopyWithImpl<$Res>
    implements _$ContentRendererCopyWith<$Res> {
  __$ContentRendererCopyWithImpl(this._self, this._then);

  final _ContentRenderer _self;
  final $Res Function(_ContentRenderer) _then;

/// Create a copy of ContentRenderer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? version = null,Object? cssUrl = null,}) {
  return _then(_ContentRenderer(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,cssUrl: null == cssUrl ? _self.cssUrl : cssUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ContentPreview {

 RenderedSide get front; RenderedSide get back; bool get valid; ContentRenderer get renderer;
/// Create a copy of ContentPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentPreviewCopyWith<ContentPreview> get copyWith => _$ContentPreviewCopyWithImpl<ContentPreview>(this as ContentPreview, _$identity);

  /// Serializes this ContentPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContentPreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentPreview&&(identical(other.front, _this.front) || other.front == _this.front)&&(identical(other.back, _this.back) || other.back == _this.back)&&(identical(other.valid, _this.valid) || other.valid == _this.valid)&&(identical(other.renderer, _this.renderer) || other.renderer == _this.renderer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContentPreview;
  return Object.hash(runtimeType,_this.front,_this.back,_this.valid,_this.renderer);
}

@override
String toString() {
  final _this = this as ContentPreview;
  return 'ContentPreview(front: ${_this.front}, back: ${_this.back}, valid: ${_this.valid}, renderer: ${_this.renderer})';
}


}

/// @nodoc
abstract mixin class $ContentPreviewCopyWith<$Res>  {
  factory $ContentPreviewCopyWith(ContentPreview value, $Res Function(ContentPreview) _then) = _$ContentPreviewCopyWithImpl;
@useResult
$Res call({
 RenderedSide front, RenderedSide back, bool valid, ContentRenderer renderer
});


$RenderedSideCopyWith<$Res> get front;$RenderedSideCopyWith<$Res> get back;$ContentRendererCopyWith<$Res> get renderer;

}
/// @nodoc
class _$ContentPreviewCopyWithImpl<$Res>
    implements $ContentPreviewCopyWith<$Res> {
  _$ContentPreviewCopyWithImpl(this._self, this._then);

  final ContentPreview _self;
  final $Res Function(ContentPreview) _then;

/// Create a copy of ContentPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? front = null,Object? back = null,Object? valid = null,Object? renderer = null,}) {
  return _then(ContentPreview(
front: null == front ? _self.front : front // ignore: cast_nullable_to_non_nullable
as RenderedSide,back: null == back ? _self.back : back // ignore: cast_nullable_to_non_nullable
as RenderedSide,valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,renderer: null == renderer ? _self.renderer : renderer // ignore: cast_nullable_to_non_nullable
as ContentRenderer,
  ));
}
/// Create a copy of ContentPreview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RenderedSideCopyWith<$Res> get front {

  return $RenderedSideCopyWith<$Res>(_self.front, (value) {
    return _then(_self.copyWith(front: value));
  });
}/// Create a copy of ContentPreview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RenderedSideCopyWith<$Res> get back {

  return $RenderedSideCopyWith<$Res>(_self.back, (value) {
    return _then(_self.copyWith(back: value));
  });
}/// Create a copy of ContentPreview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentRendererCopyWith<$Res> get renderer {

  return $ContentRendererCopyWith<$Res>(_self.renderer, (value) {
    return _then(_self.copyWith(renderer: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContentPreview].
extension ContentPreviewPatterns on ContentPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentPreview value)  $default,){
final _that = this;
switch (_that) {
case _ContentPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentPreview value)?  $default,){
final _that = this;
switch (_that) {
case _ContentPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RenderedSide front,  RenderedSide back,  bool valid,  ContentRenderer renderer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentPreview() when $default != null:
return $default(_that.front,_that.back,_that.valid,_that.renderer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RenderedSide front,  RenderedSide back,  bool valid,  ContentRenderer renderer)  $default,) {final _that = this;
switch (_that) {
case _ContentPreview():
return $default(_that.front,_that.back,_that.valid,_that.renderer);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RenderedSide front,  RenderedSide back,  bool valid,  ContentRenderer renderer)?  $default,) {final _that = this;
switch (_that) {
case _ContentPreview() when $default != null:
return $default(_that.front,_that.back,_that.valid,_that.renderer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentPreview implements ContentPreview {
  const _ContentPreview({required this.front, required this.back, this.valid = false, this.renderer = const ContentRenderer()});
  factory _ContentPreview.fromJson(Map<String, dynamic> json) => _$ContentPreviewFromJson(json);

@override final  RenderedSide front;
@override final  RenderedSide back;
@override@JsonKey() final  bool valid;
@override@JsonKey() final  ContentRenderer renderer;

/// Create a copy of ContentPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentPreviewCopyWith<_ContentPreview> get copyWith => __$ContentPreviewCopyWithImpl<_ContentPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentPreview&&(identical(other.front, front) || other.front == front)&&(identical(other.back, back) || other.back == back)&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.renderer, renderer) || other.renderer == renderer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,front,back,valid,renderer);
}

@override
String toString() {
    return 'ContentPreview(front: $front, back: $back, valid: $valid, renderer: $renderer)';
}


}

/// @nodoc
abstract mixin class _$ContentPreviewCopyWith<$Res> implements $ContentPreviewCopyWith<$Res> {
  factory _$ContentPreviewCopyWith(_ContentPreview value, $Res Function(_ContentPreview) _then) = __$ContentPreviewCopyWithImpl;
@override @useResult
$Res call({
 RenderedSide front, RenderedSide back, bool valid, ContentRenderer renderer
});


@override $RenderedSideCopyWith<$Res> get front;@override $RenderedSideCopyWith<$Res> get back;@override $ContentRendererCopyWith<$Res> get renderer;

}
/// @nodoc
class __$ContentPreviewCopyWithImpl<$Res>
    implements _$ContentPreviewCopyWith<$Res> {
  __$ContentPreviewCopyWithImpl(this._self, this._then);

  final _ContentPreview _self;
  final $Res Function(_ContentPreview) _then;

/// Create a copy of ContentPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? front = null,Object? back = null,Object? valid = null,Object? renderer = null,}) {
  return _then(_ContentPreview(
front: null == front ? _self.front : front // ignore: cast_nullable_to_non_nullable
as RenderedSide,back: null == back ? _self.back : back // ignore: cast_nullable_to_non_nullable
as RenderedSide,valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,renderer: null == renderer ? _self.renderer : renderer // ignore: cast_nullable_to_non_nullable
as ContentRenderer,
  ));
}

/// Create a copy of ContentPreview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RenderedSideCopyWith<$Res> get front {

  return $RenderedSideCopyWith<$Res>(_self.front, (value) {
    return _then(_self.copyWith(front: value));
  });
}/// Create a copy of ContentPreview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RenderedSideCopyWith<$Res> get back {

  return $RenderedSideCopyWith<$Res>(_self.back, (value) {
    return _then(_self.copyWith(back: value));
  });
}/// Create a copy of ContentPreview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentRendererCopyWith<$Res> get renderer {

  return $ContentRendererCopyWith<$Res>(_self.renderer, (value) {
    return _then(_self.copyWith(renderer: value));
  });
}
}


/// @nodoc
mixin _$FsrsParams {

 List<double> get w; String get source; String? get updatedAt; String? get revlogMigratedAt; int get reviewCount; int get minReviews; String get timezone; int get rolloverHour;
/// Create a copy of FsrsParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FsrsParamsCopyWith<FsrsParams> get copyWith => _$FsrsParamsCopyWithImpl<FsrsParams>(this as FsrsParams, _$identity);

  /// Serializes this FsrsParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FsrsParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FsrsParams&&const DeepCollectionEquality().equals(other.w, _this.w)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.revlogMigratedAt, _this.revlogMigratedAt) || other.revlogMigratedAt == _this.revlogMigratedAt)&&(identical(other.reviewCount, _this.reviewCount) || other.reviewCount == _this.reviewCount)&&(identical(other.minReviews, _this.minReviews) || other.minReviews == _this.minReviews)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.rolloverHour, _this.rolloverHour) || other.rolloverHour == _this.rolloverHour));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FsrsParams;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.w),_this.source,_this.updatedAt,_this.revlogMigratedAt,_this.reviewCount,_this.minReviews,_this.timezone,_this.rolloverHour);
}

@override
String toString() {
  final _this = this as FsrsParams;
  return 'FsrsParams(w: ${_this.w}, source: ${_this.source}, updatedAt: ${_this.updatedAt}, revlogMigratedAt: ${_this.revlogMigratedAt}, reviewCount: ${_this.reviewCount}, minReviews: ${_this.minReviews}, timezone: ${_this.timezone}, rolloverHour: ${_this.rolloverHour})';
}


}

/// @nodoc
abstract mixin class $FsrsParamsCopyWith<$Res>  {
  factory $FsrsParamsCopyWith(FsrsParams value, $Res Function(FsrsParams) _then) = _$FsrsParamsCopyWithImpl;
@useResult
$Res call({
 List<double> w, String source, String? updatedAt, String? revlogMigratedAt, int reviewCount, int minReviews, String timezone, int rolloverHour
});




}
/// @nodoc
class _$FsrsParamsCopyWithImpl<$Res>
    implements $FsrsParamsCopyWith<$Res> {
  _$FsrsParamsCopyWithImpl(this._self, this._then);

  final FsrsParams _self;
  final $Res Function(FsrsParams) _then;

/// Create a copy of FsrsParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? w = null,Object? source = null,Object? updatedAt = freezed,Object? revlogMigratedAt = freezed,Object? reviewCount = null,Object? minReviews = null,Object? timezone = null,Object? rolloverHour = null,}) {
  return _then(FsrsParams(
w: null == w ? _self.w : w // ignore: cast_nullable_to_non_nullable
as List<double>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,revlogMigratedAt: freezed == revlogMigratedAt ? _self.revlogMigratedAt : revlogMigratedAt // ignore: cast_nullable_to_non_nullable
as String?,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,minReviews: null == minReviews ? _self.minReviews : minReviews // ignore: cast_nullable_to_non_nullable
as int,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,rolloverHour: null == rolloverHour ? _self.rolloverHour : rolloverHour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FsrsParams].
extension FsrsParamsPatterns on FsrsParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FsrsParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FsrsParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FsrsParams value)  $default,){
final _that = this;
switch (_that) {
case _FsrsParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FsrsParams value)?  $default,){
final _that = this;
switch (_that) {
case _FsrsParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<double> w,  String source,  String? updatedAt,  String? revlogMigratedAt,  int reviewCount,  int minReviews,  String timezone,  int rolloverHour)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FsrsParams() when $default != null:
return $default(_that.w,_that.source,_that.updatedAt,_that.revlogMigratedAt,_that.reviewCount,_that.minReviews,_that.timezone,_that.rolloverHour);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<double> w,  String source,  String? updatedAt,  String? revlogMigratedAt,  int reviewCount,  int minReviews,  String timezone,  int rolloverHour)  $default,) {final _that = this;
switch (_that) {
case _FsrsParams():
return $default(_that.w,_that.source,_that.updatedAt,_that.revlogMigratedAt,_that.reviewCount,_that.minReviews,_that.timezone,_that.rolloverHour);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<double> w,  String source,  String? updatedAt,  String? revlogMigratedAt,  int reviewCount,  int minReviews,  String timezone,  int rolloverHour)?  $default,) {final _that = this;
switch (_that) {
case _FsrsParams() when $default != null:
return $default(_that.w,_that.source,_that.updatedAt,_that.revlogMigratedAt,_that.reviewCount,_that.minReviews,_that.timezone,_that.rolloverHour);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FsrsParams implements FsrsParams {
  const _FsrsParams({ List<double> w = const <double>[], this.source = 'default', this.updatedAt, this.revlogMigratedAt, this.reviewCount = 0, this.minReviews = 1000, this.timezone = '', this.rolloverHour = 4}): _w = w;
  factory _FsrsParams.fromJson(Map<String, dynamic> json) => _$FsrsParamsFromJson(json);

 final  List<double> _w;
@override@JsonKey() List<double> get w {
  if (_w is EqualUnmodifiableListView) return _w;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_w);
}

@override@JsonKey() final  String source;
@override final  String? updatedAt;
@override final  String? revlogMigratedAt;
@override@JsonKey() final  int reviewCount;
@override@JsonKey() final  int minReviews;
@override@JsonKey() final  String timezone;
@override@JsonKey() final  int rolloverHour;

/// Create a copy of FsrsParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FsrsParamsCopyWith<_FsrsParams> get copyWith => __$FsrsParamsCopyWithImpl<_FsrsParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FsrsParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FsrsParams&&const DeepCollectionEquality().equals(other.w, _w)&&(identical(other.source, source) || other.source == source)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.revlogMigratedAt, revlogMigratedAt) || other.revlogMigratedAt == revlogMigratedAt)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.minReviews, minReviews) || other.minReviews == minReviews)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.rolloverHour, rolloverHour) || other.rolloverHour == rolloverHour));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_w),source,updatedAt,revlogMigratedAt,reviewCount,minReviews,timezone,rolloverHour);
}

@override
String toString() {
    return 'FsrsParams(w: $w, source: $source, updatedAt: $updatedAt, revlogMigratedAt: $revlogMigratedAt, reviewCount: $reviewCount, minReviews: $minReviews, timezone: $timezone, rolloverHour: $rolloverHour)';
}


}

/// @nodoc
abstract mixin class _$FsrsParamsCopyWith<$Res> implements $FsrsParamsCopyWith<$Res> {
  factory _$FsrsParamsCopyWith(_FsrsParams value, $Res Function(_FsrsParams) _then) = __$FsrsParamsCopyWithImpl;
@override @useResult
$Res call({
 List<double> w, String source, String? updatedAt, String? revlogMigratedAt, int reviewCount, int minReviews, String timezone, int rolloverHour
});




}
/// @nodoc
class __$FsrsParamsCopyWithImpl<$Res>
    implements _$FsrsParamsCopyWith<$Res> {
  __$FsrsParamsCopyWithImpl(this._self, this._then);

  final _FsrsParams _self;
  final $Res Function(_FsrsParams) _then;

/// Create a copy of FsrsParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? w = null,Object? source = null,Object? updatedAt = freezed,Object? revlogMigratedAt = freezed,Object? reviewCount = null,Object? minReviews = null,Object? timezone = null,Object? rolloverHour = null,}) {
  return _then(_FsrsParams(
w: null == w ? _self._w : w // ignore: cast_nullable_to_non_nullable
as List<double>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,revlogMigratedAt: freezed == revlogMigratedAt ? _self.revlogMigratedAt : revlogMigratedAt // ignore: cast_nullable_to_non_nullable
as String?,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,minReviews: null == minReviews ? _self.minReviews : minReviews // ignore: cast_nullable_to_non_nullable
as int,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,rolloverHour: null == rolloverHour ? _self.rolloverHour : rolloverHour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OptimizeJob {

 bool get running; String? get startedAt; String? get finishedAt; bool get force; Map<String, dynamic>? get result; String? get error;
/// Create a copy of OptimizeJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OptimizeJobCopyWith<OptimizeJob> get copyWith => _$OptimizeJobCopyWithImpl<OptimizeJob>(this as OptimizeJob, _$identity);

  /// Serializes this OptimizeJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OptimizeJob;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OptimizeJob&&(identical(other.running, _this.running) || other.running == _this.running)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.finishedAt, _this.finishedAt) || other.finishedAt == _this.finishedAt)&&(identical(other.force, _this.force) || other.force == _this.force)&&const DeepCollectionEquality().equals(other.result, _this.result)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OptimizeJob;
  return Object.hash(runtimeType,_this.running,_this.startedAt,_this.finishedAt,_this.force,const DeepCollectionEquality().hash(_this.result),_this.error);
}

@override
String toString() {
  final _this = this as OptimizeJob;
  return 'OptimizeJob(running: ${_this.running}, startedAt: ${_this.startedAt}, finishedAt: ${_this.finishedAt}, force: ${_this.force}, result: ${_this.result}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $OptimizeJobCopyWith<$Res>  {
  factory $OptimizeJobCopyWith(OptimizeJob value, $Res Function(OptimizeJob) _then) = _$OptimizeJobCopyWithImpl;
@useResult
$Res call({
 bool running, String? startedAt, String? finishedAt, bool force, Map<String, dynamic>? result, String? error
});




}
/// @nodoc
class _$OptimizeJobCopyWithImpl<$Res>
    implements $OptimizeJobCopyWith<$Res> {
  _$OptimizeJobCopyWithImpl(this._self, this._then);

  final OptimizeJob _self;
  final $Res Function(OptimizeJob) _then;

/// Create a copy of OptimizeJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? running = null,Object? startedAt = freezed,Object? finishedAt = freezed,Object? force = null,Object? result = freezed,Object? error = freezed,}) {
  return _then(OptimizeJob(
running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as String?,force: null == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OptimizeJob].
extension OptimizeJobPatterns on OptimizeJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OptimizeJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OptimizeJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OptimizeJob value)  $default,){
final _that = this;
switch (_that) {
case _OptimizeJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OptimizeJob value)?  $default,){
final _that = this;
switch (_that) {
case _OptimizeJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool running,  String? startedAt,  String? finishedAt,  bool force,  Map<String, dynamic>? result,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OptimizeJob() when $default != null:
return $default(_that.running,_that.startedAt,_that.finishedAt,_that.force,_that.result,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool running,  String? startedAt,  String? finishedAt,  bool force,  Map<String, dynamic>? result,  String? error)  $default,) {final _that = this;
switch (_that) {
case _OptimizeJob():
return $default(_that.running,_that.startedAt,_that.finishedAt,_that.force,_that.result,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool running,  String? startedAt,  String? finishedAt,  bool force,  Map<String, dynamic>? result,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _OptimizeJob() when $default != null:
return $default(_that.running,_that.startedAt,_that.finishedAt,_that.force,_that.result,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OptimizeJob implements OptimizeJob {
  const _OptimizeJob({this.running = false, this.startedAt, this.finishedAt, this.force = false,  Map<String, dynamic>? result, this.error}): _result = result;
  factory _OptimizeJob.fromJson(Map<String, dynamic> json) => _$OptimizeJobFromJson(json);

@override@JsonKey() final  bool running;
@override final  String? startedAt;
@override final  String? finishedAt;
@override@JsonKey() final  bool force;
 final  Map<String, dynamic>? _result;
@override Map<String, dynamic>? get result {
  final value = _result;
  if (value == null) return null;
  if (_result is EqualUnmodifiableMapView) return _result;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? error;

/// Create a copy of OptimizeJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OptimizeJobCopyWith<_OptimizeJob> get copyWith => __$OptimizeJobCopyWithImpl<_OptimizeJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OptimizeJobToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OptimizeJob&&(identical(other.running, running) || other.running == running)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.force, force) || other.force == force)&&const DeepCollectionEquality().equals(other.result, _result)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,running,startedAt,finishedAt,force,const DeepCollectionEquality().hash(_result),error);
}

@override
String toString() {
    return 'OptimizeJob(running: $running, startedAt: $startedAt, finishedAt: $finishedAt, force: $force, result: $result, error: $error)';
}


}

/// @nodoc
abstract mixin class _$OptimizeJobCopyWith<$Res> implements $OptimizeJobCopyWith<$Res> {
  factory _$OptimizeJobCopyWith(_OptimizeJob value, $Res Function(_OptimizeJob) _then) = __$OptimizeJobCopyWithImpl;
@override @useResult
$Res call({
 bool running, String? startedAt, String? finishedAt, bool force, Map<String, dynamic>? result, String? error
});




}
/// @nodoc
class __$OptimizeJobCopyWithImpl<$Res>
    implements _$OptimizeJobCopyWith<$Res> {
  __$OptimizeJobCopyWithImpl(this._self, this._then);

  final _OptimizeJob _self;
  final $Res Function(_OptimizeJob) _then;

/// Create a copy of OptimizeJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? running = null,Object? startedAt = freezed,Object? finishedAt = freezed,Object? force = null,Object? result = freezed,Object? error = freezed,}) {
  return _then(_OptimizeJob(
running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as String?,force: null == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as bool,result: freezed == result ? _self._result : result // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WordPronunciation {

 String get displayIpa; String get accent; String get pos; String get status; String get usage;
/// Create a copy of WordPronunciation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordPronunciationCopyWith<WordPronunciation> get copyWith => _$WordPronunciationCopyWithImpl<WordPronunciation>(this as WordPronunciation, _$identity);

  /// Serializes this WordPronunciation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WordPronunciation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordPronunciation&&(identical(other.displayIpa, _this.displayIpa) || other.displayIpa == _this.displayIpa)&&(identical(other.accent, _this.accent) || other.accent == _this.accent)&&(identical(other.pos, _this.pos) || other.pos == _this.pos)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.usage, _this.usage) || other.usage == _this.usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WordPronunciation;
  return Object.hash(runtimeType,_this.displayIpa,_this.accent,_this.pos,_this.status,_this.usage);
}

@override
String toString() {
  final _this = this as WordPronunciation;
  return 'WordPronunciation(displayIpa: ${_this.displayIpa}, accent: ${_this.accent}, pos: ${_this.pos}, status: ${_this.status}, usage: ${_this.usage})';
}


}

/// @nodoc
abstract mixin class $WordPronunciationCopyWith<$Res>  {
  factory $WordPronunciationCopyWith(WordPronunciation value, $Res Function(WordPronunciation) _then) = _$WordPronunciationCopyWithImpl;
@useResult
$Res call({
 String displayIpa, String accent, String pos, String status, String usage
});




}
/// @nodoc
class _$WordPronunciationCopyWithImpl<$Res>
    implements $WordPronunciationCopyWith<$Res> {
  _$WordPronunciationCopyWithImpl(this._self, this._then);

  final WordPronunciation _self;
  final $Res Function(WordPronunciation) _then;

/// Create a copy of WordPronunciation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayIpa = null,Object? accent = null,Object? pos = null,Object? status = null,Object? usage = null,}) {
  return _then(WordPronunciation(
displayIpa: null == displayIpa ? _self.displayIpa : displayIpa // ignore: cast_nullable_to_non_nullable
as String,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as String,pos: null == pos ? _self.pos : pos // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WordPronunciation].
extension WordPronunciationPatterns on WordPronunciation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordPronunciation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordPronunciation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordPronunciation value)  $default,){
final _that = this;
switch (_that) {
case _WordPronunciation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordPronunciation value)?  $default,){
final _that = this;
switch (_that) {
case _WordPronunciation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayIpa,  String accent,  String pos,  String status,  String usage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordPronunciation() when $default != null:
return $default(_that.displayIpa,_that.accent,_that.pos,_that.status,_that.usage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayIpa,  String accent,  String pos,  String status,  String usage)  $default,) {final _that = this;
switch (_that) {
case _WordPronunciation():
return $default(_that.displayIpa,_that.accent,_that.pos,_that.status,_that.usage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayIpa,  String accent,  String pos,  String status,  String usage)?  $default,) {final _that = this;
switch (_that) {
case _WordPronunciation() when $default != null:
return $default(_that.displayIpa,_that.accent,_that.pos,_that.status,_that.usage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordPronunciation implements WordPronunciation {
  const _WordPronunciation({this.displayIpa = '', this.accent = '', this.pos = '', this.status = '', this.usage = ''});
  factory _WordPronunciation.fromJson(Map<String, dynamic> json) => _$WordPronunciationFromJson(json);

@override@JsonKey() final  String displayIpa;
@override@JsonKey() final  String accent;
@override@JsonKey() final  String pos;
@override@JsonKey() final  String status;
@override@JsonKey() final  String usage;

/// Create a copy of WordPronunciation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordPronunciationCopyWith<_WordPronunciation> get copyWith => __$WordPronunciationCopyWithImpl<_WordPronunciation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordPronunciationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordPronunciation&&(identical(other.displayIpa, displayIpa) || other.displayIpa == displayIpa)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.pos, pos) || other.pos == pos)&&(identical(other.status, status) || other.status == status)&&(identical(other.usage, usage) || other.usage == usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,displayIpa,accent,pos,status,usage);
}

@override
String toString() {
    return 'WordPronunciation(displayIpa: $displayIpa, accent: $accent, pos: $pos, status: $status, usage: $usage)';
}


}

/// @nodoc
abstract mixin class _$WordPronunciationCopyWith<$Res> implements $WordPronunciationCopyWith<$Res> {
  factory _$WordPronunciationCopyWith(_WordPronunciation value, $Res Function(_WordPronunciation) _then) = __$WordPronunciationCopyWithImpl;
@override @useResult
$Res call({
 String displayIpa, String accent, String pos, String status, String usage
});




}
/// @nodoc
class __$WordPronunciationCopyWithImpl<$Res>
    implements _$WordPronunciationCopyWith<$Res> {
  __$WordPronunciationCopyWithImpl(this._self, this._then);

  final _WordPronunciation _self;
  final $Res Function(_WordPronunciation) _then;

/// Create a copy of WordPronunciation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayIpa = null,Object? accent = null,Object? pos = null,Object? status = null,Object? usage = null,}) {
  return _then(_WordPronunciation(
displayIpa: null == displayIpa ? _self.displayIpa : displayIpa // ignore: cast_nullable_to_non_nullable
as String,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as String,pos: null == pos ? _self.pos : pos // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$WordSense {

 String get gloss; String get examples; String get zh; String get exampleDetails;
/// Create a copy of WordSense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordSenseCopyWith<WordSense> get copyWith => _$WordSenseCopyWithImpl<WordSense>(this as WordSense, _$identity);

  /// Serializes this WordSense to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WordSense;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordSense&&(identical(other.gloss, _this.gloss) || other.gloss == _this.gloss)&&(identical(other.examples, _this.examples) || other.examples == _this.examples)&&(identical(other.zh, _this.zh) || other.zh == _this.zh)&&(identical(other.exampleDetails, _this.exampleDetails) || other.exampleDetails == _this.exampleDetails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WordSense;
  return Object.hash(runtimeType,_this.gloss,_this.examples,_this.zh,_this.exampleDetails);
}

@override
String toString() {
  final _this = this as WordSense;
  return 'WordSense(gloss: ${_this.gloss}, examples: ${_this.examples}, zh: ${_this.zh}, exampleDetails: ${_this.exampleDetails})';
}


}

/// @nodoc
abstract mixin class $WordSenseCopyWith<$Res>  {
  factory $WordSenseCopyWith(WordSense value, $Res Function(WordSense) _then) = _$WordSenseCopyWithImpl;
@useResult
$Res call({
 String gloss, String examples, String zh, String exampleDetails
});




}
/// @nodoc
class _$WordSenseCopyWithImpl<$Res>
    implements $WordSenseCopyWith<$Res> {
  _$WordSenseCopyWithImpl(this._self, this._then);

  final WordSense _self;
  final $Res Function(WordSense) _then;

/// Create a copy of WordSense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gloss = null,Object? examples = null,Object? zh = null,Object? exampleDetails = null,}) {
  return _then(WordSense(
gloss: null == gloss ? _self.gloss : gloss // ignore: cast_nullable_to_non_nullable
as String,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as String,zh: null == zh ? _self.zh : zh // ignore: cast_nullable_to_non_nullable
as String,exampleDetails: null == exampleDetails ? _self.exampleDetails : exampleDetails // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WordSense].
extension WordSensePatterns on WordSense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordSense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordSense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordSense value)  $default,){
final _that = this;
switch (_that) {
case _WordSense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordSense value)?  $default,){
final _that = this;
switch (_that) {
case _WordSense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String gloss,  String examples,  String zh,  String exampleDetails)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordSense() when $default != null:
return $default(_that.gloss,_that.examples,_that.zh,_that.exampleDetails);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String gloss,  String examples,  String zh,  String exampleDetails)  $default,) {final _that = this;
switch (_that) {
case _WordSense():
return $default(_that.gloss,_that.examples,_that.zh,_that.exampleDetails);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String gloss,  String examples,  String zh,  String exampleDetails)?  $default,) {final _that = this;
switch (_that) {
case _WordSense() when $default != null:
return $default(_that.gloss,_that.examples,_that.zh,_that.exampleDetails);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordSense implements WordSense {
  const _WordSense({this.gloss = '', this.examples = '[]', this.zh = '[]', this.exampleDetails = '[]'});
  factory _WordSense.fromJson(Map<String, dynamic> json) => _$WordSenseFromJson(json);

@override@JsonKey() final  String gloss;
@override@JsonKey() final  String examples;
@override@JsonKey() final  String zh;
@override@JsonKey() final  String exampleDetails;

/// Create a copy of WordSense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordSenseCopyWith<_WordSense> get copyWith => __$WordSenseCopyWithImpl<_WordSense>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordSenseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordSense&&(identical(other.gloss, gloss) || other.gloss == gloss)&&(identical(other.examples, examples) || other.examples == examples)&&(identical(other.zh, zh) || other.zh == zh)&&(identical(other.exampleDetails, exampleDetails) || other.exampleDetails == exampleDetails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,gloss,examples,zh,exampleDetails);
}

@override
String toString() {
    return 'WordSense(gloss: $gloss, examples: $examples, zh: $zh, exampleDetails: $exampleDetails)';
}


}

/// @nodoc
abstract mixin class _$WordSenseCopyWith<$Res> implements $WordSenseCopyWith<$Res> {
  factory _$WordSenseCopyWith(_WordSense value, $Res Function(_WordSense) _then) = __$WordSenseCopyWithImpl;
@override @useResult
$Res call({
 String gloss, String examples, String zh, String exampleDetails
});




}
/// @nodoc
class __$WordSenseCopyWithImpl<$Res>
    implements _$WordSenseCopyWith<$Res> {
  __$WordSenseCopyWithImpl(this._self, this._then);

  final _WordSense _self;
  final $Res Function(_WordSense) _then;

/// Create a copy of WordSense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gloss = null,Object? examples = null,Object? zh = null,Object? exampleDetails = null,}) {
  return _then(_WordSense(
gloss: null == gloss ? _self.gloss : gloss // ignore: cast_nullable_to_non_nullable
as String,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as String,zh: null == zh ? _self.zh : zh // ignore: cast_nullable_to_non_nullable
as String,exampleDetails: null == exampleDetails ? _self.exampleDetails : exampleDetails // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
