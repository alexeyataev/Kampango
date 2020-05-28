global with sharing class ZumzumEStoPIConverter implements IExpenseSheetToPurchaseInvoiceConverter {
    global void convert(Set<Id> expenseSheetIds) {
        zumzum.ExpenseSheetService expenseSheetService = new zumzum.ExpenseSheetService();
        expenseSheetService.ConvertToPurchaseInvoice(expenseSheetIds);
    }
}