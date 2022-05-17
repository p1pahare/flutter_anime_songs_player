class ApiResponse {
  ApiResponse(
      {required this.status, required this.message, this.data, this.extraData});
  late final bool status;
  late final String message;
  late final dynamic data;
  late final dynamic extraData;

  ApiResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'];
    extraData = json['extra_data'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data;
    _data['extra_data'] = extraData;
    return _data;
  }
}
