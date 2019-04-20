public without sharing class NctETMembershipPaymentPageController 
{
    public contact cont;
    public  MembershipVo membershipVo{get; set;}
    public  MembershipBooleanCheckVo booleanChecking{get;set;}
    public  MembershipContactVo.SecondContactVo secondContact{get;set;}
    public  MembershipContactVo contactVo{get;set;}
    public  MembershipBooleanCheckVo.AccountDetails accountDetails{get;set;}
    private String contactType{get; set;}
    @TestVisible
    private npe03__Recurring_Donation__c recDon;
    @TestVisible
    private date expDate;
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
        
        system.debug('contact' + cont);
        membershipVo = new MembershipVo();
        booleanChecking = new MembershipBooleanCheckVo();      
        secondContact = new MembershipContactVo.SecondContactVo();
        contactVo = new MembershipContactVo();
        accountDetails = new MembershipBooleanCheckVo.AccountDetails();
            
        contactVo.salutationOptions = SObjectUtilities.getPicklistValues(con, 'salutation');
        contactVo.genderOptions = SObjectUtilities.getPicklistValues(con, 'Gender__c');
        contactVo.acquistionOptions = SObjectUtilities.getPicklistValues(gifAid, 'gaid__Acquisition_Method__c');
        membershipVo.membershipSourceOptions = SObjectUtilities.getPicklistValues(recDonate, 'Source__c');      	        
  
        
        contactVo.staffMember = MembershipConstants.NOSTAFF;
        if(cont.id != null)
        {            
            displayContactDataForExistingContact();        
        }
        booleanChecking.displaySuccessMessage = false;
        booleanChecking.displayMbrNoMessage = false;
        membershipVo.accountName='';
        membershipVo.sortCode='';
    }
    @TestVisible
    private void displayContactDataForExistingContact(){
         	if(!Schema.sObjectType.Contact.fields.Data_Source__c.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
             }     
            booleanChecking.isStaff = ContactUtilities.isStaff(cont.id);
            booleanChecking.isMembershipExists = ContactUtilities.isMembershipExists(cont.id, cont.email);
            contactVo.staffMember = MembershipConstants.STAFF; 
            primaryContact = [SELECT Id,Salutation,DoNotCall, SMS_Opt_In__c, Post_Opt_In__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,Contact_Prefrence__c,Prefered_First_Name__c,AccountId,Expected_Due_Date__c,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,Branch__r.Name,Branch__c FROM Contact where id=:ApexPages.currentPage().getParameters().get('Id')];
            booleanChecking.isCompanionContactExisting = ContactUtilities.isCompanionContactExisting(cont.id);
            System.debug('isCompanionContactExisting '+booleanChecking.isCompanionContactExisting );

            if(primaryContact != null){  
                membershipVo.eDate = String.valueof(primaryContact.Expected_Due_Date__c);
                membershipVo.nearestBranchs = MembershipConditionHelper.assignBranchValues(primaryContact.Branch__c);
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
       if(MembershipConditionCheckUtilities.dateFormatCheck(membershipVo.eDate)){
        expDate = Date.valueOf(membershipVo.eDate);
        }
        Boolean isPractitioner;
        booleanChecking.isVolunteer = ContactUtilities.isVolunteerExisting(cont.Id);
        isPractitioner = MembershipUtilties.isPractitioner(cont.firstname,cont.lastname,cont.email);
        list<Boolean> contactBooleanList = new list<Boolean>{booleanChecking.isStaff,booleanChecking.isVolunteer,isPractitioner,booleanChecking.twomems};
        accountDetails.targetCustomer = ContactUtilities.targetCustomer(contactBooleanList);
        booleanChecking.isMembershipExists = ContactUtilities.isMembershipExists(cont.Id,cont.email);
        
        if(MembershipConditionCheckUtilities.receiveInputPermissionCheck()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
        }

       
       
        if(MembershipConditionCheckUtilities.isNotExistingContactCheck(booleanChecking.isContactExisting,primaryContact)){

                membershipVo.recordType = MembershipConstants.PARENT;
                    primaryContact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(membershipVo.recordType).getRecordTypeId(),FirstName=cont.firstname,
                                        LastName=cont.lastname,Email=cont.email,Gender__c=cont.Gender__c,Phone=cont.phone,Salutation=cont.salutation,MailingPostalCode=cont.MailingPostalCode,
                                        Expected_Due_Date__c =expDate,MailingStreet=cont.MailingStreet+contactVo.streetValue1+contactVo.streetValue2,Branch__c=cont.Branch__c,
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
            primaryContact.MailingStreet = Cont.MailingStreet+contactVo.streetValue1+contactVo.streetValue2;
            primaryContact.MailingState = Cont.MailingState;
            primaryContact.MailingCity = Cont.MailingCity;
    
            Database.update(primaryContact, false);
            secondaryContactCreation();
            
        }    
       membershipVo.membershipTypeMap = MembershipUtilties.getMembershipTypeMap(contactType,accountDetails.targetCustomer,false);    
           return null;
    }
    @TestVisible
    private void secondaryContactCreation(){
        
        if(MembershipConditionCheckUtilities.secondContactRequiredCheck(booleanChecking.twomems,primaryContact.id,secondContact.secondContactFirstName))
        {            
            membershipVo.recordType = MembershipConstants.COMPANION;
            Contact con =[Select AccountId from Contact where id = :primaryContact.id];
            
            secondaryContact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(membershipVo.recordType).getRecordTypeId(),FirstName=secondContact.secondContactFirstName,
                                                         LastName=secondContact.secondContactLastName,Email=secondContact.secondContactEmail,Gender__c=secondContact.secondContactGenders,Phone=secondContact.secondContactPhone,Salutation=secondContact.salutationSecondary,MailingPostalCode=cont.MailingPostalCode,
                                                         Expected_Due_Date__c =expDate,MailingStreet=cont.MailingStreet+contactVo.streetValue1+contactVo.streetValue2,Branch__c=cont.Branch__c,
                                                         MailingState=cont.MailingState,MailingCity=cont.MailingCity,Data_Source__c = MembershipConstants.SALESFORCE,SMS_Opt_In__c=cont.SMS_Opt_In__c,Post_Opt_In__c=cont.Post_Opt_In__c,
                                                         HasOptedOutOfEmail=cont.HasOptedOutOfEmail,DoNotCall=cont.DoNotCall,Parent_Contact__c = primaryContact.id,AccountId = con.AccountId);
            Database.SaveResult srSec = Database.insert(secondaryContact, false);
            MembershipConditionHelper.saveResultCheck(srSec);
            contactType = MembershipConstants.JOINT;
        }                              
		contactType = MembershipConditionHelper.companionCheck(booleanChecking.twomems); 
    }
    public pageReference contactInfo(){
        if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
             }
         
        
        membershipVo.membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                            No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                            Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                            GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                            where Id =:membershipVo.feeAmount];
        System.debug('Membership##### '+membershipVo.membershipInfo);
		  accountDetails.sessionProfile = userinfo.getUserType();
         if(membershipVo.membershipInfo != null && accountDetails.sessionProfile != MembershipConstants.STANDARD && membershipVo.membershipInfo.Payment_Method__c == MembershipConstants.CREDIT_OR_DEBIT_CARD)
          { 

              paymentHubCallout();
              PageReference pageRef = new PageReference(''+accountDetails.redirectURL);    
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
        membershipVo.nearestBranchs = MembershipUtilties.getBranches(cont.Mailing_Postal_Code__c);
        system.debug('nct branches'+membershipVo.nearestBranchs );
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
        if(accountDetails.sessionProfile != MembershipConstants.STANDARD){
            membershipVo.feeAmount = Apexpages.currentPage().getParameters().get('seltAmountdName').escapeHtml4();
            PageReference redirecContUrl;

            membershipVo.membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:membershipVo.feeAmount];
        }
      	
        System.debug('Membership##### '+membershipVo.membershipInfo);
        booleanChecking.displaySuccessMessage = true;
        thankYouSec();
    }
   
    public void paymentSave()
    {   
        booleanChecking.displayMbrNoMessage = true;
        booleanChecking.displaySuccessMessage = false;
        thankYouSec();
    }
    public void thankYouSec()
    {
        if(accountDetails.sessionProfile == MembershipConstants.STANDARD && membershipVo.membershipInfo.Payment_Method__c == MembershipConstants.CREDIT_OR_DEBIT_CARD){
            paymentHubCallout();                
        }
        cpm__Payment_Profile__c pymtPrfl = new cpm__Payment_Profile__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(cont);
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController(sc);
        MembershipCrudHelper crudHelper = new MembershipCrudHelper(controller);
        crudHelper.primaryContact = primaryContact;
        crudHelper.secondaryContact = secondaryContact;
        if(membershipVo.membershipInfo.Payment_Method__c != MembershipConstants.CREDIT_OR_DEBIT_CARD){
           pymtPrfl = crudHelper.paymentProfile();
        }
        recDon = crudHelper.recDonation(membershipVo.membershipInfo,pymtPrfl);
        membershipNumberDisplay();
        gaid__Gift_Aid_Declaration__c gftAid = new gaid__Gift_Aid_Declaration__c();
        if(booleanChecking.isGiftAid == MembershipConstants.TRUE_VALUE){
        	gftAid = crudHelper.giftAid(membershipVo.membershipInfo);
        }
        
    }    
    
    
    public void membershipNumberDisplay(){
       booleanChecking.displayMbrNoMessage = true;
       membershipVo.membershipNumber = ThankYouHelper.membershipNumberCreation(primaryContact,recDon);
    }
    
    private PageReference paymentHubCallout()
    {   
        list<String> contactDetails = new list<String>();
        contactDetails.add(Cont.email);
        contactDetails.add(Cont.firstname);
        contactDetails.add(Cont.lastname);

        accountDetails.redirectURL = PaymentHubCalloutUtilities.PaymentHub(primaryContact,membershipVo.membershipInfo,contactDetails);
        accountDetails.sessionProfile = userinfo.getUserType();
        if(accountDetails.sessionProfile == MembershipConstants.STANDARD){
            return sendPaymentLinkToParent(accountDetails.redirectURL);
        }
        else{
            return null;
        }
       
    }
    
    private PageReference sendPaymentLinkToParent(string paymentLink)
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