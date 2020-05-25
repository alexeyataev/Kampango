public with sharing class ZumzumEStoPIConverterMock implements IExpenseSheetToPurchaseInvoiceConverter {
    public void convert(Set<Id> expenseSheetIds) {
        List<Id> expenseSheetIdsList = new List<Id>();
        expenseSheetIdsList.addAll(expenseSheetIds);
        Zumzum__Purchase_Invoice__c purchaseInvoice = new Zumzum__Purchase_Invoice__c();
        purchaseInvoice.Zumzum__Expense_Sheet__c = expenseSheetIdsList[0];
        insert purchaseInvoice;
        Zumzum__Purchase_Invoice_Line_Item__c purchaseInvoiceLineItem = new Zumzum__Purchase_Invoice_Line_Item__c();
        purchaseInvoiceLineItem.Zumzum__Purchase_Invoice__c = purchaseInvoice.Id;
        purchaseInvoiceLineItem.Zumzum__Total_Gross__c = 10;
        purchaseInvoiceLineItem.Zumzum__Expense_Sheet__c = expenseSheetIdsList[0];
        purchaseInvoiceLineItem.Zumzum__Expense_Sheet_Detail__c = 
            [SELECT Id FROM Zumzum__Expense_Sheet_Detail__c WHERE Zumzum__Expense_Sheet__c =: expenseSheetIdsList[0]].Id;
        insert purchaseInvoiceLineItem;
    }
}
