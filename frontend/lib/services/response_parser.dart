class ResponseParser {
  static String sanitize(String rawResponse) {
    if (rawResponse.isEmpty) return "No response available.";
    
    String cleaned = rawResponse.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    if (cleaned.length > 500) {
      return "${cleaned.substring(0, 497)}...";
    }

    return cleaned;
  }
}
