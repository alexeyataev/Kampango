@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #14 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing class AddContactForMembershipHandler {
    @InvocableMethod
    public static List<AddContactResult> addContact(List<String> contactId) {
        AddContactResult addContactResult = new AddContactResult();
        try {

            Contact cont = [
                SELECT Branch__r.Branch_Number__c,
                       Care_Error_Log__c,
                       Expected_Due_Date__c,
                       Email,
                       FirstName,
                       Gender__c,
                       HomePhone,
                       Id,
                       LastName,
                       MailingCity,
                       MailingCountry,
                       MailingPostalCode,
                       MailingStreet,
                       MobilePhone,
                       NCT_Number__c,
                       npe01__PreferredPhone__c,
                       Phone
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