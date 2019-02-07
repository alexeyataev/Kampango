public class NctETMembershipPaymentPageController 
{
    public string twomems{get; set;}
    public Date expDate {get; set;}
    public boolean twomem{get; set;}
    public String isGiftAid{get; set;}
    public String firstname{get; set;}
    public String lastname{get; set;}
    public String email{get; set;}
    public String phone{get; set;}
    public String sfirstname{get; set;}
    public String slastname{get; set;}
    public String semail{get; set;}
    public String sphone{get; set;}
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
    public String sGenders {get;set;}
    public list<SelectOption> genderOptions{get; set;}
    
    public list<String> contactSelectedPreferences {
        get{
            if(contactSelectedPreferences == NULL){
                
                contactSelectedPreferences = new List<String>();
            }
            return contactSelectedPreferences;
        }
        set;}
    public list<SelectOption> contactPreferenceOptions {get; set;}
    
    public boolean smsOpt{get; set;}
    public boolean postOpt{get; set;}
    public boolean emailOpt{get; set;}
    public boolean doNotCallOpt{get; set;}
    public AccountContactRelation accntContRel{get; set;}
    public cpm__Payment_Profile__c pymtPrfl {get;set;}
    public npe03__Recurring_Donation__c recDon {get;set;}
    public gaid__Gift_Aid_Declaration__c gftAid {get;set;}
    
    public Id feeAmount {get;set;}
    public Id feeAmountgift{get; set;}
    public Id selectBranch {get; set;}
    public string membershipNumber {get;set;}
    public string courseBookingNo {get;set;}
    public string redirectURL {get;set;} 
    public Id contId {get;set;}
    public boolean etSpecific;
    
    public String accountName {get; set;}
    public String sortCode {get; set;}
    public String accountNumber {get; set;}
    public string displayValue {get;set;}
    public string counter  {get;set;}
    public string selValues {get;set;}
    public Membership_Type__mdt membershipInfo {get;set;}
    public npe03__Recurring_Donation__c reccDon {get;set;}
    public Map<String, List<Membership_Type__mdt>> membershipTypeMap{get;set;}
    public list<Account> branchs {get; set;}
    
    public Map<String, list<sObject>> nearestBranchs {get; set;}
    public Id branchRecordTypeId {get; set;}
    public list<Account> latlonPostcode {get; set;}
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
        contactPreferenceOptions =SObjectUtilities.getPicklistValues(con, 'Contact_Prefrence__c');
       	Id userId = userinfo.getUserId();
        isStaff = ContactUtilities.isStaff(userId);
        
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
            newCont = [SELECT Id,Salutation,DoNotCall, SMS_Opt_Out__c, Post_Opt_Out__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,MailingPostalCode,Contact_Prefrence__c,Prefered_First_Name__c,AccountId FROM Contact where id=:contId];
            if(newCont != null){
                
                firstname = newCont.FirstName;
                lastname = newCont.LastName;
                email = newCont.Email;
                phone = newCont.Phone;
                postCode = newCont.MailingPostalCode;
                salutationPrimary = newCont.Salutation;
                genders = newCont.Gender__c;
                smsOpt = newCont.SMS_Opt_Out__c;
    			postOpt = newCont.Post_Opt_Out__c;
    			emailOpt = newCont.HasOptedOutOfEmail;
    			doNotCallOpt = newCont.DoNotCall;
            }
        }
        smsOpt = true;
        postOpt = true;
        emailOpt = true;
        doNotCallOpt = true;
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
                
        system.debug(firstname + '   *$*#@**$*$ firstname  ' + lastname + ' lastname &$#*#*# email  ' + email + '   *$*$*$ phone ' + phone);
        System.debug('Twomems :'+twomems+'salutationPrimary: '+salutationPrimary+'salutationSecondary: '+salutationSecondary
                    +'Genders: '+genders+'Contact Preferences:'+contactSelectedPreferences);
                    System.debug('smsOpt: '+smsOpt+'postOpt '+postOpt+'emailOpt '+emailOpt+'doNotCallOpt '+doNotCallOpt);

        String contactPreference = '';
        Boolean start = true;
        if(!contactSelectedPreferences.isEmpty()) {           
            for(String str : contactSelectedPreferences) {
                if(start) {
                    contactPreference = str;
                    start = false;
                } else {               
                    contactPreference = contactPreference + ';' + str;
                }
            }
        }
        
        list<String> firstContactFieldsList = new list<String>{firstname,lastname,email,genders,phone,salutationPrimary};
        list<String> secondContactFieldsList = new list<String>{sfirstname,slastname,semail,sgenders,sphone,salutationSecondary};
        list<String> contactFieldListExt = new list<String>{postCode,contactPreference,streetValue,streetValue1,streetValue2,stateValue,cityValue};
        list<Boolean> contactBooleanList = new list<Boolean>{smsOpt,postOpt,emailOpt,doNotCallOpt};
        
        System.debug('contactBooleanList: '+contactBooleanList);
     
            
       	Id userId = userinfo.getUserId();
        isStaff = ContactUtilities.isStaff(userId);
        System.debug('isStaff: '+isStaff);
        isVolunteer = ContactUtilities.isVolunteerExisting(contId);
        isPractitioner = MembershipUtilties.isPractitioner(firstname, lastname, email);
        targetCustomer = ContactUtilities.targetCustomer(isStaff,isVolunteer,isPractitioner,twomems);
        isMembershipExists = ContactUtilities.isMembershipExists(contId, email);
        
        
        System.debug('isMembershipExists: '+isMembershipExists+'targetCustomer:'+targetCustomer);
        
        
        if(isContactExisting == false){
            if(newCont == null )
            {
                recordType = 'Parent';
                
                newCont = ContactHelper.getCreateContact(firstContactFieldsList,contactFieldListExt,selectBranch,recordType,newCont,contactBooleanList);
                
                if(twomems == 'true' && sfirstname != null || sfirstname != '')
                {
                    recordType = 'Companion';
                    snewCont = ContactHelper.getCreateContact(secondContactFieldsList,contactFieldListExt,selectBranch,recordType,newCont,contactBooleanList);
                    
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint',targetCustomer,etSpecific);
                    
                    
                }
                else 
                {
                    
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('Individual',targetCustomer,etSpecific);
                    System.debug('membershipTypeMap '+membershipTypeMap);
                    
                }
            }
        }
        
        
        // Yet to define the custom metadata, once done the logic can be updated and modified accordingly, hence commenting
        
        else if(contId != null)
        {
            
            System.debug('isPractitioner :'+isPractitioner);
            
            if(isVolunteer == true || isPractitioner == true){
                
                if(twomems == 'true')
                {   
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint',targetCustomer,etSpecific);            
                }
                else 
                {
                    
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('Individual',targetCustomer,etSpecific);
                    System.debug('membershipTypeMap '+membershipTypeMap);
                }
                
                
            }
            
            else{
                if(twomems == 'true')
                {   
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint',targetCustomer,etSpecific);            
                }
                else 
                {
                    
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('Individual',targetCustomer,etSpecific);
                    System.debug('membershipTypeMap '+membershipTypeMap);
                }
            }
        }
        else if(isContactExisting == true){
            System.debug('Contact Exists(Next Flow Starts): '+isContactExisting);
            newCont =[SELECT Id,Salutation,Gender__c, LastName, FirstName, Email, Phone,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact where Email = :email limit 1];
            if(twomems == 'true' && sfirstname != null || sfirstname != '')
            {
                recordType = 'Companion';
                snewCont = ContactHelper.getCreateContact(secondContactFieldsList,contactFieldListExt,selectBranch,recordType,newCont,contactBooleanList);    
            }
            if(isVolunteer == true || isPractitioner == true){
                
                if(twomems == 'true')
                {   
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint',targetCustomer,etSpecific);            
                }
                else 
                {
                    
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('Individual',targetCustomer,etSpecific);
                    System.debug('membershipTypeMap '+membershipTypeMap);
                }                    
            }                
            else{
                if(twomems == 'true')
                {   
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint',targetCustomer,etSpecific);            
                }
                else 
                {
                    
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('Individual',targetCustomer,etSpecific);
                    System.debug('membershipTypeMap '+membershipTypeMap);
                }
            }    
        }
        if(isStaff == true){
            thankYouSec();                
        }    
        return null;
        
    }
    public PageReference contactInfo()
    {
        if(membershipInfo != null && inspect == true){
            feeAmount = Apexpages.currentPage().getParameters().get('seltdName');
            PageReference redirecContUrl;
            system.debug('*$*$*$  feeAmount   ' + feeAmount+ '$$$$$$ lifeMembership: '+lifeMembership);
            membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:feeAmount];
        }
        else{
            feeAmount = Apexpages.currentPage().getParameters().get('seltdName');
            PageReference redirecContUrl;
            system.debug('*$*$*$  feeAmount   ' + feeAmount+ '$$$$$$ lifeMembership: '+lifeMembership);
            membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:feeAmount];
        }
        System.debug('Membership##### '+membershipInfo);
        
        if(membershipInfo != null)
        {
            
            if(membershipInfo.Payment_Method__c == 'Credit/Debit Card')
            {
                sessionProfile = userinfo.getUserType();
                if(membershipInfo != null && sessionProfile != 'Standard')
                {
                    
                    paymentHubCallout();
                    PageReference pageRef = new PageReference(redirectURL);
    
                    pageRef.setRedirect(true);
                    System.debug('doing: '+sessionProfile);
                    return pageRef;
                    
                }
                else if(sessionProfile == 'Standard'){
                    displaySuccessMessage = true;
                    paymentHubCallout();
                    recDon = new npe03__Recurring_Donation__c();
                    recDon.Name = 'Credit/Debit Card Membership';
                    recDon.npe03__Amount__c = 60;
                    recDon.npe03__Contact__c = newCont.Id;
                    recDon.CARE_Payment_Frequency__c = 'One Time';
                    recDon.Source__c = membershipSource;
                    recDon.First_Contact__c = newCont.Id;
                    recDon.npe03__Schedule_Type__c = membershipInfo.Schedule_Type__c;
                    recDon.npe03__Installment_Period__c = 'Yearly';
                    recDon.npsp4hub__Payment_Method__c = 'Credit/Debit Card';
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
    public void nctBranchs(){
        
        String emails = Apexpages.currentPage().getParameters().get('emailsVal');
        if(contId == null){
            isContactExisting = ContactUtilities.isContactExisting(emails);
            System.debug('isContactExisting: '+isContactExisting);
        }
        //isMembershipExists = ContactUtilities.isMembershipExists(contId, email);
        postCode = Apexpages.currentPage().getParameters().get('postVal');
        System.debug('postCode: '+postCode);
        if(postCode != null && postCode != ''){
        nearestBranchs = MembershipUtilties.getBranches(postCode);
        System.debug('branches'+nearestBranchs);
        }
        }
    public void membershipDupeChecker(){
        
        String emails = Apexpages.currentPage().getParameters().get('emailDupeVal');
        System.debug('emails: '+emails);
        if(contId == null){
            isContactExisting = ContactUtilities.isContactExisting(emails);
            System.debug('isContactExisting: '+isContactExisting);
       
        }
        isMembershipExists = ContactUtilities.isMembershipExists(contId, emails);
		System.debug('isMembershipExists: '+isMembershipExists);         
    }
    public void giftAidCreation(){
        displayMbrNoMessage = true;
        if(sessionProfile != 'Standard'){
            feeAmount = Apexpages.currentPage().getParameters().get('seltAmountdName');
            PageReference redirecContUrl;
            system.debug('*$*$*$  feeAmount   ' + feeAmount+ '$$$$$$ lifeMembership: '+lifeMembership);
            membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Id =:feeAmount];
        }
      	
        System.debug('Membership##### '+membershipInfo);
      
        system.debug(firstname + '   *$*#@**$*$ firstname  ' + lastname + ' lastname &$#*#*# email  ' + email + '   *$*$*$ phone ' + phone);
        list<String> accountDetails = new list<String>();
         accountDetails.add(accountNumber);
         accountDetails.add(accountName);
         accountDetails.add(sortCode);
         accountDetails.add(acquistion);
         accountDetails.add(membershipSource);
        MembershipCrudHelper MemCrudHelp = new MembershipCrudHelper();
        if(isGiftAid == 'true'){
        	gftAid = MemCrudHelp.giftAid(newCont.Id,isGiftAid,membershipInfo,accountDetails);
        }
        inspect = true;
    }
   
    public void paymentSave()
    {   
        displayMbrNoMessage = true;
        system.debug(firstname + '   *$*#@**$*$ firstname  ' + lastname + ' lastname &$#*#*# email  ' + email + '   *$*$*$ phone ' + phone);
        list<String> accountDetails = new list<String>();
         accountDetails.add(accountNumber);
         accountDetails.add(accountName);
         accountDetails.add(sortCode);
         accountDetails.add(acquistion);
         accountDetails.add(membershipSource);
         //accountDetails.sort();
        System.debug('accountDetails:'+accountDetails);
        MembershipCrudHelper MemCrudHelp = new MembershipCrudHelper();
        pymtPrfl = MemCrudHelp.paymentProfile(newCont,accountDetails);
        if(isGiftAid == 'true'){
        	gftAid = MemCrudHelp.giftAid(newCont.Id,isGiftAid,membershipInfo,accountDetails);
        }
        if(pymtPrfl != null){
            recDon = MemCrudHelp.recDonation(newCont.Id,snewCont,membershipInfo,pymtPrfl,accountDetails);
        }
        thankYouSec();
    }    
    public void thankYouSec()
    {
       displayMbrNoMessage = true;
       ThankYouHelper thankYou = new ThankYouHelper();
       System.debug('Blocker: '+recDon);
       membershipNumber = thankYou.membershipNumberCreation(newCont,recDon,lifeMembership);
    }
    public PageReference paymentHubCallout()
    {   
        list<String> contactDetails = new list<String>();
        contactDetails.add(email);
        contactDetails.add(firstname);
        contactDetails.add(lastname);
        //contactDetails.add(redirectURL);
        contactDetails.sort();
       
        redirectURL = PaymentHubCalloutUtilities.PaymentHub(newCont,membershipInfo,contactDetails, recDon);
        sessionProfile = userinfo.getUserType();
        if(sessionProfile == 'Standard'){
            return sendPaymentLinkToParent(redirectURL);
        }
        else{
            return null;
        }
        //return null;
        
        
        
    }
    public PageReference sendPaymentLinkToParent(string paymentLink)
    {   
        /* Updated by Mahanth 20/12/2018
        *  The following code creates a payment link record
        *   
        */
        System.debug('********** Creating Payment Link Record **************');
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