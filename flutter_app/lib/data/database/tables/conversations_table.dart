import 'package:drift/drift.dart';

@DataClassName('ConversationsData')
class Conversations extends Table {
  TextColumn get conversationId => text()();
  TextColumn get userLowId => text()();
  TextColumn get userHighId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {conversationId};
}
