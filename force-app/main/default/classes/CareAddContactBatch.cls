public class CareAddContactBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, Email, MailingPostalCode, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE RecordType.Name = \'Client\' AND NCT_Number__c = null');
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope){
        for(Contact cont : scope) {
            String contNumber = CareHelper.sendContact(cont);
        }
        CareHelper.updateContacts();
    }

   public void finish(Database.BatchableContext bc){
   }
}