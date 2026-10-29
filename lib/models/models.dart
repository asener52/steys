class HomeMembershipSummary {
  final String facilityName;
  final String packageName;
  final int? remainingRights;
  final DateTime endDate;

  HomeMembershipSummary({
    required this.facilityName,
    required this.packageName,
    required this.endDate,
    this.remainingRights,
  });

  factory HomeMembershipSummary.fromJson(Map<String, dynamic> json) => HomeMembershipSummary(
        facilityName: json['facilityName'] as String,
        packageName: json['packageName'] as String,
        remainingRights: json['remainingRights'] as int?,
        endDate: DateTime.parse(json['endDate'] as String),
      );
}

class HomeSummary {
  final String firstName;
  final String lastName;
  final String? activePackageName;
  final int? remainingRights;
  final DateTime? membershipEndDate;
  final DateTime? lastAccessAt;
  final List<HomeMembershipSummary> memberships;

  HomeSummary({
    required this.firstName,
    required this.lastName,
    this.activePackageName,
    this.remainingRights,
    this.membershipEndDate,
    this.lastAccessAt,
    this.memberships = const [],
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) => HomeSummary(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        activePackageName: json['activePackageName'] as String?,
        remainingRights: json['remainingRights'] as int?,
        membershipEndDate: json['membershipEndDate'] != null
            ? DateTime.parse(json['membershipEndDate'] as String)
            : null,
        lastAccessAt:
            json['lastAccessAt'] != null ? DateTime.parse(json['lastAccessAt'] as String) : null,
        memberships: (json['memberships'] as List<dynamic>? ?? [])
            .map((e) => HomeMembershipSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class FamilyMember {
  final String citizenId;
  final String firstName;
  final String lastName;
  final bool isSelf;

  FamilyMember({required this.citizenId, required this.firstName, required this.lastName, required this.isSelf});

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
        citizenId: json['citizenId'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        isSelf: json['isSelf'] as bool,
      );
}

class SessionOccurrence {
  final String id;
  final String templateName;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;
  final int booked;
  final int remaining;
  final bool reservationRequired;

  SessionOccurrence({
    required this.id,
    required this.templateName,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    required this.booked,
    required this.remaining,
    required this.reservationRequired,
  });

  factory SessionOccurrence.fromJson(Map<String, dynamic> json) => SessionOccurrence(
        id: json['id'] as String,
        templateName: json['templateName'] as String,
        startsAt: DateTime.parse(json['startsAt'] as String),
        endsAt: DateTime.parse(json['endsAt'] as String),
        capacity: json['capacity'] as int,
        booked: json['booked'] as int,
        remaining: json['remaining'] as int,
        reservationRequired: json['reservationRequired'] as bool,
      );
}

class ReservationItem {
  final String id;
  final String sessionOccurrenceId;
  final int status; // 0 Booked, 1 Cancelled, 2 CheckedIn, 3 NoShow
  final DateTime createdAt;

  ReservationItem({
    required this.id,
    required this.sessionOccurrenceId,
    required this.status,
    required this.createdAt,
  });

  factory ReservationItem.fromJson(Map<String, dynamic> json) => ReservationItem(
        id: json['id'] as String,
        sessionOccurrenceId: json['sessionOccurrenceId'] as String,
        status: json['status'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class AccessHistoryItem {
  final String id;
  final DateTime timestamp;
  final String credentialType;
  final String result;
  final String denialReason;

  AccessHistoryItem({
    required this.id,
    required this.timestamp,
    required this.credentialType,
    required this.result,
    required this.denialReason,
  });

  factory AccessHistoryItem.fromJson(Map<String, dynamic> json) => AccessHistoryItem(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        credentialType: json['credentialType'] as String,
        result: json['result'] as String,
        denialReason: json['denialReason'] as String,
      );
}

class MembershipItem {
  final String id;
  final String packageName;
  final DateTime startDate;
  final DateTime endDate;
  final int status;
  final int? availableRights;

  MembershipItem({
    required this.id,
    required this.packageName,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.availableRights,
  });

  factory MembershipItem.fromJson(Map<String, dynamic> json) => MembershipItem(
        id: json['id'] as String,
        packageName: json['packageName'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        status: json['status'] as int,
        availableRights: json['availableRights'] as int?,
      );
}

class AnnouncementItem {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  AnnouncementItem({required this.id, required this.title, required this.body, required this.createdAt});

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) => AnnouncementItem(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class CourseScheduleItem {
  final String day; final String startsAt; final String endsAt;
  CourseScheduleItem({required this.day, required this.startsAt, required this.endsAt});
  factory CourseScheduleItem.fromJson(Map<String, dynamic> json) => CourseScheduleItem(day: json['day'], startsAt: json['startsAt'], endsAt: json['endsAt']);
}

class CourseItem {
  final String enrollmentId, courseName, facilityName, status;
  final String? instructorName; final DateTime startsOn, endsOn; final int extendedDays; final List<CourseScheduleItem> schedules;
  CourseItem({required this.enrollmentId, required this.courseName, required this.facilityName, required this.status, this.instructorName, required this.startsOn, required this.endsOn, required this.extendedDays, required this.schedules});
  factory CourseItem.fromJson(Map<String, dynamic> json) => CourseItem(enrollmentId: json['enrollmentId'], courseName: json['courseName'], facilityName: json['facilityName'], status: json['status'], instructorName: json['instructorName'], startsOn: DateTime.parse(json['startsOn']), endsOn: DateTime.parse(json['endsOn']), extendedDays: json['extendedDays'], schedules: (json['schedules'] as List).map((e) => CourseScheduleItem.fromJson(e)).toList());
}
