class ApiResponse {
  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });
  late final bool status;
  late final String message;
  late final dynamic data;

  ApiResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data;
    return _data;
  }
}
