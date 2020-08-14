final String STATUS_DRAFT = 'Draft';
final String  EXCEPTION_MESSAGE = 'The following exception has occurred: ';
final Boolean EXECUTE_IN_BATCH_PROCESSING = true;

try {

    List<Zumzum__Sales_Invoice__c> listDraftSalesInvoices = [
        SELECT Id
        FROM Zumzum__Sales_Invoice__c
        WHERE Zumzum__Status__c = :STATUS_DRAFT
        LIMIT 50000
    ];

    Zumzum.SalesInvoicePostService salesInvoicePostService = new Zumzum.SalesInvoicePostService();
    salesInvoicePostService.PostSalesInvoices(listDraftSalesInvoices);

} catch (QueryException qe) {
    System.debug(EXCEPTION_MESSAGE + qe.getMessage()); 
}


try {

    Map<Id, Zumzum__Purchase_Invoice__c> draftSalesPurchaseMap = new Map<Id, Zumzum__Purchase_Invoice__c> (
        [
                SELECT Id
                FROM Zumzum__Purchase_Invoice__c
                WHERE Zumzum__Status__c = :STATUS_DRAFT
                LIMIT 50000
        ]
    );

    Zumzum.PurchaseInvoiceService purchaseInvoicePostService = new Zumzum.PurchaseInvoiceService();
    purchaseInvoicePostService.PostPurchaseInvoice(draftSalesPurchaseMap.keySet(), EXECUTE_IN_BATCH_PROCESSING);

} catch (QueryException qe) {
    System.debug(EXCEPTION_MESSAGE + qe.getMessage());
}


