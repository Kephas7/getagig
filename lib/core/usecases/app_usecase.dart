import 'package:dartz/dartz.dart';
import 'package:getagig/core/error/failures.dart';

abstract interface class UsecaseWithParms<SucessType, Params> {
  Future<Either<Failures, SucessType>> call(Params params);
}

abstract interface class UsecaseWithoutParams<SucessType> {
  Future<Either<Failures, SucessType>> call();
}
