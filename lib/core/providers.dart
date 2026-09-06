import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network/api_client.dart';
import '../models/deck.dart';

const kDefaultBaseUrl = 'https://mem.home.rethinkos.com';
const kBaseUrlPrefKey = 'baseUrl';

class SettingsState {
  const SettingsState({this.baseUrl = kDefaultBaseUrl, this.loaded = false});
  final String baseUrl;
  final bool loaded;

  SettingsState copyWith({String? baseUrl, bool? loaded}) => SettingsState(
        baseUrl: baseUrl ?? this.baseUrl,
        loaded: loaded ?? this.loaded,
      );
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(kBaseUrlPrefKey);
    if (saved != null && saved.isNotEmpty) {
      state = state.copyWith(baseUrl: saved, loaded: true);
    } else {
      state = state.copyWith(loaded: true);
    }
  }

  Future<void> save(String url) async {
    final normalized = url.trim().replaceAll(RegExp(r'/+$'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kBaseUrlPrefKey, normalized);
    state = state.copyWith(baseUrl: normalized);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(settingsProvider).baseUrl),
);

final decksProvider = FutureProvider<List<Deck>>(
  (ref) => ref.watch(apiClientProvider).decks(),
);
