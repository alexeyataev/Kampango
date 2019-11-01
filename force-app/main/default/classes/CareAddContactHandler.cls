@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class CareAddContactHandler {
    public static final String MESSAGE_TYPE_SUCCESS = 'success';
    public static final String MESSAGE_TYPE_ERROR = 'error';
    public static final String MESSAGE_TEXT_ERROR = 'error!';
    @InvocableMethod
    public static List<MembershipResultObject> addContact(List<String> contactId) {
        System.debug('###Added Contact');
        try {
            Contact cont = [
                SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, MailingPostalCode, Email, MailingStreet, MailingCity, MailingCountry 
                FROM Contact 
                WHERE Id =: contactId
                WITH SECURITY_ENFORCED
            ];
            String contNumber = CareHelper.sendContact(cont);
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = MESSAGE_TYPE_SUCCESS;
            membershipResultObject.messageText = contNumber;
            return new List<MembershipResultObject> {membershipResultObject};
        } catch(Exception e) {
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = MESSAGE_TYPE_ERROR;
            membershipResultObject.messageText = MESSAGE_TEXT_ERROR;
            return new List<MembershipResultObject> {membershipResultObject};
        }
    }
    private class AddContactException extends Exception {}
}