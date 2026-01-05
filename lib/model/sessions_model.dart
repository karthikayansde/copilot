class SessionsModel {
  List<Sessions>? sessions;

  SessionsModel({this.sessions});

  SessionsModel.fromJson(Map<String, dynamic> json) {
    if (json['sessions'] != null) {
      sessions = <Sessions>[];
      json['sessions'].forEach((v) {
        sessions!.add(new Sessions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sessions != null) {
      data['sessions'] = this.sessions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Sessions {
  String? sessionId;
  String? title;
  String? updatedAt;

  Sessions({this.sessionId, this.title, this.updatedAt});

  Sessions.fromJson(Map<String, dynamic> json) {
    sessionId = json['session_id'];
    title = json['title'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['session_id'] = this.sessionId;
    data['title'] = this.title;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
