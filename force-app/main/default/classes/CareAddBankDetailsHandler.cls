public with sharing class CareAddBankDetailsHandler {
    public static final String MESSAGE_TYPE_SUCCESS = 'success';
    public static final String MESSAGE_TYPE_ERROR = 'error';
    public static final String MESSAGE_TEXT_ERROR = 'error!';
    @InvocableMethod
    public static List<MembershipResultObject> addBankDetails(List<cpm__Installment__c> installment) {
        try {
            String nctNumber = installment[0].NCT_Number_Parent__c;
            String contactId = installment[0].cpm__Contact__c;
            Contact cont = [
                SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, MailingPostalCode, Email, MailingStreet, MailingCity, MailingCountry 
                FROM Contact 
                WHERE Id =: contactId
                WITH SECURITY_ENFORCED
            ]; //NOPMD
            cpm__Payment_Profile__c paymentProfile = [
                SELECT Id, paybacs__Sort_Code__c, cpm__Bank_Account__c, cpm__Holder_Name__c
                FROM cpm__Payment_Profile__c
                WHERE Id =: installment[0].cpm__Payment_Profile__c
                WITH SECURITY_ENFORCED
            ];
            String bankDetailNumber = CareHelper.sendBankDetails(paymentProfile, cont, nctNumber);
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = MESSAGE_TYPE_SUCCESS;
            membershipResultObject.messageText = bankDetailNumber;
            return new List<MembershipResultObject> {membershipResultObject};
        } catch(Exception e) {
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = MESSAGE_TYPE_ERROR;
            membershipResultObject.messageText = MESSAGE_TEXT_ERROR;
            return new List<MembershipResultObject> {membershipResultObject};
        }
    }
}