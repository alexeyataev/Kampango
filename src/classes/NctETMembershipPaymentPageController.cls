public without sharing class NctETMembershipPaymentPageController 
{
    public contact cont;
    public MembershipVo.AccountInfo accountInformation{get; set;}
    public MembershipVo.BooleanCheck booleanChecking{get;set;}
    public MembershipVo.MembershipInformation membershipDetails{get;set;}
    public MembershipVo.SecondContactVo secondContact{get;set;}
    @TestVisible
    private npe03__Recurring_Donation__c recDon;
    @TestVisible
    private date expDate;
    private static Boolean inspect = false;
    public static Boolean onComplete {get; set;}     
    private List<Contact> contactList;    
    
    @TestVisible
    private contact primaryContact;
    @TestVisible
    private contact secondaryContact;
    
    public NctETMembershipPaymentPageController(ApexPages.StandardController controller)
    {  
        this.cont = (contact)controller.getRecord();
        system.debug('*$*$**$ contId  ' + cont.id);
        recDon = new npe03__Recurring_Donation__c();
       	Contact con= new Contact();
        gaid__Gift_Aid_Declaration__c gifAid = new gaid__Gift_Aid_Declaration__c();
        npe03__Recurring_Donation__c recDonate = new npe03__Recurring_Donation__c();
        
        system.debug('tt' + cont);
        accountInformation = new MembershipVo.AccountInfo();
        booleanChecking = new MembershipVo.BooleanCheck();
        membershipDetails  = new MembershipVo.MembershipInformation();        
        secondContact = new MembershipVo.SecondContactVo();
            
        booleanChecking.salutationOptions = SObjectUtilities.getPicklistValues(con, 'salutation');
        booleanChecking.genderOptions = SObjectUtilities.getPicklistValues(con, 'Gender__c');
        membershipDetails.acquistionOptions = SObjectUtilities.getPicklistValues(gifAid, 'gaid__Acquisition_Method__c');
        membershipDetails.membershipSourceOptions = SObjectUtilities.getPicklistValues(recDonate, 'Source__c');      	        
  
        
        membershipDetails.staffMember = MembershipConstants.NOSTAFF;
        if(cont.id != null)
        {            
            displayContactDataForExistingContact();        
        }
        booleanChecking.displaySuccessMessage = false;
        booleanChecking.displayMbrNoMessage = false;
        accountInformation.accountName='';
        accountInformation.sortCode='';
    }
    private void displayContactDataForExistingContact(){
         	if(!Schema.sObjectType.Contact.fields.Data_Source__c.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
             }     
            booleanChecking.isStaff = ContactUtilities.isStaff(cont.id);
            booleanChecking.isMembershipExists = ContactUtilities.isMembershipExists(cont.id, cont.email);
            membershipDetails.staffMember = MembershipConstants.STAFF; 
            primaryContact = [SELECT Id,Salutation,DoNotCall, SMS_Opt_In__c, Post_Opt_In__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,Contact_Prefrence__c,Prefered_First_Name__c,AccountId,Expected_Due_Date__c,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,Branch__r.Name,Branch__c FROM Contact where id=:ApexPages.currentPage().getParameters().get('Id')];
            booleanChecking.isCompanionContactExisting = ContactUtilities.isCompanionContactExisting(cont.id);
            System.debug('isCompanionContactExisting '+booleanChecking.isCompanionContactExisting );

            if(primaryContact != null){  
                secondContact.eDate = String.valueof(primaryContact.Expected_Due_Date__c);
                membershipDetails.nearestBranchs = MembershipConditionHelper.assignBranchValues(primaryContact.Branch__c);
            }
            List<Contact> secondaryContactList = [SELECT Id,Salutation,DoNotCall, Branch__c,SMS_Opt_In__c, Post_Opt_In__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,MailingPostalCode,Contact_Prefrence__c,Prefered_First_Name__c,AccountId FROM Contact where Parent_Contact__c =:primaryContact	.Id LIMIT 1];
            if(secondaryContactList.size()>0){
                
                secondContact.secondContactFirstName = secondaryContactList[0].FirstName;
                secondContact.secondContactLastName = secondaryContactList[0].LastName;
                secondContact.secondContactEmail = secondaryContactList[0].Email;
                secondContact.secondContactPhone = secondaryContactList[0].Phone;
                secondContact.salutationSecondary = secondaryContactList[0].Salutation;
                secondContact.secondContactGenders = secondaryContactList[0].Gender__c;

            }
    }
   public PageReference  receiveInput(){                
       if(MembershipConditionCheckUtilities.dateFormatCheck(secondContact.eDate)){
        expDate = Date.valueOf(secondContact.eDate);
        }
        Boolean isPractitioner;
        booleanChecking.isVolunteer = ContactUtilities.isVolunteerExisting(cont.Id);
        isPractitioner = MembershipUtilties.isPractitioner(cont.firstname,cont.lastname,cont.email);
        list<Boolean> contactBooleanList = new list<Boolean>{booleanChecking.isStaff,booleanChecking.isVolunteer,isPractitioner,booleanChecking.twomems};
        accountInformation.targetCustomer = ContactUtilities.targetCustomer(contactBooleanList);
        booleanChecking.isMembershipExists = ContactUtilities.isMembershipExists(cont.Id,cont.email);
        
        if(MembershipConditionCheckUtilities.receiveInputPermissionCheck()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
        }

       
       
        if(MembershipConditionCheckUtilities.isNotExistingContactCheck(booleanChecking.isContactExisting,primaryContact)){

                accountInformation.recordType = MembershipConstants.PARENT;
                    primaryContact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(accountInformation.recordType).getRecordTypeId(),FirstName=cont.firstname,
                                        LastName=cont.lastname,Email=cont.email,Gender__c=cont.Gender__c,Phone=cont.phone,Salutation=cont.salutation,MailingPostalCode=cont.MailingPostalCode,
                                        Expected_Due_Date__c =expDate,MailingStreet=cont.MailingStreet+secondContact.streetValue1+secondContact.streetValue2,Branch__c=cont.Branch__c,
                                        MailingState=cont.MailingState,MailingCity=cont.MailingCity,Data_Source__c = MembershipConstants.SALESFORCE,SMS_Opt_In__c=cont.SMS_Opt_In__c,Post_Opt_In__c=cont.Post_Opt_In__c,
                                        HasOptedOutOfEmail=cont.HasOptedOutOfEmail,DoNotCall=cont.DoNotCall);
                    Database.SaveResult sr = Database.insert(primaryContact, false);
                MembershipConditionHelper.saveResultCheck(sr);
            	secondaryContactCreation();
         }
        else if(MembershipConditionCheckUtilities.isExistingContactCheck(cont.Id,booleanChecking.isContactExisting)){
            
            System.debug('Contact Exists(Next Flow Starts): '+booleanChecking.isContactExisting);
            primaryContact = MembershipConditionHelper.contactFinder(cont.Id,cont.email);
            contactList =[SELECT Id,Salutation,Gender__c,Parent_Contact__c,Branch__c, LastName, FirstName, Email,MailingStreet,MailingState,MailingCity, Phone,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact WHERE Parent_Contact__c = :primaryContact.Id];
            
            primaryContact.Branch__c = Cont.Branch__c;
            primaryContact.MailingPostalCode = Cont.MailingPostalCode;
            primaryContact.MailingStreet = Cont.MailingStreet+secondContact.streetValue1+secondContact.streetValue2;
            primaryContact.MailingState = Cont.MailingState;
            primaryContact.MailingCity = Cont.MailingCity;
    
            Database.update(primaryContact, false);
            secondaryContactCreation();
            
        }    
       membershipDetails.membershipTypeMap = MembershipUtilties.getMembershipTypeMap(accountInformation.contactType,accountInformation.targetCustomer,false);    
           return null;
    }
    @TestVisible
    private void secondaryContactCreation(){
        Contact con;
        if(MembershipConditionCheckUtilities.secondContactRequiredCheck(booleanChecking.twomems,primaryContact.id,secondContact.secondContactFirstName))
        {            
            accountInformation.recordType = MembershipConstants.COMPANION;
            con =[Select AccountId from Contact where id = :primaryContact.id];
            
            secondaryContact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(accountInformation.recordType).getRecordTypeId(),FirstName=secondContact.secondContactFirstName,
                                                         LastName=secondContact.secondContactLastName,Email=secondContact.secondContactEmail,Gender__c=secondContact.secondContactGenders,Phone=secondContact.secondContactPhone,Salutation=secondContact.salutationSecondary,MailingPostalCode=cont.MailingPostalCode,
                                                         Expected_Due_Date__c =expDate,MailingStreet=cont.MailingStreet+secondContact.streetValue1+secondContact.streetValue2,Branch__c=cont.Branch__c,
                                                         MailingState=cont.MailingState,MailingCity=cont.MailingCity,Data_Source__c = MembershipConstants.SALESFORCE,SMS_Opt_In__c=cont.SMS_Opt_In__c,Post_Opt_In__c=cont.Post_Opt_In__c,
                                                         HasOptedOutOfEmail=cont.HasOptedOutOfEmail,DoNotCall=cont.DoNotCall,Parent_Contact__c = primaryContact.id,AccountId = con.AccountId);
            Database.SaveResult srSec = Database.insert(secondaryContact, false);
            MembershipConditionHelper.saveResultCheck(srSec);
            accountInformation.contactType = MembershipConstants.JOINT;
        }                              
		accountInformation.contactType = MembershipConditionHelper.companionCheck(booleanChecking.twomems); 
    }
    public pageReference contactInfo(){
        if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
             }
         
        system.debug('*$*$*$  feeAmount   ' + accountInformation.feeAmount);
        
        membershipDetails.membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                            No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                            Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                            GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                            where Id =:accountInformation.feeAmount];
        System.debug('Membership##### '+membershipDetails.membershipInfo);
		  accountInformation.sessionProfile = userinfo.getUserType();
         if(membershipDetails.membershipInfo != null && accountInformation.sessionProfile != MembershipConstants.STANDARD && membershipDetails.membershipInfo.Payment_Method__c == MembershipConstants.CREDIT_OR_DEBIT_CARD)
          { 

              paymentHubCallout();
              PageReference pageRef = new PageReference(''+accountInformation.redirectURL);    
              pageRef.setRedirect(true);
              return pageRef;                    
          }
         return null;
    }
    public void onCompleteContactInfo(){
        onComplete = true;

    }
    public void nctBranchs(){
        
        String emails = Apexpages.currentPage().getParameters().get('emailsVal').escapeHtml4();
        if(cont.Id == null){
            booleanChecking.isContactExisting = ContactUtilities.isContactExisting(emails);

        }
        booleanChecking.isMembershipExists = ContactUtilities.isMembershipExists(cont.Id, emails);
        cont.Mailing_Postal_Code__c = Apexpages.currentPage().getParameters().get('postVal').escapeHtml4();

        if(cont.Mailing_Postal_Code__c != null && cont.Mailing_Postal_Code__c != ''){
        membershipDetails.nearestBranchs = MembershipUtilties.getBranches(cont.Mailing_Postal_Code__c);
        system.debug('nct branches'+membershipDetails.nearestBranchs );
        }
        }
    public void membershipDupeChecker(){
        
        String emails = Apexpages.currentPage().getParameters().get('emailDupeVal').escapeHtml4();

        if(cont.Id == null){
            booleanChecking.isContactExisting = ContactUtilities.isContactExisting(emails);       
        }
        booleanChecking.isMembershipExists = ContactUtilities.isMembershipExists(cont.Id, emails);
       
    }
    public void giftAidCreation(){
        if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
        }
        booleanChecking.displayMbrNoMessage = true;
        if(accountInformation.sessionProfile != MembershipConstants.STANDARD){
            accountInformation.feeAmount = Apexpages.currentPage().getParameters().get('seltAmountdName').escapeHtml4();
            PageReference redirecContUrl;

            membershipDetails.membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:accountInformation.feeAmount];
        }
      	
        System.debug('Membership##### '+membershipDetails.membershipInfo);
        booleanChecking.displaySuccessMessage = true;
        thankYouSec();
        inspect = true;
    }
   
    public void paymentSave()
    {   
        booleanChecking.displayMbrNoMessage = true;
        booleanChecking.displaySuccessMessage = false;
        thankYouSec();
    }
    public void thankYouSec()
    {
        if(accountInformation.sessionProfile == MembershipConstants.STANDARD && membershipDetails.membershipInfo.Payment_Method__c == MembershipConstants.CREDIT_OR_DEBIT_CARD){
            paymentHubCallout();                
        }
           
        MembershipVo.MemberCrudHelper crudHelper = new MembershipVo.MemberCrudHelper();
        crudHelper.accountName = accountInformation.accountName;
        crudHelper.accountNumber = accountInformation.accountNumber;
        crudHelper.acquistion = membershipDetails.acquistion;
        crudHelper.membershipSource = membershipDetails.membershipSource;
        crudHelper.sortCode = accountInformation.sortCode;
        crudHelper.pcont = primaryContact;
        crudHelper.scont = secondaryContact;
        crudHelper.isVolunteer = booleanChecking.isVolunteer;
        cpm__Payment_Profile__c pymtPrfl = new cpm__Payment_Profile__c();
        MembershipCrudHelper.crudHelper = crudHelper;
        if(membershipDetails.membershipInfo.Payment_Method__c != MembershipConstants.CREDIT_OR_DEBIT_CARD){
           pymtPrfl = MembershipCrudHelper.paymentProfile();
        }
        recDon = MembershipCrudHelper.recDonation(membershipDetails.membershipInfo,pymtPrfl);
        membershipNumberDisplay();
        gaid__Gift_Aid_Declaration__c gftAid = new gaid__Gift_Aid_Declaration__c();
        if(accountInformation.isGiftAid == MembershipConstants.TRUE_VALUE){
        	gftAid = MembershipCrudHelper.giftAid(membershipDetails.membershipInfo);
        }
        
    }    
    public void membershipNumberDisplay(){
       booleanChecking.displayMbrNoMessage = true;
       membershipDetails.membershipNumber = ThankYouHelper.membershipNumberCreation(primaryContact,recDon);
    }
    
    public PageReference paymentHubCallout()
    {   
        list<String> contactDetails = new list<String>();
        contactDetails.add(Cont.email);
        contactDetails.add(Cont.firstname);
        contactDetails.add(Cont.lastname);

        accountInformation.redirectURL = PaymentHubCalloutUtilities.PaymentHub(primaryContact,membershipDetails.membershipInfo,contactDetails);
        accountInformation.sessionProfile = userinfo.getUserType();
        if(accountInformation.sessionProfile == MembershipConstants.STANDARD){
            return sendPaymentLinkToParent(accountInformation.redirectURL);
        }
        else{
            return null;
        }
       
    }
    
    public PageReference sendPaymentLinkToParent(string paymentLink)
    {   
        /* Updated by Mahanth 20/12/2018
        *  The following code creates a payment link record
        *   
        */
        System.debug('********** Creating Payment Link Record **************');
        if(!Schema.sObjectType.Payment_Link__c.fields.Email__c.isCreateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
        }
        Payment_Link__c payLink = new Payment_Link__c();
        payLink.Contact__c = primaryContact.Id;
        payLink.Email__c = primaryContact.Email;
        payLink.Link_Sent_Date__c = Date.Today();
        payLink.Payment_Key__c = MembershipConstants.TEST;
        payLink.Payment_Link__c = paymentLink;
        insert payLink;
        System.debug('Payment Link Record Created : '+'ID: '+payLink.Id+', /r/n'+payLink.Contact__c+', '+payLink.Payment_Key__c+', '+payLink.Payment_Link__c);
        return null;
    }

}