@SuppressWarnings('PMD.EmptyStatementBlock')
//Incident #57 - https://confluence.nct.org.uk:8443/x/EoSO
public class AddMembershipBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private final String CARE_STATUS = 'Waiting';
    private final String SUCCESS_STATUS = 'Success';
    private final String FAILURE_STATUS = 'Failure';
    private final String PAYMENT_METHOD_CARE_MEMBERSHIP = 'Care Membership';
    private final String PAYMENT_PROCESSOR = 'PaymentHub-WorldPay';
    private final String PAYMENT_STATUS = 'Collected';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, ga_decl_1__c, ga_decl_2__c, Bank_Details_Number__c, Care_Add_Membership_Attempts__c, Care_Add_Membership_Tx_Code__c,
                cpm__Contact__r.Branch__r.Branch_Number__c, cpm__Payment_Method__c, cpm__Contact__r.NCT_Number__c,
                Partner_Contact__r.NCT_Number__c, Membership_Type__c, Membership_Amount__c 
            FROM cpm__Installment__c
            WHERE Care_Membership_Added__c = false 
            AND Care_Status__c =: CARE_STATUS 
            AND (
                (
                    cpm__Payment_Processor__c =: PAYMENT_PROCESSOR
                    AND cpm__Status__c =: PAYMENT_STATUS
                ) 
                OR cpm__Payment_Method__c =: PAYMENT_METHOD_CARE_MEMBERSHIP
            )
        ]);
    }

    public void execute(Database.BatchableContext bc, List<cpm__Installment__c> scope){
        for(cpm__Installment__c installment : scope) {
            installment.Care_Add_Membership_Attempts__c += 1;
            CareRequestBodyUtil.MembershipOjbect membershipOjbect = CareHelper.addMembership(installment);
            if(membershipOjbect.error == null) {
                installment.Care_Membership_Added__c = true;
                installment.Care_Error_Log__c = '';
                installment.Care_Status__c = SUCCESS_STATUS;
            } else {
                installment.Care_Error_Log__c = membershipOjbect.error[0].errorMessage;
                installment.Care_Status__c = FAILURE_STATUS;
            }
        }
        update scope;
    }

   public void finish(Database.BatchableContext bc){
   }
}