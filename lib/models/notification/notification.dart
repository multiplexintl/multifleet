import 'lst_doc_expiry.dart';
import 'lst_odo_reminder.dart';
import 'lst_service_reminder.dart';
import 'lst_unpaid_fine.dart';

class Notification {
  List<LstDocExpiry>? lstDocExpiry;
  List<LstServiceReminder>? lstServiceReminder;
  List<LstOdoReminder>? lstOdoReminder;
  List<LstUnpaidFine>? lstUnpaidFines;

  Notification({
    this.lstDocExpiry,
    this.lstServiceReminder,
    this.lstOdoReminder,
    this.lstUnpaidFines,
  });

  @override
  String toString() {
    return 'Notification(lstDocExpiry: $lstDocExpiry, lstServiceReminder: $lstServiceReminder, lstOdoReminder: $lstOdoReminder, lstUnpaidFines: $lstUnpaidFines)';
  }

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        lstDocExpiry: (json['lstDocExpiry'] as List<dynamic>?)
            ?.map((e) => LstDocExpiry.fromJson(e as Map<String, dynamic>))
            .toList(),
        lstServiceReminder: (json['lstServiceReminder'] as List<dynamic>?)
            ?.map((e) => LstServiceReminder.fromJson(e as Map<String, dynamic>))
            .toList(),
        lstOdoReminder: (json['lstOdoReminder'] as List<dynamic>?)
            ?.map((e) => LstOdoReminder.fromJson(e as Map<String, dynamic>))
            .toList(),
        lstUnpaidFines: (json['lstUnpaidFines'] as List<dynamic>?)
            ?.map((e) => LstUnpaidFine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'lstDocExpiry': lstDocExpiry?.map((e) => e.toJson()).toList(),
        'lstServiceReminder':
            lstServiceReminder?.map((e) => e.toJson()).toList(),
        'lstOdoReminder': lstOdoReminder?.map((e) => e.toJson()).toList(),
        'lstUnpaidFines': lstUnpaidFines?.map((e) => e.toJson()).toList(),
      };

  Notification copyWith({
    List<LstDocExpiry>? lstDocExpiry,
    List<LstServiceReminder>? lstServiceReminder,
    List<LstOdoReminder>? lstOdoReminder,
    List<LstUnpaidFine>? lstUnpaidFines,
  }) {
    return Notification(
      lstDocExpiry: lstDocExpiry ?? this.lstDocExpiry,
      lstServiceReminder: lstServiceReminder ?? this.lstServiceReminder,
      lstOdoReminder: lstOdoReminder ?? this.lstOdoReminder,
      lstUnpaidFines: lstUnpaidFines ?? this.lstUnpaidFines,
    );
  }
}
