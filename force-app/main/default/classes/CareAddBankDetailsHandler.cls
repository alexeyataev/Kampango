@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #13 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class CareAddBankDetailsHandler {
    @InvocableMethod
    public static List<MembershipResultObject> addBankDetails(List<cpm__Installment__c> installment) {
        try {
            String contactId = installment[0].cpm__Contact__c;
            Contact cont = [
                SELECT NCT_Number__c
                FROM Contact 
                WHERE Id =: contactId
                WITH SECURITY_ENFORCED
            ];
            cpm__Payment_Profile__c paymentProfile = [
                SELECT Id, paybacs__Sort_Code__c, cpm__Bank_Account__c, cpm__Holder_Name__c
                FROM cpm__Payment_Profile__c
                WHERE Id =: installment[0].cpm__Payment_Profile__c
                WITH SECURITY_ENFORCED
            ];
            String bankDetailNumber = CareHelper.sendBankDetails(paymentProfile, cont);
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = CareRequestBodyUtil.MESSAGE_TYPE_SUCCESS;
            membershipResultObject.messageText = bankDetailNumber;
            return new List<MembershipResultObject> {membershipResultObject};
        } catch(Exception e) {
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = CareRequestBodyUtil.MESSAGE_TYPE_ERROR;
            membershipResultObject.messageText = CareRequestBodyUtil.MESSAGE_TEXT_ERROR;
            return new List<MembershipResultObject> {membershipResultObject};
        }
    }
}