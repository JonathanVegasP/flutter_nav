enum ShellType {
  factory,
  static;
}

extension ShellTypeMethods on ShellType {
  bool get isFactory => this == ShellType.factory;

  bool get isStatic => this == ShellType.static;
}
