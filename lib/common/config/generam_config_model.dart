import 'terms_and_policies_model.dart';

class GeneralConfig {
  GeneralConfig({this.termsAndPolicies});

  TermsAndPolicies? termsAndPolicies;

  Map<String, dynamic> toJson() => {
        'termsAndPolicies': termsAndPolicies ?? "",
      };

  GeneralConfig.fromJson(Map<String, dynamic>? json)
      : termsAndPolicies = json != null ? TermsAndPolicies.fromJson(json['termsAndPolicies']) : null;
}
