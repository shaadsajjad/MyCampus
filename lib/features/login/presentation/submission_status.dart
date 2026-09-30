/// The lifecycle of the login form's submit button — drives the loading
/// spinner, the one-shot success reaction, and the error banner.
enum SubmissionStatus { idle, submitting, success, failure }
