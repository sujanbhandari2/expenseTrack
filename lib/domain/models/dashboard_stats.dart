class DashboardStats {
  const DashboardStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.savingsRate,
    required this.averageDailyExpense,
    required this.highestCategory,
    required this.expenseGrowth,
    required this.weeklyBudgetUsed,
    required this.transactionCount,
    required this.expenseToIncomeRatio,
    required this.weekSpent,
    required this.weekRemaining,
  });

  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double savingsRate;
  final double averageDailyExpense;
  final String highestCategory;
  final double expenseGrowth;
  final double weeklyBudgetUsed;
  final int transactionCount;
  final double expenseToIncomeRatio;
  final double weekSpent;
  final double weekRemaining;

  static const empty = DashboardStats(
    totalIncome: 0,
    totalExpense: 0,
    balance: 0,
    savingsRate: 0,
    averageDailyExpense: 0,
    highestCategory: '-',
    expenseGrowth: 0,
    weeklyBudgetUsed: 0,
    transactionCount: 0,
    expenseToIncomeRatio: 0,
    weekSpent: 0,
    weekRemaining: 0,
  );
}
