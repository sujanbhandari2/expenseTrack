import 'package:daily_finance_tracker/data/db/app_database.dart';
import 'package:daily_finance_tracker/domain/models/budget_goal.dart';

class GoalRepository {
  GoalRepository(this._database);

  final AppDatabase _database;

  Future<BudgetGoal?> getActiveGoal() async {
    final db = await _database.database;
    final rows = await db.query(
      'goals',
      where: 'isActive = 1',
      orderBy: 'startDate DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<void> saveGoal(BudgetGoal goal) async {
    final db = await _database.database;
    await db.update('goals', {'isActive': 0});
    await db.insert('goals', {
      'weeklyBudget': goal.weeklyBudget,
      'startDate': goal.startDate.toIso8601String(),
      'isActive': goal.isActive ? 1 : 0,
    });
  }

  BudgetGoal _fromMap(Map<String, dynamic> map) {
    return BudgetGoal(
      id: map['id'] as int,
      weeklyBudget: (map['weeklyBudget'] as num).toDouble(),
      startDate: DateTime.parse(map['startDate'] as String),
      isActive: (map['isActive'] as int) == 1,
    );
  }
}
