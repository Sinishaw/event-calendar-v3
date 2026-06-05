class MonthImageUrls {
  int? id;
  String? thm;
  String? dsc;
  bool? published;
  String? msUrl, tkUrl, hdUrl, thUrl, trUrl, ykUrl, mgUrl, mzUrl, gnUrl, snUrl, hmUrl, nhUrl, pgUrl;

  MonthImageUrls(
      {this.id,
      this.thm,
      this.dsc,
      this.published,
      this.msUrl,
      this.tkUrl,
      this.hdUrl,
      this.thUrl,
      this.trUrl,
      this.ykUrl,
      this.mgUrl,
      this.mzUrl,
      this.gnUrl,
      this.snUrl,
      this.hmUrl,
      this.nhUrl,
      this.pgUrl});

  MonthImageUrls.fromJson(Map<String, dynamic>? json)
      : id = json != null ? json['id'] : 0,
        thm = json != null ? json['thm'] : null,
        dsc = json != null ? json['dsc'] : null,
        published = json != null ? json['published'] : false,
        msUrl = json != null ? json['msUrl'] : null,
        tkUrl = json != null ? json['tkUrl'] : null,
        hdUrl = json != null ? json['hdUrl'] : null,
        thUrl = json != null ? json['thUrl'] : null,
        trUrl = json != null ? json['trUrl'] : null,
        ykUrl = json != null ? json['ykUrl'] : null,
        mgUrl = json != null ? json['mgUrl'] : null,
        mzUrl = json != null ? json['mzUrl'] : null,
        gnUrl = json != null ? json['gnUrl'] : null,
        snUrl = json != null ? json['snUrl'] : null,
        hmUrl = json != null ? json['hmUrl'] : null,
        nhUrl = json != null ? json['nhUrl'] : null,
        pgUrl = json != null ? json['pgUrl'] : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'thm': thm,
        'dsc': dsc,
        'published': published,
        'msUrl': msUrl,
        'tkUrl': tkUrl,
        'hdUrl': hdUrl,
        'thUrl': thUrl,
        'trUrl': trUrl,
        'ykUrl': ykUrl,
        'mgUrl': mgUrl,
        'mzUrl': mzUrl,
        'gnUrl': gnUrl,
        'snUrl': snUrl,
        'hmUrl': hmUrl,
        'nhUrl': nhUrl,
        'pgUrl': pgUrl
      };
}
