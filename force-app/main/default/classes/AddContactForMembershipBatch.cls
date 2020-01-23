global class AddContactForMembershipBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, Branch__r.Branch_Number__c, FirstName, LastName, NCT_Number__c, Gender__c, Email, MailingPostalCode, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE RecordType.Name = \'Client\' AND NCT_Number__c = null AND Care_Status__c = \'Waiting\'');
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){
        for(Contact cont : scope) {
            AddContactResult careAddContactResult = CareHelper.sendContact(cont);
            if(careAddContactResult.nctNumber != null) {
                cont.NCT_Number__c = careAddContactResult.nctNumber;
                cont.Care_Status__c = 'Success';
            } else {
                cont.Care_Status__c = 'Failure';
            }
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC){
    }
}