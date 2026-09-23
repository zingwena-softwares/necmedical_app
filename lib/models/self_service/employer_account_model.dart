/// An employer's own Self Service account — from `/employers/register`,
/// `/employers/login` and `/employers/me`.
class EmployerAccount {
  final int id;
  final String tradeName;
  final String? ownerFullName;
  final String? physicalAddress;
  final String? necContactName;
  final String? necContactEmail;
  final String? necContactCell;
  final String? status;

  const EmployerAccount({
    required this.id,
    required this.tradeName,
    this.ownerFullName,
    this.physicalAddress,
    this.necContactName,
    this.necContactEmail,
    this.necContactCell,
    this.status,
  });

  factory EmployerAccount.fromJson(Map<String, dynamic> json) => EmployerAccount(
        id: json['id'] as int,
        tradeName: json['trade_name'] as String? ?? '',
        ownerFullName: json['owner_full_name'] as String?,
        physicalAddress: json['physical_address'] as String?,
        necContactName: json['nec_contact_name'] as String?,
        necContactEmail: json['nec_contact_email'] as String?,
        necContactCell: json['nec_contact_cell'] as String?,
        status: json['status'] as String?,
      );
}
