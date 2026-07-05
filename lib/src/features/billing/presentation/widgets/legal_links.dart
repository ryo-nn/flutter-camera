import 'package:flutter/material.dart';
import 'package:flutter_camera/src/features/billing/data/billing_config_repository.dart';
import 'package:url_launcher/url_launcher.dart';

/// S-10 法定表記リンク行(design.md 画面設計・UIフロー章「S-10」
/// 「⑥法定表記リンク行」準拠。「利用規約」「プライバシーポリシー」
/// 「特定商取引法に基づく表記」を外部ブラウザで開く)。
///
/// リンク先URLは [BillingLegalLinks]([billing_config_repository.dart] 参照)から
/// 取得する。未設定(null)のリンクは表示しない。
///
/// NOTE(coreChangeRequests参照): `url_launcher` パッケージが pubspec.yaml に
/// 未追加のため、統合フェーズでの追加が必要。
class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key, required this.links});

  final BillingLegalLinks links;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String?)>[
      ('利用規約', links.termsUrl),
      ('プライバシーポリシー', links.privacyUrl),
      ('特定商取引法に基づく表記', links.tokushoUrl),
    ];
    final visible = entries.where((e) => e.$2 != null).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (final entry in visible)
          TextButton(
            onPressed: () => _open(entry.$2!),
            child: Text(entry.$1),
          ),
      ],
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
