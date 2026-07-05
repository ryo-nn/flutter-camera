// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'functions_post_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(postRepository)
final postRepositoryProvider = PostRepositoryProvider._();

final class PostRepositoryProvider
    extends $FunctionalProvider<PostRepository, PostRepository, PostRepository>
    with $Provider<PostRepository> {
  PostRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postRepositoryHash();

  @$internal
  @override
  $ProviderElement<PostRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostRepository create(Ref ref) {
    return postRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostRepository>(value),
    );
  }
}

String _$postRepositoryHash() => r'0889712f9fde4a9b6ccffe511c9094ea668a45fa';

/// 投稿後のSNSごとステータス監視(design.md アーキテクチャ章
/// `postStatusProvider`・family(postId) 準拠)。

@ProviderFor(postStatus)
final postStatusProvider = PostStatusFamily._();

/// 投稿後のSNSごとステータス監視(design.md アーキテクチャ章
/// `postStatusProvider`・family(postId) 準拠)。

final class PostStatusProvider
    extends $FunctionalProvider<AsyncValue<Post>, Post, Stream<Post>>
    with $FutureModifier<Post>, $StreamProvider<Post> {
  /// 投稿後のSNSごとステータス監視(design.md アーキテクチャ章
  /// `postStatusProvider`・family(postId) 準拠)。
  PostStatusProvider._({
    required PostStatusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postStatusHash();

  @override
  String toString() {
    return r'postStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Post> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Post> create(Ref ref) {
    final argument = this.argument as String;
    return postStatus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postStatusHash() => r'd4cae9e6f1230973fd2b8ef0e651a686ef43eef2';

/// 投稿後のSNSごとステータス監視(design.md アーキテクチャ章
/// `postStatusProvider`・family(postId) 準拠)。

final class PostStatusFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Post>, String> {
  PostStatusFamily._()
    : super(
        retry: null,
        name: r'postStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 投稿後のSNSごとステータス監視(design.md アーキテクチャ章
  /// `postStatusProvider`・family(postId) 準拠)。

  PostStatusProvider call(String postId) =>
      PostStatusProvider._(argument: postId, from: this);

  @override
  String toString() => r'postStatusProvider';
}
