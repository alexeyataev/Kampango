@SuppressWarnings('PMD.EmptyStatementBlock')
//Incident #57 - https://confluence.nct.org.uk:8443/x/EoSO
public class AddContactForMembershipBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Branch__r.Branch_Number__c, Care_Error_Log__c, Email, FirstName, Gender__c, Individual.Has_Opted_In_Email__c, Individual.Has_Opted_In_Post__c, Individual.Has_Opted_In_SMS__c, Individual.Has_Opted_In_Telephone__c, LastName, MailingCity, MailingCountryCode, MailingPostalCode, MailingStreet, MobilePhone, NCT_Number__c, npe01__PreferredPhone__c, Phone, HomePhone FROM Contact WHERE RecordType.Name = \'Client\' AND Care_Status__c = \'Waiting\'');
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope){
        for(Contact cont : scope) {
            AddContactResult careAddContactResult = CareHelper.sendContact(cont);
            if(careAddContactResult.nctNumber != null) {
                cont.NCT_Number__c = careAddContactResult.nctNumber;
            }
            List<AddMarketingPreferencesToCare.MarketingPreferencesResult> marketingPreferencesResultList = AddMarketingPreferencesToCare.addMarketingPreferencesForContact(cont);
            String marketingPreferencesError = AddMarketingPreferencesToCare.getErrorLog(marketingPreferencesResultList);
            if(careAddContactResult.error == null && marketingPreferencesError == '') {
                cont.Care_Status__c = CareHelper.SUCCESS_STATUS;
            } else {
                cont.Care_Status__c = CareHelper.FAILURE_STATUS;
                if(careAddContactResult.error != null) {
                    cont.Care_Error_Log__c = careAddContactResult.error;
                }
                if(marketingPreferencesError != '') {
                    cont.Care_Error_Log__c = CareHelper.addErrorLog(marketingPreferencesError, cont.Care_Error_Log__c);
                }
            }
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc){
    }
}