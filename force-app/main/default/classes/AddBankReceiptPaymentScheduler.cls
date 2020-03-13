public with sharing class AddBankReceiptPaymentScheduler implements Schedulable {

    public static final String SCHEDULED_TIME = '0 0 00 ? * 1'; //Cron tbd
    public static final String CLASS_NAME = 'AddBankReceiptPaymentScheduler';
    public static Integer batchSize; // tbd


    public static Id scheduleBatch(Integer chunkSize) {
        batchSize = chunkSize;
        return (Test.isRunningTest()) ?
                System.schedule(CLASS_NAME + 'Test', SCHEDULED_TIME, new AddBankReceiptPaymentScheduler()) :
                System.schedule(CLASS_NAME, SCHEDULED_TIME, new AddBankReceiptPaymentScheduler());
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new AddBankReceiptForWorldpayPaymentBatch(), batchSize);
    }
}