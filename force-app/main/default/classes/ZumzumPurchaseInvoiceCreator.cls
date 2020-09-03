public with sharing class ZumzumPurchaseInvoiceCreator implements IPurchaseInvoiceServiceProvider {

    public static Zumzum.PurchaseInvoiceService.Response postPurchaseInvoice(Set<Id> setOfPurchaseInvoiceIds, Boolean executeInBatchProcessing) {
        Zumzum.PurchaseInvoiceService postPurchaseInvoice = new Zumzum.PurchaseInvoiceService();

        return postPurchaseInvoice.PostPurchaseInvoice(setOfPurchaseInvoiceIds, executeInBatchProcessing);
    }

}
