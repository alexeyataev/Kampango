public without sharing class MembershipCrudHelper {
        
    public gaid__Gift_Aid_Declaration__c gftAid {get;set;}
    public cpm__Payment_Profile__c pymtPrfl {get;set;}
    public npe03__Recurring_Donation__c recDon {get;set;}   
    
    public MembershipCrudHelper(){       
            pymtPrfl = new cpm__Payment_Profile__c();
            recDon = new npe03__Recurring_Donation__c();
            gftAid = new gaid__Gift_Aid_Declaration__c();
    }
    
    public cpm__Payment_Profile__c paymentProfile(contact con,list<string> accountDetails){
        if(con != null)
        {
        system.debug(' *$*$*$* Contact Account Id   ' + con.AccountId);
            pymtPrfl.RecordTypeId = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();
            pymtPrfl.cpm__Contact__c = con.Id; 
            if(accountDetails[0] != '' && accountDetails[0] != null)
            {
                pymtPrfl.cpm__Bank_Account__c = accountDetails[0];
            }            
            pymtPrfl.cpm__Account__c = con.AccountId;
            pymtPrfl.cpm__Holder_Name__c = accountDetails[1];
            pymtPrfl.paybacs__Sort_Code__c = accountDetails[2];
            insert pymtPrfl;
        }
        return pymtPrfl;
    }
    public gaid__Gift_Aid_Declaration__c giftAid(ID contID, string isGiftAid,Membership_Type__mdt membershipDetails,list<string> accountDetails){
         if(contID != null)
        {
             if(isGiftAid == 'true') 
              {
                gftAid.gaid__Contact__c= contID;
                gftAid.gaid__Type__c = membershipDetails.GiftAid_Type__c;
                if(accountDetails[3] != '' && accountDetails[3] != null){
                      gftAid.gaid__Acquisition_Method__c = accountDetails[3];
                }
                else{
                      gftAid.gaid__Acquisition_Method__c = membershipDetails.GiftAid_Acquisition_Method__c;
                }
                gftAid.gaid__Start_Date__c = system.today();
                gftAid.gaid__Date_Made__c = system.today();
                gftAid.gaid__Active__c = true; 
                insert gftAid;
              } 
        }
        system.debug('GiftAid Record'+ gftAid);
        return gftAid;
    }
    public npe03__Recurring_Donation__c recDonation(ID contID,Membership_Type__mdt membershipDetails,cpm__Payment_Profile__c pymtPrfl,list<string> accountDetails){
         if(contID != null)
         {
             recDon.Name =membershipDetails.Contact_Type__c + ' ' + membershipDetails.Membership__c;
            recDon.npe03__Amount__c = membershipDetails.Installment_Amount__c;
            recDon.npe03__Installments__c = membershipDetails.No_of_Installments__c;
            recDon.npe03__Contact__c = contID;
            if(accountDetails[4] != '' && accountDetails[4] != null){
                 recDon.Source__c = accountDetails[4];
            }
            
            recDon.npe03__Next_Payment_Date__c = MembershipUtilties.getNextDonationDate(System.Date.today());
            recDon.First_Contact__c = contID;
            recDon.npe03__Schedule_Type__c = membershipDetails.Schedule_Type__c;
            recDon.npe03__Installment_Period__c = membershipDetails.Installment_Period__c;
            recDon.npe03__Installments__c = membershipDetails.No_of_Installments__c;
            recDon.npsp4hub__Payment_Method__c = membershipDetails.Payment_Method__c;
            recDon.npsp4hub__Payment_Processor__c = membershipDetails.Payment_Processor__c;
            recDon.npsp4hub__Target__c = membershipDetails.Payment_Target__c;
            recDon.Membership_Status__c = 'Confirmed';
            recDon.npsp4hub__Payment_Profile__c = pymtPrfl.Id;
            insert recDon;
         }
        return recDon;
    }
}