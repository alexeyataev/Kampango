public class MembershipController {

    public String getMembership() {
        return null;
    }

    public list<npe03__Recurring_Donation__c> lstMemberShipInfo {get;set;}
    public Id selectedMemberId{get;set;}   
    
    public MembershipController()
    { 
        if(userInfo.getUserId() != null)
        {
            User usr = [select Id, ContactId from User where Id =: userInfo.getUserId()];
            selectedMemberId = usr.ContactId;
        }
        lstMemberShipInfo = [select Id,Name,Membership_Number__c,First_Contact__c,First_Contact__r.Prefered_First_Name__c,Membership_type__c,npsp4hub__Payment_Method__c,npe03__Installments__c,npe03__Installment_Period__c,npe03__Installment_Amount__c,npe03__Amount__c,Last_Payment__c,Renewal_Date__c from npe03__Recurring_Donation__c where First_Contact__c =: selectedMemberId limit 1];
        if(lstMemberShipInfo.isEmpty()){
            lstMemberShipInfo = new list<npe03__Recurring_Donation__c>();
        }
    }
}