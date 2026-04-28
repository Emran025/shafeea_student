import 'package:dio/dio.dart';

import 'failures.dart';


// lib/core/error/exceptions.dart

/// A base class for all custom exceptions in the application.
///
/// Implementing [Exception] allows these classes to be thrown and caught
/// as exceptions. This is the technical layer representation of an error,
/// which will be caught in the data layer (Repository) and converted into
/// a domain-layer `Failure`.
abstract class AppException implements Exception {
  final String message;
  final String? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException: $message (Code: $statusCode)';
}

/// Thrown when an error occurs during an API request.
///
/// This exception is typically thrown from a remote data source when an HTTP
/// request fails (e.g., status code 4xx or 5xx).
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});

  @override
  String toString() => 'ServerException: $message (Code: $statusCode)';
}

/// Thrown when there is an issue with the network connection.
///
/// This can be used to wrap Dart's `SocketException` or other network-related
/// errors into a more specific application exception.
class NetworkException extends AppException {
  const NetworkException({required super.message}) : super(statusCode: null);

  @override
  String toString() => 'NetworkException: $message';
}


/// Thrown when an error occurs while accessing local cache or database.
///
/// For example, if the database is not found, a table is missing, or
/// a query returns no results when one was expected.
class CacheException extends AppException {
  const CacheException({required super.message}) : super(statusCode: null);

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when data parsing (e.g., from JSON) fails.
///
/// This can be used to wrap `FormatException` or other errors that occur
/// when trying to convert raw data into data models.
class DataParsingException extends AppException {
  const DataParsingException({required super.message}) : super(statusCode: null);

  @override
  String toString() => 'DataParsingException: $message';
}

/// Thrown for any other unexpected error.
///
/// This serves as a generic fallback for exceptions that don't fit into
/// the other more specific categories.
class UnknownException extends AppException {
  const UnknownException({required super.message}) : super(statusCode: null);

  @override
  String toString() => 'UnknownException: $message';
}

void handleDioExceptions(DioException? e) {
  if (e != null) {
    String message = "Unexpected error occurred";
    String? statusCode;

    if (e.response != null && e.response?.data != null) {
      try {
        final errorData = ErrorModel.fromJson(e.response!.data);
        message = errorData.message;
        statusCode = errorData.status;
      } catch (_) {
        message = e.response?.statusMessage ?? "Server error";
        statusCode = e.response?.statusCode?.toString();
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        throw ServerException(
          message: message.isNotEmpty ? message : "Connection timeout with API server",
          statusCode: statusCode ?? "TIMEOUT",
        );
      case DioExceptionType.sendTimeout:
        throw ServerException(
          message: message.isNotEmpty ? message : "Send timeout in association with API server",
          statusCode: statusCode ?? "SEND_TIMEOUT",
        );
      case DioExceptionType.receiveTimeout:
        throw ServerException(
          message: message.isNotEmpty ? message : "Receive timeout in connection with API server",
          statusCode: statusCode ?? "RECEIVE_TIMEOUT",
        );
      case DioExceptionType.badCertificate:
        throw ServerException(
          message: message.isNotEmpty ? message : "Bad certificate with API server",
          statusCode: statusCode ?? "BAD_CERTIFICATE",
        );
      case DioExceptionType.cancel:
        throw ServerException(
          message: message.isNotEmpty ? message : "Request to API server was cancelled",
          statusCode: statusCode ?? "CANCEL",
        );
      case DioExceptionType.connectionError:
        throw ServerException(
          message: "No Internet Connection",
          statusCode: "CONNECTION_ERROR",
        );
      case DioExceptionType.unknown:
        throw ServerException(
          message: message.isNotEmpty ? message : "Unexpected error occurred",
          statusCode: statusCode ?? "UNKNOWN",
        );
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400:
            throw ServerException(message: message, statusCode: "400");
          case 401:
            throw ServerException(message: message, statusCode: "401");
          case 403:
            throw ServerException(message: message, statusCode: "403");
          case 404:
            throw ServerException(message: message, statusCode: "404");
          case 409:
            throw ServerException(message: message, statusCode: "409");
          case 422:
            throw ServerException(message: message, statusCode: "422");
          case 500:
            throw ServerException(message: "Internal Server Error", statusCode: "500");
          case 504:
            throw ServerException(message: message, statusCode: "504");
          default:
            throw ServerException(
              message: message.isNotEmpty ? message : "Oops! There was an error, please try again",
              statusCode: e.response?.statusCode?.toString(),
            );
        }
    }
  } else {
    throw const ServerException(
      message: "An unknown error occurred, please check your internet connection",
      statusCode: "0",
    );
  }
}

