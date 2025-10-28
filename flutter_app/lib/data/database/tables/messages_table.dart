import 'package:drift/drift.dart';

@DataClassName('MessagesData')
class Messages extends Table {
  TextColumn get messageId => text()();
  TextColumn get conversationId => text().nullable()();
  TextColumn get senderId => text()();
  TextColumn get receiverId => text()();
  TextColumn get content => text()();
  TextColumn get meta => text().nullable()(); // JSON string
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {messageId};
}
