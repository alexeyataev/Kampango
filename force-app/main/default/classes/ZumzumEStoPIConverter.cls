global with sharing class ZumzumEStoPIConverter implements IExpenseSheetToPurchaseInvoiceConverter {
    global zumzum.ExpenseSheetService.Response convert(Set<Id> expenseSheetIds) {
        zumzum.ExpenseSheetService expenseSheetService = new zumzum.ExpenseSheetService();

        return expenseSheetService.ConvertToPurchaseInvoice(expenseSheetIds);
    }
}