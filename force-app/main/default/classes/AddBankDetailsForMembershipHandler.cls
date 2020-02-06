@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #13 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class AddBankDetailsForMembershipHandler {
    @InvocableMethod
    public static List<AddBankDetailsResult> addBankDetails(List<cpm__Installment__c> installment) {
        AddBankDetailsResult addBankDetailsResult = new AddBankDetailsResult();
        try {
            if(installment == null || installment.size() != 1 || installment[0] == null) {
                throw new ListException('1 installment parameter must be passed');
            }
            String contactId = installment[0].cpm__Contact__c;
            Contact cont = [
                SELECT NCT_Number__c, Branch__r.Branch_Number__c
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
            addBankDetailsResult = CareHelper.sendBankDetails(paymentProfile, cont);
            return new List<AddBankDetailsResult> {addBankDetailsResult};
        } catch(Exception e) {
            addBankDetailsResult.error = e.getMessage();
            return new List<AddBankDetailsResult> {addBankDetailsResult};
        }
    }
}