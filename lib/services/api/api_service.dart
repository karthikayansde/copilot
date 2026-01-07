import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/snack_bar_widget.dart';
import 'endpoints.dart';

/// # ApiService Return Structure

/// - `code`: An integer representing the outcome.
///   - For **success** and **API-specific errors (4xx, 5xx)**, this will be the HTTP status code.
///   - For **client-side errors**, this will be a custom integer code (see below).
/// - `message`: A user-friendly string describing the outcome.
/// - `data`: The decoded JSON response body (Map or List), or an empty Map `{}` if no data or an error occurred.

enum ApiMethod { get, post, put, delete, patch }

enum ApiCode {
  unexpected0,
  requestTimeout1,
  invalidResponseFormat2,
  networkError3,
  success200,
  error400,
  unauthorized401,
  notFound404,
  conflict409,
}

class ApiErrorConfig {
  final String title;
  final String message;
  final ContentType contentType;

  ApiErrorConfig({
    required this.title,
    required this.message,
    required this.contentType,
  });
}

final Map<ApiCode, ApiErrorConfig> apiResponseConfig = {
  ApiCode.unexpected0: ApiErrorConfig(
    title: "Unexpected Error",
    message: "An unexpected error occurred. Please try again later.",
    contentType: ContentType.failure,
  ),
  ApiCode.requestTimeout1: ApiErrorConfig(
    title: "Request Timed Out",
    message:
        "The server took too long to respond. Please check your connection.",
    contentType: ContentType.failure,
  ),
  ApiCode.invalidResponseFormat2: ApiErrorConfig(
    title: "Invalid Response",
    message: "The server returned an unexpected response format.",
    contentType: ContentType.failure,
  ),
  ApiCode.networkError3: ApiErrorConfig(
    title: "Network Error",
    message:
        "Unable to connect to the server. Please check your internet connection.",
    contentType: ContentType.failure,
  ),
  ApiCode.success200: ApiErrorConfig(
    title: "Success",
    message: "Your request completed successfully.",
    contentType: ContentType.success,
  ),
  ApiCode.error400: ApiErrorConfig(
    title: "Invalid",
    message: "Invalid request. Please check your input and try again.",
    contentType: ContentType.warning,
  ),
  ApiCode.unauthorized401: ApiErrorConfig(
    title: "Unauthorized",
    message: "You are not authorized. Please log in again.",
    contentType: ContentType.failure,
  ),
  ApiCode.notFound404: ApiErrorConfig(
    title: "Not Found",
    message: "The requested resource could not be found.",
    contentType: ContentType.warning,
  ),
  ApiCode.conflict409: ApiErrorConfig(
    title: "Conflict",
    message: "There is a conflict with your request. Please try again.",
    contentType: ContentType.warning,
  ),
};

class ApiResponse {
  final int code;
  final String message;
  final dynamic data;

  ApiResponse({required this.code, required this.message, required this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message, 'data': data};
  }

  @override
  String toString() {
    return 'ApiResponse(code: $code, message: "$message", data: $data)';
  }
}

ApiErrorConfig apiErrorConfigDefault = ApiErrorConfig(
  title: "Error",
  message: "Something went wrong",
  contentType: ContentType.failure,
);

class ApiService {
  // Singleton pattern for easy access throughout the app
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Future<ApiResponse> request({
    required ApiMethod method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool customUrl = false,
    bool useFormData = false,
  }) async {
    final Uri uri = Uri.parse('${customUrl?"":Endpoints.baseUrl}$endpoint');

    // Combine common headers with any request-specific headers
    final Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Content-Type': useFormData 
          ? 'application/x-www-form-urlencoded'
          : 'application/json',
      // ...{
      //   'Authorization': 'Bearer ${await KeycloakAuthService().getAccessToken()}',
      // },
      ...(headers ?? {}),
    };

    http.Response response;
    try {
      switch (method) {
        case ApiMethod.get:
          (requestHeaders);
          response = await http
              .get(uri, headers: requestHeaders)
              .timeout(
                Duration(seconds: 30),
                onTimeout: () => _createTimeoutResponse(),
              );
          break;
        case ApiMethod.post:
          response = await http
              .post(uri, 
                headers: requestHeaders, 
                body: useFormData
                    ? body?.map((key, value) => MapEntry(key, value.toString()))
                    : jsonEncode(body ?? {}));
              // .timeout(
              //   Duration(seconds: 30),
              //   onTimeout: () => _createTimeoutResponse(),
              // );
          break;
        case ApiMethod.put:
          response = await http
              .put(uri, 
                headers: requestHeaders, 
                body: useFormData
                    ? body?.map((key, value) => MapEntry(key, value.toString()))
                    : jsonEncode(body ?? {}))
              .timeout(
                Duration(seconds: 30),
                onTimeout: () => _createTimeoutResponse(),
              );
          break;
        case ApiMethod.delete:
          response = await http
              .delete(
                uri,
                headers: requestHeaders,
                body: useFormData
                    ? body?.map((key, value) => MapEntry(key, value.toString()))
                    : jsonEncode(body ?? {}),
              )
              .timeout(
                Duration(seconds: 30),
                onTimeout: () => _createTimeoutResponse(),
              );
          break;
        case ApiMethod.patch:
          response = await http
              .patch(uri, 
                headers: requestHeaders, 
                body: useFormData
                    ? body?.map((key, value) => MapEntry(key, value.toString()))
                    : jsonEncode(body ?? {}))
              .timeout(
                Duration(seconds: 30),
                onTimeout: () => _createTimeoutResponse(),
              );
          break;
      }
      return _handleResponse(response);
    } on http.ClientException {
      // Catches network-related errors (e.g., host lookup failed, connection refused)
      // debugPrint('HTTP Client Error for $endpoint: $e');
      return ApiResponse(
        code: ApiCode.networkError3.index,
        message: "Network error: Please check your internet connection.",
        data: {},
      );
    } catch (e) {
      // Catches any other unexpected errors during the request process
      // debugPrint('Unhandled API Error for $endpoint: $e');
      return ApiResponse(
        code: ApiCode.unexpected0.index,
        message: "An unexpected error occurred: $e",
        data: {},
      );
    }
  }

  /// Multipart request for file uploads with form data
  Future<ApiResponse> multipartRequest({
    required String endpoint,
    required Map<String, String> fields,
    List<http.MultipartFile>? files,
    Map<String, String>? headers,
    bool customUrl = false,
  }) async {
    final Uri uri = Uri.parse('${customUrl?"":Endpoints.baseUrl}$endpoint');
    
    var request = http.MultipartRequest('POST', uri);
    
    // Add headers
    request.headers.addAll({
      'Accept': 'application/json',
      // ...{
      //   'Authorization': 'Bearer ${await KeycloakAuthService().getAccessToken()}',
      // },
      ...(headers ?? {}),
    });
    
    // Add form fields
    request.fields.addAll(fields);
    
    // Add files if any
    if (files != null) {
      request.files.addAll(files);
    }
    
    try {
      var streamedResponse = await request.send().timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );
      var response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on http.ClientException {
      return ApiResponse(
        code: ApiCode.networkError3.index,
        message: "Network error: Please check your internet connection.",
        data: {},
      );
    } catch (e) {
      if (e.toString().contains('timeout')) {
        return ApiResponse(
          code: ApiCode.requestTimeout1.index,
          message: "The connection has timed out.",
          data: {},
        );
      }
      return ApiResponse(
        code: ApiCode.unexpected0.index,
        message: "An unexpected error occurred: $e",
        data: {},
      );
    }
  }

  http.Response _createTimeoutResponse() {
    return http.Response(
      jsonEncode({"message": "The connection has timed out."}),
      408, // HTTP 408 Request Timeout status
      headers: {'Content-Type': 'application/json'},
    );
  }

  ApiResponse _handleResponse(http.Response response) {
    dynamic decodedBody;
    // Attempt to decode the response body first
    try {
      if (response.body.isNotEmpty) {
        decodedBody = jsonDecode(response.body);
      } else {
        decodedBody = {}; // Treat empty body as an empty map
      }
    } catch (e) {
      // JSON decode error (response body is not valid JSON)
      // debugPrint('JSON Decode Error for status ${response.statusCode}: $e');
      return ApiResponse(
        code: ApiCode.invalidResponseFormat2.index,
        message: "Invalid response format from server.",
        data: {},
      );
    }

    // Determine the outcome based on HTTP status code
    if (response.statusCode >= 200 && response.statusCode < 300 || response.statusCode == 304) {
      // Success (2xx status codes)
      return ApiResponse(
        code: ApiCode.success200.index,
        message: "success",
        data: decodedBody,
      );
    } else if (response.statusCode == 408) {
      // Request Timeout (HTTP 408) - mapped to custom code 1
      String message =
          (decodedBody is Map && decodedBody.containsKey('message'))
          ? decodedBody['message']
          : 'The connection has timed out.';
      return ApiResponse(
        code: ApiCode.requestTimeout1.index,
        message: message,
        data: {},
      );
    } else if (response.statusCode == 401) {
      // Unauthorized (HTTP 401)
      String message =
          (decodedBody is Map && decodedBody.containsKey('message'))
          ? decodedBody['message']
          : 'Unauthorized.';
      return ApiResponse(
        code: ApiCode.unauthorized401.index,
        message: message,
        data: decodedBody,
      );
    } else if (response.statusCode == 404) {
      // Unauthorized (HTTP 401)
      String message =
          (decodedBody is Map && decodedBody.containsKey('message'))
          ? decodedBody['message']
          : 'Not Found';
      return ApiResponse(
        code: ApiCode.notFound404.index,
        message: message,
        data: decodedBody,
      );
    } else if (response.statusCode == 409) {
      // Unauthorized (HTTP 401)
      String message =
          (decodedBody is Map && decodedBody.containsKey('message'))
          ? decodedBody['message']
          : 'Conflict';
      return ApiResponse(
        code: ApiCode.conflict409.index,
        message: message,
        data: decodedBody,
      );
    } else {
      // Other non-2xx error responses (4xx, 5xx)
      String message =
          (decodedBody is Map && decodedBody.containsKey('message'))
          ? decodedBody['message']
          : response.reasonPhrase ?? 'An error occurred'; // Fallback message

      // debugPrint('API Error - Status: ${response.statusCode}, Body: ${response.body}');
      return ApiResponse(
        code: ApiCode.error400.index,
        message: message,
        data: decodedBody,
      );
    }
  }

  bool showApiResponse({
    required BuildContext context,
    required ApiResponse response,

    bool useDefaultErrorConfig = false,

    Map<ApiCode, bool> codes = const {},
    Map<ApiCode, bool> customMessages = const {},
      }) {
    ApiErrorConfig config = apiErrorConfigDefault;

    if (response.code != ApiCode.success200.index && useDefaultErrorConfig) {
      SnackBarWidget.show(
        context,
        title: config.title,
        message: config.message,
        contentType: config.contentType,
      );
      return false;
    }

    for (var entry in codes.entries) {
      if (entry.value) {
        if(response.code == entry.key.index){
          config = apiResponseConfig[entry.key] ?? apiErrorConfigDefault;
          String message = customMessages[entry.key] == true ? response.data['message'] : config.message;
          SnackBarWidget.show(
            context,
            title: config.title,
            message: message,
            contentType: config.contentType,
          );
          if (entry.key == ApiCode.success200) {
            return true;
          }
          return false;
        }
      }
    }

    if (response.code == ApiCode.success200.index) {
      return true;
    }

    // Show default snackbar if code is not 200 and not in the map
    SnackBarWidget.showError(
      context,
    );
    return false;
  }
}
