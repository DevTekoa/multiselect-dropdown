/// Extension on [String] to provide additional text normalization functionality.
extension StringExtension on String {
  /// Normalizes the string by removing diacritics and converting it to lowercase and trimming whitespace.
  /// For example, 'Áéíóú' becomes 'aeiou'.
  String normalizeText() {
    const withDiacritics = 'áàâãäåéèêëíìîïóòôõöúùûüçñýÿÁÀÂÃÄÅÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑÝ';
    const withoutDiacritics = 'aaaaaaeeeeiiiiooooouuuucnyyAAAAAAEEEEIIIIOOOOOUUUUCNY';

    var result = this;
    for (var i = 0; i < withDiacritics.length; i++) {
      result = result.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }

    return result.toLowerCase().trim();
  }
}
