public with sharing class ZumzumEStoPIConverterMock implements IExpenseSheetToPurchaseInvoiceConverter {
    public void convert(Set<Id> expenseSheetIds) {
        List<Id> expenseSheetIdsList = new List<Id>();
        expenseSheetIdsList.addAll(expenseSheetIds);
        Map<Id, Zumzum__Purchase_Invoice__c> newPurchaseInvoiceMap = new Map<Id, Zumzum__Purchase_Invoice__c>();
        for(Id expenseSheetId : expenseSheetIdsList) {
            Zumzum__Purchase_Invoice__c newPurchaseInvoice = new Zumzum__Purchase_Invoice__c();
            newPurchaseInvoice.Zumzum__Expense_Sheet__c = expenseSheetId;
            newPurchaseInvoiceMap.put(expenseSheetId, newPurchaseInvoice);
        }
        insert newPurchaseInvoiceMap.values();
        List<Zumzum__Expense_Sheet_Detail__c> expenseSheetDetailList = [
            SELECT Id, Zumzum__Expense_Sheet__c, Zumzum__Total_Gross__c
            FROM Zumzum__Expense_Sheet_Detail__c 
            WHERE Zumzum__Expense_Sheet__c IN : expenseSheetIds
        ];
        List<Zumzum__Purchase_Invoice_Line_Item__c> newPurchaseInvoiceLineItemList = new List<Zumzum__Purchase_Invoice_Line_Item__c>();
        for(Zumzum__Expense_Sheet_Detail__c expenseSheetDetail : expenseSheetDetailList) {
            Zumzum__Purchase_Invoice_Line_Item__c newPurchaseInvoiceLineItem = new Zumzum__Purchase_Invoice_Line_Item__c();
            newPurchaseInvoiceLineItem.Zumzum__Purchase_Invoice__c = newPurchaseInvoiceMap.get(expenseSheetDetail.Zumzum__Expense_Sheet__c).Id;
            newPurchaseInvoiceLineItem.Zumzum__Total_Gross__c = expenseSheetDetail.Zumzum__Total_Gross__c;
            newPurchaseInvoiceLineItem.Zumzum__Expense_Sheet__c = expenseSheetDetail.Zumzum__Expense_Sheet__c;
            newPurchaseInvoiceLineItem.Zumzum__Expense_Sheet_Detail__c = expenseSheetDetail.Id;
            newPurchaseInvoiceLineItemList.add(newPurchaseInvoiceLineItem);
        }
        insert newPurchaseInvoiceLineItemList;
    }
}
