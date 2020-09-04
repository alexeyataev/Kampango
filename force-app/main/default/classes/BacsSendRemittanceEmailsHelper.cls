public with sharing class BacsSendRemittanceEmailsHelper {
    @InvocableMethod
    public static void sendEmails(List<List<Payment_Run_Line_Item__c>> prliList) {
        BacsSendRemittanceEmailsBatch bacsSendRemittanceEmailsBatch = new BacsSendRemittanceEmailsBatch(prliList[0]);
        Database.executeBatch(bacsSendRemittanceEmailsBatch, 500);
    }
    private static String createEmailBody(String body, Payment_Run_Line_Item__c prli) {
        return String.format(body, new List<String> {String.valueOf(prli.Paid_Amount__c), prli.Reference_Info__c});
    }
}
