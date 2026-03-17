class KnowledgeSourceModel {
  String? contentId;
  String? documentContent;
  String? sourceFile;
  String? category;
  String? createDate;
  String? status;
  String? role;

  KnowledgeSourceModel({
    this.contentId,
    this.documentContent,
    this.sourceFile,
    this.category,
    this.createDate,
    this.status,
    this.role,
  });

  KnowledgeSourceModel.fromJson(Map<String, dynamic> json) {
    contentId = json['CONTENT_ID'];
    documentContent = json['DOCUMENT_CONTENT'];
    sourceFile = json['SOURCE_FILE'];
    category = json['CATEGORY'];
    createDate = json['CREATE_DATE'];
    status = json['STATUS'];
    role = json['ROLE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CONTENT_ID'] = contentId;
    data['DOCUMENT_CONTENT'] = documentContent;
    data['SOURCE_FILE'] = sourceFile;
    data['CATEGORY'] = category;
    data['CREATE_DATE'] = createDate;
    data['STATUS'] = status;
    data['ROLE'] = role;
    return data;
  }
}
