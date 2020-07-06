public interface IExpenseSheetToPurchaseInvoiceConverter {
    zumzum.ExpenseSheetService.Response convert(Set<Id> expenseSheetIds);
}
