import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:getagig/core/error/failures.dart';
import '../entities/organizer_entity.dart';

abstract interface class IOrganizerRepository {
  Future<Either<Failure, OrganizerEntity>> createProfile(
    Map<String, dynamic> data,
  );
  
  Future<Either<Failure, OrganizerEntity>> getProfile();
  
  Future<Either<Failure, OrganizerEntity>> getProfileById(String id);
  
  Future<Either<Failure, OrganizerEntity>> updateProfile(
    Map<String, dynamic> data,
  );
  
  Future<Either<Failure, void>> deleteProfile();
  
  Future<Either<Failure, OrganizerEntity>> uploadProfilePicture(File file);
  
  Future<Either<Failure, OrganizerEntity>> addPhotos(List<File> files);
  
  Future<Either<Failure, OrganizerEntity>> removePhoto(String photoUrl);
  
  Future<Either<Failure, OrganizerEntity>> addVideos(List<File> files);
  
  Future<Either<Failure, OrganizerEntity>> removeVideo(String videoUrl);
  
  Future<Either<Failure, OrganizerEntity>> addVerificationDocuments(
    List<File> files,
  );
  
  Future<Either<Failure, OrganizerEntity>> removeVerificationDocument(
    String documentUrl,
  );
  
  Future<Either<Failure, OrganizerEntity>> updateActiveStatus(bool isActive);
}

