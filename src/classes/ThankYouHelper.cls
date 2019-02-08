public without sharing class ThankYouHelper {
    public boolean isStaff {get; set;}
    public string membershipNumber {get;set;}
    list<User> userList = new list<User>();
    public list<npe03__Recurring_Donation__c> reccDonList = new list<npe03__Recurring_Donation__c>();
    public npe03__Recurring_Donation__c recDon {get; set;}
    public ThankYouHelper(){
        Id userId = userinfo.getUserId();
        isStaff = ContactUtilities.isStaff(userId);
    }
      
    public String membershipNumberCreation(contact cont,npe03__Recurring_Donation__c recDon, Boolean lifeMembership){
        system.debug('Apexpages.currentPage().getParameters().get(contId) ---   ' + Apexpages.currentPage().getParameters().get('contId'));
        if(Apexpages.currentPage().getParameters().get('contId') != null && Apexpages.currentPage().getParameters().get('contId') !='')
        {
            system.debug('Apexpages.currentPage().getParameters().get(contId) ---   ' + Apexpages.currentPage().getParameters().get('contId'));
            reccDonList = [select Id, Membership_Number__c,npe03__Contact__c,npsp4hub__Payment_Method__c,npe03__Contact__r.AccountId,npe03__Contact__r.Phone,
                       npe03__Amount__c,npe03__Installment_Period__c,Membership_type__c, npe03__Contact__r.Prefered_First_Name__c,
                       npe03__Contact__r.LastName,npe03__Contact__r.Email,npe03__Installment_Amount__c, Membership_Status__c,
                       npe03__Date_Established__c from npe03__Recurring_Donation__c where npe03__Contact__c =: Apexpages.currentPage().getParameters().get('contId') limit 1];   
            if(reccDonList != null && !reccDonList.isEmpty())
            {
                membershipNumber = reccDonList[0].Membership_Number__c;
                reccDonList[0].Membership_Status__c = 'Confirmed';
                upsert reccDonList;
                system.debug('membershipNumber  ' + membershipNumber);
            }
            else if(reccDonList == null || reccDonList.isEmpty())
            {
                recDon = new npe03__Recurring_Donation__c();
                recDon.Name = 'Credit/Debit Card Membership';
                recDon.npe03__Amount__c = 60;
                recDon.npe03__Contact__c = Apexpages.currentPage().getParameters().get('contId');
                recDon.CARE_Payment_Frequency__c = 'One Time';
                recDon.First_Contact__c = Apexpages.currentPage().getParameters().get('contId');
                recDon.npe03__Installment_Period__c = 'Yearly';
                recDon.npsp4hub__Payment_Method__c = 'Credit/Debit Card';
                
                recDon.Membership_Status__c = 'Confirmed';
                
                Insert recDon;
            }
        }
        else{    
            if(cont != null && lifeMembership == true){
                recDon = new npe03__Recurring_Donation__c();
                recDon.Name = 'Staff Membership';
                recDon.npe03__Amount__c = 0;
                recDon.npe03__Contact__c = cont.Id;
                recDon.CARE_Payment_Frequency__c = 'One Time';
                recDon.First_Contact__c = cont.Id;
                recDon.npe03__Installment_Period__c = 'Yearly';
                
                recDon.Membership_Status__c = 'Confirmed';
               
                Insert recDon;
            }
                
            
        }
        if(recDon.Id != null)
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
            
            system.debug('RECCURRING DONATION record  ' + reccDonList);            
        } 
        return membershipNumber;
   }

}