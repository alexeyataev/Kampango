public with sharing class ZumzumPostSalesInvoiceHelper {
    @InvocableMethod
    public static void postSalesInvoice(List<Zumzum__Sales_Invoice__c> salesInvoice) {
        System.debug(salesInvoice);
        if (salesInvoice != null && !salesInvoice.isEmpty()) {
            try {
                System.debug(salesInvoice);
                ZumzumSalesInvoiceCreator.postSI(salesInvoice);
            } catch(Exception ex) {
                throw new PostSalesInvoiceException();
            }
        }

    }

    public class PostSalesInvoiceException extends Exception {}
}
