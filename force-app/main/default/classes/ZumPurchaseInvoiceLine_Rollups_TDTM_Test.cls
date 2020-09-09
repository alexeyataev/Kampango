@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #131 - https://confluence.nct.org.uk:8443/x/EoSO

@IsTest
public with sharing class ZumPurchaseInvoiceLine_Rollups_TDTM_Test {
    private static final String SUPPLIER_ACCOUNT_NUMBER = '123456';
    private static final String PURCHASE_INVOICE_STATUS = 'Posted';
    private static final String PURCHASE_INVOICE_TYPE = 'Purchase Credit';

    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String> {
        'triggerHandlerName' => 'ZumzumPurchaseInvoiceLine_Rollups_TDTM',
        'className' => 'ZumzumPurchaseInvoiceLine_Rollups_TDTM',
        'objectAPIName' => 'Zumzum__Purchase_Invoice_Line_Item__c',
        'triggerActions' => 'AfterInsert;AfterUpdate;AfterDelete;AfterUndelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };

    @TestSetup
    private static void TestSetup() {

        TestDataFactory dataFactory = TestDataFactory.getInstance();
            TestDataFactory.getInstance()
                .buildBranchAccount()
                .buildOrganizationAccount(SUPPLIER_ACCOUNT_NUMBER)
                .createFinanceUser()
                .buildPractitioner('John Practitioner')
                .buildPractitionerFeeRate()
                .buildVenue()
                .buildRoom()
                .buildLicenceToPractice()
                .buildCoursesWithSessions(1, 1);

        Account supplierAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Organization' LIMIT 1];

        TestFinanceDataFactory financeDataFactory = TestFinanceDataFactory.getInstance();
        financeDataFactory.createZumzumData();
        financeDataFactory.createZumzumPurchaseInvoiceWithLineItems(1);
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @IsTest
    private static void CheckPurchaseInvoiceLa4VTDTM_UpdatedPurchaseInvoiceLa4V_RecompiledWasSuccess() {
        Course__c courseRecordBeforeUpdated = [SELECT Id, Total_Venue_Costs__c FROM Course__c];

        Zumzum__Purchase_Invoice__c purchaseInvoiceRecord = [
            SELECT Id, Zumzum__Status__c
            FROM Zumzum__Purchase_Invoice__c
        ];

        Zumzum__Nominal_Account__c nominalAccount = [
            SELECT Id
            FROM Zumzum__Nominal_Account__c
            WHERE Zumzum__Nominal_Code__c = '5157'
        ];

        Zumzum__Purchase_Invoice_Line_Item__c purchaseInvoceLineItemsRecord = [
            SELECT Id, Zumzum__Nominal_Account__c, Course__c
            FROM Zumzum__Purchase_Invoice_Line_Item__c 
            WHERE Zumzum__Purchase_Invoice__c = :purchaseInvoiceRecord.Id
        ];

        Test.startTest();
            purchaseInvoiceRecord.Zumzum__Status__c = PURCHASE_INVOICE_STATUS;
            purchaseInvoiceRecord.Zumzum__Type__c = PURCHASE_INVOICE_TYPE;
            update purchaseInvoiceRecord;

            purchaseInvoceLineItemsRecord.Zumzum__Nominal_Account__c = nominalAccount.Id;
            purchaseInvoceLineItemsRecord.Course__c = courseRecordBeforeUpdated.Id;
            update purchaseInvoceLineItemsRecord;
        Test.stopTest();

        Course__c courseRecordAfterUpdated = [SELECT Id, Total_Venue_Costs__c FROM Course__c];

        System.assertEquals(-10, courseRecordAfterUpdated.Total_Venue_Costs__c, 'Should be equals');

    }
}

