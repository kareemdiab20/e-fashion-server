import 'package:dartz/dartz.dart';
import 'package:efashion_flutter/components/authComponent/data/datasources/local/auth_local_data_source.dart';
import 'package:efashion_flutter/shared/error/exception.dart';
import 'package:efashion_flutter/shared/error/failure.dart';
import 'package:efashion_flutter/components/authComponent/data/datasources/remote/auth_data_source.dart';
import 'package:efashion_flutter/components/authComponent/domain/repositories/auth_repository.dart';
import 'package:efashion_flutter/components/authComponent/domain/entities/tokens.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  
  AuthRepositoryImpl(this._authRemoteDataSource, this._authLocalDataSource);

  @override
  Future<Either<Failure, Tokens>> userLogin({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login with email: $email');
      final result = await _authRemoteDataSource.userLogin(
        email: email,
        password: password,
      );
      print('Login successful, result: $result');
      _authLocalDataSource.addAuthTokens(authTokensModel: result);
      return right(result.toAuthTokens());
    } on ServerException catch (exception) {
      // طباعة الخطأ في حالة استثناء من السيرفر
      print('ServerException occurred during login: ${exception.message}');
      return left(ApiFailure(exception.message!));
    } catch (e) {
      // طباعة أي خطأ غير متوقع
      print('Unexpected error occurred during login: $e');
      return left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Tokens>> userSignUp({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      print('Attempting sign-up with email: $email');
      final result = await _authRemoteDataSource.userSignUp(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      print('Sign-up successful, result: $result');
      _authLocalDataSource.addAuthTokens(authTokensModel: result);
      return right(result.toAuthTokens());
    } on ServerException catch (exception) {
      // طباعة الخطأ في حالة استثناء من السيرفر
      print('ServerException occurred during sign-up: ${exception.message}');
      return left(ApiFailure(exception.message!));
    } catch (e) {
      // طباعة أي خطأ غير متوقع
      print('Unexpected error occurred during sign-up: $e');
      return left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<void> deleteTokens() {
    print('Deleting tokens');
    return _authLocalDataSource.deleteAuthTokens();
  }

  @override
  bool checkIfTokensExist() {
    print('Checking if tokens exist');
    return _authLocalDataSource.checkIfTokensExist();
  }

  @override
  Future<Either<Failure,String>> getAccessToken() async {
    try {
      final accessToken = _authLocalDataSource.getAccessToken();
      print('Access token retrieved: $accessToken');
      if (accessToken.isNotEmpty) {
        return right(accessToken);
      } else {
        print('Access token is empty, attempting to refresh token');
        final refreshToken = await _authLocalDataSource.getRefreshToken();
        print('Refresh token retrieved: $refreshToken');
        final newAccessToken = await _authRemoteDataSource.updateAccessToken(refreshToken: refreshToken);
        await _authLocalDataSource.updateAccessToken(accessToken: newAccessToken);
        return right(newAccessToken);
      }
    } on ServerException catch (exception) {
      print('ServerException occurred while getting access token: ${exception.message}');
      return left(ApiFailure(exception.message!));
    } catch (e) {
      print('Unexpected error occurred while getting access token: $e');
      return left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> forgetPassword({required String email}) async {
    try {
      print('Attempting to reset password for email: $email');
      final forgetPasswordRequest = await _authRemoteDataSource.forgetPassword(email: email);
      print('Password reset request successful, response: $forgetPasswordRequest');
      return right(forgetPasswordRequest);
    } on ServerException catch (exception) {
      print('ServerException occurred during forget password: ${exception.message}');
      return left(ApiFailure(exception.message!));
    } catch (e) {
      print('Unexpected error occurred during forget password: $e');
      return left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp({required String email, required String otpCode}) async {
    try {
      print('Attempting OTP verification for email: $email with OTP: $otpCode');
      final verifyOtpRequest = await _authRemoteDataSource.verifyOtp(email: email, otpCode: otpCode);
      print('OTP verification successful, response: $verifyOtpRequest');
      return right(verifyOtpRequest);
    } on ServerException catch (exception) {
      print('ServerException occurred during OTP verification: ${exception.message}');
      return left(ApiFailure(exception.message!));
    } catch (e) {
      print('Unexpected error occurred during OTP verification: $e');
      return left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({required String email, required String otpCode, required newPassword}) async {
    try {
      print('Attempting to reset password for email: $email with OTP: $otpCode');
      final resetPasswordRequest = await _authRemoteDataSource.resetPassword(email: email, otpCode: otpCode, newPassword: newPassword);
      print('Password reset successful, response: $resetPasswordRequest');
      return right(resetPasswordRequest);
    } on ServerException catch (exception) {
      print('ServerException occurred during reset password: ${exception.message}');
      return left(ApiFailure(exception.message!));
    } catch (e) {
      print('Unexpected error occurred during reset password: $e');
      return left(ApiFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> changePassword({
    required String userAccessToken,
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      print('Attempting to change password for user with access token: $userAccessToken');
      final changePasswordRequest = await _authRemoteDataSource.changePassword(
        userAccessToken: userAccessToken,
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      print('Password change successful, response: $changePasswordRequest');
      return right(changePasswordRequest);
    } on ServerException catch (exception) {
      print('ServerException occurred during change password: ${exception.message}');
      return left(ApiFailure(exception.message!));
    } catch (e) {
      print('Unexpected error occurred during change password: $e');
      return left(ApiFailure(e.toString()));
    }
  }
}
