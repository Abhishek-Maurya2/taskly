import 'dart:convert';

import 'package:flutter/material.dart';
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
    debugPrint('Checking for updates...');
    final packageInfo = await PackageInfo.fromPlatform();
    final current = '${packageInfo.version}+${packageInfo.buildNumber}';
    debugPrint('Current version: $current');

    final uri = Uri.https(
      'api.github.com',
      '/repos/$owner/$repo/releases/latest',
    );
    debugPrint('Fetching release info from: $uri');
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    debugPrint('Response status: ${response.statusCode}');
    if (response.statusCode == 404) {
      debugPrint(
        'Error: Repo not found or private (404). Make sure the repo is public or a release exists.',
      );
      throw Exception(
        'Repository not found or private. Check if repo is public.',
      );
    }

    if (response.statusCode != 200) {
      debugPrint('Error fetching release info: ${response.body}');
      throw Exception(
        'Unable to fetch release info (Status: ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tag = (data['tag_name'] as String?)?.trim() ?? '';
    final latest = tag.startsWith('v') ? tag.substring(1) : tag;
    debugPrint('Latest version tag: $tag (parsed: $latest)');
    final body = data['body'] as String?;

    final assets = (data['assets'] as List<dynamic>? ?? []);
    final asset = assets.cast<Map<String, dynamic>?>().firstWhere(
      (a) => (a?['name'] as String? ?? '').endsWith('.apk'),
      orElse: () => null,
    );
    final downloadUrl =
        asset?['browser_download_url'] as String? ??
        (data['assets_url'] as String? ?? '');
    debugPrint('Download URL: $downloadUrl');

    final hasUpdate = _isNewer(latest, current);
    debugPrint('Has update: $hasUpdate');

    return UpdateInfo(
      currentVersion: current,
      latestVersion: latest.isEmpty ? current : latest,
      hasUpdate: hasUpdate,
      downloadUrl: downloadUrl,
      releaseNotes: body,
    );
  }

  bool _isNewer(String latest, String current) {
    debugPrint('Comparing versions: latest=$latest, current=$current');
    if (latest.isEmpty) return false;
    final latestParts = latest.split('+');
    final currentParts = current.split('+');

    final latestVer = latestParts.first.split('.');
    final currentVer = currentParts.first.split('.');

    for (var i = 0; i < 3; i++) {
      final l = i < latestVer.length ? int.tryParse(latestVer[i]) ?? 0 : 0;
      final c = i < currentVer.length ? int.tryParse(currentVer[i]) ?? 0 : 0;
      if (l > c) {
        debugPrint('Newer major/minor/patch: $l > $c');
        return true;
      }
      if (l < c) return false;
    }

    if (latestParts.length > 1 && currentParts.length > 1) {
      final lBuild = int.tryParse(latestParts[1]) ?? 0;
      final cBuild = int.tryParse(currentParts[1]) ?? 0;
      if (lBuild > cBuild) {
        debugPrint('Newer build number: $lBuild > $cBuild');
        return true;
      }
    }

    return false;
  }
}
