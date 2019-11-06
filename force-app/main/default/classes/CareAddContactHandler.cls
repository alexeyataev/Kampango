@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #14 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class CareAddContactHandler {
    @InvocableMethod
    public static List<BookingJourneyInvocableResult> addContact(List<String> contactId) {
        try {
            Contact cont = [
                SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, MailingPostalCode, Email, MailingStreet, MailingCity, MailingCountry 
                FROM Contact 
                WHERE Id =: contactId
                WITH SECURITY_ENFORCED
            ];
            String contNumber = CareHelper.sendContact(cont);
            BookingJourneyInvocableResult result = new BookingJourneyInvocableResult();
            result.messageType = CareRequestBodyUtil.MESSAGE_TYPE_SUCCESS;
            result.messageText = contNumber;
            return new List<BookingJourneyInvocableResult> {result};
        } catch(Exception e) {
            BookingJourneyInvocableResult result = new BookingJourneyInvocableResult();
            result.messageType = CareRequestBodyUtil.MESSAGE_TYPE_ERROR;
            result.messageText = CareRequestBodyUtil.MESSAGE_TEXT_ERROR;
            return new List<BookingJourneyInvocableResult> {result};
        }
    }
    private class AddContactException extends Exception {}
}