public with sharing class AddBankReceiptPaymentScheduler implements Schedulable {

    public static final String SCHEDULED_TIME = '0 0 0/1 ? * * *';
    public static final String CLASS_NAME = 'AddBankReceiptPaymentScheduler';

    private Integer batchSize;

    public AddBankReceiptPaymentScheduler(Integer batchSize){
        this.batchSize = batchSize;
    }

    public static Id scheduleBatch(Integer chunkSize) {
        return (Test.isRunningTest()) ?
                System.schedule(CLASS_NAME + 'Test', SCHEDULED_TIME, new AddBankReceiptPaymentScheduler(chunkSize)) :
                System.schedule(CLASS_NAME, SCHEDULED_TIME, new AddBankReceiptPaymentScheduler(chunkSize));
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new AddBankReceiptForWorldpayPaymentBatch(), batchSize);
    }
}