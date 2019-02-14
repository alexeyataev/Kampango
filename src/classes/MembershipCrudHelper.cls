public without sharing class MembershipCrudHelper {
        
    public gaid__Gift_Aid_Declaration__c gftAid {get;set;}
    public cpm__Payment_Profile__c pymtPrfl{get;set;}
    public npe03__Recurring_Donation__c recDon {get;set;}
    public list<cpm__Payment_Profile__c> paymentProfileRecord = new list<cpm__Payment_Profile__c>();
    public list<gaid__Gift_Aid_Declaration__c> giftAidDeclarationRecord = new list<gaid__Gift_Aid_Declaration__c>();
    public list<npe03__Recurring_Donation__c> recDonationRecord = new list<npe03__Recurring_Donation__c>(); 
    
    
    public MembershipCrudHelper(){       
            pymtPrfl = new cpm__Payment_Profile__c();
            recDon = new npe03__Recurring_Donation__c();
            gftAid = new gaid__Gift_Aid_Declaration__c();
    }
    
    public cpm__Payment_Profile__c paymentProfile(contact con,list<string> accountDetails){
        if(con != null)
        {
             if (!Schema.sObjectType.cpm__Payment_Profile__c.fields.RecordTypeId.isCreateable() &&
                 Schema.sObjectType.cpm__Payment_Profile__c.fields.RecordTypeId.isUpdateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
         }
            paymentProfileRecord = [SELECT 
                                        Id, 
                                        RecordTypeId,
                                        cpm__Contact__c,
                                        cpm__Bank_Account__c,
                                        cpm__Holder_Name__c,
                                        paybacs__Sort_Code__c 
                                    FROM 
                                        cpm__Payment_Profile__c 
                                    WHERE 
                                        cpm__Contact__c = :con.id
                                    AND
                                        CreatedDate = :System.Date.today() limit 1];
            if(paymentProfileRecord.size()>0){
                paymentProfileRecord[0].RecordTypeId = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();
                    //extPymtPrfyl.cpm__Contact__c = con.Id; 
                    if(accountDetails[0] != '' && accountDetails[0] != null)
                    {
                        paymentProfileRecord[0].cpm__Bank_Account__c = accountDetails[0];
                    }            
                    paymentProfileRecord[0].cpm__Account__c = con.AccountId;
                    paymentProfileRecord[0].cpm__Holder_Name__c = accountDetails[1];
                    paymentProfileRecord[0].paybacs__Sort_Code__c = accountDetails[2];
                	upsert paymentProfileRecord[0];
                	
            }
            else{
                if (!Schema.sObjectType.cpm__Payment_Profile__c.fields.cpm__Account__c.isUpdateable() || 
                    !Schema.sObjectType.cpm__Payment_Profile__c.fields.cpm__Account__c.isCreateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
         }
               
                pymtPrfl = new cpm__Payment_Profile__c();
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
                
                upsert pymtPrfl;
                
            }
            if(paymentProfileRecord.size()>0){
                return paymentProfileRecord[0];
            }
            else{
                return pymtPrfl;
            }
        }
        else{
            return null;
        }
        
        
    }
    public gaid__Gift_Aid_Declaration__c giftAid(ID contID, string isGiftAid,Membership_Type__mdt membershipDetails,list<string> accountDetails){
         
        if(contID != null && isGiftAid == 'true') 
        {
            if (!Schema.sObjectType.gaid__Gift_Aid_Declaration__c.fields.gaid__Type__c.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
         }
            giftAidDeclarationRecord = [SELECT 
                                        id,
                                        gaid__Type__c,
                                        gaid__Acquisition_Method__c,
                                        gaid__Start_Date__c,
                                        gaid__Date_Made__c,
                                        gaid__Active__c 
                                        FROM
                                        gaid__Gift_Aid_Declaration__c
                                        WHERE 
                                        gaid__Contact__c = :contID
                                        AND
                                        CreatedDate = :System.Date.today() limit 1];
            if(giftAidDeclarationRecord.size()>0){
                
                giftAidDeclarationRecord[0].gaid__Type__c = membershipDetails.GiftAid_Type__c;
                if(accountDetails[3] != '' && accountDetails[3] != null){
                    giftAidDeclarationRecord[0].gaid__Acquisition_Method__c = accountDetails[3];
                }
                else{
                    giftAidDeclarationRecord[0].gaid__Acquisition_Method__c = membershipDetails.GiftAid_Acquisition_Method__c;
                }
                giftAidDeclarationRecord[0].gaid__Start_Date__c = system.today();
                giftAidDeclarationRecord[0].gaid__Date_Made__c = system.today();
                giftAidDeclarationRecord[0].gaid__Active__c = true;
                upsert giftAidDeclarationRecord[0];
                
            }
            else{
               if (!Schema.sObjectType.gaid__Gift_Aid_Declaration__c.fields.gaid__Contact__c.isUpdateable() || 
                    !Schema.sObjectType.gaid__Gift_Aid_Declaration__c.fields.gaid__Contact__c.isCreateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
         }
                gftAid = new gaid__Gift_Aid_Declaration__c();
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
                
                upsert gftAid;
                
            }
            if(giftAidDeclarationRecord.size()>0){
                return giftAidDeclarationRecord[0];
            }
            else{
                return gftAid;
            }
            
        }
        else{
            return null;
        }
     
        
    }
    public npe03__Recurring_Donation__c recDonation(ID contID,Contact scont,Membership_Type__mdt membershipDetails,cpm__Payment_Profile__c pymtProfl,list<string> accountDetails){
         if(contID != null)
         {
              if (!Schema.sObjectType.npe03__Recurring_Donation__c.fields.Name.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
         }
             recDonationRecord =[SELECT
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
                                     npe03__Contact__c = :contID
                                 AND
                                     CreatedDate = :System.Date.today() limit 1];
             
             if(recDonationRecord.size()>0){
                 recDonationRecord[0].Name =membershipDetails.Contact_Type__c + ' ' + membershipDetails.Membership__c;
                    recDonationRecord[0].npe03__Amount__c = membershipDetails.Installment_Amount__c;
                    recDonationRecord[0].Membership_type__c = membershipDetails.Membership__c;
                    recDonationRecord[0].npe03__Installments__c = membershipDetails.No_of_Installments__c;
                    if(accountDetails[4] != '' && accountDetails[4] != null){
                         recDonationRecord[0].Source__c = accountDetails[4];
                    }
                    if(scont != null){
                        recDonationRecord[0].Second_Contact__c = scont.Id; 
                    }
                    
                    recDonationRecord[0].npe03__Next_Payment_Date__c = MembershipUtilties.getNextDonationDate(System.Date.today());
                    recDonationRecord[0].npe03__Schedule_Type__c = membershipDetails.Schedule_Type__c;
                    recDonationRecord[0].npe03__Installment_Period__c = membershipDetails.Installment_Period__c;
                    recDonationRecord[0].npe03__Installments__c = membershipDetails.No_of_Installments__c;
                    recDonationRecord[0].npsp4hub__Payment_Method__c = membershipDetails.Payment_Method__c;
                    recDonationRecord[0].CARE_Payment_Frequency__c = 'Care Frequency';
                    recDonationRecord[0].npsp4hub__Payment_Processor__c = membershipDetails.Payment_Processor__c;
                    recDonationRecord[0].npsp4hub__Target__c = membershipDetails.Payment_Target__c;
                    recDonationRecord[0].Membership_Status__c = 'Confirmed';
                    recDonationRecord[0].npsp4hub__Payment_Profile__c = pymtProfl.Id;
                 	upsert recDonationRecord[0];
                 	
             }
             else{
                     if (!Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_type__c.isAccessible() ||
                        Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_type__c.isCreateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
         }     
                         recDon = new npe03__Recurring_Donation__c();
                 recDon.Name =membershipDetails.Contact_Type__c + ' ' + membershipDetails.Membership__c;
                    recDon.npe03__Amount__c = membershipDetails.Installment_Amount__c;
                    recDon.Membership_type__c = membershipDetails.Membership__c;
                    recDon.npe03__Installments__c = membershipDetails.No_of_Installments__c;
                    recDon.npe03__Contact__c = contID;
                    if(accountDetails[4] != '' && accountDetails[4] != null){
                         recDon.Source__c = accountDetails[4];
                    }
                    
                    recDon.npe03__Next_Payment_Date__c = MembershipUtilties.getNextDonationDate(System.Date.today());
                    recDon.First_Contact__c = contID;
                 	if(scont != null){
                        recDon.Second_Contact__c = scont.Id; 
                    }
                 
                 	recDon.Data_Source__c = 'Salesforce';
                    recDon.npe03__Schedule_Type__c = membershipDetails.Schedule_Type__c;
                    recDon.npe03__Installment_Period__c = membershipDetails.Installment_Period__c;
                    recDon.npe03__Installments__c = membershipDetails.No_of_Installments__c;
                    recDon.npsp4hub__Payment_Method__c = membershipDetails.Payment_Method__c;
                    recDon.CARE_Payment_Frequency__c = 'Care Frequency';
                    recDon.npsp4hub__Payment_Processor__c = membershipDetails.Payment_Processor__c;
                    recDon.npsp4hub__Target__c = membershipDetails.Payment_Target__c;
                    recDon.Membership_Status__c = 'Confirmed';
                    recDon.npsp4hub__Payment_Profile__c = pymtProfl.Id;
                    upsert recDon;
                 	
                 	
             }
             if(recDonationRecord.size()>0){
                return recDonationRecord[0];
            }
            else{
                return recDon;
            }
         }
        else{
            return null;
        }
       	 
    }
}