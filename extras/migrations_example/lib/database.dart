import 'package:moor/moor.dart';

import 'tables.dart';

part 'database.g.dart';

@UseMoor(include: {'tables.moor'})
class Database extends _$Database {
  @override
  int get schemaVersion => 3;

  Database(DatabaseConnection connection) : super.connect(connection);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, before, now) async {
        for (var target = before + 1; target <= now; target++) {
          if (target == 2) {
            // Migration from 1 to 2: Add name column in users. Use "no name"
            // as a default value.
            await m.alterTable(
              TableMigration(
                users,
                columnTransformer: {
                  users.name: const Constant<String>('no name'),
                },
                newColumns: [users.name],
              ),
            );
          } else if (target == 3) {
            // Migration from 2 to 3: We added the groups table
            await m.createTable(groups);
          }
        }
      },
    );
  }
}
