enum ObjectLabel {
  moldy;

  @override
  String toString() {
    switch (this) {
      case ObjectLabel.moldy:
        return 'Moldy';
    }
  }

  static ObjectLabel from(num value) {
    switch (value) {
      case 1:
        return ObjectLabel.moldy;
      default:
        throw Exception('Unknown ObjectLabel value: $value');
    }
  }
}
