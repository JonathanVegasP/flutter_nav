extension MatchMap on Match {
  Map<String, String> toParams(List<String> params) {
    final length = params.length;

    return {for (var i = 0; i < length; i++) params[i]: this[i + 1]!};
  }
}
