@SuppressWarnings('PMD.EmptyStatementBlock')
//Incident #57 - https://confluence.nct.org.uk:8443/x/EoSO
public class AddContactForMembershipBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    private final String SUCCESS_STATUS = 'Success';
    private final String FAILURE_STATUS = 'Failure';

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Branch__r.Branch_Number__c, FirstName, LastName, NCT_Number__c, Gender__c, Email, npe01__PreferredPhone__c, Phone, MobilePhone, HomePhone, MailingPostalCode, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE RecordType.Name = \'Client\' AND NCT_Number__c = null AND Care_Status__c = \'Waiting\'');
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope){
        for(Contact cont : scope) {
            AddContactResult careAddContactResult = CareHelper.sendContact(cont);
            if(careAddContactResult.nctNumber != null) {
                cont.NCT_Number__c = careAddContactResult.nctNumber;
                cont.Care_Status__c = SUCCESS_STATUS;
            } else {
                cont.Care_Status__c = FAILURE_STATUS;
            }
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc){
    }
}