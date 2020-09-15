public without sharing class ZumzumPostSalesInvoiceHelper {
    public static ISalesInvoiceCreator salesInvoiceCreator {
        get {
            if(salesInvoiceCreator == null) {
                salesInvoiceCreator = new ZumzumSalesInvoiceCreator();
            }
            return salesInvoiceCreator;
        }
        public set;
    }
    @InvocableMethod
    public static void postSalesInvoice(List<Zumzum__Sales_Invoice__c> salesInvoice) {
        
        if (salesInvoice != null && !salesInvoice.isEmpty()) {
            try {
                salesInvoiceCreator.postSI(salesInvoice);
            } catch(Exception ex) {
                throw new PostSalesInvoiceException();
            }
        }

    }

    public class PostSalesInvoiceException extends Exception {}
}