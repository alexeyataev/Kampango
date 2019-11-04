//@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #14 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class CareAddContactHandler {
    @InvocableMethod
    public static List<MembershipResultObject> addContact(List<String> contactId) {
        try {
            Contact cont = [
                SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, MailingPostalCode, Email, MailingStreet, MailingCity, MailingCountry 
                FROM Contact 
                WHERE Id =: contactId
                WITH SECURITY_ENFORCED
            ];
            String contNumber = CareHelper.sendContact(cont);
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = CareRequestBodyUtil.MESSAGE_TYPE_SUCCESS;
            membershipResultObject.messageText = contNumber;
            return new List<MembershipResultObject> {membershipResultObject};
        } catch(Exception e) {
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = CareRequestBodyUtil.MESSAGE_TYPE_ERROR;
            membershipResultObject.messageText = CareRequestBodyUtil.MESSAGE_TEXT_ERROR;
            return new List<MembershipResultObject> {membershipResultObject};
        }
    }
    private class AddContactException extends Exception {}
}