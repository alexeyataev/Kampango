public with sharing class BacsSendRemittanceEmailsHelper {
    @InvocableMethod
    public static void sendEmails(List<List<Payment_Run_Line_Item__c>> prliList) {
        BacsSendRemittanceEmailsBatch bacsSendRemittanceEmailsBatch = new BacsSendRemittanceEmailsBatch(prliList[0]);
        Database.executeBatch(bacsSendRemittanceEmailsBatch, 500);
    }
}
