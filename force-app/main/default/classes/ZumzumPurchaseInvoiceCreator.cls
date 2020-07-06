public with sharing class ZumzumPurchaseInvoiceCreator implements IPurchaseInvoiceServiceProvider {

    public static Zumzum.PurchaseInvoiceService.Response postPurchaseInvoice(Set<Id> setOfPurchaseInvoiceIds, Boolean executeInBatchProcessing) {
        Zumzum.PurchaseInvoiceService PostPurchaseInvoice = new Zumzum.PurchaseInvoiceService();

        return PostPurchaseInvoice.PostPurchaseInvoice(setOfPurchaseInvoiceIds, executeInBatchProcessing);
    }

}
