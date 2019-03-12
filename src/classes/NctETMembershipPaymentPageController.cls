public without sharing class NctETMembershipPaymentPageController 
{
    public Boolean twomems{get; set;}
    public boolean twomem{get; set;}
    public Date expDate {get; set;}
    public String isGiftAid{get; set;}
    public String firstname{get; set;}
    public String lastname{get; set;}
    public String email{get; set;}
    public String phone{get; set;}
    public String secondContactFirstName{get; set;}
    public String secondContactLastName{get; set;}
    public String secondContactEmail{get; set;}
    public String secondContactPhone{get; set;}
    public String postCode{get; set;}
    public String membershipSource{get;set;}
    public list<SelectOption> membershipSourceOptions{get; set;}
    public String genderValue {get; set;}
    public String streetValue {get; set;}
    public String streetValue1 {get; set;}
    public String streetValue2 {get; set;}
    public String stateValue {get; set;}
    public String cityValue {get; set;}
    public Contact primaryContact {get;set;} 
    public Contact secondaryContact {get;set;} 
    public String salutation{get; set;}
    public String salutationPrimary {get;set;}
    public String salutationSecondary {get;set;}
    public list<SelectOption> salutationOptions{get; set;}
    public String acquistion {get;set;}
    public list<SelectOption> acquistionOptions{get; set;}
    public String genders {get;set;}
    public String secondContactGenders {get;set;}
    public list<SelectOption> genderOptions{get; set;}
    public boolean smsOpt{get; set;}
    public boolean postOpt{get; set;}
    public boolean emailOpt{get; set;}
    public boolean doNotCallOpt{get; set;}
    public cpm__Payment_Profile__c pymtPrfl {get;set;}
    public npe03__Recurring_Donation__c recDon {get;set;}
    public gaid__Gift_Aid_Declaration__c gftAid {get;set;}
    
    public Id feeAmount {get;set;}
    public Id selectBranch {get; set;}
    public string membershipNumber {get;set;}
    public string redirectURL {get;set;} 
    public Id contId {get;set;}
    public boolean etSpecific;
    
    public String accountName {get; set;}
    public String sortCode {get; set;}
    public String accountNumber {get; set;}
    public string displayValue {get;set;}
    public string counter  {get;set;}
    public Membership_Type__mdt membershipInfo {get;set;}
    public Map<String, List<Membership_Type__mdt>> membershipTypeMap{get;set;}
    
    public Map<String, list<sObject>> nearestBranchs {get; set;}
    public String eDate {get; set;}
    public boolean displaySuccessMessage {get;set;}
    public boolean displayMbrNoMessage {get;set;}
    public boolean isPractitioner {get; set;}
    public boolean isContactExisting {get; set;}
    public boolean isVolunteer {get; set;}
    public boolean isStaff {get; set;}
    public string targetCustomer{get; set;}
    public boolean isMembershipExists {get; set;}
    public String staffMember {get; set;}
    public String recordType;
    public String sessionProfile;
    public Boolean lifeMembership{get; set;}
    public static Boolean inspect = false;
    public static Boolean onComplete {get; set;}
    public String contactType;
    public NctETMembershipPaymentPageController()
    {  
        ID contactID = ApexPages.currentPage().getParameters().get('Id');
        contId = contactID;
        system.debug('*$*$**$ contId  ' + contId);
       	Contact con= new Contact();
        gaid__Gift_Aid_Declaration__c giftAid = new gaid__Gift_Aid_Declaration__c();
        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
        
        salutationOptions = SObjectUtilities.getPicklistValues(con, 'salutation');
        genderOptions = SObjectUtilities.getPicklistValues(con, 'Gender__c');
        acquistionOptions = SObjectUtilities.getPicklistValues(giftAid, 'gaid__Acquisition_Method__c');
        membershipSourceOptions = SObjectUtilities.getPicklistValues(recDon, 'Source__c');
       	        
    	sessionProfile = userinfo.getUserType();
        if(sessionProfile == MembershipConstants.STANDARD){
            etSpecific = true;
        }
        else{
            etSpecific = false;
        }
        
        staffMember =MembershipConstants.NOSTAFF;
        if(contId != null)
        {
            if (!Schema.sObjectType.Contact.fields.FirstName.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
             }
            isStaff = ContactUtilities.isStaff(contId);
            primaryContact = [SELECT Id,Salutation,DoNotCall, SMS_Opt_In__c, Post_Opt_In__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,MailingPostalCode,Contact_Prefrence__c,Prefered_First_Name__c,AccountId FROM Contact where id=:contId];
            if(primaryContact != null){
                
                firstname = primaryContact.FirstName;
                lastname = primaryContact.LastName;
                email = primaryContact.Email;
                phone = primaryContact.Phone;
                postCode = primaryContact.MailingPostalCode;
                salutationPrimary = primaryContact.Salutation;
                genders = primaryContact.Gender__c;
                smsOpt = primaryContact.SMS_Opt_In__c;
                postOpt = primaryContact.Post_Opt_In__c;
                emailOpt = primaryContact.HasOptedOutOfEmail;
                doNotCallOpt = primaryContact.DoNotCall;

            }
            List<Contact> secondaryContactList = [SELECT Id,Salutation,DoNotCall, SMS_Opt_In__c, Post_Opt_In__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,MailingPostalCode,Contact_Prefrence__c,Prefered_First_Name__c,AccountId FROM Contact where Parent_Contact__c =:primaryContact.Id LIMIT 1];
            if(secondaryContactList.size()>0){
                
                secondContactFirstName = secondaryContactList[0].FirstName;
                secondContactLastName = secondaryContactList[0].LastName;
                secondContactEmail = secondaryContactList[0].Email;
                secondContactPhone = secondaryContactList[0].Phone;

            }
        
        }
        pymtPrfl = new cpm__Payment_Profile__c();
        recDon = new npe03__Recurring_Donation__c();
        gftAid = new gaid__Gift_Aid_Declaration__c();
        displaySuccessMessage = false;
        displayMbrNoMessage = false;
        displayValue = MembershipConstants.NONE;
        counter = '';
        accountName='';
        sortCode='';
        accountName='';  


    }
         private Boolean receiveInputPermissionCheck(){
        return !Schema.sObjectType.Contact.fields.FirstName.isCreateable() && !Schema.sObjectType.Contact.fields.FirstName.isAccessible();
    }
    private Boolean receiveInputSecondContactPermissionCheck(){
        return twomems == true && secondContactFirstName != null || secondContactFirstName != '';      
    }
    public PageReference  receiveInput(){
                
        Contact con;
        if(eDate != null && eDate != ''){
        expDate = Date.valueOf(eDate); 
        }
        
        
     
        isVolunteer = ContactUtilities.isVolunteerExisting(contId);
        isPractitioner = MembershipUtilties.isPractitioner(firstname, lastname, email);
        list<Boolean> contactBooleanList = new list<Boolean>{isStaff,isVolunteer,isPractitioner,twomems};
        targetCustomer = ContactUtilities.targetCustomer(contactBooleanList);
        isMembershipExists = ContactUtilities.isMembershipExists(contId, email);
        
        if(receiveInputPermissionCheck()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
        }

        if(isContactExisting == false && primaryContact == null){

                recordType = MembershipConstants.PARENT;
                    primaryContact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId(),FirstName=firstname,
                                        LastName=lastname,Email=email,Gender__c=genders,Phone=phone,Salutation=salutationPrimary,MailingPostalCode=postCode,
                                        Expected_Due_Date__c = expDate,MailingStreet=streetValue+streetValue1+streetValue2,Branch__c=selectBranch,
                                        MailingState=stateValue,MailingCity=cityValue,Data_Source__c = MembershipConstants.SALESFORCE,SMS_Opt_In__c=smsOpt,Post_Opt_In__c=postOpt,
                                        HasOptedOutOfEmail=emailOpt,DoNotCall=doNotCallOpt);
                    Database.SaveResult sr = Database.insert(primaryContact, false);
                if(!sr.isSuccess()) {
                    
                    // Insertion failed due to duplicate detected
                    for(Database.Error duplicateError : sr.getErrors()){
                        Datacloud.DuplicateResult duplicateResult = 
                            ((Database.DuplicateError)duplicateError).getDuplicateResult();
                        System.debug('Duplicate records have been detected by ' + 
                                     duplicateResult.getDuplicateRule());
                        System.debug(duplicateResult.getErrorMessage());
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.DUPLICATE_RECORDS_FOUND));
                    }
                }
                if(receiveInputSecondContactPermissionCheck())
                {
                    
                    recordType = MembershipConstants.COMPANION;
                    con =[Select AccountId from Contact where id = :primaryContact.id];
                    secondaryContact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId(),FirstName=secondContactFirstName,
                                      LastName=secondContactLastName,Email=secondContactEmail,Gender__c=secondContactGenders,Phone=secondContactPhone,Salutation=salutationSecondary,MailingPostalCode=postCode,
                                      Expected_Due_Date__c = expDate,MailingStreet=streetValue+streetValue1+streetValue2,Branch__c=selectBranch,
                                      MailingState=stateValue,MailingCity=cityValue,Data_Source__c = MembershipConstants.SALESFORCE,SMS_Opt_In__c=smsOpt,Post_Opt_In__c=postOpt,
                                      HasOptedOutOfEmail=emailOpt,DoNotCall=doNotCallOpt,Parent_Contact__c = primaryContact.id,AccountId = con.AccountId);
                    insert secondaryContact;
                    contactType = MembershipConstants.JOINT;
                }
                else 
                {
                    contactType = MembershipConstants.INDIVIDUAL;
                    
                }

        }
        else if(contId != null || isContactExisting == true){
        List<Contact> contactList;
        System.debug('Contact Exists(Next Flow Starts): '+isContactExisting);
        primaryContact =[SELECT Id,Salutation,Gender__c, LastName, FirstName, Email, Phone,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact WHERE (Email = :email AND Email != '') OR Id =:contId limit 1];
        contactList =[SELECT Id,Salutation,Gender__c,Parent_Contact__c, LastName, FirstName, Email, Phone,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact WHERE Parent_Contact__c = :primaryContact.Id];
        if(receiveInputSecondContactPermissionCheck())
        {
            recordType = MembershipConstants.COMPANION;
            if(contactList.size()<0){
            con =[Select AccountId from Contact where id = :primaryContact.id];
            secondaryContact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId(),FirstName=secondContactFirstName,
                                      LastName=secondContactLastName,Email=secondContactEmail,Gender__c=secondContactGenders,Phone=secondContactPhone,Salutation=salutationSecondary,MailingPostalCode=postCode,
                                      Expected_Due_Date__c = expDate,MailingStreet=streetValue+streetValue1+streetValue2,Branch__c=selectBranch,
                                      MailingState=stateValue,MailingCity=cityValue,Data_Source__c = MembershipConstants.SALESFORCE,SMS_Opt_In__c=smsOpt,Post_Opt_In__c=postOpt,
                                      HasOptedOutOfEmail=emailOpt,DoNotCall=doNotCallOpt,Parent_Contact__c = primaryContact.id,AccountId = con.AccountId);
            insert secondaryContact;
        }
        contactType = MembershipConstants.JOINT;
        }                                 
        else{
            
            contactType = MembershipConstants.INDIVIDUAL;
                
            }
        }    
        membershipTypeMap = MembershipUtilties.getMembershipTypeMap(contactType,targetCustomer,etSpecific);    
        return null;
        
    }
    public PageReference contactInfo()
    {
        if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
             }
        if(membershipInfo != null && inspect == true){
            PageReference redirecContUrl;
            system.debug('*$*$*$  feeAmount   ' + feeAmount+ '$$$$$$ lifeMembership: '+lifeMembership);
            membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:feeAmount];
        }
        else{
            PageReference redirecContUrl;

            system.debug('*$*$*$  feeAmount   ' + feeAmount+ '$$$$$$ lifeMembership: '+lifeMembership);

            membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:feeAmount];
        }
        System.debug('Membership##### '+membershipInfo);

            
            if(membershipInfo != null && membershipInfo.Payment_Method__c == MembershipConstants.CREDIT_OR_DEBIT_CARD)
            {
                sessionProfile = userinfo.getUserType();
                if(membershipInfo != null && sessionProfile != MembershipConstants.STANDARD)
                {
                    
                    paymentHubCallout();
                    PageReference pageRef = new PageReference(''+redirectURL);    
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
        if(contId == null){
            isContactExisting = ContactUtilities.isContactExisting(emails);

        }
        isMembershipExists = ContactUtilities.isMembershipExists(contId, emails);
        postCode = Apexpages.currentPage().getParameters().get('postVal').escapeHtml4();

        if(postCode != null && postCode != ''){
        nearestBranchs = MembershipUtilties.getBranches(postCode);

        }
        }
    public void membershipDupeChecker(){
        
        String emails = Apexpages.currentPage().getParameters().get('emailDupeVal').escapeHtml4();

        if(contId == null){
            isContactExisting = ContactUtilities.isContactExisting(emails);
       
        }
        isMembershipExists = ContactUtilities.isMembershipExists(contId, emails);
       
    }
    public void giftAidCreation(){
        if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
        }
        displayMbrNoMessage = true;
        if(sessionProfile != MembershipConstants.STANDARD){
            feeAmount = Apexpages.currentPage().getParameters().get('seltAmountdName').escapeHtml4();
            PageReference redirecContUrl;

            system.debug('*$*$*$  feeAmount   ' + feeAmount+ '$$$$$$ lifeMembership: '+lifeMembership);

            membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:feeAmount];
        }
      	
        System.debug('Membership##### '+membershipInfo);

        displaySuccessMessage = true;
        thankYouSec();
        inspect = true;
    }
   
    public void paymentSave()
    {   
        displayMbrNoMessage = true;
        displaySuccessMessage = false;
        thankYouSec();
    }
    public void thankYouSec()
    {

        if(sessionProfile == MembershipConstants.STANDARD && membershipInfo.Payment_Method__c == MembershipConstants.CREDIT_OR_DEBIT_CARD){
            paymentHubCallout();                
        }
     
        MembershipCrudHelper memCrudHelp = new MembershipCrudHelper();
        memCrudHelp.pcont = primaryContact;
        memCrudHelp.scont = secondaryContact;
        memCrudHelp.accountName = accountName;
        memCrudHelp.accountNumber = accountNumber;
        memCrudHelp.sortCode = sortCode;
        memCrudHelp.acquistion = acquistion;
        memCrudHelp.membershipSource = membershipSource;
        if(membershipInfo.Payment_Method__c != MembershipConstants.CREDIT_OR_DEBIT_CARD){
           pymtPrfl = memCrudHelp.paymentProfile();
        }
        if(isGiftAid == MembershipConstants.TRUE_VALUE){
        	gftAid = memCrudHelp.giftAid(membershipInfo);
        }
        recDon = memCrudHelp.recDonation(membershipInfo,pymtPrfl);
        
        membershipNumberDisplay();
    }    
    public void membershipNumberDisplay(){
       displayMbrNoMessage = true;
       ThankYouHelper thankYou = new ThankYouHelper();
        thankyou.membershipDetails = membershipInfo;
       membershipNumber = thankYou.membershipNumberCreation(primaryContact,recDon,lifeMembership);
    }
    public PageReference paymentHubCallout()
    {   
        list<String> contactDetails = new list<String>();
        contactDetails.add(email);
        contactDetails.add(firstname);
        contactDetails.add(lastname);

        contactDetails.sort();
       
        redirectURL = PaymentHubCalloutUtilities.PaymentHub(primaryContact,membershipInfo,contactDetails);
        sessionProfile = userinfo.getUserType();
        if(sessionProfile == MembershipConstants.STANDARD){
            return sendPaymentLinkToParent(redirectURL);
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
        if(!Schema.sObjectType.Payment_Link__c.fields.Contact__c.isCreateable()){
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