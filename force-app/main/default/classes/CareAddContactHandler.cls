public with sharing class CareAddContactHandler {
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
            membershipResultObject.messageType = 'success';
            membershipResultObject.messageText = contNumber;
            return new List<MembershipResultObject> {membershipResultObject};
        } catch(Exception e) {
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = 'error';
            membershipResultObject.messageText = 'error!';
            return new List<MembershipResultObject> {membershipResultObject};
        }
    }
    private class AddContactException extends Exception {}
}