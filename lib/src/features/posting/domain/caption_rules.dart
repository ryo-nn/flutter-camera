/// S-07 キャプション入力のバリデーション・文字数カウントルール(純Dart・
/// Flutter/Firebase SDK非依存)。design.md UIフロー章 S-07節 +
/// quota章「X投稿本文のURL検出・ブロック」「クライアント側バリデーション」節 準拠。
///
/// twitter-textの公式Dart実装は存在しないため、quota章が許容する2案
/// 「(a) 互換移植パッケージ / (b) サーバーより厳しめ(false positive許容)に
/// 倒した自前サブセット」のうち (b) を採用する(選定はdesign.md自身が
/// openQuestions扱いとしているため、依存パッケージを増やさない方針で本実装を選択。
/// notes参照)。最終判定は常にサーバー側(`snsPublishPost`のtwitter-text)が正であり、
/// 本クラスはUXのための事前チェックに過ぎない。
abstract final class CaptionRules {
  const CaptionRules._();

  /// Instagramキャプション上限(Graph API仕様。UI章 S-07節準拠)。
  static const int instagramMaxLength = 2200;
  static const int instagramMaxHashtags = 30;
  static const int instagramMaxMentions = 20;

  /// X加重文字数上限(twitter-text互換カウント。UI章 S-07節準拠)。
  static const int xMaxWeightedLength = 280;

  static const int _xUrlWeight = 23;

  static final RegExp _schemeUrlPattern = RegExp(
    r'https?://\S+',
    caseSensitive: false,
  );

  /// スキームなしのドメイン風文字列(例: example.com、example.co.jp/path)。
  /// twitter-textの厳密なTLD一覧の代わりに、ラベルがドット区切りで2つ以上続く
  /// 文字列を一律検出する(false positive許容のサブセット)。
  static final RegExp _domainLikePattern = RegExp(
    r'\b[a-zA-Z0-9][a-zA-Z0-9-]*(?:\.[a-zA-Z0-9][a-zA-Z0-9-]*)+(?:/\S*)?',
  );

  static final RegExp _hashtagPattern = RegExp(r'(?:^|\s)#[^\s#]+');
  static final RegExp _mentionPattern = RegExp(r'(?:^|\s)@[^\s@]+');

  /// キャプション中の「URLらしき文字列」の(start, end)範囲を検出する
  /// (スキーム付きURLを優先し、重複するドメイン風検出は除外する)。
  static List<(int, int)> _urlRanges(String caption) {
    final ranges = <(int, int)>[
      for (final m in _schemeUrlPattern.allMatches(caption)) (m.start, m.end),
    ];
    for (final m in _domainLikePattern.allMatches(caption)) {
      final overlaps = ranges.any((r) => m.start < r.$2 && m.end > r.$1);
      if (!overlaps) ranges.add((m.start, m.end));
    }
    ranges.sort((a, b) => a.$1.compareTo(b.$1));
    return ranges;
  }

  /// キャプション中の「URLらしき文字列」を検出する
  /// (Xターゲット選択時のURL検出ブロックバリデーションに使用)。
  static List<String> detectUrls(String caption) => [
    for (final r in _urlRanges(caption)) caption.substring(r.$1, r.$2),
  ];

  /// Xターゲットが選択されている投稿でのみ適用する
  /// (Instagramのみの投稿はブロックしない。quota章準拠)。
  static bool containsUrl(String caption) => detectUrls(caption).isNotEmpty;

  /// X投稿の加重文字数。日本語等の全角相当文字・絵文字は2、URLは実際の長さに
  /// 関わらず一律23として計上する(twitter-text互換の自前サブセット。
  /// quota章「X投稿本文のURL検出・ブロック」節準拠)。
  static int xWeightedLength(String caption) {
    if (caption.isEmpty) return 0;
    final ranges = _urlRanges(caption);
    var weight = ranges.length * _xUrlWeight;

    final iterator = caption.runes.iterator;
    while (iterator.moveNext()) {
      final index = iterator.rawIndex;
      final inUrl = ranges.any((r) => index >= r.$1 && index < r.$2);
      if (inUrl) continue;
      weight += _isWideOrEmoji(iterator.current) ? 2 : 1;
    }
    return weight;
  }

  /// CJK統合漢字・かな・ハングル・全角記号等の代表的なレンジ + 絵文字レンジ。
  /// 公式twitter-text実装の完全互換ではなく、「日本語等CJK=2・絵文字=2」を
  /// 満たす実用上のサブセット。
  static bool _isWideOrEmoji(int rune) {
    return (rune >= 0x1100 && rune <= 0x115F) || // ハングル字母
        (rune >= 0x2E80 && rune <= 0x30FF) || // CJK部首・記号・かな・カタカナ
        (rune >= 0x3100 && rune <= 0x33FF) || // 注音・ハングル互換・CJK互換記号
        (rune >= 0x3400 && rune <= 0x4DBF) || // CJK拡張A
        (rune >= 0x4E00 && rune <= 0x9FFF) || // CJK統合漢字
        (rune >= 0xA960 && rune <= 0xA97F) || // ハングル拡張A
        (rune >= 0xAC00 && rune <= 0xD7A3) || // ハングル音節
        (rune >= 0xF900 && rune <= 0xFAFF) || // CJK互換漢字
        (rune >= 0xFF00 && rune <= 0xFF60) || // 全角記号
        (rune >= 0xFFE0 && rune <= 0xFFE6) ||
        (rune >= 0x1F300 && rune <= 0x1FAFF) || // 絵文字全般
        (rune >= 0x20000 && rune <= 0x3FFFD); // CJK拡張B以降
  }

  static int instagramHashtagCount(String caption) =>
      _hashtagPattern.allMatches(caption).length;

  static int instagramMentionCount(String caption) =>
      _mentionPattern.allMatches(caption).length;
}
