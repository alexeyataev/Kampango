public without sharing class MembershipCrudHelper {
        
    public  gaid__Gift_Aid_Declaration__c gftAid {get;set;}
    public  cpm__Payment_Profile__c pymtPrfl{get;set;}
    public  npe03__Recurring_Donation__c recDon {get;set;}
    public contact primaryContact{get;set;}
    public contact secondaryContact{get;set;}
    public list<cpm__Payment_Profile__c> paymentProfileRecord = new list<cpm__Payment_Profile__c>();
    public list<gaid__Gift_Aid_Declaration__c> giftAidDeclarationRecord = new list<gaid__Gift_Aid_Declaration__c>();
    public list<npe03__Recurring_Donation__c> recDonationRecord = new list<npe03__Recurring_Donation__c>();
    @TestVisible
    NctETMembershipPaymentPageController eT;
    public MembershipCrudHelper(NctETMembershipPaymentPageController controller){
        eT = controller;        
    }
    private boolean paymentProfileCheck(){
        return !Schema.sObjectType.cpm__Payment_Profile__c.fields.RecordTypeId.isAccessible()
        &&(!Schema.sObjectType.cpm__Payment_Profile__c.fields.RecordTypeId.isCreateable() || !Schema.sObjectType.cpm__Payment_Profile__c.fields.RecordTypeId.isUpdateable());
    }
    private boolean giftAidCheck(){
        return !Schema.sObjectType.gaid__Gift_Aid_Declaration__c.fields.gaid__Contact__c.isAccessible()
        &&(!Schema.sObjectType.gaid__Gift_Aid_Declaration__c.fields.gaid__Contact__c.isUpdateable() || !Schema.sObjectType.gaid__Gift_Aid_Declaration__c.fields.gaid__Contact__c.isCreateable());
    }
    private boolean recDonationCheck(){
        return !Schema.sObjectType.npe03__Recurring_Donation__c.fields.Name.isAccessible()
        &&(!Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_type__c.isAccessible() || !Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_type__c.isCreateable()
        &&(!Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_type__c.isupdateable() || !Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_type__c.isCreateable()));
    }
    private boolean ismembershipSource(){
    	return eT.membershipVo.membershipSource != '' && eT.membershipVo.membershipSource != null;
    }
    public cpm__Payment_Profile__c paymentProfile(){
        if(paymentProfileCheck()){
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
                                    cpm__Contact__c = :primaryContact.id
                                AND
                                    CreatedDate = :System.Date.today() limit 1 FOR UPDATE];
        if(paymentProfileRecord.size()>0){
            if(paymentProfileCheck()){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
              return null;
             }
            paymentProfileRecord[0].RecordTypeId = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByName().get(MembershipConstants.BANK_ACCOUNT).getRecordTypeId();
            
                if(eT.membershipVo.accountNumber != '' && eT.membershipVo.accountNumber != null)
                {
                    paymentProfileRecord[0].cpm__Bank_Account__c = eT.membershipVo.accountNumber;
                }            
                paymentProfileRecord[0].cpm__Account__c = primaryContact.AccountId;
                paymentProfileRecord[0].cpm__Holder_Name__c = eT.membershipVo.accountName;
                paymentProfileRecord[0].paybacs__Sort_Code__c = eT.membershipVo.sortCode;
                upsert paymentProfileRecord[0];
                return paymentProfileRecord[0];
                
        }
        else{
            
            pymtPrfl = new cpm__Payment_Profile__c();
            system.debug(' *$*$*$* Contact Account Id   ' + primaryContact.AccountId);
            pymtPrfl.RecordTypeId = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByName().get(MembershipConstants.BANK_ACCOUNT).getRecordTypeId();
            pymtPrfl.cpm__Contact__c = primaryContact.Id; 
            if(eT.membershipVo.accountNumber != '' && eT.membershipVo.accountNumber != null)
            {
                pymtPrfl.cpm__Bank_Account__c = eT.membershipVo.accountNumber;
            }            
                pymtPrfl.cpm__Account__c = primaryContact.AccountId;
            pymtPrfl.cpm__Holder_Name__c = eT.membershipVo.accountName;
            pymtPrfl.paybacs__Sort_Code__c = eT.membershipVo.sortCode;
            
            upsert pymtPrfl;
            return pymtPrfl;
        }

        
        
    }
    public gaid__Gift_Aid_Declaration__c giftAid(Membership_Type__mdt membershipDetails){
        if(giftAidCheck()){
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
                                    gaid__Contact__c = :primaryContact.Id
                                    AND
                                    CreatedDate = :System.Date.today() limit 1];
        if(giftAidDeclarationRecord.size()>0){
            if(giftAidCheck()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
                return null;
            }
            giftAidDeclarationRecord[0].gaid__Type__c = membershipDetails.GiftAid_Type__c;
            if(eT.membershipVo.acquistion != '' && eT.membershipVo.acquistion != null){
                giftAidDeclarationRecord[0].gaid__Acquisition_Method__c = eT.membershipVo.acquistion;
            }
            else{
                giftAidDeclarationRecord[0].gaid__Acquisition_Method__c = membershipDetails.GiftAid_Acquisition_Method__c;
            }
            giftAidDeclarationRecord[0].gaid__Start_Date__c = system.date.today();
            giftAidDeclarationRecord[0].gaid__Date_Made__c = system.date.today();
            giftAidDeclarationRecord[0].gaid__Active__c = true;
            upsert giftAidDeclarationRecord[0];
            return giftAidDeclarationRecord[0];
            
        }
        else{
            gftAid = new gaid__Gift_Aid_Declaration__c();
            gftAid.gaid__Contact__c= primaryContact.Id;
            gftAid.gaid__Type__c = membershipDetails.GiftAid_Type__c;
            if(eT.membershipVo.acquistion != '' && eT.membershipVo.acquistion != null){
                gftAid.gaid__Acquisition_Method__c = eT.membershipVo.acquistion;
            }
            else{
                gftAid.gaid__Acquisition_Method__c = membershipDetails.GiftAid_Acquisition_Method__c;
            }
        
        
            gftAid.gaid__Start_Date__c = system.date.today();
            gftAid.gaid__Date_Made__c = system.date.today();
            gftAid.gaid__Active__c = true;
            
            Database.insert(gftAid, false);
            return gftAid;
            
        }
                       
    }
    public npe03__Recurring_Donation__c recDonation(Membership_Type__mdt membershipDetails,cpm__Payment_Profile__c pymtProfl){

            if(recDonationCheck()){
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
                                    npe03__Contact__c = :primaryContact.Id
                                AND
                                    CreatedDate = :System.Date.today() limit 1];
            
            if(recDonationRecord.size()>0){
                if(recDonationCheck()){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
                 return null;
                }                
                recDonationRecord[0].Name =membershipDetails.Contact_Type__c + ' ' + membershipDetails.Membership__c;
                recDonationRecord[0].npe03__Amount__c = membershipDetails.Installment_Amount__c;
                String membershipType = membershipTypeChecker(membershipDetails);
                recDonationRecord[0].Membership_type__c = membershipType; 
                recDonationRecord[0].npe03__Installments__c = membershipDetails.No_of_Installments__c;
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
                return recDonationRecord[0];   
            }
            else{
                    
                        recDon = new npe03__Recurring_Donation__c();
                recDon.Name =membershipDetails.Contact_Type__c + ' ' + membershipDetails.Membership__c+' '+membershipDetails.Payment_Method__c;
                recDon.npe03__Amount__c = membershipDetails.Installment_Amount__c;
                String membershipType = membershipTypeChecker(membershipDetails);
                recDon.Membership_type__c = membershipType; 
                recDon.npe03__Installments__c = membershipDetails.No_of_Installments__c;
                recDon.npe03__Contact__c = primaryContact.Id;
                if(ismembershipSource()){
                        recDon.Source__c = eT.membershipVo.membershipSource;
                }else{
                     recDon.Source__c = MembershipConstants.ONLINE_MEMBERSHIP_APPLICATION;
                }
                
                recDon.npe03__Next_Payment_Date__c = MembershipUtilties.getNextDonationDate(System.Date.today());
                recDon.First_Contact__c = primaryContact.Id;
                if(secondaryContact != null){
                    recDon.Second_Contact__c = secondaryContact.Id; 
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
            return recDon;
        }
       	 
    }
    private String membershipTypeChecker(Membership_Type__mdt membershipDetails){
        String membershipType;
        if(eT.booleanChecking.isVolunteer == true){
             membershipType = membershipDetails.Membership__c+' '+membershipDetails.Target_Customer__c+' - '+membershipDetails.Contact_Type__c;
        }
        else{
             membershipType = membershipDetails.Membership__c +' - '+ membershipDetails.Contact_Type__c; 
        }
        return membershipType;
               
    }
}