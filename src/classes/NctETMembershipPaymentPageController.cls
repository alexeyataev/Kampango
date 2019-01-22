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
    public String genderValue {get; set;}
    public String streetValue {get; set;}
    public String streetValue1 {get; set;}
    public String streetValue2 {get; set;}
    public String stateValue {get; set;}
    public String cityValue {get; set;}
    public Contact newCont {get;set;} 
    public Contact snewCont {get;set;} 
    public String salutation{get; set;}
    public String SelectedPreferences {get;set;}
    public String SSelectedPreferences {get;set;}
    public list<SelectOption> salutationOptions{get; set;}
   
    public String Genders {get;set;}
    public String SGenders {get;set;}
    public list<SelectOption> genderOptions{get; set;}
    
    public list<String> ContactSelectedPreferences {
        get{
            if(ContactSelectedPreferences == NULL){
                
                ContactSelectedPreferences = new List<String>();
            }
            return ContactSelectedPreferences;
        }
        set;}
    public list<SelectOption> contactPreferenceOptions {get; set;}
    
    public AccountContactRelation accntContRel{get; set;}
    public cpm__Payment_Profile__c pymtPrfl {get;set;}
    public npe03__Recurring_Donation__c recDon {get;set;}
    public gaid__Gift_Aid_Declaration__c gftAid {get;set;}
    
    public Id feeAmount {get;set;}
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
    public string SelValues {get;set;}
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
    
    public nctETMembershipPaymentPageController()
    {  
        contId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('*$*$**$ contId  ' + contId);
        etSpecific = true;
       	Contact con= new Contact();
        salutationOptions = SObjectUtilities.getPicklistValues(con, 'salutation');
        genderOptions = SObjectUtilities.getPicklistValues(con, 'Gender__c');
        contactPreferenceOptions =SObjectUtilities.getPicklistValues(con, 'Contact_Prefrence__c');
       	Id userId = userinfo.getUserId();
        isStaff = ContactUtilities.isStaff(userId);
        if(isStaff == true){
            
            list<User> staffUserList = StaffMembershipUtilities.createStaffMembership(userId);
       		staffMember ='staff';
            if(staffUserList.size()>0){
                firstname = staffUserList[0].FirstName;
                lastname = staffUserList[0].LastName;
                email = staffUserList[0].Email;
                phone = staffUserList[0].Phone;
                
            }
            recDon = new npe03__Recurring_Donation__c();
            displaySuccessMessage = false;
            displayMbrNoMessage = true;
            displayValue = 'none';
            counter = '';
            accountName='';
            sortCode='';
            accountName=''; 
        }
        else{
            staffMember ='no staff';
            if(contId != null)
            {
                newCont = [SELECT Id,Salutation,Gender__c, LastName, FirstName, Email, Phone,MailingPostalCode,Contact_Prefrence__c,Prefered_First_Name__c,AccountId FROM Contact where id=:contId];
                if(newCont != null){
                    firstname = newCont.Prefered_First_Name__c;
                    lastname = newCont.LastName;
                    email = newCont.Email;
                    phone = newCont.Phone;
                    postCode = newCont.MailingPostalCode;
                    SelectedPreferences = newCont.Salutation;
                    Genders = newCont.Gender__c;
                }
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
        
       
        
        
    }
    public PageReference  receiveInput(){
                
        system.debug(firstname + '   *$*#@**$*$ firstname  ' + lastname + ' lastname &$#*#*# email  ' + email + '   *$*$*$ phone ' + phone);
        System.debug('Twomems :'+twomems);
        System.debug('SelectedPreferences: '+SelectedPreferences);
        System.debug('SSelectedPreferences: '+SSelectedPreferences);
        System.debug('Genders: '+Genders);
        System.debug('Contact Preferences:'+ContactSelectedPreferences);
        String ContactPreference = '';
        Boolean Start = true;
        if(!ContactSelectedPreferences.isEmpty()) {           
            for(String Str : ContactSelectedPreferences) {
                if(Start) {
                    ContactPreference = Str;
                    Start = false;
                } else {               
                    ContactPreference = ContactPreference + ';' + Str;
                }
            }
        }
       	Id userId = userinfo.getUserId();
        isStaff = ContactUtilities.isStaff(userId);
        System.debug('isStaff: '+isStaff);
        isVolunteer = ContactUtilities.isVolunteerExisting(contId);
        isPractitioner = MembershipUtilties.isPractitioner(firstname, lastname, email);
        targetCustomer = ContactUtilities.targetCustomer(isStaff,isVolunteer,isPractitioner,twomems);
        isMembershipExists = ContactUtilities.isMembershipExists(contId, email);
        
        
        System.debug('isMembershipExists: '+isMembershipExists);
        System.debug('targetCustomer:'+targetCustomer);
        if(isMembershipExists == true ){
            System.debug('Test Redirect');
            if(contId != null){
                return membershipRedirect(contId);
            }
            else{
                npe03__Recurring_Donation__c recDonList = [SELECT 
                                                              Id, 
                                                              Name,
                                                              npe03__Contact__c,
                                                              npe03__Contact__r.Email,
                                                              Membership_Number__c 
                                                       FROM 
                                                              npe03__Recurring_Donation__c
                                                       WHERE
                                                              npe03__Contact__r.Email = :email limit 1];
                Id conID = recDonList.npe03__Contact__r.Id;
                System.debug('conID: '+conId);
                return membershipRedirect(conID);
            }
            	
        }
        else{
            if(isContactExisting == false){
                if(newCont == null )
                {
                    newCont = new Contact();
                    newCont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
                    newCont.Prefered_First_Name__c = firstname;
                    newCont.LastName = lastname;
                    newCont.Email = email;
                    newCont.Phone = phone;
                    newCont.MailingPostalCode = postCode;
                    //if(eDate != null){
                        //expDate = Date.valueOf(eDate);
                        //newCont.Expected_Due_Date__c = expDate; 
                    //}
                    newCont.Branch__c = selectBranch; 
                    newCont.Salutation = SelectedPreferences;
                    newCont.Gender__c = Genders;
                    newCont.Contact_Prefrence__c = ContactPreference;
                    newCont.MailingStreet = streetValue+''+streetValue2+''+streetValue2;
                    newCont.MailingState = stateValue;
                    newCont.MailingCity = cityValue;
                    Database.insert(newCont, false);
                	
                    
                    if(twomems == 'true' && sfirstname != null || sfirstname != '')
                    {
                        snewCont = new Contact();
                        snewCont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Companion').getRecordTypeId();
                        snewCont.Prefered_First_Name__c = sfirstname;
                        snewCont.LastName = slastname;
                        snewCont.Email = semail;
                        snewCont.Phone = sphone;
                        snewCont.Parent_Contact__c = newCont.id;
                        snewCont.MailingPostalCode = postCode;
                        //snewCont.Contact_Prefrence__c = ContactSelectedPreferences;
                        //snewCont.Expected_Due_Date__c = expDate;
                        snewCont.Gender__c = SGenders;
                        snewCont.Salutation = SSelectedPreferences;     
                        snewCont.Branch__c = selectBranch;
                        snewCont.MailingStreet = streetValue+''+streetValue1+''+streetValue2;
                        snewCont.MailingState = stateValue;
                        snewCont.MailingCity = cityValue;
                        Database.insert(snewCont, false);
                        membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint',targetCustomer,etSpecific);
                        
                        
                    }
                    else 
                    {
                        System.debug('twomems '+twomems);
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
                        System.debug('twomems '+twomems);
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
                        System.debug('twomems '+twomems);
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
                    snewCont = new Contact();
                    snewCont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Companion').getRecordTypeId();
                    snewCont.Prefered_First_Name__c = sfirstname;
                    snewCont.LastName = slastname;
                    snewCont.Email = semail;
                    snewCont.Phone = sphone;
                    snewCont.Parent_Contact__c = newCont.id;
                    snewCont.MailingPostalCode = postCode;
                    //snewCont.Expected_Due_Date__c = expDate;
                    snewCont.Gender__c = SGenders;
                    snewCont.Salutation = SSelectedPreferences;     
                    snewCont.Branch__c = selectBranch;
                    //snewCont.Contact_Prefrence__c = ContactSelectedPreferences;
                    snewCont.MailingStreet = streetValue+''+streetValue2+''+streetValue2;
                    snewCont.MailingState = stateValue;
                    snewCont.MailingCity = cityValue;
                    Database.insert(snewCont, false);
                    
                    
                }
                if(isVolunteer == true || isPractitioner == true){
                        
                    if(twomems == 'true')
                    {   
                        membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint',targetCustomer,etSpecific);            
                    }
                    else 
                    {
                        System.debug('twomems '+twomems);
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
                        System.debug('twomems '+twomems);
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
        
            
    }
    public void ContactInfo()
    {
        feeAmount = Apexpages.currentPage().getParameters().get('seltdName');
        PageReference redirecContUrl;
        system.debug('*$*$*$  feeAmount   ' + feeAmount);
        membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                where Id =:feeAmount];
        System.debug('Membership##### '+membershipInfo);
        if(membershipInfo != null)
        {
            if(membershipInfo.Payment_Method__c == 'Credit/Debit Card')
            {
                displaySuccessMessage = true;
                
                PaymentHubCallout();
                
                
               	recDon.Name = 'Credit/Debit Card Membership';
                recDon.npe03__Amount__c = 60;
                recDon.npe03__Contact__c = newCont.Id;
                recDon.CARE_Payment_Frequency__c = 'One Time';
                recDon.First_Contact__c = newCont.Id;
                recDon.npe03__Installment_Period__c = 'Yearly';
                recDon.npsp4hub__Payment_Method__c = 'Credit/Debit Card';
                
                recDon.Membership_Status__c = 'Pending';
                
                Insert recDon;
                
                thankYouSec();
                
            }
            else{
                thankYouSec();
            }
        }
    }
  
    public void nctBranchs(){
        
        String emails = Apexpages.currentPage().getParameters().get('emailsVal');
        if(contId == null){
            isContactExisting = ContactUtilities.isContactExisting(emails);
            System.debug('isContactExisting: '+isContactExisting);
        }
        
        postCode = Apexpages.currentPage().getParameters().get('postVal');
        System.debug('postCode: '+postCode);
        nearestBranchs = MembershipUtilties.getBranches(postCode);
        System.debug('branches'+nearestBranchs);
        
    }
    public void PaymentSave()
    {
        displayMbrNoMessage = true;
        system.debug(firstname + '   *$*#@**$*$ firstname  ' + lastname + ' lastname &$#*#*# email  ' + email + '   *$*$*$ phone ' + phone);
         
        if(newCont != null)
        {
            system.debug(' *$*$*$* Contact Account Id   ' + newCont.AccountId);
            pymtPrfl.RecordTypeId = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();
            pymtPrfl.cpm__Contact__c = newCont.Id; 
            if(accountNumber != '' && accountNumber != null)
            {
                pymtPrfl.cpm__Bank_Account__c = accountNumber;
            }            
            pymtPrfl.cpm__Account__c = newCont.AccountId;
            pymtPrfl.cpm__Holder_Name__c = accountName;
            pymtPrfl.paybacs__Sort_Code__c = sortCode;
            insert pymtPrfl; 
          System.debug('Gift Aid Check box: '+isGiftAid);
            if(isGiftAid == 'true' ) 
            {
                gftAid.gaid__Contact__c= newCont.Id;
                //gftAid.Method__c = 'Online';
                gftAid.gaid__Type__c = membershipInfo.GiftAid_Type__c;
                gftAid.gaid__Acquisition_Method__c = membershipInfo.GiftAid_Acquisition_Method__c;
                gftAid.gaid__Start_Date__c = system.today();
                gftAid.gaid__Date_Made__c = system.today();
                gftAid.gaid__Active__c = true;
                insert gftAid;             
            } 
            recDon.Name = membershipInfo.Contact_Type__c + ' ' + membershipInfo.Membership__c;
            recDon.npe03__Amount__c = membershipInfo.Installment_Amount__c;
            recDon.npe03__Installments__c = membershipInfo.No_of_Installments__c;
            recDon.npe03__Contact__c = newCont.Id;
            
            recDon.First_Contact__c = newCont.Id;
            recDon.npe03__Schedule_Type__c = membershipInfo.Schedule_Type__c;
            recDon.npe03__Installment_Period__c = membershipInfo.Installment_Period__c;
            recDon.npe03__Installments__c = membershipInfo.No_of_Installments__c;
            recDon.npsp4hub__Payment_Method__c = membershipInfo.Payment_Method__c;
            recDon.npsp4hub__Payment_Processor__c = membershipInfo.Payment_Processor__c;
            recDon.npsp4hub__Target__c = membershipInfo.Payment_Target__c;
            recDon.Membership_Status__c = 'Confirmed';
            recDon.npsp4hub__Payment_Profile__c = pymtPrfl.Id;
            Insert recDon; 
       }
       thankYouSec();
    }    
    public void thankYouSec()
    {
        displayMbrNoMessage = true;
        list<User> UserList = new list<User>();
        list<npe03__Recurring_Donation__c> reccDonList = new list<npe03__Recurring_Donation__c>();
        
        system.debug('Apexpages.currentPage().getParameters().get(contId) ---   ' + Apexpages.currentPage().getParameters().get('contId'));
        if(Apexpages.currentPage().getParameters().get('contId') != null && Apexpages.currentPage().getParameters().get('contId') !='')
        {
            system.debug('Apexpages.currentPage().getParameters().get(contId) ---   ' + Apexpages.currentPage().getParameters().get('contId'));
            reccDonList = [select Id, Membership_Number__c,npe03__Contact__c,npsp4hub__Payment_Method__c,npe03__Contact__r.AccountId,npe03__Contact__r.Phone,
                       npe03__Amount__c,npe03__Installment_Period__c,Membership_type__c, npe03__Contact__r.Prefered_First_Name__c,
                       npe03__Contact__r.LastName,npe03__Contact__r.Email,npe03__Installment_Amount__c, Membership_Status__c,
                       npe03__Date_Established__c from npe03__Recurring_Donation__c where npe03__Contact__c =: Apexpages.currentPage().getParameters().get('contId') limit 1];   
            if(reccDonList != null && !reccDonList.isEmpty())
            {
                membershipNumber = reccDonList[0].Membership_Number__c;
                reccDonList[0].Membership_Status__c = 'Confirmed';
                upsert reccDonList;
                system.debug('membershipNumber  ' + membershipNumber);
            }
            else if(reccDonList == null && reccDonList.isEmpty())
            {
                recDon.Name = 'Credit/Debit Card Membership';
                recDon.npe03__Amount__c = 60;
                recDon.npe03__Contact__c = Apexpages.currentPage().getParameters().get('contId');
                recDon.CARE_Payment_Frequency__c = 'One Time';
                recDon.First_Contact__c = Apexpages.currentPage().getParameters().get('contId');
                recDon.npe03__Installment_Period__c = 'Yearly';
                recDon.npsp4hub__Payment_Method__c = 'Credit/Debit Card';
                
                recDon.Membership_Status__c = 'Pending';
                
                Insert recDon;
            }
        }
        else{
             
            
            
            if(isStaff == true)
            {
                System.debug('Staff flow');
                recDon.Name = 'Staff Membership';
                recDon.npe03__Amount__c = 0;
                recDon.npe03__Contact__c = newCont.Id;
                recDon.CARE_Payment_Frequency__c = 'One Time';
                recDon.First_Contact__c = newCont.Id;
                recDon.npe03__Installment_Period__c = 'Yearly';
                
                recDon.Membership_Status__c = 'Confirmed';
               
                Insert recDon;
            }
           
           
            
        }
        system.debug('RECCURRING DONATION   ' + recDon.Id);
        if(recDon.Id != null)
        {
            reccDonList = [select Id, Membership_Number__c,npe03__Contact__c,npsp4hub__Payment_Method__c,
                       npe03__Amount__c,npe03__Installment_Period__c,Membership_type__c, npe03__Contact__r.Prefered_First_Name__c,
                       npe03__Contact__r.LastName, npe03__Contact__r.Email,npe03__Installment_Amount__c, npe03__Contact__r.Phone,
                       npe03__Date_Established__c,npe03__Contact__r.AccountId from npe03__Recurring_Donation__c where Id =: recDon.Id];   
            if(reccDonList != null && !reccDonList.isEmpty())
            {
                membershipNumber = reccDonList[0].Membership_Number__c;
                system.debug('membershipNumber  ' + membershipNumber);
            } 
            
            system.debug('RECCURRING DONATION record  ' + reccDonList);            
        } 
        if(reccDonList != null && !reccDonList.isEmpty())
        {
            UserList = [select Id, Name from User where user.ContactId =: reccDonList[0].npe03__Contact__c and Username =:reccDonList[0].npe03__Contact__r.Email];
            System.debug('User List:'+UserList);
            System.debug('displayMbrNoMessage: '+displayMbrNoMessage);
            if(UserList == null || UserList.isEmpty())
            {
                try
                {
                    account accnt = new account(Id = reccDonList[0].npe03__Contact__r.AccountId);
                    user etUsr = [select Id from User where profile.name = 'Enquiry PSA' limit 1];
                    accnt.OwnerId = etUsr.Id;
                    update accnt;
                    Profile portalProfile = [SELECT Id,Name FROM Profile WHERE Name ='Membership Coordinator' Limit 1];
                    User usr = new User();
                    string alias = reccDonList[0].npe03__Contact__r.Prefered_First_Name__c + reccDonList[0].npe03__Contact__r.LastName;
                    usr.Username = reccDonList[0].npe03__Contact__r.Email;
                    usr.Email = reccDonList[0].npe03__Contact__r.Email;
                    usr.FirstName = reccDonList[0].npe03__Contact__r.Prefered_First_Name__c;
                    usr.LastName = reccDonList[0].npe03__Contact__r.LastName;
                    //usr.CommunityNickname = 'comNick';
                    usr.Alias = alias.substring(1, 6);
                    usr.TimeZoneSidKey = 'GMT';
                    usr.LocaleSidKey = 'en_GB';
                    usr.EmailEncodingKey = 'ISO-8859-1';
                    usr.LanguageLocaleKey = 'en_US';
                    usr.ProfileId = portalProfile.Id;
                    usr.ContactId = reccDonList[0].npe03__Contact__c;
                    usr.Phone = reccDonList[0].npe03__Contact__r.Phone;
                    insert usr;
                }
                catch(DmlException e)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Community User credentials Exists in the System with this Username: '+reccDonList[0].npe03__Contact__r.Email));
                }
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Community User credentials Exists in the System with this Username: '+reccDonList[0].npe03__Contact__r.Email));
                System.debug('User Exists: '+UserList);
            } 
         }
         System.debug('Membership no'+membershipNumber);
    }
    public void PaymentHubCallout()
    {
        decimal instlmntAmt; 
        if(membershipInfo != null)
        {
           instlmntAmt = membershipInfo.Installment_Amount__c; 
        }
        
        
        string responseContent;
        
        HttpRequest tokenRequest = new HttpRequest();
        HttpResponse tokenResponse = new HttpResponse();
        Http tokenHttp = new Http();
        
        //tokenRequest.setEndpoint(System.Label.ENDPOINTOAUTH+'client_id='+System.Label.CLIENTID+'&client_secret='+System.Label.CLIENT_SECRET+'&grant_type=password&username='+System.Label.ENDPOINT_USERNAME+'&password='+System.Label.ENDPOINT_PASSWORD);
        tokenRequest.setEndpoint('https://test.salesforce.com/services/oauth2/token?client_id=3MVG95AcBeaB55lVpFY_Rw8rGI.KUCG9dcqi1zRxbXuXhdoYYpgHOQUg01kQrJyfp_yYqnT6F.aEXC1U7n06J&client_secret=5804933462634405366&grant_type=password&username=payment.api@nct.org.uk.preuat&password=payment123rl3GtuRGUj15A1W6ysGuUAT3N');
  
        tokenRequest.setMethod('POST'); 
        tokenRequest.setTimeout(120000);    
        tokenResponse = tokenHttp.send(tokenRequest);

        AcessTokenResponseVo accessTokenVo = (AcessTokenResponseVo) JSON.deserialize(tokenResponse.getBody(),AcessTokenResponseVo.class);

        
        PaymentRequestVo paymentReq = new PaymentRequestVo();
        paymentReq.SuccessURL= System.Label.PAYMENTSTATUSURL+'/nctPaymentHubSuccessMsgPage?contId='+ newCont.Id;//'https://preuat-mynct.cs102.force.com/nctMembershipPaymentPage/nctPaymentHubErrorMsgPage'
        paymentReq.FailureURL= System.Label.PAYMENTSTATUSURL+'/nctPaymentHubErrorMsgPage';
        paymentReq.Origin='test';
 
        PaymentRequestVo.ContactVo cvo = new PaymentRequestVo.ContactVo();
        if(newCont != null)
        {
            cvo.Email = newCont.Email;        
          cvo.FirstName = newCont.Prefered_First_Name__c;
          cvo.LastName = newCont.LastName;
        }
        else if (newCont == null)
        {
            cvo.Email = email;        
          cvo.FirstName = firstname;
          cvo.LastName = lastname;
        }
 
        PaymentRequestVo.PayerVo payerReq = new PaymentRequestVo.PayerVo();
        payerReq.AllowDeduplication=true;
        payerReq.contact = cvo;
        payerReq.ContactUpdate ='replace';
        paymentReq.Payer = payerReq;
 
        PaymentRequestVo.PaymentVo payment = new PaymentRequestVo.PaymentVo();
        system.debug('*$*$**$*$ feeAmount  ' + instlmntAmt);        
        payment.Amount=instlmntAmt;
        paymentReq.Payment = payment;
 
        PaymentRequestVo.PaymentMethodVo paymentMethod = new PaymentRequestVo.PaymentMethodVo();
        paymentMethod.Name='CreditCard';
        paymentReq.PaymentMethod = paymentMethod;
 
        PaymentRequestVo.SourceConnectorVo sourceConnector = new PaymentRequestVo.SourceConnectorVo();
        sourceConnector.Name='PaymentHub';
        paymentReq.SourceConnector = sourceConnector;
 
        System.Debug('*$*$*$*$* JSON  =   ' + JSON.serializePretty(paymentReq));
        
        HttpRequest paymentHubRequest = new HttpRequest();
        HttpResponse paymentHubResponse = new HttpResponse();
        Http paymentHubHttp = new Http(); 
        
        //paymentHubRequest.setEndpoint(System.Label.SF_INSTANCE+'/services/apexrest/cpm/v1.0/Payment'); 
        
        paymentHubRequest.setEndpoint('https://cs102.salesforce.com/services/apexrest/cpm/v1.0/Payment');        
        paymentHubRequest.setHeader('Authorization','Bearer '+accessTokenVo.access_token);  
        //paymentHubRequest.setHeader('Authorization','Bearer '+ UserInfo.getSessionID()); 
        paymentHubRequest.setHeader('Content-Type','application/json; charset=UTF-8');
        paymentHubRequest.setHeader('Accept','application/json');
        
        //paymentHubRequest.setHeader('api-token',System.Label.API_TOKEN);
        paymentHubRequest.setHeader('api-token','IPy3Yvtin0aa2GPIke79Ewp24a0YSt6Daj5HJ9v9IGq2VTDYTWWkSx5jE2Pg54u02j0uHQZ3BwHfxFh8nKfXK4fiqZSQbZuXFQtQfAE926aFrwwVoOxPOJ6MiWSFpMc8b0UrOcbUD9pdcW7x8xNu3CtI5JfukTrRZqNByghsdTnWKLb79XrKpttmtHepMmVPv3QyPZYq');
        paymentHubRequest.setBody(JSON.serialize(paymentReq));
        paymentHubRequest.setMethod('POST'); 
        paymentHubRequest.setTimeout(120000);    
        paymentHubResponse = paymentHubHttp.send(paymentHubRequest);
        System.debug('*$*$*$*$*  RESPONSE =   ' + paymentHubResponse.getBody());
        responseContent = paymentHubResponse.getBody();
        system.debug('*$*$*$* responseContent ===   ' + responseContent);
        redirectURL = responseContent.subString(responseContent.IndexOf('PaymentHub')+28, responseContent.lastIndexOf('PaymentMethod')-3);
        system.debug('*$*$*$** redirectURL =   ' + redirectURL);
        redirectURL += '&nooverride=1';
        
        sendPaymentLinkToParent(redirectURL);
    }
    public void sendPaymentLinkToParent(string paymentLink)
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
        
    }
    public PageReference membershipRedirect(Id contId){
        if(contId != null || contId != ''){
            PageReference pageRef = new PageReference('/apex/MembershipStatus?id='+contId);
            System.debug('doing');
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;

    }

}