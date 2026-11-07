/// Cloudinary settings for unsigned image uploads.
///
/// Unsigned uploads do not use the API secret. The cloud name and preset are
/// safe to include in the client and can be overridden at build time with
/// `--dart-define=CLOUDINARY_CLOUD_NAME=...`.
class CloudinaryConfig {
  CloudinaryConfig._();

  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'j3gsraoc',
  );

  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'flutter_incident_name',
  );

  static const String folder = String.fromEnvironment(
    'CLOUDINARY_FOLDER',
    defaultValue: 'campuscomfort/incidents',
  );
}
