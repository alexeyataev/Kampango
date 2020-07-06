@SuppressWarnings('PMD.MethodNamingConventions')

@isTest
public without sharing class ZumzumPurchaseInvoiceCreatorTest {

    static final Boolean EXECUTE_IN_BATCH_PROCESSING = false;
    static final String PURCHASE_INVOICE_STATUS_POSTED = 'Posted';
    static final String PURCHASE_INVOICE_STATUS_DRAFT = 'Draft';
    static final String PURCHASE_INVOICE_RESPONSE_STATUS_SUCCESS = 'Success';

    @TestSetup
    static void createTestData() {

    TestDataFactory.getInstance()
        .buildBranchAccount()
        .buildOrganizationAccount('acc5');

    TestFinanceDataFactory.createZumzumPurchaseInvoiceWithLineItems(2);
    }

    @isTest
    public static void PurchaseInvoicePost_PassPIRecordWithStatusDraft_ReturnPIRecordWithSatatusPosted() {
        Zumzum__Purchase_Invoice__c purchaseInvoiceRecordBeforePost = [SELECT Id FROM Zumzum__Purchase_Invoice__c LIMIT 1];
        Zumzum.PurchaseInvoiceService.Response postPurchaseInvoiceResponse = new Zumzum.PurchaseInvoiceService.Response();

        Test.startTest();
            Set<Id> purchaseInvoiceIds = new Set<Id>{ purchaseInvoiceRecordBeforePost.Id };
            postPurchaseInvoiceResponse = ZumzumPurchaseInvoiceCreator.postPurchaseInvoice(purchaseInvoiceIds, EXECUTE_IN_BATCH_PROCESSING);
        Test.stopTest();

        Zumzum__Purchase_Invoice__c purchaseInvoiceAfterPostRecord = [SELECT Zumzum__Status__c FROM Zumzum__Purchase_Invoice__c LIMIT 1];

        System.assertEquals(postPurchaseInvoiceResponse.ResponseMessage, PURCHASE_INVOICE_RESPONSE_STATUS_SUCCESS, 'Response message should be Success');
        System.assertEquals(purchaseInvoiceAfterPostRecord.Zumzum__Status__c, PURCHASE_INVOICE_STATUS_POSTED , 'Status should be Posted');
    }

    @isTest
    public static void PurchaseInvoicePost_PassPIRecordWithNotValidRecord_ReturnPIRecordWithSatatusDraftAndNotSuccess() {
        Zumzum__Purchase_Invoice__c purchaseInvoiceRecordBeforePost = [SELECT Id FROM Zumzum__Purchase_Invoice__c LIMIT 1];

        Zumzum__Purchase_Invoice_Line_Item__c purchaseInvoiceLineItemsRecord = [
            SELECT Id
            FROM Zumzum__Purchase_Invoice_Line_Item__c 
            WHERE Zumzum__Purchase_Invoice__c = :purchaseInvoiceRecordBeforePost.Id
            LIMIT 1
        ];

        purchaseInvoiceLineItemsRecord.Zumzum__Nominal_Account__c = null;
        update purchaseInvoiceLineItemsRecord;

        Zumzum.PurchaseInvoiceService.Response postPurchaseInvoiceResponse = new Zumzum.PurchaseInvoiceService.Response();

        Test.startTest();
            Set<Id> purchaseInvoiceIds = new Set<Id>{ purchaseInvoiceRecordBeforePost.Id};
            postPurchaseInvoiceResponse = ZumzumPurchaseInvoiceCreator.postPurchaseInvoice(purchaseInvoiceIds, EXECUTE_IN_BATCH_PROCESSING);
        Test.stopTest();

        Zumzum__Purchase_Invoice__c purchaseInvoiceAfterPostRecord = [SELECT Zumzum__Status__c FROM Zumzum__Purchase_Invoice__c LIMIT 1];

        System.assert(postPurchaseInvoiceResponse.ResponseMessage != PURCHASE_INVOICE_RESPONSE_STATUS_SUCCESS, 'Response message should be not Success');
        System.assertEquals(purchaseInvoiceAfterPostRecord.Zumzum__Status__c, PURCHASE_INVOICE_STATUS_DRAFT , 'Status should be Draft');
    }
}
