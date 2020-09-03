@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #106 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class ZumzumEStoPIConverter implements IExpenseSheetToPurchaseInvoiceConverter {
    global zumzum.ExpenseSheetService.Response convert(Set<Id> expenseSheetIds) {
        zumzum.ExpenseSheetService expenseSheetService = new zumzum.ExpenseSheetService();

        return expenseSheetService.ConvertToPurchaseInvoice(expenseSheetIds);
    }
}