public class NctETMembershipPaymentPageController 
{
    public Boolean twomems{get; set;}
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
    public Contact newCont {get;set;} 
    public Contact snewCont {get;set;} 
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
        contId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('*$*$**$ contId  ' + contId);
       	Contact con= new Contact();
        gaid__Gift_Aid_Declaration__c giftAid = new gaid__Gift_Aid_Declaration__c();
        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
        
        salutationOptions = SObjectUtilities.getPicklistValues(con, 'salutation');
        genderOptions = SObjectUtilities.getPicklistValues(con, 'Gender__c');
        acquistionOptions = SObjectUtilities.getPicklistValues(giftAid, 'gaid__Acquisition_Method__c');
        membershipSourceOptions = SObjectUtilities.getPicklistValues(recDon, 'Source__c');
       	        
    	sessionProfile = userinfo.getUserType();
        if(sessionProfile == 'Standard'){
            etSpecific = true;
        }
        else{
            etSpecific = false;
        }
        System.debug('sessionProfile '+sessionProfile);
        staffMember ='no staff';
        if(contId != null)
        {
            if (!Schema.sObjectType.Contact.fields.FirstName.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
             }
            isStaff = ContactUtilities.isStaff(contId);
            newCont = [SELECT Id,Salutation,DoNotCall, SMS_Opt_Out__c, Post_Opt_Out__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,MailingPostalCode,Contact_Prefrence__c,Prefered_First_Name__c,AccountId FROM Contact where id=:contId];
            if(newCont != null){
                
                firstname = newCont.FirstName;
                lastname = newCont.LastName;
                email = newCont.Email;
                phone = newCont.Phone;
                postCode = newCont.MailingPostalCode;
                salutationPrimary = newCont.Salutation;
                genders = newCont.Gender__c;
               if(newCont.SMS_Opt_Out__c == true){
                    smsOpt = false;
                }
                else{
                    smsOpt = true;
                }
                if(newCont.Post_Opt_Out__c == true){
                    postOpt = false;
                }
                else{
                    postOpt = true;
                }
                if(newCont.HasOptedOutOfEmail == true){
                    emailOpt = false;
                }
                else{
                    emailOpt = true;
                }
                if(newCont.DoNotCall == true){
                    doNotCallOpt = false;
                }
                else{
                    doNotCallOpt = true;
                }
 		
            }
        
        }else{
            smsOpt = true;
            postOpt = true;
            emailOpt = true;
            doNotCallOpt = true;
        }
        pymtPrfl = new cpm__Payment_Profile__c();
        recDon = new npe03__Recurring_Donation__c();
        gftAid = new gaid__Gift_Aid_Declaration__c();
        displaySuccessMessage = false;
        displayMbrNoMessage = false;
        displayValue = 'none';
        counter = '';
        accountName='';
        sortCode='';
        accountName='';  
       
               
    }
    public PageReference  receiveInput(){
                
       
        list<String> firstContactFieldsList = new list<String>{firstname,lastname,email,genders,phone,salutationPrimary};
        list<String> secondContactFieldsList = new list<String>{secondContactFirstName,secondContactLastName,secondContactEmail,secondContactGenders,secondContactPhone,salutationSecondary};
        list<String> contactFieldListExt = new list<String>{postCode,eDate,streetValue,streetValue1,streetValue2,stateValue,cityValue};
        list<Boolean> contactBooleanList = new list<Boolean>{smsOpt,postOpt,emailOpt,doNotCallOpt};
        
     
        isVolunteer = ContactUtilities.isVolunteerExisting(contId);
        isPractitioner = MembershipUtilties.isPractitioner(firstname, lastname, email);
        targetCustomer = ContactUtilities.targetCustomer(isStaff,isVolunteer,isPractitioner,twomems);
        isMembershipExists = ContactUtilities.isMembershipExists(contId, email);
        
        
        if(isContactExisting == false){
            if(newCont == null )
            {
                recordType = 'Parent';
                newCont = ContactHelper.getCreateContact(firstContactFieldsList,contactFieldListExt,selectBranch,recordType,newCont,contactBooleanList);
                
                if(twomems == true && secondContactFirstName != null || secondContactFirstName != '')
                {
                    recordType = 'Companion';
                    snewCont = ContactHelper.getCreateContact(secondContactFieldsList,contactFieldListExt,selectBranch,recordType,newCont,contactBooleanList);
                    contactType = 'joint';
                }
                else 
                {
                    contactType = 'Individual';
                    
                }
            }
        }
        else if(contId != null || isContactExisting == true){
        List<Contact> contactList;
<<<<<<< HEAD
=======
        System.debug('Contact Exists(Next Flow Starts): '+isContactExisting);
            if (!Schema.sObjectType.Contact.fields.FirstName.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
             }
>>>>>>> 78b44049aa9f7737e7adc06f7faec50f8452f4f0
        newCont =[SELECT Id,Salutation,Gender__c, LastName, FirstName, Email, Phone,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact WHERE Email = :email limit 1];
        contactList =[SELECT Id,Salutation,Gender__c,Parent_Contact__c, LastName, FirstName, Email, Phone,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact WHERE Parent_Contact__c = :newCont.Id OR Parent_Contact__c = :contId];
        if(twomems == true && secondContactFirstName != null || secondContactFirstName != '')
        {
            recordType = 'Companion';
            if(contactList.size()<0){
            snewCont = ContactHelper.getCreateContact(secondContactFieldsList,contactFieldListExt,selectBranch,recordType,newCont,contactBooleanList);    
        }
        contactType = 'joint';
        }                                 
        else{
            
            contactType = 'Individual';
                
            }
        }    
        membershipTypeMap = MembershipUtilties.getMembershipTypeMap(contactType,targetCustomer,etSpecific);    
        return null;
        
    }
    public PageReference contactInfo()
    {
        if(membershipInfo != null && inspect == true){
            feeAmount = Apexpages.currentPage().getParameters().get('seltdName');
            PageReference redirecContUrl;
<<<<<<< HEAD
=======
            system.debug('*$*$*$  feeAmount   ' + feeAmount+ '$$$$$$ lifeMembership: '+lifeMembership);
            if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
             }
>>>>>>> 78b44049aa9f7737e7adc06f7faec50f8452f4f0
            membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:feeAmount];
        }
        else{
            feeAmount = Apexpages.currentPage().getParameters().get('seltdName');
            PageReference redirecContUrl;
<<<<<<< HEAD

=======
            system.debug('*$*$*$  feeAmount   ' + feeAmount+ '$$$$$$ lifeMembership: '+lifeMembership);
             if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
             }
>>>>>>> 78b44049aa9f7737e7adc06f7faec50f8452f4f0
            membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:feeAmount];
        }
        System.debug('Membership##### '+membershipInfo);
        
        if(membershipInfo != null)
        {
            
             if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible() &&
                 Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isCreateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
             }
            if(membershipInfo.Payment_Method__c == 'Credit/Debit Card')
            {
                sessionProfile = userinfo.getUserType();
                if(membershipInfo != null && sessionProfile != 'Standard')
                {
                    
                    paymentHubCallout();
                    PageReference pageRef = new PageReference(redirectURL);
    
                    pageRef.setRedirect(true);

                    return pageRef;
                    
                }
                else if(sessionProfile == 'Standard'){
                    displaySuccessMessage = true;
                    paymentHubCallout();
                    recDon = new npe03__Recurring_Donation__c();
                    recDon.Name = membershipInfo.Contact_Type__c + ' ' + membershipInfo.Membership__c;
                    recDon.npe03__Amount__c = membershipInfo.Installment_Amount__c;
                    recDon.npe03__Contact__c = newCont.Id;
                    recDon.CARE_Payment_Frequency__c = 'One Time';
                    recDon.Source__c = membershipSource;
                    recDon.First_Contact__c = newCont.Id;
                    recDon.npe03__Schedule_Type__c = membershipInfo.Schedule_Type__c;
                    recDon.Membership_type__c = membershipInfo.Membership__c;
                    recDon.npe03__Installment_Period__c = membershipInfo.Installment_Period__c;
                    recDon.npsp4hub__Payment_Method__c = membershipInfo.Payment_Method__c;
                    recDon.Membership_Status__c = 'Pending';
                    Insert recDon;
                    
                    thankYouSec();
                }
               
            }
            else if(lifeMembership == true){
                 thankYouSec();
            }
        }
        return null;
    } 
    public void onCompleteContactInfo(){
        onComplete = true;

    }
    public void nctBranchs(){
        
        String emails = Apexpages.currentPage().getParameters().get('emailsVal');
        if(contId == null){
            isContactExisting = ContactUtilities.isContactExisting(emails);

        }
        isMembershipExists = ContactUtilities.isMembershipExists(contId, emails);
        postCode = Apexpages.currentPage().getParameters().get('postVal');

        if(postCode != null && postCode != ''){
        nearestBranchs = MembershipUtilties.getBranches(postCode);

        }
        }
    public void membershipDupeChecker(){
        
        String emails = Apexpages.currentPage().getParameters().get('emailDupeVal');

        if(contId == null){
            isContactExisting = ContactUtilities.isContactExisting(emails);
       
        }
        isMembershipExists = ContactUtilities.isMembershipExists(contId, emails);
       
    }
    public void giftAidCreation(){
        displayMbrNoMessage = true;
        if(sessionProfile != 'Standard'){
            feeAmount = Apexpages.currentPage().getParameters().get('seltAmountdName');
            PageReference redirecContUrl;
<<<<<<< HEAD

=======
            system.debug('*$*$*$  feeAmount   ' + feeAmount+ '$$$$$$ lifeMembership: '+lifeMembership);
             if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
             }
>>>>>>> 78b44049aa9f7737e7adc06f7faec50f8452f4f0
            membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:feeAmount];
        }
      	
        System.debug('Membership##### '+membershipInfo);

        list<String> accountDetails = new list<String>();
         accountDetails.add(accountNumber);
         accountDetails.add(accountName);
         accountDetails.add(sortCode);
         accountDetails.add(acquistion);
         accountDetails.add(membershipSource);
        MembershipCrudHelper memCrudHelp = new MembershipCrudHelper();
        if(isGiftAid == 'true'){
        	gftAid = memCrudHelp.giftAid(newCont.Id,isGiftAid,membershipInfo,accountDetails);
        }
        inspect = true;
    }
   
    public void paymentSave()
    {   
        displayMbrNoMessage = true;

        list<String> accountDetails = new list<String>();
         accountDetails.add(accountNumber);
         accountDetails.add(accountName);
         accountDetails.add(sortCode);
         accountDetails.add(acquistion);
         accountDetails.add(membershipSource);
<<<<<<< HEAD

        MembershipCrudHelper MemCrudHelp = new MembershipCrudHelper();
        pymtPrfl = MemCrudHelp.paymentProfile(newCont,accountDetails);
=======
         //accountDetails.sort();
        System.debug('accountDetails:'+accountDetails);
        MembershipCrudHelper memCrudHelp = new MembershipCrudHelper();
        pymtPrfl = memCrudHelp.paymentProfile(newCont,accountDetails);
>>>>>>> 78b44049aa9f7737e7adc06f7faec50f8452f4f0
        if(isGiftAid == 'true'){
        	gftAid = memCrudHelp.giftAid(newCont.Id,isGiftAid,membershipInfo,accountDetails);
        }
        if(pymtPrfl != null){
            recDon = memCrudHelp.recDonation(newCont.Id,snewCont,membershipInfo,pymtPrfl,accountDetails);
        }
        thankYouSec();
    }    
    public void thankYouSec()
    {
       displayMbrNoMessage = true;
       ThankYouHelper thankYou = new ThankYouHelper();

       membershipNumber = thankYou.membershipNumberCreation(newCont,recDon,lifeMembership);
    }
    public PageReference paymentHubCallout()
    {   
        list<String> contactDetails = new list<String>();
        contactDetails.add(email);
        contactDetails.add(firstname);
        contactDetails.add(lastname);

        contactDetails.sort();
       
        redirectURL = PaymentHubCalloutUtilities.PaymentHub(newCont,membershipInfo,contactDetails, recDon);
        sessionProfile = userinfo.getUserType();
        if(sessionProfile == 'Standard'){
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
        if (!Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isAccessible() &&
            Schema.sObjectType.Membership_Type__mdt.fields.MasterLabel.isCreateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
             }
        Payment_Link__c payLink = new Payment_Link__c();
        payLink.Contact__c = newCont.Id;
        payLink.Email__c = newCont.Email;
        payLink.Link_Sent_Date__c = Date.Today();
        payLink.Payment_Key__c = 'Test';
        payLink.Payment_Link__c = paymentLink;
        insert payLink;
        System.debug('Payment Link Record Created : '+'ID: '+payLink.Id+', /r/n'+payLink.Contact__c+', '+payLink.Payment_Key__c+', '+payLink.Payment_Link__c);
        return null;
    }
    


}