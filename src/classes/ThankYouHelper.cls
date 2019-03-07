public without sharing class ThankYouHelper {
    public boolean isStaff {get; set;}
    public string membershipNumber {get;set;}
    public Membership_Type__mdt membershipDetails{get;set;}
    list<User> userList = new list<User>();
    public list<npe03__Recurring_Donation__c> reccDonList = new list<npe03__Recurring_Donation__c>();
    public npe03__Recurring_Donation__c recDon {get; set;}
    public ThankYouHelper(){
        Id userId = userinfo.getUserId();
        isStaff = ContactUtilities.isStaff(userId);
    }
    private Boolean permissionCheck(){
    	return !Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_Status__c.isAccessible()
              && (!Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_Status__c.isUpdateable() || !Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_Status__c.isCreateable());
    }
    private boolean contIdCheck(){
    	return Apexpages.currentPage().getParameters().get('contId') != null && Apexpages.currentPage().getParameters().get('contId') !='';
    }   
    public String membershipNumberCreation(contact cont,npe03__Recurring_Donation__c recDon, Boolean lifeMembership){
        if(permissionCheck()){ 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
                return null;
        }
         
        if(contIdCheck())
        {
          
          reccDonList = [select Id, Membership_Number__c,npe03__Contact__c,npsp4hub__Payment_Method__c,npe03__Contact__r.AccountId,npe03__Contact__r.Phone,
                       npe03__Amount__c,npe03__Installment_Period__c,Membership_type__c, npe03__Contact__r.Prefered_First_Name__c,
                       npe03__Contact__r.LastName,npe03__Contact__r.Email,npe03__Installment_Amount__c, Membership_Status__c,
                       npe03__Date_Established__c from npe03__Recurring_Donation__c where npe03__Contact__c =: Apexpages.currentPage().getParameters().get('contId') limit 1];   
            if(reccDonList != null && !reccDonList.isEmpty())
            {
                membershipNumber = reccDonList[0].Membership_Number__c;
                reccDonList[0].Membership_Status__c = MembershipConstants.CONFIRMED;
                upsert reccDonList;
            
            }
            
        }
        else if(recDon != null)
        {
            reccDonList = [select Id, Membership_Number__c,npe03__Contact__c,npsp4hub__Payment_Method__c,
                       npe03__Amount__c,npe03__Installment_Period__c,Membership_type__c, npe03__Contact__r.Prefered_First_Name__c,
                       npe03__Contact__r.LastName, npe03__Contact__r.Email,npe03__Installment_Amount__c, npe03__Contact__r.Phone,
                       npe03__Date_Established__c,npe03__Contact__r.AccountId from npe03__Recurring_Donation__c where Id =: recDon.Id];   
            if(reccDonList != null && !reccDonList.isEmpty())
            {
                membershipNumber = reccDonList[0].Membership_Number__c;
                system.debug('membershipNumber  ' + membershipNumber);
            } 
                      
        } 
        return membershipNumber;
   }

}