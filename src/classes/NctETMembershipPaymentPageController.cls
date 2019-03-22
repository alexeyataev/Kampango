public without sharing class NctETMembershipPaymentPageController 
{
    public MembershipVo membership{get;set;}
    private static Boolean inspect = false;
    public static Boolean onComplete {get; set;}  
    public cpm__Payment_Profile__c pymtPrfl {get;set;}
    public npe03__Recurring_Donation__c recDon {get;set;}
    public gaid__Gift_Aid_Declaration__c gftAid {get;set;}
    private List<Contact> contactList;
    public Boolean isCompanionContactExisting {get; set;}
    
    public NctETMembershipPaymentPageController()
    {  
        membership = new MembershipVo();
        ID contactID = ApexPages.currentPage().getParameters().get('Id');
        membership.contId = contactID;
        system.debug('*$*$**$ contId  ' + membership.contId);
       	Contact con= new Contact();
        gaid__Gift_Aid_Declaration__c giftAid = new gaid__Gift_Aid_Declaration__c();
        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
        
        membership.salutationOptions = SObjectUtilities.getPicklistValues(con, 'salutation');
        membership.genderOptions = SObjectUtilities.getPicklistValues(con, 'Gender__c');
        membership.acquistionOptions = SObjectUtilities.getPicklistValues(giftAid, 'gaid__Acquisition_Method__c');
        membership.membershipSourceOptions = SObjectUtilities.getPicklistValues(recDon, 'Source__c');
       	        
    	membership.sessionProfile = userinfo.getUserType();
        if(membership.sessionProfile == MembershipConstants.STANDARD){
            membership.etSpecific = true;
        }
        else{
             membership.etSpecific = false;
        }
        
       membership.staffMember =MembershipConstants.NOSTAFF;
        if(membership.contId != null)
        {
            displayContactDataForExistingContact();
        
        }
        pymtPrfl = new cpm__Payment_Profile__c();
        recDon = new npe03__Recurring_Donation__c();
        gftAid = new gaid__Gift_Aid_Declaration__c();
         membership.displaySuccessMessage = false;
        membership.displayMbrNoMessage = false;
        membership.displayValue = MembershipConstants.NONE;
        membership.counter = '';
        membership.accountName='';
        membership.sortCode='';
        membership.accountName=''; 


    }
    private void displayContactDataForExistingContact(){
         if (!Schema.sObjectType.Contact.fields.FirstName.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
             }
            membership.isStaff = ContactUtilities.isStaff(membership.contId);membership.isMembershipExists = ContactUtilities.isMembershipExists(membership.contId, membership.email);
            membership.staffMember = MembershipConstants.STAFF;
            membership.primaryContact = [SELECT Id,Salutation,DoNotCall, SMS_Opt_In__c, Post_Opt_In__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,Contact_Prefrence__c,Prefered_First_Name__c,AccountId,Expected_Due_Date__c,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,Branch__r.Name,Branch__c FROM Contact where id=:membership.contId];
            isCompanionContactExisting = ContactUtilities.isCompanionContactExisting(membership.contId);
            System.debug('isCompanionContactExisting '+isCompanionContactExisting );
            if(membership.primaryContact != null){
                
                membership.firstname = membership.primaryContact.FirstName;
                membership.lastname = membership.primaryContact.LastName;
                membership.email = membership.primaryContact.Email;
                membership.phone = membership.primaryContact.Phone;
                membership.postCode = membership.primaryContact.MailingPostalCode;
                membership.salutationPrimary = membership.primaryContact.Salutation;
                membership.genders = membership.primaryContact.Gender__c;
                membership.smsOpt = membership.primaryContact.SMS_Opt_In__c;
                membership.postOpt = membership.primaryContact.Post_Opt_In__c;
                membership.emailOpt = membership.primaryContact.HasOptedOutOfEmail;
                membership.doNotCallOpt = membership.primaryContact.DoNotCall;
                membership.eDate = String.valueOf(membership.primaryContact.Expected_Due_Date__c); 	
                membership.cityValue = String.valueOf(membership.primaryContact.MailingCity);                               	
                membership.stateValue = String.valueOf(membership.primaryContact.MailingState); 
                membership.streetValue = String.valueOf(membership.primaryContact.MailingStreet);
                assignBranchValues(membership.primaryContact.Branch__c); 
                

            }
            List<Contact> secondaryContactList = [SELECT Id,Salutation,DoNotCall, SMS_Opt_In__c, Post_Opt_In__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,MailingPostalCode,Contact_Prefrence__c,Prefered_First_Name__c,AccountId FROM Contact where Parent_Contact__c =:membership.primaryContact.Id LIMIT 1];
            if(secondaryContactList.size()>0){
                
                membership.secondContactFirstName = secondaryContactList[0].FirstName;
                membership.secondContactLastName = secondaryContactList[0].LastName;
                membership.secondContactEmail = secondaryContactList[0].Email;
                membership.secondContactPhone = secondaryContactList[0].Phone;

            }
    }
    private Boolean receiveInputPermissionCheck(){
        return !Schema.sObjectType.Contact.fields.FirstName.isCreateable() && !Schema.sObjectType.Contact.fields.FirstName.isAccessible();
    }
    private Boolean receiveInputSecondContactPermissionCheck(){
        return membership.twomems == true && (membership.secondContactFirstName != null || membership.secondContactFirstName != '');      
    }
    
    private void assignBranchValues(Id branch){
        List<Account> acc;
        if(branch!= null){
                        acc = Database.Query('SELECT id,name,Data_Source__c FROM account WHERE ID =\''+branch+'\' LIMIT 1');
                        String strs = acc[0].Name;
                        map<string, list<account>> accmap = new map<string, list<account>>();
                        accmap.put(strs,acc);
                        membership.nearestBranchs = accmap; 
                    }    
    }
    
    public PageReference  receiveInput(){
                
        Contact con;
        if(dateFormatCheck()){
        membership.expDate = Date.valueOf(membership.eDate); 
        }
        
        
     
        membership.isVolunteer = ContactUtilities.isVolunteerExisting(membership.contId);
        membership.isPractitioner = MembershipUtilties.isPractitioner(membership.firstname,membership.lastname,membership.email);
        list<Boolean> contactBooleanList = new list<Boolean>{membership.isStaff,membership.isVolunteer,membership.isPractitioner,membership.twomems};
        membership.targetCustomer = ContactUtilities.targetCustomer(contactBooleanList);
        membership.isMembershipExists = ContactUtilities.isMembershipExists(membership.contId,membership.email);
        
        if(receiveInputPermissionCheck()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
        }

        if(isNotExistingContactCheck()){

                membership.recordType = MembershipConstants.PARENT;
                    membership.primaryContact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(membership.recordType).getRecordTypeId(),FirstName=membership.firstname,
                                        LastName=membership.lastname,Email=membership.email,Gender__c=membership.genders,Phone=membership.phone,Salutation=membership.salutationPrimary,MailingPostalCode=membership.postCode,
                                        Expected_Due_Date__c =membership.expDate,MailingStreet=membership.streetValue+membership.streetValue1+membership.streetValue2,Branch__c=membership.selectBranch,
                                        MailingState=membership.stateValue,MailingCity=membership.cityValue,Data_Source__c = MembershipConstants.SALESFORCE,SMS_Opt_In__c=membership.smsOpt,Post_Opt_In__c=membership.postOpt,
                                        HasOptedOutOfEmail=membership.emailOpt,DoNotCall=membership.doNotCallOpt);
                    Database.SaveResult sr = Database.insert(membership.primaryContact, false);
                if (!sr.isSuccess()) {
                    
                    // Insertion failed due to duplicate detected
                    for(Database.Error duplicateError : sr.getErrors()){
                        DuplicateFinder(duplicateError);
                    }
                }
                if(receiveInputSecondContactPermissionCheck())
                {
                    
                    membership.recordType = MembershipConstants.COMPANION;
                    con =[Select AccountId from Contact where id = :membership.primaryContact.id];
                    membership.secondaryContact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(membership.recordType).getRecordTypeId(),FirstName=membership.secondContactFirstName,
                                      LastName=membership.secondContactLastName,Email=membership.secondContactEmail,Gender__c=membership.secondContactGenders,Phone=membership.secondContactPhone,Salutation=membership.salutationSecondary,MailingPostalCode=membership.postCode,
                                      Expected_Due_Date__c =membership.expDate,MailingStreet=membership.streetValue+membership.streetValue1+membership.streetValue2,Branch__c=membership.selectBranch,
                                      MailingState=membership.stateValue,MailingCity=membership.cityValue,Data_Source__c = MembershipConstants.SALESFORCE,SMS_Opt_In__c=membership.smsOpt,Post_Opt_In__c=membership.postOpt,
                                      HasOptedOutOfEmail=membership.emailOpt,DoNotCall=membership.doNotCallOpt,Parent_Contact__c = membership.primaryContact.id,AccountId = con.AccountId);
                    insert membership.secondaryContact;
                    membership.contactType = MembershipConstants.JOINT;
                }
                else 
                {
                    membership.contactType = MembershipConstants.INDIVIDUAL;
                    
                }

        }
        else if(isExistingContactCheck()){
        
        System.debug('Contact Exists(Next Flow Starts): '+membership.isContactExisting);
        contactFinder(); 
        contactList =[SELECT Id,Salutation,Gender__c,Parent_Contact__c, LastName, FirstName, Email,MailingStreet,MailingState,MailingCity, Phone,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact WHERE Parent_Contact__c = :membership.primaryContact.Id];

        membership.primaryContact.MailingStreet = membership.streetValue+membership.streetValue1+membership.streetValue2;
        membership.primaryContact.MailingState = membership.stateValue;
        membership.primaryContact.MailingCity = membership.cityValue;

        Database.update(membership.primaryContact, false);
        if(secondContactRequiredCheck())
        {
            membership.recordType = MembershipConstants.COMPANION;
            con =[Select AccountId from Contact where id = :membership.primaryContact.id];
            membership.secondaryContact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(membership.recordType).getRecordTypeId(),FirstName=membership.secondContactFirstName,
                                      LastName=membership.secondContactLastName,Email=membership.secondContactEmail,Gender__c=membership.secondContactGenders,Phone=membership.secondContactPhone,Salutation=membership.salutationSecondary,MailingPostalCode=membership.postCode,
                                      Expected_Due_Date__c =membership.expDate,MailingStreet=membership.streetValue+membership.streetValue1+membership.streetValue2,Branch__c=membership.selectBranch,
                                      MailingState=membership.stateValue,MailingCity=membership.cityValue,Data_Source__c = MembershipConstants.SALESFORCE,SMS_Opt_In__c=membership.smsOpt,Post_Opt_In__c=membership.postOpt,
                                      HasOptedOutOfEmail=membership.emailOpt,DoNotCall=membership.doNotCallOpt,Parent_Contact__c = membership.primaryContact.id,AccountId = con.AccountId);
            insert membership.secondaryContact;
            membership.contactType = MembershipConstants.JOINT;
        }                                 
        else{
            
            membership.contactType = MembershipConstants.INDIVIDUAL;
                
            }
        }    
        membership.membershipTypeMap = MembershipUtilties.getMembershipTypeMap(membership.contactType,membership.targetCustomer,membership.etSpecific);    
        return null;
        
    }
    private void contactFinder(){
        if(membership.contId != null){
             membership.primaryContact =[SELECT Id,Salutation,Gender__c, LastName, FirstName, Email, Phone,MailingStreet,MailingState,MailingCity,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact WHERE Id =:membership.contId limit 1];
        }
        else{
            membership.primaryContact =[SELECT Id,Salutation,Gender__c, LastName, FirstName, Email, Phone,MailingStreet,MailingState,MailingCity,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact WHERE Email = :membership.email AND Email != '' limit 1];
        }
    }
    private boolean isNotExistingContactCheck(){
    	return membership.isContactExisting == false && membership.primaryContact == null;
    }
    private boolean isExistingContactCheck(){
    	return membership.contId != null || membership.isContactExisting == true;
    }
    private boolean dateFormatCheck(){
    	return membership.eDate != null && membership.eDate != '';
    }
    private boolean secondContactRequiredCheck(){
    	return receiveInputSecondContactPermissionCheck() && contactList.size()<0;
    }
    private void duplicateFinder(Database.Error duplicateError){
        if(duplicateError instanceof Database.DuplicateError) {
            Datacloud.DuplicateResult duplicateResult = 
                ((Database.DuplicateError)duplicateError).getDuplicateResult();
            System.debug('Duplicate records have been detected by ' + 
                         duplicateResult.getDuplicateRule());
            System.debug(duplicateResult.getErrorMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,MembershipConstants.DUPLICATE_RECORDS_FOUND));
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,MembershipConstants.DUPLICATE_RECORDS_FOUND));
        }
    }
    public PageReference contactInfo()
    {
        if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
             }
         if(membership.membershipInfo != null && inspect == true){
            PageReference redirecContUrl;
            system.debug('*$*$*$  feeAmount   ' + membership.feeAmount+ '$$$$$$ lifeMembership: '+membership.lifeMembership);
            membership.membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:membership.feeAmount];
        }
        else{
            PageReference redirecContUrl;

            system.debug('*$*$*$  feeAmount   ' + membership.feeAmount+ '$$$$$$ lifeMembership: '+membership.lifeMembership);

            membership.membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:membership.feeAmount];
        }
        System.debug('Membership##### '+membership.membershipInfo);

            
            if(membership.membershipInfo != null && membership.membershipInfo.Payment_Method__c == MembershipConstants.CREDIT_OR_DEBIT_CARD)
            {
                membership.sessionProfile = userinfo.getUserType();
                if(membership.membershipInfo != null && membership.sessionProfile != MembershipConstants.STANDARD)
                {
                    
                    paymentHubCallout();
                    PageReference pageRef = new PageReference(''+membership.redirectURL);    
                    pageRef.setRedirect(true);
                    return pageRef;
                    
                }

        }
        return null;
    } 
    public void onCompleteContactInfo(){
        onComplete = true;

    }
    public void nctBranchs(){
        
        String emails = Apexpages.currentPage().getParameters().get('emailsVal').escapeHtml4();
        if(membership.contId == null){
            membership.isContactExisting = ContactUtilities.isContactExisting(emails);

        }
        membership.isMembershipExists = ContactUtilities.isMembershipExists(membership.contId, emails);
        membership.postCode = Apexpages.currentPage().getParameters().get('postVal').escapeHtml4();

        if(membership.postCode != null && membership.postCode != ''){
        membership.nearestBranchs = MembershipUtilties.getBranches(membership.postCode);

        }
        }
    public void membershipDupeChecker(){
        
        String emails = Apexpages.currentPage().getParameters().get('emailDupeVal').escapeHtml4();

        if(membership.contId == null){
            membership.isContactExisting = ContactUtilities.isContactExisting(emails);
       
        }
        membership.isMembershipExists = ContactUtilities.isMembershipExists(membership.contId, emails);
       
    }
    public void giftAidCreation(){
        if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
        }
        membership.displayMbrNoMessage = true;
        if(membership.sessionProfile != MembershipConstants.STANDARD){
            membership.feeAmount = Apexpages.currentPage().getParameters().get('seltAmountdName').escapeHtml4();
            PageReference redirecContUrl;

            system.debug('*$*$*$  feeAmount   ' + membership.feeAmount+ '$$$$$$ lifeMembership: '+membership.lifeMembership);

            membership.membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:membership.feeAmount];
        }
      	
        System.debug('Membership##### '+membership.membershipInfo);

        membership.displaySuccessMessage = true;
        thankYouSec();
        inspect = true;
    }
   
    public void paymentSave()
    {   
        membership.displayMbrNoMessage = true;
        membership.displaySuccessMessage = false;
        thankYouSec();
    }
    public void thankYouSec()
    {

        if(membership.sessionProfile == MembershipConstants.STANDARD && membership.membershipInfo.Payment_Method__c == MembershipConstants.CREDIT_OR_DEBIT_CARD){
            paymentHubCallout();                
        }
           
        MembershipVo.MemberCrudHelper crudHelper = new MembershipVo.MemberCrudHelper();
        crudHelper.accountName = membership.accountName;
        crudHelper.accountNumber = membership.accountNumber;
        crudHelper.acquistion = membership.acquistion;
        crudHelper.membershipSource = membership.membershipSource;
        crudHelper.sortCode = membership.sortCode;
        crudHelper.pcont = membership.primaryContact;
        crudHelper.scont = membership.secondaryContact;
        crudHelper.isVolunteer = membership.isVolunteer;
        
        MembershipCrudHelper.crudHelper = crudHelper;
        if(membership.membershipInfo.Payment_Method__c != MembershipConstants.CREDIT_OR_DEBIT_CARD){
           pymtPrfl = MembershipCrudHelper.paymentProfile();
        }
        if(membership.isGiftAid == MembershipConstants.TRUE_VALUE){
        	gftAid = MembershipCrudHelper.giftAid(membership.membershipInfo);
        }
        recDon = MembershipCrudHelper.recDonation(membership.membershipInfo,pymtPrfl);
        
        membershipNumberDisplay();
    }    
    public void membershipNumberDisplay(){
       membership.displayMbrNoMessage = true;
        ThankYouHelper.membershipDetails = membership.membershipInfo;
       membership.membershipNumber = ThankYouHelper.membershipNumberCreation(membership.primaryContact,recDon,membership.lifeMembership);
    }
    public PageReference paymentHubCallout()
    {   
        list<String> contactDetails = new list<String>();
        contactDetails.add(membership.email);
        contactDetails.add(membership.firstname);
        contactDetails.add(membership.lastname);

        contactDetails.sort();
       
         membership.redirectURL = PaymentHubCalloutUtilities.PaymentHub(membership.primaryContact,membership.membershipInfo,contactDetails);
        membership.sessionProfile = userinfo.getUserType();
        if(membership.sessionProfile == MembershipConstants.STANDARD){
            return sendPaymentLinkToParent(membership.redirectURL);
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
        payLink.Contact__c = membership.primaryContact.Id;
        payLink.Email__c = membership.primaryContact.Email;
        payLink.Link_Sent_Date__c = Date.Today();
        payLink.Payment_Key__c = MembershipConstants.TEST;
        payLink.Payment_Link__c = paymentLink;
        insert payLink;
        System.debug('Payment Link Record Created : '+'ID: '+payLink.Id+', /r/n'+payLink.Contact__c+', '+payLink.Payment_Key__c+', '+payLink.Payment_Link__c);
        return null;
    }
    


}