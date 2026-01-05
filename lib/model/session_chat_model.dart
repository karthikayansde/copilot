class SessionChatModel {
  String? sessionId;
  String? username;
  List<Messages>? messages;

  SessionChatModel({this.sessionId, this.username, this.messages});

  SessionChatModel.fromJson(Map<String, dynamic> json) {
    sessionId = json['session_id'];
    username = json['username'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(new Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['session_id'] = this.sessionId;
    data['username'] = this.username;
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String? role;
  String? content;
  String? createdAt;

  Messages({this.role, this.content, this.createdAt});

  Messages.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    content = json['content'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role'] = this.role;
    data['content'] = this.content;
    data['created_at'] = this.createdAt;
    return data;
  }
}
