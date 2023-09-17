class MemberDetail {
  final int memberId;
  final String regId;
  final String regName;
  final String memberName;
  final String area;
  final String room;
  final String perkara;
  final String pin;
  final String active;
  final String branch;
  final String balance;

  MemberDetail({
    required this.memberId,
    required this.regId,
    required this.regName,
    required this.memberName,
    required this.area,
    required this.room,
    required this.perkara,
    required this.pin,
    required this.active,
    required this.branch,
    required this.balance,
  });

  factory MemberDetail.fromJson(Map<String, dynamic> json) {
    return MemberDetail(
      memberId: json['Id'] != null ? int.parse(json['Id']) : 0,
      regId: json['RegId'] ?? 'No DATA',
      regName: json['RegName'] ?? 'No DATA',
      memberName: json['MemberName'] ?? 'No DATA',
      area: json['Area'] ?? 'No DATA',
      room: json['Room'] ?? 'No DATA',
      perkara: json['Case'] ?? 'No DATA',
      pin: json['Pin'] ?? 'No DATA',
      active: json['Active'] ?? 'No DATA',
      branch: json['Branch'] ?? 'No DATA',
      balance: json['Balance'] ?? 'No DATA',
    );
  }
}
