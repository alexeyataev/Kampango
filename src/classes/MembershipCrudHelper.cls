public without sharing class MembershipCrudHelper {
        
    public gaid__Gift_Aid_Declaration__c gftAid {get;set;}
    public cpm__Payment_Profile__c pymtPrfl{get;set;}
    public npe03__Recurring_Donation__c recDon {get;set;}
    public Contact pcont{set; get;}
    public Contact scont{set; get;}
    public String accountNumber {get; set;}
    public String sortCode {get; set;}
    public String accountName {get; set;}
    public String acquistion {get;set;}
    public String membershipSource{get;set;}

    public list<cpm__Payment_Profile__c> paymentProfileRecord = new list<cpm__Payment_Profile__c>();
    public list<gaid__Gift_Aid_Declaration__c> giftAidDeclarationRecord = new list<gaid__Gift_Aid_Declaration__c>();
    public list<npe03__Recurring_Donation__c> recDonationRecord = new list<npe03__Recurring_Donation__c>(); 
    
    
    public MembershipCrudHelper(){       
            pymtPrfl = new cpm__Payment_Profile__c();
            recDon = new npe03__Recurring_Donation__c();
            gftAid = new gaid__Gift_Aid_Declaration__c();
    }
    
    public cpm__Payment_Profile__c paymentProfile(){
        if (!Schema.sObjectType.cpm__Payment_Profile__c.fields.RecordTypeId.isAccessible()){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
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
                                    cpm__Contact__c = :pcont.id
                                AND
                                    CreatedDate = :System.Date.today() limit 1 FOR UPDATE];
        if(paymentProfileRecord.size()>0){
            if (!Schema.sObjectType.cpm__Payment_Profile__c.fields.RecordTypeId.isCreateable() || !Schema.sObjectType.cpm__Payment_Profile__c.fields.RecordTypeId.isUpdateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
                return null;
            }
            paymentProfileRecord[0].RecordTypeId = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByName().get(MembershipConstants.BANK_ACCOUNT).getRecordTypeId();
            
                if(accountNumber != '' && accountNumber != null)
                {
                    paymentProfileRecord[0].cpm__Bank_Account__c = accountNumber;
                }            
                paymentProfileRecord[0].cpm__Account__c = pcont.AccountId;
                paymentProfileRecord[0].cpm__Holder_Name__c = accountName;
                paymentProfileRecord[0].paybacs__Sort_Code__c = sortCode;
                upsert paymentProfileRecord[0];
                
        }
        else{
            
            pymtPrfl = new cpm__Payment_Profile__c();
            system.debug(' *$*$*$* Contact Account Id   ' + pcont.AccountId);
            pymtPrfl.RecordTypeId = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByName().get(MembershipConstants.BANK_ACCOUNT).getRecordTypeId();
            pymtPrfl.cpm__Contact__c = pcont.Id; 
            if(accountNumber != '' && accountNumber != null)
            {
                pymtPrfl.cpm__Bank_Account__c = accountNumber;
            }            
                pymtPrfl.cpm__Account__c = pcont.AccountId;
            pymtPrfl.cpm__Holder_Name__c = accountName;
            pymtPrfl.paybacs__Sort_Code__c = sortCode;
            
            upsert pymtPrfl;
            
        }
        if(paymentProfileRecord.size()>0){
            return paymentProfileRecord[0];
        }
        else{
            return pymtPrfl;
        }

        
        
    }
    public gaid__Gift_Aid_Declaration__c giftAid(Membership_Type__mdt membershipDetails){
        if (!Schema.sObjectType.gaid__Gift_Aid_Declaration__c.fields.gaid__Contact__c.isAccessible()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
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
                                    gaid__Contact__c = :pcont.Id
                                    AND
                                    CreatedDate = :System.Date.today() limit 1];
        if(giftAidDeclarationRecord.size()>0){
            if (!Schema.sObjectType.gaid__Gift_Aid_Declaration__c.fields.gaid__Contact__c.isUpdateable() || !Schema.sObjectType.gaid__Gift_Aid_Declaration__c.fields.gaid__Contact__c.isCreateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
                    return null;
            }
            giftAidDeclarationRecord[0].gaid__Type__c = membershipDetails.GiftAid_Type__c;
            if(acquistion != '' && acquistion != null){
                giftAidDeclarationRecord[0].gaid__Acquisition_Method__c = acquistion;
            }
            else{
                giftAidDeclarationRecord[0].gaid__Acquisition_Method__c = membershipDetails.GiftAid_Acquisition_Method__c;
            }
            giftAidDeclarationRecord[0].gaid__Start_Date__c = system.date.today();
            giftAidDeclarationRecord[0].gaid__Date_Made__c = system.date.today();
            giftAidDeclarationRecord[0].gaid__Active__c = true;
            upsert giftAidDeclarationRecord[0];
            
        }
        else{
            gftAid = new gaid__Gift_Aid_Declaration__c();
            gftAid.gaid__Contact__c= pcont.Id;
            gftAid.gaid__Type__c = membershipDetails.GiftAid_Type__c;
            if(acquistion != '' && acquistion != null){
                gftAid.gaid__Acquisition_Method__c = acquistion;
            }
            else{
                gftAid.gaid__Acquisition_Method__c = membershipDetails.GiftAid_Acquisition_Method__c;
            }
        
        
            gftAid.gaid__Start_Date__c = system.date.today();
            gftAid.gaid__Date_Made__c = system.date.today();
            gftAid.gaid__Active__c = true;
            
            Database.insert(gftAid, false);
            
        }
        if(giftAidDeclarationRecord.size()>0){
            return giftAidDeclarationRecord[0];
        }
        else{
            return gftAid;
        }
                       
    }
    public npe03__Recurring_Donation__c recDonation(Membership_Type__mdt membershipDetails,cpm__Payment_Profile__c pymtProfl){

            if(!Schema.sObjectType.npe03__Recurring_Donation__c.fields.Name.isAccessible()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
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
                                    npe03__Contact__c = :pcont.Id
                                AND
                                    CreatedDate = :System.Date.today() limit 1];
            
            if(recDonationRecord.size()>0){
                if(!Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_type__c.isAccessible() || !Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_type__c.isCreateable()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
                    return null;
                }
                recDonationRecord[0].Name =membershipDetails.Contact_Type__c + ' ' + membershipDetails.Membership__c;
                recDonationRecord[0].npe03__Amount__c = membershipDetails.Installment_Amount__c;
                recDonationRecord[0].Membership_type__c = membershipDetails.Membership__c;
                recDonationRecord[0].npe03__Installments__c = membershipDetails.No_of_Installments__c;
                if(membershipSource != '' && membershipSource != null){
                        recDonationRecord[0].Source__c = membershipSource;
                }
                if(scont != null){
                    recDonationRecord[0].Second_Contact__c = scont.Id; 
                }
                
                recDonationRecord[0].npe03__Next_Payment_Date__c = MembershipUtilties.getNextDonationDate(System.Date.today());
                recDonationRecord[0].npe03__Schedule_Type__c = membershipDetails.Schedule_Type__c;
                recDonationRecord[0].npe03__Installment_Period__c = membershipDetails.Installment_Period__c;
                recDonationRecord[0].npe03__Installments__c = membershipDetails.No_of_Installments__c;
                recDonationRecord[0].npsp4hub__Payment_Method__c = membershipDetails.Payment_Method__c;
                recDonationRecord[0].npsp4hub__Payment_Processor__c = membershipDetails.Payment_Processor__c;
                recDonationRecord[0].npsp4hub__Target__c = membershipDetails.Payment_Target__c;
                if(membershipDetails.Payment_Method__c != MembershipConstants.CREDIT_OR_DEBIT_CARD){
                recDonationRecord[0].Membership_Status__c = MembershipConstants.CONFIRMED;
                recDonationRecord[0].npsp4hub__Payment_Profile__c = pymtProfl.Id;
                }
                else{
                    recDonationRecord[0].Membership_Status__c = MembershipConstants.PENDING;
                }
                upsert recDonationRecord[0];
                
            }
            else{
                    
                        recDon = new npe03__Recurring_Donation__c();
                recDon.Name =membershipDetails.Contact_Type__c + ' ' + membershipDetails.Membership__c+' '+membershipDetails.Payment_Method__c;
                recDon.npe03__Amount__c = membershipDetails.Installment_Amount__c;
                recDon.Membership_type__c = membershipDetails.Membership__c;
                recDon.npe03__Installments__c = membershipDetails.No_of_Installments__c;
                recDon.npe03__Contact__c = pcont.Id;
                if(membershipSource != '' && membershipSource != null){
                        recDon.Source__c = membershipSource;
                }else{
                     recDon.Source__c = MembershipConstants.ONLINE_MEMBERSHIP_APPLICATION;
                }
                
                recDon.npe03__Next_Payment_Date__c = MembershipUtilties.getNextDonationDate(System.Date.today());
                recDon.First_Contact__c = pcont.Id;
                if(scont != null){
                    recDon.Second_Contact__c = scont.Id; 
                }
                if(!Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_type__c.isupdateable() || !Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_type__c.isCreateable()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
                    return null;
                }
                recDon.Data_Source__c = MembershipConstants.SALESFORCE;
                recDon.npe03__Schedule_Type__c = membershipDetails.Schedule_Type__c;
                recDon.npe03__Installment_Period__c = membershipDetails.Installment_Period__c;
                recDon.npe03__Installments__c = membershipDetails.No_of_Installments__c;
                recDon.npsp4hub__Payment_Method__c = membershipDetails.Payment_Method__c;
                recDon.npsp4hub__Payment_Processor__c = membershipDetails.Payment_Processor__c;
                recDon.npsp4hub__Target__c = membershipDetails.Payment_Target__c;
                if(membershipDetails.Payment_Method__c != MembershipConstants.CREDIT_OR_DEBIT_CARD){
                recDon.Membership_Status__c = MembershipConstants.CONFIRMED;
                recDon.npsp4hub__Payment_Profile__c = pymtProfl.Id;
                }
                else{
                    recDon.Membership_Status__c = MembershipConstants.PENDING;
                }
                Database.insert(recDon, false);
                
                
            }
            if(recDonationRecord.size()>0){
            return recDonationRecord[0];
        }
        else{
            return recDon;
        }
       	 
    }
}