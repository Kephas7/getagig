import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/organizer/data/datasources/organizer_datasource.dart';
import 'package:getagig/features/organizer/data/datasources/remote/organizer_remote_datasource.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/domain/repositories/organizer_repository.dart';
import 'package:getagig/core/error/failures.dart';

final organizerRepositoryProvider = Provider<IOrganizerRepository>((ref) {
  final remoteDatasource = ref.read(organizerRemoteDataSourceProvider);
  return OrganizerRepository(remoteDataSource: remoteDatasource);
});

class OrganizerRepository implements IOrganizerRepository {
  final IOrganizerRemoteDataSource remoteDataSource;

  OrganizerRepository({required this.remoteDataSource});

  @override
  Future<Either<Failure, OrganizerEntity>> createProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await remoteDataSource.createProfile(data);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to create profile'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> getProfile() async {
    try {
      final model = await remoteDataSource.getProfile();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to fetch profile'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> getProfileById(String id) async {
    try {
      final model = await remoteDataSource.getProfileById(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to fetch profile'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await remoteDataSource.updateProfile(data);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to update profile'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile() async {
    try {
      await remoteDataSource.deleteProfile();
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to delete profile'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> uploadProfilePicture(
    File file,
  ) async {
    try {
      final model = await remoteDataSource.uploadProfilePicture(file);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(
          e,
          fallback: 'Failed to upload profile picture',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> addPhotos(List<File> files) async {
    try {
      final model = await remoteDataSource.addPhotos(files);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to add photos'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> removePhoto(String photoUrl) async {
    try {
      final model = await remoteDataSource.removePhoto(photoUrl);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to remove photo'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> addVideos(List<File> files) async {
    try {
      final model = await remoteDataSource.addVideos(files);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to add videos'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> removeVideo(String videoUrl) async {
    try {
      final model = await remoteDataSource.removeVideo(videoUrl);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to remove video'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> addVerificationDocuments(
    List<File> files,
  ) async {
    try {
      final model = await remoteDataSource.addVerificationDocuments(files);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to add documents'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> removeVerificationDocument(
    String documentUrl,
  ) async {
    try {
      final model = await remoteDataSource.removeVerificationDocument(
        documentUrl,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to remove document'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> updateActiveStatus(
    bool isActive,
  ) async {
    try {
      final model = await remoteDataSource.updateActiveStatus(isActive);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(e, fallback: 'Failed to update status'),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerEntity>> requestVerification() async {
    try {
      final model = await remoteDataSource.requestVerification();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure.fromDioException(
          e,
          fallback: 'Failed to request verification',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
