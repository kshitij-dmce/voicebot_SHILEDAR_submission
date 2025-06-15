class UserConfig {
  static String language = 'en'; // default: English

  static void setLanguage(String langCode) {
    language = langCode;
  }

  static String getLanguage() {
    return language;
  }
}
