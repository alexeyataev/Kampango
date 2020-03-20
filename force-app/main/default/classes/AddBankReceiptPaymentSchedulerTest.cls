@IsTest
public with sharing class AddBankReceiptPaymentSchedulerTest {
    @isTest static void schedulerTest() {
    	final String SCHEDULED_TIME = '0 0 00 ? * 1';
        Test.startTest();
        Id jobId = AddBankReceiptPaymentScheduler.scheduleBatch(100);
        Test.stopTest();
        Integer jobCount = [SELECT Count() FROM CronTrigger WHERE Id = :jobId LIMIT 10];
        System.assertEquals(1, jobCount);
    }
}