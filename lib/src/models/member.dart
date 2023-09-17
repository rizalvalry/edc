class Member {
  final String memberId;
  final String registrationId;
  final String registrationName;
  final String memberName;
  final String amount;
  final String status;
  final String filename;
  final String va;
  final String block;
  final String kamar;
  final String perkara;
  final String pin;
  final String vaExpired;
  final String branchId;

  Member({
    required this.memberId,
    required this.registrationId,
    required this.registrationName,
    required this.memberName,
    required this.amount,
    required this.status,
    required this.filename,
    required this.va,
    required this.block,
    required this.kamar,
    required this.perkara,
    required this.pin,
    required this.vaExpired,
    required this.branchId,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['LEVE_MEMBERID'] ?? 'Tidak Ada',
      registrationId: json['LEVE_REGISTRATIONID'] ?? 'Tidak Ada',
      registrationName: json['LEVE_REGISTRATIONNAME'] ?? 'Tidak Ada',
      memberName: json['LEVE_MEMBERNAME'] ?? 'Tidak Ada',
      amount: json['LEVE_AMOUNT'] ?? 'Tidak Ada',
      status: json['LEVE_STATUS'] ?? 'Tidak Ada',
      filename: json['LEVE_FILENAME'] ?? 'Tidak Ada',
      va: json['LEVE_VA'] ?? 'Tidak Ada',
      block: json['LEVE_BLOCK'] ?? 'Tidak Ada',
      kamar: json['LEVE_KAMAR'] ?? 'Tidak Ada',
      perkara: json['LEVE_PERKARA'] ?? 'Tidak Ada',
      pin: json['LEVE_PIN'] ?? 'Tidak Ada',
      vaExpired: json['LEVE_VA_DEXPIRED'] ?? 'Tidak Ada',
      branchId: json['LEVE_BRANCHID'] ?? 'Tidak Ada',
    );
  }
}
