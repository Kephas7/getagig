// lib/features/musician/domain/repositories/i_musician_repository.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/musician_entity.dart';

abstract interface class IMusicianRepository {
  Future<Either<Failures, MusicianEntity>> createProfile(
    Map<String, dynamic> data,
  );
  
  Future<Either<Failures, MusicianEntity>> getProfile();
  
  Future<Either<Failures, MusicianEntity>> getProfileById(String id);
  
  Future<Either<Failures, MusicianEntity>> updateProfile(
    Map<String, dynamic> data,
  );
  
  Future<Either<Failures, void>> deleteProfile();
  
  Future<Either<Failures, MusicianEntity>> uploadProfilePicture(File file);
  
  Future<Either<Failures, MusicianEntity>> addPhotos(List<File> files);
  
  Future<Either<Failures, MusicianEntity>> removePhoto(String photoUrl);
  
  Future<Either<Failures, MusicianEntity>> addVideos(List<File> files);
  
  Future<Either<Failures, MusicianEntity>> removeVideo(String videoUrl);
  
  Future<Either<Failures, MusicianEntity>> addAudio(List<File> files);
  
  Future<Either<Failures, MusicianEntity>> removeAudio(String audioUrl);
  
  Future<Either<Failures, MusicianEntity>> updateAvailability(bool isAvailable);
}