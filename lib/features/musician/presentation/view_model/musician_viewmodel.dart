import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/musician/domain/usecases/get_profile_byId_usecase.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import '../../domain/usecases/create_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/delete_profile_usecase.dart';
import '../../domain/usecases/upload_profile_picture_usecase.dart';
import '../../domain/usecases/add_photos_usecase.dart';
import '../../domain/usecases/remove_photo_usecase.dart';
import '../../domain/usecases/add_videos_usecase.dart';
import '../../domain/usecases/remove_video_usecase.dart';
import '../../domain/usecases/add_audio_usecase.dart';
import '../../domain/usecases/remove_audio_usecase.dart';
import '../../domain/usecases/update_availability_usecase.dart';

final musicianProfileViewModelProvider =
    NotifierProvider<MusicianProfileViewModel, MusicianProfileState>(
      MusicianProfileViewModel.new,
    );

class MusicianProfileViewModel extends Notifier<MusicianProfileState> {
  late final CreateProfileUseCase _createProfileUseCase;
  late final GetProfileUseCase _getProfileUseCase;
  late final GetProfileByIdUseCase _getProfileByIdUseCase;
  late final UpdateProfileUseCase _updateProfileUseCase;
  late final DeleteProfileUseCase _deleteProfileUseCase;
  late final UploadProfilePictureUseCase _uploadProfilePictureUseCase;
  late final AddPhotosUseCase _addPhotosUseCase;
  late final RemovePhotoUseCase _removePhotoUseCase;
  late final AddVideosUseCase _addVideosUseCase;
  late final RemoveVideoUseCase _removeVideoUseCase;
  late final AddAudioUseCase _addAudioUseCase;
  late final RemoveAudioUseCase _removeAudioUseCase;
  late final UpdateAvailabilityUseCase _updateAvailabilityUseCase;

  @override
  MusicianProfileState build() {
    _createProfileUseCase = ref.read(createProfileUseCaseProvider);
    _getProfileUseCase = ref.read(getProfileUseCaseProvider);
    _getProfileByIdUseCase = ref.read(getProfileByIdUseCaseProvider);
    _updateProfileUseCase = ref.read(updateProfileUseCaseProvider);
    _deleteProfileUseCase = ref.read(deleteProfileUseCaseProvider);
    _uploadProfilePictureUseCase = ref.read(
      uploadProfilePictureUseCaseProvider,
    );
    _addPhotosUseCase = ref.read(addPhotosUseCaseProvider);
    _removePhotoUseCase = ref.read(removePhotoUseCaseProvider);
    _addVideosUseCase = ref.read(addVideosUseCaseProvider);
    _removeVideoUseCase = ref.read(removeVideoUseCaseProvider);
    _addAudioUseCase = ref.read(addAudioUseCaseProvider);
    _removeAudioUseCase = ref.read(removeAudioUseCaseProvider);
    _updateAvailabilityUseCase = ref.read(updateAvailabilityUseCaseProvider);
    return const MusicianProfileState();
  }

  Future<void> createProfile({
    required String stageName,
    String? bio,
    required String phone,
    required String city,
    required String stateProvince,
    required String country,
    required List<String> genres,
    required List<String> instruments,
    required int experienceYears,
    double? hourlyRate,
    bool? isAvailable,
  }) async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _createProfileUseCase(
      CreateProfileParams(
        stageName: stageName,
        bio: bio,
        phone: phone,
        city: city,
        state: stateProvince,
        country: country,
        genres: genres,
        instruments: instruments,
        experienceYears: experienceYears,
        hourlyRate: hourlyRate,
        isAvailable: isAvailable,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: MusicianProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: MusicianProfileStatus.created,
          profile: profile,
          resetErrorMessage: true,
        );
      },
    );
  }

  Future<void> getProfile() async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _getProfileUseCase();

    result.fold(
      (failure) {
        final errorMsg = failure.message.toLowerCase();
        if (errorMsg.contains('not found') ||
            errorMsg.contains('404') ||
            errorMsg.contains('does not exist')) {
          state = state.copyWith(
            status: MusicianProfileStatus.initial,
            profile: null,
            resetErrorMessage: true,
          );
        } else {
          state = state.copyWith(
            status: MusicianProfileStatus.error,
            errorMessage: failure.message,
          );
        }
      },
      (profile) => state = state.copyWith(
        status: MusicianProfileStatus.loaded,
        profile: profile,
        resetErrorMessage: true,
      ),
    );
  }

  Future<void> getProfileById(String id) async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _getProfileByIdUseCase(GetProfileByIdParams(id: id));

    result.fold(
      (failure) {
        final errorMsg = failure.message.toLowerCase();
        if (errorMsg.contains('not found') ||
            errorMsg.contains('404') ||
            errorMsg.contains('does not exist')) {
          state = state.copyWith(
            status: MusicianProfileStatus.initial,
            profile: null,
            resetErrorMessage: true,
          );
        } else {
          state = state.copyWith(
            status: MusicianProfileStatus.error,
            errorMessage: failure.message,
          );
        }
      },
      (profile) => state = state.copyWith(
        status: MusicianProfileStatus.loaded,
        profile: profile,
        resetErrorMessage: true,
      ),
    );
  }

  Future<void> updateProfile({
    String? stageName,
    String? bio,
    String? phone,
    String? city,
    String? stateProvince,
    String? country,
    List<String>? genres,
    List<String>? instruments,
    int? experienceYears,
    double? hourlyRate,
    bool? isAvailable,
  }) async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        stageName: stageName,
        bio: bio,
        phone: phone,
        city: city,
        state: stateProvince,
        country: country,
        genres: genres,
        instruments: instruments,
        experienceYears: experienceYears,
        hourlyRate: hourlyRate,
        isAvailable: isAvailable,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: MusicianProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: MusicianProfileStatus.updated,
          profile: profile,
          resetErrorMessage: true,
        );
        getProfile();
      },
    );
  }

  Future<void> deleteProfile() async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _deleteProfileUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        status: MusicianProfileStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(
          status: MusicianProfileStatus.deleted,
          resetProfile: true,
          resetErrorMessage: true,
        );
      },
    );
  }

  Future<void> uploadProfilePicture(File file) async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _uploadProfilePictureUseCase(file);

    result.fold(
      (failure) => state = state.copyWith(
        status: MusicianProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: MusicianProfileStatus.updated,
          profile: profile,
          resetErrorMessage: true,
        );
      },
    );
  }

  Future<void> addPhotos(List<File> files) async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _addPhotosUseCase(files);

    result.fold(
      (failure) => state = state.copyWith(
        status: MusicianProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: MusicianProfileStatus.updated,
          profile: profile,
          resetErrorMessage: true,
        );
      },
    );
  }

  Future<void> removePhoto(String photoUrl) async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _removePhotoUseCase(
      RemovePhotoParams(photoUrl: photoUrl),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: MusicianProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: MusicianProfileStatus.updated,
          profile: profile,
          resetErrorMessage: true,
        );
      },
    );
  }

  Future<void> addVideos(List<File> files) async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _addVideosUseCase(files);

    result.fold(
      (failure) => state = state.copyWith(
        status: MusicianProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: MusicianProfileStatus.updated,
          profile: profile,
          resetErrorMessage: true,
        );
      },
    );
  }

  Future<void> removeVideo(String videoUrl) async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _removeVideoUseCase(
      RemoveVideoParams(videoUrl: videoUrl),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: MusicianProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: MusicianProfileStatus.updated,
          profile: profile,
          resetErrorMessage: true,
        );
      },
    );
  }

  Future<void> addAudio(List<File> files) async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _addAudioUseCase(files);

    result.fold(
      (failure) => state = state.copyWith(
        status: MusicianProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: MusicianProfileStatus.updated,
          profile: profile,
          resetErrorMessage: true,
        );
      },
    );
  }

  Future<void> removeAudio(String audioUrl) async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _removeAudioUseCase(
      RemoveAudioParams(audioUrl: audioUrl),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: MusicianProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: MusicianProfileStatus.updated,
          profile: profile,
          resetErrorMessage: true,
        );
      },
    );
  }

  Future<void> updateAvailability(bool isAvailable) async {
    state = state.copyWith(status: MusicianProfileStatus.loading);

    final result = await _updateAvailabilityUseCase(
      UpdateAvailabilityParams(isAvailable: isAvailable),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: MusicianProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: MusicianProfileStatus.updated,
          profile: profile,
          resetErrorMessage: true,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(resetErrorMessage: true);
  }

  void clearProfile() {
    state = state.copyWith(resetProfile: true);
  }

  void resetState() {
    state = state.copyWith(
      status: MusicianProfileStatus.initial,
      resetProfile: true,
      resetErrorMessage: true,
    );
  }
}
