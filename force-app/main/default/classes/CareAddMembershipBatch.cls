public class CareAddMembershipBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, ga_decl_1__c, ga_decl_2__c, Bank_Details_Number__c, cpm__Payment_Method__c, cpm__Contact__r.NCT_Number__c, Partner_Contact__r.NCT_Number__c, Membership_Type__c, cpm__Amount__c FROM cpm__Installment__c WHERE Care_Membership_Added__c = false AND Bank_Details_Number__c != null');
    }

    public void execute(Database.BatchableContext bc, List<cpm__Installment__c> scope){
        List<cpm__Installment__c> installmentUpdateList = new List<cpm__Installment__c>();
        for(cpm__Installment__c installment : scope) {
            CareHelper.AddMembershipStatus addMembershipStatus = CareHelper.addMembership(installment);
            if(addMembershipStatus == CareHelper.AddMembershipStatus.SUCCESS) {
                installment.Care_Membership_Added__c = true;
                installmentUpdateList.add(installment);
            }
        }
        update installmentUpdateList;
    }

   public void finish(Database.BatchableContext bc){
   }
}