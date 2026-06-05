class TermsAndPolicies {
  TermsAndPolicies({
    this.version,
    this.terms,
    this.webUrl,
    this.appVersionNumber,
    this.appVersionName,
    this.appVersionSummary,
  });
  String? version, terms, webUrl, appVersionNumber, appVersionName, appVersionSummary;
  Map<String, dynamic> toJson() => {
        'version': version != null ? version.toString() : "",
        'terms': terms ?? "",
        'description': webUrl ?? "",
        'appVersionNumber': appVersionNumber ?? "",
        'appVersionName': appVersionName ?? "",
        'appVersionSummary': appVersionSummary ?? "",
      };

  TermsAndPolicies.fromJson(Map<String, dynamic>? json)
      : version = (json != null && json['version'] != null) ? json['version'] : "",
        terms = (json != null && json['terms'] != null) ? json['terms'] : "",
        webUrl = (json != null && json['webUrl'] != null) ? json['webUrl'] : "",
        appVersionNumber = (json != null && json['appVersionNumber'] != null) ? json['appVersionNumber'] : "",
        appVersionName = (json != null && json['appVersionName'] != null) ? json['appVersionName'] : "",
        appVersionSummary = (json != null && json['appVersionSummary'] != null) ? json['appVersionSummary'] : "";
}
