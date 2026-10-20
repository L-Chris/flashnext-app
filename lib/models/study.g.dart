// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeckSettings _$DeckSettingsFromJson(Map<String, dynamic> json) =>
    _DeckSettings(
      deckId: (json['deckId'] as num).toInt(),
      newPerDay: (json['newPerDay'] as num?)?.toInt() ?? 20,
      reviewPerDay: (json['reviewPerDay'] as num?)?.toInt() ?? 500,
      timezone: json['timezone'] as String? ?? 'Asia/Shanghai',
      rolloverHour: (json['rolloverHour'] as num?)?.toInt() ?? 4,
      version: (json['version'] as num?)?.toInt() ?? 0,
      audioAutoplay: json['audioAutoplay'] as bool? ?? false,
      showNewCardAnswerImmediately:
          json['showNewCardAnswerImmediately'] as bool? ?? false,
      autoRevealAnswerSeconds: (json['autoRevealAnswerSeconds'] as num?)
          ?.toInt(),
    );

Map<String, dynamic> _$DeckSettingsToJson(_DeckSettings instance) =>
    <String, dynamic>{
      'deckId': instance.deckId,
      'newPerDay': instance.newPerDay,
      'reviewPerDay': instance.reviewPerDay,
      'timezone': instance.timezone,
      'rolloverHour': instance.rolloverHour,
      'version': instance.version,
      'audioAutoplay': instance.audioAutoplay,
      'showNewCardAnswerImmediately': instance.showNewCardAnswerImmediately,
      'autoRevealAnswerSeconds': instance.autoRevealAnswerSeconds,
    };

_ReviewOptions _$ReviewOptionsFromJson(Map<String, dynamic> json) =>
    _ReviewOptions(
      audioAutoplay: json['audioAutoplay'] as bool? ?? false,
      showNewCardAnswerImmediately:
          json['showNewCardAnswerImmediately'] as bool? ?? false,
      autoRevealAnswerSeconds: (json['autoRevealAnswerSeconds'] as num?)
          ?.toInt(),
      settingsVersion: (json['settingsVersion'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ReviewOptionsToJson(_ReviewOptions instance) =>
    <String, dynamic>{
      'audioAutoplay': instance.audioAutoplay,
      'showNewCardAnswerImmediately': instance.showNewCardAnswerImmediately,
      'autoRevealAnswerSeconds': instance.autoRevealAnswerSeconds,
      'settingsVersion': instance.settingsVersion,
    };

_CardPresentation _$CardPresentationFromJson(Map<String, dynamic> json) =>
    _CardPresentation(
      audioAutoplay: json['audioAutoplay'] as bool? ?? false,
      answerRevealAfterMs: (json['answerRevealAfterMs'] as num?)?.toInt(),
      settingsVersion: (json['settingsVersion'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CardPresentationToJson(_CardPresentation instance) =>
    <String, dynamic>{
      'audioAutoplay': instance.audioAutoplay,
      'answerRevealAfterMs': instance.answerRevealAfterMs,
      'settingsVersion': instance.settingsVersion,
    };

_CardMedia _$CardMediaFromJson(Map<String, dynamic> json) => _CardMedia(
  mediaId: json['mediaId'] as String,
  id: json['id'] as String? ?? '',
  side: json['side'] as String? ?? 'front',
  position: (json['position'] as num?)?.toInt() ?? 0,
  mimeType: json['mimeType'] as String? ?? '',
  bytes: (json['bytes'] as num?)?.toInt() ?? 0,
  originalName: json['originalName'] as String? ?? '',
  createdAt: json['createdAt'] as String? ?? '',
  url: json['url'] as String,
);

Map<String, dynamic> _$CardMediaToJson(_CardMedia instance) =>
    <String, dynamic>{
      'mediaId': instance.mediaId,
      'id': instance.id,
      'side': instance.side,
      'position': instance.position,
      'mimeType': instance.mimeType,
      'bytes': instance.bytes,
      'originalName': instance.originalName,
      'createdAt': instance.createdAt,
      'url': instance.url,
    };

_ContentDiagnostic _$ContentDiagnosticFromJson(Map<String, dynamic> json) =>
    _ContentDiagnostic(
      message: json['message'] as String? ?? '公式无法渲染',
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      line: (json['line'] as num?)?.toInt() ?? 1,
      column: (json['column'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$ContentDiagnosticToJson(_ContentDiagnostic instance) =>
    <String, dynamic>{
      'message': instance.message,
      'offset': instance.offset,
      'line': instance.line,
      'column': instance.column,
    };

_RenderedSide _$RenderedSideFromJson(Map<String, dynamic> json) =>
    _RenderedSide(
      html: json['html'] as String? ?? '',
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map(
                (e) => ContentDiagnostic.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ContentDiagnostic>[],
    );

Map<String, dynamic> _$RenderedSideToJson(_RenderedSide instance) =>
    <String, dynamic>{'html': instance.html, 'errors': instance.errors};

_ContentRenderer _$ContentRendererFromJson(Map<String, dynamic> json) =>
    _ContentRenderer(
      name: json['name'] as String? ?? '',
      version: json['version'] as String? ?? '',
      cssUrl: json['cssUrl'] as String? ?? '/api/content/assets/katex.min.css',
    );

Map<String, dynamic> _$ContentRendererToJson(_ContentRenderer instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'cssUrl': instance.cssUrl,
    };

_ContentPreview _$ContentPreviewFromJson(Map<String, dynamic> json) =>
    _ContentPreview(
      front: RenderedSide.fromJson(json['front'] as Map<String, dynamic>),
      back: RenderedSide.fromJson(json['back'] as Map<String, dynamic>),
      valid: json['valid'] as bool? ?? false,
      renderer: json['renderer'] == null
          ? const ContentRenderer()
          : ContentRenderer.fromJson(json['renderer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContentPreviewToJson(_ContentPreview instance) =>
    <String, dynamic>{
      'front': instance.front,
      'back': instance.back,
      'valid': instance.valid,
      'renderer': instance.renderer,
    };

_FsrsParams _$FsrsParamsFromJson(Map<String, dynamic> json) => _FsrsParams(
  w:
      (json['w'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      const <double>[],
  source: json['source'] as String? ?? 'default',
  updatedAt: json['updatedAt'] as String?,
  revlogMigratedAt: json['revlogMigratedAt'] as String?,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  minReviews: (json['minReviews'] as num?)?.toInt() ?? 1000,
  timezone: json['timezone'] as String? ?? '',
  rolloverHour: (json['rolloverHour'] as num?)?.toInt() ?? 4,
);

Map<String, dynamic> _$FsrsParamsToJson(_FsrsParams instance) =>
    <String, dynamic>{
      'w': instance.w,
      'source': instance.source,
      'updatedAt': instance.updatedAt,
      'revlogMigratedAt': instance.revlogMigratedAt,
      'reviewCount': instance.reviewCount,
      'minReviews': instance.minReviews,
      'timezone': instance.timezone,
      'rolloverHour': instance.rolloverHour,
    };

_OptimizeJob _$OptimizeJobFromJson(Map<String, dynamic> json) => _OptimizeJob(
  running: json['running'] as bool? ?? false,
  startedAt: json['startedAt'] as String?,
  finishedAt: json['finishedAt'] as String?,
  force: json['force'] as bool? ?? false,
  result: json['result'] as Map<String, dynamic>?,
  error: json['error'] as String?,
);

Map<String, dynamic> _$OptimizeJobToJson(_OptimizeJob instance) =>
    <String, dynamic>{
      'running': instance.running,
      'startedAt': instance.startedAt,
      'finishedAt': instance.finishedAt,
      'force': instance.force,
      'result': instance.result,
      'error': instance.error,
    };

_WordPronunciation _$WordPronunciationFromJson(Map<String, dynamic> json) =>
    _WordPronunciation(
      displayIpa: json['displayIpa'] as String? ?? '',
      accent: json['accent'] as String? ?? '',
      pos: json['pos'] as String? ?? '',
      status: json['status'] as String? ?? '',
      usage: json['usage'] as String? ?? '',
    );

Map<String, dynamic> _$WordPronunciationToJson(_WordPronunciation instance) =>
    <String, dynamic>{
      'displayIpa': instance.displayIpa,
      'accent': instance.accent,
      'pos': instance.pos,
      'status': instance.status,
      'usage': instance.usage,
    };

_WordSense _$WordSenseFromJson(Map<String, dynamic> json) => _WordSense(
  gloss: json['gloss'] as String? ?? '',
  examples: json['examples'] as String? ?? '[]',
  zh: json['zh'] as String? ?? '[]',
  exampleDetails: json['exampleDetails'] as String? ?? '[]',
);

Map<String, dynamic> _$WordSenseToJson(_WordSense instance) =>
    <String, dynamic>{
      'gloss': instance.gloss,
      'examples': instance.examples,
      'zh': instance.zh,
      'exampleDetails': instance.exampleDetails,
    };
