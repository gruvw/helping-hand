import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:hooks_riverpod/misc.dart";

/// A transformer that can filter out and map values.
final class _MapFilterAsync<T>
    with SyncProviderTransformerMixin<AsyncValue<T>, AsyncValue<T>> {
  _MapFilterAsync(this.source, this._filter);

  @override
  final ProviderListenable<AsyncValue<T>> source;

  final bool Function(T value) _filter;

  @override
  ProviderTransformer<AsyncValue<T>, AsyncValue<T>> transform(
    ProviderTransformerContext<AsyncValue<T>, AsyncValue<T>> context,
  ) {
    // helper to convert an AsyncValue<In> to AsyncValue<Out>
    // used for errors, loading, and valid data
    AsyncValue<T> convert(AsyncValue<T> input) {
      return input.map(
        data: (d) => AsyncData<T>(d.value),
        error: (e) => AsyncError<T>(e.error, e.stackTrace),
        loading: (l) => AsyncLoading<T>(),
      );
    }

    return ProviderTransformer(
      initState: (_) {
        final current = context.sourceState.requireValue;

        if (current case AsyncData(value: final v) when _filter(v)) {
          return AsyncData<T>(v);
        } else if (current is AsyncError<T>) {
          return AsyncError<T>(current.error, current.stackTrace);
        }

        // default to loading if the first value is filtered out
        return AsyncLoading<T>();
      },
      listener: (self, previous, next) {
        if (next case AsyncData(value: final innerValue)) {
          switch (innerValue) {
            case AsyncData(value: final v):
              if (_filter(v)) {
                // wrap the converted AsyncValue back into a successful AsyncResult
                self.state = AsyncData(convert(innerValue));
              }
            case AsyncLoading() || AsyncError():
              self.state = AsyncData(convert(innerValue));
          }
        } else if (next case AsyncError(error: final e, stackTrace: final st)) {
          // the provider evaluation itself failed
          self.state = AsyncError(e, st);
        }
      },
    );
  }
}

extension FilterAsyncExtension<T> on ProviderListenable<AsyncValue<T>> {
  /// Keeps the type [T] but filters out emissions based on [filter].
  ProviderListenable<AsyncValue<T>> filterAsync(bool Function(T value) filter) {
    return _MapFilterAsync<T>(this, filter);
  }
}

extension WhereNotNullExtension<T> on ProviderListenable<AsyncValue<T?>> {
  /// Narrows the type from [T?] to [T] by filtering out null values.
  ProviderListenable<AsyncValue<T>> whereNotNull() {
    return _MapFilterAsync(
      this,
      (v) => v != null,
    ).select((v) => v.whenData((v) => v!));
  }
}
