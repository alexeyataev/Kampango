@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #14 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class AddContactForMembershipHandler {
    @InvocableMethod
    public static List<AddContactResult> addContact(List<String> contactId) {
        AddContactResult addContactResult = new AddContactResult();
        try {
            Contact cont = [
                SELECT Id, Branch__r.Branch_Number__c, Care_Error_Log__c, FirstName, LastName, NCT_Number__c, Gender__c, MailingPostalCode, Email, npe01__PreferredPhone__c, Phone, MobilePhone, HomePhone, MailingStreet, MailingCity, MailingCountryCode 
                FROM Contact 
                WHERE Id =: contactId
                WITH SECURITY_ENFORCED
            ];
            addContactResult = CareHelper.sendContact(cont);
            return new List<AddContactResult> {addContactResult};
        } catch(Exception e) {
            addContactResult.error = e.getMessage();
            return new List<AddContactResult> {addContactResult};
        }
    }
}