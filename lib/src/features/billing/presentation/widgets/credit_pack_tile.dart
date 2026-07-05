import 'package:flutter/material.dart';

/// S-10 クレジットパックタイル(design.md 画面設計・UIフロー章「S-10」
/// 「③クレジットパックタイル」準拠。「X投稿10回パック」の名称は
/// UI文言としてdesign.mdに明記された固定表記であり、価格のみ
/// `StoreProduct.priceString`(呼び出し側で解決済み)を渡す)。
class CreditPackTile extends StatelessWidget {
  const CreditPackTile({
    super.key,
    required this.priceString,
    required this.isLoading,
    required this.onPressed,
  });

  final String priceString;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('X投稿10回パック'),
        subtitle: const Text('購入分は無期限でご利用いただけます'),
        trailing: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Semantics(
                label: 'X投稿10回パック、$priceString',
                button: true,
                child: ExcludeSemantics(
                  child: OutlinedButton(
                    onPressed: onPressed,
                    child: Text(priceString),
                  ),
                ),
              ),
      ),
    );
  }
}
