@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #121 - https://confluence.nct.org.uk:8443/x/EoSO

@IsTest
public with sharing class PRLineItem_PreventDeletion_TDTM_Test {
    private static final String PAYMENT_RUN_STATUS_READY = 'Ready';
    private static final String PAYMENT_RUN_STATUS_CLOSED = 'Closed';
    private static final Integer COUNT_RECORDS = 2;

    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String> {
        'triggerHandlerName' => 'PRLineItem_PreventDeletion_TDTM',
        'className' => 'PRLineItem_PreventDeletion_TDTM',
        'objectAPIName' => 'Payment_Run_Line_Item__c',
        'triggerActions' => 'BeforeDelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };

    @TestSetup
    static void SetupTestData() {

        List<Payment_Run__c> paymentRunList = new List<Payment_Run__c>();
        for (Integer i = 0; i < COUNT_RECORDS; i++) {
            Payment_Run__c paymentRun = new Payment_Run__c();

            if (i > 0) {
                paymentRun.Status__c = PAYMENT_RUN_STATUS_READY;
            } else {
                paymentRun.Status__c = PAYMENT_RUN_STATUS_CLOSED;
            }

            paymentRunList.add(paymentRun);
        }

        insert paymentRunList;

        List<Payment_Run_Line_Item__c> paymentRunLineItemList = new List<Payment_Run_Line_Item__c>();
        for(Integer i = 0; i < COUNT_RECORDS; i++) {
            Payment_Run_Line_Item__c paymentRunLineItem = new Payment_Run_Line_Item__c();
            if ( i > 0) {
                paymentRunLineItem.Payment_Run__c = paymentRunList[i].Id;

            } else {
                paymentRunLineItem.Payment_Run__c = paymentRunList[i].Id;
            }

            paymentRunLineItemList.add(paymentRunLineItem);
        }

        insert paymentRunLineItemList;

        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @IsTest
    public static void PreventDeletePRLineItems_SetRunPaymentStatusToReady_PreventedDeletingPRLineItemsRecord() {
        Payment_Run_Line_Item__c paymentRunLineItem = [SELECT Id, Payment_Run__r.Status__c FROM Payment_Run_Line_Item__c WHERE Payment_Run__r.Status__c = :PAYMENT_RUN_STATUS_READY LIMIT 1];
        Database.DeleteResult dataBaseResult;

        Test.startTest();
            dataBaseResult = Database.delete(paymentRunLineItem, false);
        Test.stopTest();

        System.assertEquals(System.Label.Delete_Payment_Run_Line_Item_Error_Text, dataBaseResult.getErrors()[0].getMessage(), 'Should be error message');
    }

    @IsTest
    public static void PreventDeletePRLineItems_SetRunPaymentStatusToClosed_PreventedDeletingPRLineItemsRecord() {
        Payment_Run_Line_Item__c paymentRunLineItem = [SELECT Id, Payment_Run__r.Status__c FROM Payment_Run_Line_Item__c WHERE Payment_Run__r.Status__c = :PAYMENT_RUN_STATUS_CLOSED LIMIT 1];
        Database.DeleteResult dataBaseResult;

        Test.startTest();
            dataBaseResult = Database.delete(paymentRunLineItem, false);
        Test.stopTest();

        System.assertEquals(System.Label.Delete_Payment_Run_Line_Item_Error_Text, dataBaseResult.getErrors()[0].getMessage(), 'Should be error message');
    }
}
