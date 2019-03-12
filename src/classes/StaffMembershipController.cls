public with sharing class StaffMembershipController{
	public static list<npe03__Recurring_Donation__c> recurringDon{set;get;}
    @auraenabled
    public static void membershipInsert(Id contId)
    { 
        if (!Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_Number__c.isAccessible()
            && !Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible()
            && !Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_type__c.isCreateable()){
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
        }  
       Membership_Type__mdt membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Payment_Type__c= :MembershipConstants.LIFEMEMBERSHIP limit 1];
       recurringDon= [SELECT
                          Id,
                          Name,
                          npe03__Amount__c,
                          npe03__Installments__c,
                          npe03__Contact__c,
                          Source__c,
                          npe03__Next_Payment_Date__c,
                          First_Contact__c,
                          Second_Contact__c,
                          npe03__Schedule_Type__c,
                          npe03__Installment_Period__c,
                          npsp4hub__Payment_Method__c,
                          CARE_Payment_Frequency__c,
                          npsp4hub__Payment_Processor__c,
                          npsp4hub__Target__c,
                          Membership_Status__c,
                          npsp4hub__Payment_Profile__c
                      FROM
                          npe03__Recurring_Donation__c
                      WHERE
                          npe03__Contact__c = :contId limit 1];
        if(recurringDon.size() == 0 || recurringDon.size() == null){
                npe03__Recurring_Donation__c recurringDonation = new npe03__Recurring_Donation__c();
                recurringDonation.Name = membershipDetails.Contact_Type__c + ' ' + membershipDetails.Membership__c;
                recurringDonation.npe03__Amount__c = membershipDetails.Installment_Amount__c;
                recurringDonation.npe03__Contact__c = contId;
                recurringDonation.First_Contact__c = contId;
                recurringDonation.npe03__Installment_Period__c = membershipDetails.Installment_Period__c;
                recurringDonation.npe03__Installments__c = membershipDetails.No_of_Installments__c;
                recurringDonation.Membership_Status__c = MembershipConstants.CONFIRMED;
                Insert recurringDonation;
        }
        else{
            AuraHandledException e = new AuraHandledException('You Cant Add Membership, hence membership already exists for this contact');
            e.setMessage('You Cant Add Membership, hence membership already exists for this contact');
            system.debug(e);
            throw e;
        }

     }
}