@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #58 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class ZumzumSalesInvoiceCreatorMock implements ISalesInvoiceCreator {
    public static List<Zumzum__Sales_Invoice__c> createSI(List<Zumzum.SalesInvoicePostService.SalesInvoiceWrapper> newSalesInvoiceDataList) {
        Zumzum__Sales_Invoice__c salesInvoice = new Zumzum__Sales_Invoice__c();
        List<Zumzum__Sales_Invoice_Line_Item__c> salesInvoiceLineList = new List<Zumzum__Sales_Invoice_Line_Item__c>();
        Zumzum.SalesInvoicePostService.SalesInvoiceWrapper salesInvoiceWrapper = newSalesInvoiceDataList[0];
        salesInvoice.Zumzum__Account__c = salesInvoice.Zumzum__Account__c == null ? salesInvoiceWrapper.Customer : salesInvoice.Zumzum__Account__c;
        salesInvoice.Zumzum__Invoice_Date__c = Date.today();
        salesInvoice.Zumzum__Transaction_Currency__c = salesInvoice.Zumzum__Transaction_Currency__c == null ? salesInvoiceWrapper.TransactionCurrency : salesInvoice.Zumzum__Transaction_Currency__c;
        for(Zumzum.SalesInvoicePostService.SalesInvoiceLineWrapper salesInvoiceLineWrapper : salesInvoiceWrapper.LineItems) {
            Zumzum__Sales_Invoice_Line_Item__c salesInvoiceLineItem = new Zumzum__Sales_Invoice_Line_Item__c();
            salesInvoiceLineItem.Zumzum__Product__c = salesInvoiceLineWrapper.Product;
            salesInvoiceLineItem.Zumzum__Nominal_Account__c = salesInvoiceLineWrapper.NominalAccount;
            salesInvoiceLineItem.Zumzum__Quantity__c = salesInvoiceLineWrapper.quantity;
            salesInvoiceLineItem.Zumzum__Tax_Rate__c = salesInvoiceLineWrapper.TaxRate;
            salesInvoiceLineItem.Zumzum__Foreign_Net_Amount__c = salesInvoiceLineWrapper.ForeignNetAmount;
            salesInvoiceLineItem.Zumzum__Amount__c = salesInvoiceLineWrapper.ForeignNetAmount;
            salesInvoiceLineItem.Zumzum__Foreign_Net_Total__c = salesInvoiceLineWrapper.ForeignNetAmount;
            salesInvoiceLineItem.Zumzum__Foreign_Gross__c = salesInvoiceLineWrapper.ForeignNetAmount;
            salesInvoiceLineItem.Zumzum__Total_Gross__c = salesInvoiceLineWrapper.ForeignNetAmount;
            salesInvoiceLineItem.Zumzum__Dimension_1__c = salesInvoiceLineWrapper.Dimension1;
            salesInvoiceLineItem.Zumzum__Dimension_2__c = salesInvoiceLineWrapper.Dimension2;
            salesInvoiceLineList.add(salesInvoiceLineItem);
        }
        insert salesInvoice;
        for(Zumzum__Sales_Invoice_Line_Item__c salesInvoiceLineItem : salesInvoiceLineList) {
            salesInvoiceLineItem.Zumzum__Sales_Invoice__c = salesInvoice.Id;
        }
        insert salesInvoiceLineList;
        return new List<Zumzum__Sales_Invoice__c> {salesInvoice};
    }
    public static void postSI(List<Zumzum__Sales_Invoice__c> salesInvoiceList) {
        List<Zumzum__Ledger__c> ledgerList = new List<Zumzum__Ledger__c>();
        for(Zumzum__Sales_Invoice__c salesInvoice : salesInvoiceList) {
            salesInvoice.Zumzum__Status__c = 'Posted';
            for (Zumzum__Sales_Invoice_Line_Item__c salesInvoiceLineItem : salesInvoice.Zumzum__Sales_Invoice_Line_Items__r) {
                Zumzum__Ledger__c ledger = new Zumzum__Ledger__c();
                ledger.Zumzum__Show_On_Transaction__c = 1;
                ledger.Zumzum__Trans_No__c = 50001;
                ledger.Zumzum__Trans_Date__c = Date.today();
                ledger.Zumzum__Transaction_Currency__c = salesInvoice.Zumzum__Transaction_Currency__c;
                ledger.Zumzum__Foreign_Currency_Rate__c = 1;
                ledger.Zumzum__Customer_Supplier_Account_Name__c = salesInvoice.Zumzum__Account__c;
                ledger.Zumzum__Sub_Account__c = '12345';
                ledger.Zumzum__Net_Amount__c = salesInvoiceLineItem.Zumzum__Foreign_Net_Amount__c;
                ledger.Zumzum__Company_Net_Total__c = salesInvoiceLineItem.Zumzum__Foreign_Net_Amount__c;
                ledger.Zumzum__Debit__c = salesInvoiceLineItem.Zumzum__Foreign_Net_Amount__c + (salesInvoiceLineItem.Zumzum__Foreign_Tax_Total__c == null ? 0 : salesInvoiceLineItem.Zumzum__Foreign_Tax_Total__c);
                ledger.Zumzum__Sub_Account_Nominal__c = '9300';
                ledger.Zumzum__Sub_Account_Nominal_Link__c = salesInvoiceLineItem.Zumzum__Nominal_Account__c;
                ledger.Zumzum__Type__c = 'SI';
                ledger.Zumzum__Paid__c = 'N';
                ledger.Zumzum__Doc_ID__c = '000001';
                ledger.Zumzum__Sales_Invoice__c = salesInvoice.Id;
                ledger.Zumzum__Sales_Invoice_Line_Item__c = salesInvoiceLineItem.Id;
                ledgerList.add(ledger);
            }
        }
        insert ledgerList;
        update salesInvoiceList;
    }
}