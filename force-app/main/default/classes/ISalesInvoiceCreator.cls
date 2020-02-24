public interface ISalesInvoiceCreator {
    List<Zumzum__Sales_Invoice__c> createSI(List<Zumzum.SalesInvoicePostService.SalesInvoiceWrapper> newSalesInvoiceDataList);
    void postSI(List<Zumzum__Sales_Invoice__c> salesInvoiceList);
}