global class CareAddContactBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, Email, MailingPostalCode, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE RecordType.Name = \'Client\' AND NCT_Number__c = null');
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){
        List<Contact> contUpdateList = new List<Contact>();
        for(Contact cont : scope) {
            String nctNumber = CareHelper.sendContact(cont);
            if(nctNumber != null) {
                cont.NCT_Number__c = nctNumber;
                contUpdateList.add(cont);
            }
        }
        update contUpdateList;
    }

   global void finish(Database.BatchableContext BC){
   }
}