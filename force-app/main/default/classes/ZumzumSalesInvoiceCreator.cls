public without sharing class ZumzumSalesInvoiceCreator implements ISalesInvoiceCreator {
    public static List<Zumzum__Sales_Invoice__c> createSI(List<Zumzum.SalesInvoicePostService.SalesInvoiceWrapper> newSalesInvoiceDataList) {
        Zumzum.SalesInvoicePostService salesInvoicePostService = new Zumzum.SalesInvoicePostService();
        List<Zumzum__Sales_Invoice__c> newSalesInvoices = salesInvoicePostService.CreateSalesInvoices(newSalesInvoiceDataList);
        return newSalesInvoices;
    }
    public static void postSI(List<Zumzum__Sales_Invoice__c> salesInvoiceList) {
        Zumzum.SalesInvoicePostService salesInvoicePostService = new Zumzum.SalesInvoicePostService();
        salesInvoicePostService.PostSalesInvoices(salesInvoiceList);
    }
}