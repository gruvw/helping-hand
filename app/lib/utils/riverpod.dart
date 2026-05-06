import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:hooks_riverpod/misc.dart";

/// A transformer that can filter out values.
final class _WhereAsync<T>
    with SyncProviderTransformerMixin<AsyncValue<T>, AsyncValue<T>> {
  _WhereAsync(this.source, this._filter);

  @override
  final ProviderListenable<AsyncValue<T>> source;

  final bool Function(T value) _filter;

  @override
  ProviderTransformer<AsyncValue<T>, AsyncValue<T>> transform(
    ProviderTransformerContext<AsyncValue<T>, AsyncValue<T>> context,
  ) {
    return ProviderTransformer(
      initState: (_) {
        final current = context.sourceState.requireValue;

        return switch (current) {
          AsyncData(:final value) =>
            _filter(value) ? current : AsyncLoading<T>(),
          _ => current,
        };
      },
      listener: (self, previous, next) {
        if (next case AsyncData(
          value: AsyncData(value: final v),
        ) when !_filter(v)) {
          return;
        }
        self.state = next;
      },
    );
  }
}

extension WhereAsyncExtension<T> on ProviderListenable<AsyncValue<T>> {
  /// Keeps the type [T] but filters out emissions based on [filter].
  ProviderListenable<AsyncValue<T>> whereAsync(bool Function(T value) filter) {
    return _WhereAsync<T>(this, filter);
  }
}

extension WhereNotNullExtension<T> on ProviderListenable<AsyncValue<T?>> {
  /// Narrows the type from [T?] to [T] by filtering out null values.
  ProviderListenable<AsyncValue<T>> whereNotNull() {
    return whereAsync((v) => v != null).select((v) => v.whenData((v) => v!));
  }
}
