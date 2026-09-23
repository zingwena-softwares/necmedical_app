/// Result of `POST /reports` — the API only echoes back the reference
/// number, not a full record (and there's no `GET /reports/track`
/// equivalent to `cases/track`, so this is all we ever get back).
class ReportSubmissionResult {
  final String referenceNumber;
  const ReportSubmissionResult(this.referenceNumber);
  factory ReportSubmissionResult.fromJson(Map<String, dynamic> json) =>
      ReportSubmissionResult(json['reference_number'] as String);
}
