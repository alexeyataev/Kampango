public with sharing class ZumzumPostSalesInvoiceHelper {
    @InvocableMethod
    public static void postSalesInvoice(List<Zumzum__Sales_Invoice__c> salesInvoice) {
        
        if (salesInvoice != null && !salesInvoice.isEmpty()) {
            try {
                ZumzumSalesInvoiceCreator.postSI(salesInvoice);
            } catch(Exception ex) {
                throw new PostSalesInvoiceException();
            }
        }

    }

    public class PostSalesInvoiceException extends Exception {}
}
