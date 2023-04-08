const _pattern = r':(\w+)';

extension PathString on String {
  RegExp toRegExp(List<String> params) {
    final regexp = RegExp(_pattern);
    final matches = regexp.allMatches(this);
    final buffer = StringBuffer('^');
    var start = 0;

    for (final match in matches) {
      final s = match.start;

      if (s > start) {
        buffer.write(RegExp.escape(substring(start, s)));
      }

      final param = match[1]!;

      params.add(param);

      buffer.write(r'([^/]+)');

      start = match.end;
    }

    if (length > start) {
      buffer.write(RegExp.escape(substring(start)));
    }

    if (this != '/') {
      buffer.write(r'(?=/|$)');
    }

    return RegExp(buffer.toString(), caseSensitive: false);
  }

  String toPath(Map<String, String> params) {
    final regexp = RegExp(_pattern);
    final matches = regexp.allMatches(this);
    final buffer = StringBuffer();
    var start = 0;

    for (final match in matches) {
      final s = match.start;

      if (s > start) {
        buffer.write(substring(start, s));
      }

      final param = match[1]!;

      buffer.write(params[param]);

      start = match.end;
    }

    if (length > start) {
      buffer.write(substring(start));
    }

    return buffer.toString();
  }
}
