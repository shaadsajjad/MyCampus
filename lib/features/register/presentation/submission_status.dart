/// The lifecycle of a registration form's submit button — drives the
/// loading spinner, the one-shot success reaction, and the error banner.
/// Shared across the three registration Cubits (student/teacher/super
/// admin) since they're one feature.
enum SubmissionStatus { idle, submitting, success, failure }
