class NavData {
  final String path;
  final String url;
  final Map<String, String> pathParams;
  final Map<String, String> query;
  final Map<String, List<String>> queries;
  final Object? extra;
  final List<NavData> children;

  NavData({required Uri uri, required this.pathParams, this.extra})
      : path = uri.path,
        url = uri.toString(),
        query = uri.queryParameters,
        queries = uri.queryParametersAll,
        children = [];
}
