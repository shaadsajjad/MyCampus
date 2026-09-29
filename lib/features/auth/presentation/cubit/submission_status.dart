/// The lifecycle of a form's submit button — drives the loading spinner,
/// the one-shot success reaction, and the error banner. Shared across the
/// `auth` feature's four form Cubits (login + 3 registration flows).
enum SubmissionStatus { idle, submitting, success, failure }
