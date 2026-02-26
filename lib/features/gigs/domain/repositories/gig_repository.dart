import 'package:dartz/dartz.dart';
import '../entities/gig_entity.dart';
import 'package:getagig/core/error/failures.dart';

abstract interface class IGigRepository {
  Future<Either<Failure, List<GigEntity>>> getAllGigs();
  Future<Either<Failure, GigEntity>> getGigById(String id);
  Future<Either<Failure, GigEntity>> createGig(Map<String, dynamic> data);
  Future<Either<Failure, GigEntity>> updateGig(String id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteGig(String id);
  Future<Either<Failure, void>> applyToGig(String gigId, String coverLetter);
}

