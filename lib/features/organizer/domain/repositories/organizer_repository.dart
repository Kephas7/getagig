import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/organizer_entity.dart';

abstract interface class IOrganizerRepository {
  Future<Either<Failures, OrganizerEntity>> createProfile(
    Map<String, dynamic> data,
  );
  
  Future<Either<Failures, OrganizerEntity>> getProfile();
  
  Future<Either<Failures, OrganizerEntity>> getProfileById(String id);
  
  Future<Either<Failures, OrganizerEntity>> updateProfile(
    Map<String, dynamic> data,
  );
  
  Future<Either<Failures, void>> deleteProfile();
  
  Future<Either<Failures, OrganizerEntity>> uploadProfilePicture(File file);
  
  Future<Either<Failures, OrganizerEntity>> addPhotos(List<File> files);
  
  Future<Either<Failures, OrganizerEntity>> removePhoto(String photoUrl);
  
  Future<Either<Failures, OrganizerEntity>> addVideos(List<File> files);
  
  Future<Either<Failures, OrganizerEntity>> removeVideo(String videoUrl);
  
  Future<Either<Failures, OrganizerEntity>> addVerificationDocuments(
    List<File> files,
  );
  
  Future<Either<Failures, OrganizerEntity>> removeVerificationDocument(
    String documentUrl,
  );
  
  Future<Either<Failures, OrganizerEntity>> updateActiveStatus(bool isActive);
}
