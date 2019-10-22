global class CareAddContactBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, Email, MailingPostalCode, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE RecordType.Name = \'Client\' AND NCT_Number__c = null');
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){
        for(Contact cont : scope) {
            String contNumber = CareHelper.sendContact(cont);
        }
        CareHelper.updateContacts();
    }

   global void finish(Database.BatchableContext BC){
   }
}