import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/organizer/domain/usecases/add_organizer_photos_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/add_organizer_verification_documents_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/add_organizer_videos_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/create_organizer_profile_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/delete_organizer_profile_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/get_organizer_profile_by_id_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/get_organizer_profile_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/remove_organizer_photo_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/remove_organizer_verification_document_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/remove_organizer_video_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/update_organizer_active_status_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/update_organizer_profile_usecase.dart';
import 'package:getagig/features/organizer/domain/usecases/upload_organizer_profile_picture_usecase.dart';
import 'package:getagig/features/organizer/presentation/state/organizer_state.dart';

final organizerProfileViewModelProvider =
    NotifierProvider<OrganizerProfileViewModel, OrganizerProfileState>(
      OrganizerProfileViewModel.new,
    );

class OrganizerProfileViewModel extends Notifier<OrganizerProfileState> {
  late final CreateOrganizerProfileUseCase _createProfileUseCase;
  late final GetOrganizerProfileUseCase _getProfileUseCase;
  late final GetOrganizerProfileByIdUseCase _getProfileByIdUseCase;
  late final UpdateOrganizerProfileUseCase _updateProfileUseCase;
  late final DeleteOrganizerProfileUseCase _deleteProfileUseCase;
  late final UploadOrganizerProfilePictureUseCase _uploadProfilePictureUseCase;
  late final AddOrganizerPhotosUseCase _addPhotosUseCase;
  late final RemoveOrganizerPhotoUseCase _removePhotoUseCase;
  late final AddOrganizerVideosUseCase _addVideosUseCase;
  late final RemoveOrganizerVideoUseCase _removeVideoUseCase;
  late final AddOrganizerVerificationDocumentsUseCase _addVerificationDocumentsUseCase;
  late final RemoveOrganizerVerificationDocumentUseCase _removeVerificationDocumentUseCase;
  late final UpdateOrganizerActiveStatusUseCase _updateActiveStatusUseCase;

  @override
  OrganizerProfileState build() {
    _createProfileUseCase = ref.read(createOrganizerProfileUseCaseProvider);
    _getProfileUseCase = ref.read(getOrganizerProfileUseCaseProvider);
    _getProfileByIdUseCase = ref.read(getOrganizerProfileByIdUseCaseProvider);
    _updateProfileUseCase = ref.read(updateOrganizerProfileUseCaseProvider);
    _deleteProfileUseCase = ref.read(deleteOrganizerProfileUseCaseProvider);
    _uploadProfilePictureUseCase = ref.read(
      uploadOrganizerProfilePictureUseCaseProvider,
    );
    _addPhotosUseCase = ref.read(addOrganizerPhotosUseCaseProvider);
    _removePhotoUseCase = ref.read(removeOrganizerPhotoUseCaseProvider);
    _addVideosUseCase = ref.read(addOrganizerVideosUseCaseProvider);
    _removeVideoUseCase = ref.read(removeOrganizerVideoUseCaseProvider);
    _addVerificationDocumentsUseCase = ref.read(addOrganizerVerificationDocumentsUseCaseProvider);
    _removeVerificationDocumentUseCase = ref.read(removeOrganizerVerificationDocumentUseCaseProvider);
    _updateActiveStatusUseCase = ref.read(updateOrganizerActiveStatusUseCaseProvider);
    return const OrganizerProfileState();
  }

  Future<void> createProfile({
    required String organizationName,
    String? bio,
    required String contactPerson,
    required String phone,
    required String email,
    required String city,
    required String stateProvince,
    required String country,
    required String organizationType,
    required List<String> eventTypes,
    String? website,
  }) async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _createProfileUseCase(
      CreateOrganizerProfileParams(
        organizationName: organizationName,
        bio: bio,
        contactPerson: contactPerson,
        phone: phone,
        email: email,
        city: city,
        state: stateProvince,
        country: country,
        organizationType: organizationType,
        eventTypes: eventTypes,
        website: website,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: OrganizerProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: OrganizerProfileStatus.created,
          profile: profile,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getProfile() async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _getProfileUseCase();

    result.fold(
      (failure) {
        final errorMsg = failure.message.toLowerCase();
        if (errorMsg.contains('not found') ||
            errorMsg.contains('404') ||
            errorMsg.contains('does not exist')) {
          state = state.copyWith(
            status: OrganizerProfileStatus.initial,
            profile: null,
            errorMessage: null,
          );
        } else {
          state = state.copyWith(
            status: OrganizerProfileStatus.error,
            errorMessage: failure.message,
          );
        }
      },
      (profile) => state = state.copyWith(
        status: OrganizerProfileStatus.loaded,
        profile: profile,
        errorMessage: null,
      ),
    );
  }

  Future<void> getProfileById(String id) async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _getProfileByIdUseCase(id);

    result.fold(
      (failure) {
        final errorMsg = failure.message.toLowerCase();
        if (errorMsg.contains('not found') ||
            errorMsg.contains('404') ||
            errorMsg.contains('does not exist')) {
          state = state.copyWith(
            status: OrganizerProfileStatus.initial,
            profile: null,
            errorMessage: null,
          );
        } else {
          state = state.copyWith(
            status: OrganizerProfileStatus.error,
            errorMessage: failure.message,
          );
        }
      },
      (profile) => state = state.copyWith(
        status: OrganizerProfileStatus.loaded,
        profile: profile,
        errorMessage: null,
      ),
    );
  }

  Future<void> updateProfile({
    String? organizationName,
    String? bio,
    String? contactPerson,
    String? phone,
    String? email,
    String? city,
    String? stateProvince,
    String? country,
    String? organizationType,
    List<String>? eventTypes,
    String? website,
  }) async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _updateProfileUseCase(
      UpdateOrganizerProfileParams(
        organizationName: organizationName,
        bio: bio,
        contactPerson: contactPerson,
        phone: phone,
        email: email,
        city: city,
        state: stateProvince,
        country: country,
        organizationType: organizationType,
        eventTypes: eventTypes,
        website: website,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: OrganizerProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: OrganizerProfileStatus.updated,
          profile: profile,
          errorMessage: null,
        );
        getProfile();
      },
    );
  }

  Future<void> deleteProfile() async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _deleteProfileUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        status: OrganizerProfileStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(
          status: OrganizerProfileStatus.deleted,
          profile: null,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> uploadProfilePicture(File file) async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _uploadProfilePictureUseCase(file);

    result.fold(
      (failure) => state = state.copyWith(
        status: OrganizerProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: OrganizerProfileStatus.updated,
          profile: profile,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> addPhotos(List<File> files) async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _addPhotosUseCase(files);

    result.fold(
      (failure) => state = state.copyWith(
        status: OrganizerProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: OrganizerProfileStatus.updated,
          profile: profile,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> removePhoto(String photoUrl) async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _removePhotoUseCase(
      RemoveOrganizerPhotoParams(photoUrl: photoUrl),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: OrganizerProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: OrganizerProfileStatus.updated,
          profile: profile,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> addVideos(List<File> files) async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _addVideosUseCase(files);

    result.fold(
      (failure) => state = state.copyWith(
        status: OrganizerProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: OrganizerProfileStatus.updated,
          profile: profile,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> removeVideo(String videoUrl) async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _removeVideoUseCase(
      RemoveOrganizerVideoParams(videoUrl: videoUrl),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: OrganizerProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: OrganizerProfileStatus.updated,
          profile: profile,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> addVerificationDocuments(List<File> files) async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _addVerificationDocumentsUseCase(files);

    result.fold(
      (failure) => state = state.copyWith(
        status: OrganizerProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: OrganizerProfileStatus.updated,
          profile: profile,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> removeVerificationDocument(String documentUrl) async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _removeVerificationDocumentUseCase(
      RemoveOrganizerVerificationDocumentParams(documentUrl: documentUrl),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: OrganizerProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: OrganizerProfileStatus.updated,
          profile: profile,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> updateActiveStatus(bool isActive) async {
    state = state.copyWith(status: OrganizerProfileStatus.loading);

    final result = await _updateActiveStatusUseCase(isActive);

    result.fold(
      (failure) => state = state.copyWith(
        status: OrganizerProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        state = state.copyWith(
          status: OrganizerProfileStatus.updated,
          profile: profile,
          errorMessage: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearProfile() {
    state = state.copyWith(profile: null);
  }

  void resetState() {
    state = state.copyWith(
      status: OrganizerProfileStatus.initial,
      profile: null,
      errorMessage: null,
    );
  }
}

