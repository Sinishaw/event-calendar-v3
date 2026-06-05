class CompanyProfile {
  //region Constructor
  CompanyProfile(
      {
      // this.id,
      // this.documentId,
      // this.company,
      // this.name,
      this.category,
      this.description,
      this.established,
      this.address,
      this.phone,
      this.pobox,
      this.website,
      this.email,
      this.vUrl,
      this.wUrl,
      this.mission,
      this.vision,
      this.iUrl,
      // this.st,
      // this.stString,
      this.facebook,
      this.twitter,
      this.youtube,
      this.instagram});

  //endregion

  //region Fields
  DateTime? established;
  String? /*id, documentId, company, name,*/ category, description, address, phone, pobox, website;
  String? email, vUrl, wUrl, mission, vision, iUrl, /*st, stString,*/ facebook, twitter, youtube, instagram;

  //endregion

  //region JSON

  Map<String, dynamic> toJson() => {
        'established': established != null ? established.toString() : "",
        // 'id': id != null ? id : "",
        // 'documentId': documentId != null ? documentId : "",
        // 'company': company != null ? company : "",
        // 'name': name != null ? name : "",
        'category': category ?? "",
        'description': description ?? "",
        'address': address ?? "",
        'phone': phone ?? "",
        'pobox': pobox ?? "",
        'website': website ?? "",
        'email': email ?? "",
        'vUrl': vUrl ?? "",
        'wUrl': wUrl ?? "",
        'mission': mission ?? "",
        'vision': vision ?? "",
        'iUrl': iUrl ?? "",
        // 'st': st != null ? st : "",
        // 'stString': stString != null ? stString : "",
        'facebook': facebook ?? "",
        'twitter': twitter ?? "",
        'youtube': youtube ?? "",
        'instagram': instagram ?? "",
      };

  CompanyProfile.fromJson(Map<String, dynamic>? json)
      : established = json != null ? DateTime.parse(json['established']) : null,
        // id = json != null ? json['id'] : null,
        // documentId = json != null ? json['documentId'] : null,
        // company = json != null ? json['company'] : null,
        // name = json != null ? json['name'] : null,
        category = json != null ? json['category'] : null,
        description = json != null ? json['description'] : null,
        address = json != null ? json['address'] : null,
        phone = json != null ? json['phone'] : false as String?,
        pobox = json != null ? json['pobox'] : null,
        website = json != null ? json['website'] : false as String?,
        email = json != null ? json['email'] : false as String?,
        vUrl = json != null ? json['vUrl'] : true as String?,
        wUrl = json != null ? json['wUrl'] : null,
        mission = json != null ? json['mission'] : null,
        vision = json != null ? json['vision'] : null,
        iUrl = json != null ? json['iUrl'] : null,
        // st = json != null ? json['st'] : null,
        // stString = json != null ? json['stString'] : null,
        facebook = json != null ? json['facebook'] : null,
        twitter = json != null ? json['twitter'] : null,
        youtube = json != null ? json['youtube'] : null,
        instagram = json != null ? json['instagram'] : null;
//endregion
}
