import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.downloadUrl,
    required this.releaseNotes,
  });

  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String downloadUrl;
  final String? releaseNotes;
}

class UpdateService {
  const UpdateService({this.owner = 'Abhishek-Maurya2', this.repo = 'taskly'});

  final String owner;
  final String repo;

  Future<UpdateInfo> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final current = packageInfo.version;

    final uri = Uri.https(
      'api.github.com',
      '/repos/$owner/$repo/releases/latest',
    );
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to fetch release info');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tag = (data['tag_name'] as String?)?.trim() ?? '';
    final latest = tag.startsWith('v') ? tag.substring(1) : tag;
    final body = data['body'] as String?;

    final assets = (data['assets'] as List<dynamic>? ?? []);
    final asset = assets.cast<Map<String, dynamic>?>().firstWhere(
      (a) => (a?['name'] as String? ?? '').endsWith('.apk'),
      orElse: () => null,
    );
    final downloadUrl =
        asset?['browser_download_url'] as String? ??
        (data['assets_url'] as String? ?? '');

    final hasUpdate = _isNewer(latest, current);

    return UpdateInfo(
      currentVersion: current,
      latestVersion: latest.isEmpty ? current : latest,
      hasUpdate: hasUpdate,
      downloadUrl: downloadUrl,
      releaseNotes: body,
    );
  }

  bool _isNewer(String latest, String current) {
    if (latest.isEmpty) return false;
    final latestParts = latest.split('+').first.split('.');
    final currentParts = current.split('+').first.split('.');
    for (var i = 0; i < 3; i++) {
      final l = i < latestParts.length ? int.tryParse(latestParts[i]) ?? 0 : 0;
      final c = i < currentParts.length
          ? int.tryParse(currentParts[i]) ?? 0
          : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }
}
