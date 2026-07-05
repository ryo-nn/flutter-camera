import 'package:flutter/material.dart';

/// 実行系プライマリボタン(投稿する/連携する/作成する/保存する 等)。
/// `isLoading` 中はボタン内スピナー表示+操作無効化する
/// (design.md UIフロー章「共通UI状態の設計方針」準拠)。
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
