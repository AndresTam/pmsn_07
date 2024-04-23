class AppNotifications {
  String? id, title, subtitle, component, sender;
  int? type;
  DateTime? created;
  bool? read;

  AppNotifications({
    this.component,
    this.created,
    this.id,
    this.read,
    this.sender,
    this.subtitle,
    this.title,
    this.type, // 0: receive like, 1: matched, 2: message, 3: report, 5: calls
  });

  factory AppNotifications.fromMap(var map) {
    return AppNotifications(
      component: map['component'],
      created: map['create'].toDate(),
      id: map['id'],
      read: map['read'],
      sender: map['sender'],
      subtitle: map['subtitle'],
      title: map['title'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map['component'] = component ?? '';
    map['create'] = created ?? DateTime.now();
    map['id'] = id ?? '';
    map['read'] = read ?? false;
    map['sender'] = sender ?? '';
    map['subtitle'] = subtitle ?? '';
    map['title'] = title ?? '';
    map['type'] = type ?? 0;
    return map;
  }
}
