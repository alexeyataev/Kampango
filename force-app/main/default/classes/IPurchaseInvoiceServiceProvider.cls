public interface IPurchaseInvoiceServiceProvider {
    Zumzum.PurchaseInvoiceService.Response postPurchaseInvoice(Set<Id> setOfPurchaseInvoiceIds, Boolean executeInBatchProcessing);
}
