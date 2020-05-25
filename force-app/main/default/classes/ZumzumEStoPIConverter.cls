global with sharing class ZumzumEStoPIConverter implements IExpenseSheetToPurchaseInvoiceConverter {
    global void convert(Set<Id> expenseSheetIds) {
        zumzum.ExpenseSheetService objExpenseSheetService = new zumzum.ExpenseSheetService();
        zumzum.ExpenseSheetService.Response objResponse = objExpenseSheetService.ConvertToPurchaseInvoice(expenseSheetIds);
        system.debug('Response>>' + objResponse.ResponseMessage);
        System.debug(objResponse.purchaseInvoices);
    }
}