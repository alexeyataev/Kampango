final String STATUS_DRAFT = 'Draft';
final String  EXCEPTION_MESSAGE = 'The following exception has occurred: ';

try {

    List<Zumzum__Sales_Invoice__c> listDraftSalesInvoices = [
        SELECT Id
        FROM Zumzum__Sales_Invoice__c
        WHERE Zumzum__Status__c = :STATUS_DRAFT
        ORDER BY Zumzum__Account__c
        LIMIT 49995
    ];

    Zumzum.SalesInvoicePostService salesInvoicePostService = new Zumzum.SalesInvoicePostService();
    salesInvoicePostService.PostSalesInvoices(listDraftSalesInvoices);

} catch (QueryException qe) {
    System.debug(EXCEPTION_MESSAGE + qe.getMessage()); 
}