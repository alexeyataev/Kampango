@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #134 - https://confluence.nct.org.uk:8443/x/EoSO

@IsTest
public with sharing class BatchReceiptReportItem_TDTM_Test {

    private static final String STATUS_DRAFT = 'Draft';

    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String> {
        'triggerHandlerName' => 'BatchReceiptReportItem_TDTM',
        'className' => 'BatchReceiptReportItem_TDTM',
        'objectAPIName' => 'Batch_Receipt_Report_Item__c',
        'triggerActions' => 'AfterInsert;AfterUpdate;AfterDelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };

    @TestSetup
    private static void SetupTestData() {
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);

        Batch_Receipt_Report__c batchReceiptReportRecord = new TestBatchReceiptReportBuilder().insertRecord(true).build();

        Zumzum__Batch_Bank_Receipt__c batchBankReceipt = new Zumzum__Batch_Bank_Receipt__c (
            Zumzum__Status__c = STATUS_DRAFT
        );

        insert batchBankReceipt;

        Zumzum__Bank_Receipt__c bankReceiptInstanse = new Zumzum__Bank_Receipt__c (
            Zumzum__Amount__c = 10,
            Zumzum__Status__c = STATUS_DRAFT,
            Zumzum__Batch_Bank_Receipt__c = batchBankReceipt.Id
        );

        insert bankReceiptInstanse;

        TestBatchReceiptReportItemBuilder batchReceiptReportItemInstanse = new TestBatchReceiptReportItemBuilder();
        batchReceiptReportItemInstanse.withBatchReceiptReport(batchReceiptReportRecord.Id)
            .withBankReceipt(bankReceiptInstanse.Id)
            .insertRecord(true)
            .build();
    }

    @IsTest
    public static void BRReportItemCheckAfterDeleting_DeletedBRRepotItemRecord_TotalMatchedShouldBeZero() {

        Batch_Receipt_Report_Item__c batchReceiptReportItem = [SELECT Id FROM Batch_Receipt_Report_Item__c LIMIT 1];
        Batch_Receipt_Report__c batchReceiptReportRecordBeforeDelete = [SELECT Total_Matched__c FROM Batch_Receipt_Report__c LIMIT 1];

        System.assertEquals(1, batchReceiptReportRecordBeforeDelete.Total_Matched__c, 'Should be equals 1');

        Test.startTest();
            delete batchReceiptReportItem;
        Test.stopTest();

        Batch_Receipt_Report__c batchReceiptReportRecordAfterDeleted = [SELECT Total_Matched__c FROM Batch_Receipt_Report__c LIMIT 1];
        System.assertEquals(0, batchReceiptReportRecordAfterDeleted.Total_Matched__c, 'Should be equals 0');
    }

    @IsTest
    public static void BRReportItemCheckAfterUpdating_UpdateBRRepotItemRecord_TotalMatchedShouldBeZero() {

        Batch_Receipt_Report_Item__c batchReceiptReportItem = [SELECT Id, Bank_Receipt__c FROM Batch_Receipt_Report_Item__c LIMIT 1];
        Batch_Receipt_Report__c batchReceiptReportRecordBeforeUpdate = [SELECT Total_Matched__c FROM Batch_Receipt_Report__c LIMIT 1];

        System.assertEquals(1, batchReceiptReportRecordBeforeUpdate.Total_Matched__c, 'Should be equals 1');

        Test.startTest();
            batchReceiptReportItem.Bank_Receipt__c = null;
            update batchReceiptReportItem;
        Test.stopTest();

        Batch_Receipt_Report__c batchReceiptReportRecordAfterUpdate = [SELECT Total_Matched__c FROM Batch_Receipt_Report__c LIMIT 1];
        System.assertEquals(0, batchReceiptReportRecordAfterUpdate.Total_Matched__c, 'Should be equals 0');
    }

    @IsTest
    public static void BRReportItemCheckAfterInsert_InsertBRRepotItemRecord_TotalMatchedShouldBeTwo() {

        Batch_Receipt_Report__c batchReceiptReportRecordBeforeInsert = [SELECT Id, Total_Matched__c FROM Batch_Receipt_Report__c LIMIT 1];

        System.assertEquals(1, batchReceiptReportRecordBeforeInsert.Total_Matched__c, 'Should be equals 1');

        Zumzum__Batch_Bank_Receipt__c batchBankReceipt = new Zumzum__Batch_Bank_Receipt__c (
            Zumzum__Status__c = STATUS_DRAFT
        );

        insert batchBankReceipt;

        Zumzum__Bank_Receipt__c bankReceiptInstanse = new Zumzum__Bank_Receipt__c (
            Zumzum__Amount__c = 20,
            Zumzum__Status__c = STATUS_DRAFT,
            Zumzum__Batch_Bank_Receipt__c = batchBankReceipt.Id
        );

        insert bankReceiptInstanse;

        Test.startTest();
            TestBatchReceiptReportItemBuilder batchReceiptReportItemInstanse = new TestBatchReceiptReportItemBuilder();
            batchReceiptReportItemInstanse.withBatchReceiptReport(batchReceiptReportRecordBeforeInsert.Id)
                .withBankReceipt(bankReceiptInstanse.Id)
                .insertRecord(true)
                .build();
        Test.stopTest();

        Batch_Receipt_Report__c batchReceiptReportRecordAfterInsert = [SELECT Total_Matched__c FROM Batch_Receipt_Report__c LIMIT 1];
        System.assertEquals(2, batchReceiptReportRecordAfterInsert.Total_Matched__c, 'Should be equals 2');
    }

}