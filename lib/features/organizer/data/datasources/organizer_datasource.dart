import 'dart:io';
import '../models/organizer_api_model.dart';

abstract class IOrganizerRemoteDataSource {
  Future<OrganizerApiModel> createProfile(Map<String, dynamic> data);
  Future<OrganizerApiModel> getProfile();
  Future<OrganizerApiModel> getProfileById(String id);
  Future<OrganizerApiModel> updateProfile(Map<String, dynamic> data);
  Future<void> deleteProfile();
  Future<OrganizerApiModel> uploadProfilePicture(File file);
  Future<OrganizerApiModel> addPhotos(List<File> files);
  Future<OrganizerApiModel> removePhoto(String photoUrl);
  Future<OrganizerApiModel> addVideos(List<File> files);
  Future<OrganizerApiModel> removeVideo(String videoUrl);
  Future<OrganizerApiModel> addVerificationDocuments(List<File> files);
  Future<OrganizerApiModel> removeVerificationDocument(String documentUrl);
  Future<OrganizerApiModel> updateActiveStatus(bool isActive);
}
