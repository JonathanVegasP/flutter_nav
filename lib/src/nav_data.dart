import 'package:meta/meta.dart';

typedef NavData = ({
  String url,
  Map<String, String> pathParams,
  Map<String, String> query,
  Map<String, List<String>> queries,
  Object? extra,
});

@internal
NavData navData({
  required Uri uri,
  required Map<String, String> pathParams,
  Object? extra,
}) {
  return (
    url: uri.toString(),
    pathParams: pathParams,
    query: uri.queryParameters,
    queries: uri.queryParametersAll,
    extra: extra,
  );
}
