import 'package:freezed_annotation/freezed_annotation.dart';

part 'study.freezed.dart';
part 'study.g.dart';

@freezed
sealed class DeckSettings with _$DeckSettings {
  const DeckSettings._();
  const factory DeckSettings({
    required int deckId,
    @Default(20) int newPerDay,
    @Default(500) int reviewPerDay,
    @Default('Asia/Shanghai') String timezone,
    @Default(4) int rolloverHour,
    @Default(0) int version,
    @Default(false) bool audioAutoplay,
    @Default(false) bool showNewCardAnswerImmediately,
    @JsonKey(includeIfNull: true) int? autoRevealAnswerSeconds,
  }) = _DeckSettings;
  factory DeckSettings.fromJson(Map<String, dynamic> json) =>
      _$DeckSettingsFromJson(json);

  /// Include an explicitly changed null; omission would keep the server's value.
  Map<String, dynamic> changesFrom(DeckSettings saved) {
    final previous = saved.toJson();
    return Map.fromEntries(
      toJson().entries.where(
        (entry) =>
            entry.key != 'deckId' &&
            entry.key != 'version' &&
            previous[entry.key] != entry.value,
      ),
    );
  }
}

@freezed
sealed class ReviewOptions with _$ReviewOptions {
  const factory ReviewOptions({
    @Default(false) bool audioAutoplay,
    @Default(false) bool showNewCardAnswerImmediately,
    int? autoRevealAnswerSeconds,
    @Default(0) int settingsVersion,
  }) = _ReviewOptions;
  factory ReviewOptions.fromJson(Map<String, dynamic> json) =>
      _$ReviewOptionsFromJson(json);
}

@freezed
sealed class CardPresentation with _$CardPresentation {
  const factory CardPresentation({
    @Default(false) bool audioAutoplay,
    int? answerRevealAfterMs,
    @Default(0) int settingsVersion,
  }) = _CardPresentation;
  factory CardPresentation.fromJson(Map<String, dynamic> json) =>
      _$CardPresentationFromJson(json);
}

@freezed
sealed class CardMedia with _$CardMedia {
  const factory CardMedia({
    required String mediaId,
    @Default('') String id,
    @Default('front') String side,
    @Default(0) int position,
    @Default('') String mimeType,
    @Default(0) int bytes,
    @Default('') String originalName,
    @Default('') String createdAt,
    required String url,
  }) = _CardMedia;
  factory CardMedia.fromJson(Map<String, dynamic> json) =>
      _$CardMediaFromJson(json);
}

@freezed
sealed class ContentDiagnostic with _$ContentDiagnostic {
  const factory ContentDiagnostic({
    @Default('公式无法渲染') String message,
    @Default(0) int offset,
    @Default(1) int line,
    @Default(1) int column,
  }) = _ContentDiagnostic;
  factory ContentDiagnostic.fromJson(Map<String, dynamic> json) =>
      _$ContentDiagnosticFromJson(json);
}

@freezed
sealed class RenderedSide with _$RenderedSide {
  const factory RenderedSide({
    @Default('') String html,
    @Default(<ContentDiagnostic>[]) List<ContentDiagnostic> errors,
  }) = _RenderedSide;
  factory RenderedSide.fromJson(Map<String, dynamic> json) =>
      _$RenderedSideFromJson(json);
}

@freezed
sealed class ContentRenderer with _$ContentRenderer {
  const factory ContentRenderer({
    @Default('') String name,
    @Default('') String version,
    @Default('/api/content/assets/katex.min.css') String cssUrl,
  }) = _ContentRenderer;
  factory ContentRenderer.fromJson(Map<String, dynamic> json) =>
      _$ContentRendererFromJson(json);
}

@freezed
sealed class ContentPreview with _$ContentPreview {
  const factory ContentPreview({
    required RenderedSide front,
    required RenderedSide back,
    @Default(false) bool valid,
    @Default(ContentRenderer()) ContentRenderer renderer,
  }) = _ContentPreview;
  factory ContentPreview.fromJson(Map<String, dynamic> json) =>
      _$ContentPreviewFromJson(json);
}

@freezed
sealed class FsrsParams with _$FsrsParams {
  const factory FsrsParams({
    @Default(<double>[]) List<double> w,
    @Default('default') String source,
    String? updatedAt,
    String? revlogMigratedAt,
    @Default(0) int reviewCount,
    @Default(1000) int minReviews,
    @Default('') String timezone,
    @Default(4) int rolloverHour,
  }) = _FsrsParams;
  factory FsrsParams.fromJson(Map<String, dynamic> json) =>
      _$FsrsParamsFromJson(json);
}

@freezed
sealed class OptimizeJob with _$OptimizeJob {
  const factory OptimizeJob({
    @Default(false) bool running,
    String? startedAt,
    String? finishedAt,
    @Default(false) bool force,
    Map<String, dynamic>? result,
    String? error,
  }) = _OptimizeJob;
  factory OptimizeJob.fromJson(Map<String, dynamic> json) =>
      _$OptimizeJobFromJson(json);
}

@freezed
sealed class WordPronunciation with _$WordPronunciation {
  const factory WordPronunciation({
    @Default('') String displayIpa,
    @Default('') String accent,
    @Default('') String pos,
    @Default('') String status,
    @Default('') String usage,
  }) = _WordPronunciation;
  factory WordPronunciation.fromJson(Map<String, dynamic> json) =>
      _$WordPronunciationFromJson(json);
}

@freezed
sealed class WordSense with _$WordSense {
  const factory WordSense({
    @Default('') String gloss,
    @Default('[]') String examples,
    @Default('[]') String zh,
    @Default('[]') String exampleDetails,
  }) = _WordSense;
  factory WordSense.fromJson(Map<String, dynamic> json) =>
      _$WordSenseFromJson(json);
}
