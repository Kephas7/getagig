// lib/features/musician/domain/repositories/i_musician_repository.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/musician_entity.dart';

abstract interface class IMusicianRepository {
  Future<Either<Failure, MusicianEntity>> createProfile(
    Map<String, dynamic> data,
  );
  
  Future<Either<Failure, MusicianEntity>> getProfile();
  
  Future<Either<Failure, MusicianEntity>> getProfileById(String id);
  
  Future<Either<Failure, MusicianEntity>> updateProfile(
    Map<String, dynamic> data,
  );
  
  Future<Either<Failure, void>> deleteProfile();
  
  Future<Either<Failure, MusicianEntity>> uploadProfilePicture(File file);
  
  Future<Either<Failure, MusicianEntity>> addPhotos(List<File> files);
  
  Future<Either<Failure, MusicianEntity>> removePhoto(String photoUrl);
  
  Future<Either<Failure, MusicianEntity>> addVideos(List<File> files);
  
  Future<Either<Failure, MusicianEntity>> removeVideo(String videoUrl);
  
  Future<Either<Failure, MusicianEntity>> addAudio(List<File> files);
  
  Future<Either<Failure, MusicianEntity>> removeAudio(String audioUrl);
  
  Future<Either<Failure, MusicianEntity>> updateAvailability(bool isAvailable);
}

