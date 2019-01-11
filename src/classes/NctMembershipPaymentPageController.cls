public class NctMembershipPaymentPageController 
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
    public AccountContactRelation accntContRel{get; set;}
    public cpm__Payment_Profile__c pymtPrfl {get;set;}
    public npe03__Recurring_Donation__c recDon {get;set;}
    public gaid__Gift_Aid_Declaration__c gftAid {get;set;}
    public Booking__c corsBkng {get;set;}
    public Id feeAmount {get;set;}
    public Id selectBranch {get; set;}
    public string membershipNumber {get;set;}
    public string courseBookingNo {get;set;}
    public string redirectURL {get;set;} 
    public Id contId {get;set;}
    public Course__c cors;
    // added by MembershipFormController
    public String accountName {get; set;}
    public String sortCode {get; set;}
    public String accountNumber {get; set;}
    public string displayValue {get;set;}
    public string counter  {get;set;}
    public string SelValues {get;set;}
    public string acquistion{get; set;} 
    public Membership_Type__mdt membershipInfo {get;set;}
    public npe03__Recurring_Donation__c reccDon {get;set;}
    public Map<String, List<Membership_Type__mdt>> membershipTypeMap{get;set;}
    public list<Account> branchs {get; set;}
    public list<Account> nearestBranchs {get; set;}
    public Id branchRecordTypeId {get; set;}
    public list<Account> latlonPostcode {get; set;}
    public String eDate {get; set;} 
    public boolean isPractitioner {get; set;}
    public boolean isContactExisting {get; set;}
    public boolean isVolunteer {get; set;}
    public String SelectedPreferences {get;set;}
    public String SSelectedPreferences {get;set;}
    public List<SelectOption> getPreferenceOptions() {
        List<SelectOption> Options = new List<SelectOption>();
        Options.add(new SelectOption('Mr.','Mr.'));
        Options.add(new SelectOption('Ms.','Ms.'));
        Options.add(new SelectOption('Mrs.','Mrs.'));
        Options.add(new SelectOption('Miss.','Miss.'));
        Options.add(new SelectOption('Dr.','Dr.'));
        Options.add(new SelectOption('Prof.','Prof.'));
         
        return Options;
    }
    public List<SelectOption> getSPreferenceOptions() {
        List<SelectOption> Options = new List<SelectOption>();
        Options.add(new SelectOption('Mr.','Mr.'));
        Options.add(new SelectOption('Ms.','Ms.'));
        Options.add(new SelectOption('Mrs.','Mrs.'));
        Options.add(new SelectOption('Miss.','Miss.'));
        Options.add(new SelectOption('Dr.','Dr.'));
        Options.add(new SelectOption('Prof.','Prof.'));
         
        return Options;
    }
    public String Genders {get;set;}
    public String SGenders {get;set;}
    public List<SelectOption> getGenderOptions() {
        List<SelectOption> Options = new List<SelectOption>();
        Options.add(new SelectOption('Male','Male'));
        Options.add(new SelectOption('Female','Female'));
        Options.add(new SelectOption('Other','Other')); 
        return Options;
    }
    public list<String> ContactSelectedPreferences {
        get{
            if(ContactSelectedPreferences == NULL){
                
                ContactSelectedPreferences = new List<String>();
            }
            return ContactSelectedPreferences;
        }
        set;}
    public List<SelectOption> getContactPreferenceOptions() {
        List<SelectOption> Options = new List<SelectOption>();
        Options.add(new SelectOption('Post','Post'));
        Options.add(new SelectOption('Email','Email'));
        Options.add(new SelectOption('SMS Text','SMS Text'));
        Options.add(new SelectOption('Telephone','Telephone'));
        return Options;
    }
    //public string isContactExistingVal {get; set;}
    
    public nctMembershipPaymentPageController()
    {   
        contId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('*$*$**$ contId  ' + contId);
        if(contId != null)
        {
            newCont = [SELECT Id,Salutation,Gender__c, LastName, FirstName, Contact_Prefrence__c, Email, Phone,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact where id=:contId];
            if(newCont != null){
                firstname = newCont.Prefered_First_Name__c;
                lastname = newCont.LastName;
                email = newCont.Email;
                phone = newCont.Phone;
                postCode = newCont.MailingPostalCode;
                SelectedPreferences = newCont.Salutation;
                Genders = newCont.Gender__c;
                System.debug('SelectedPreferences: '+SelectedPreferences);
            }
        }
        pymtPrfl = new cpm__Payment_Profile__c();
        recDon = new npe03__Recurring_Donation__c();
        gftAid = new gaid__Gift_Aid_Declaration__c();       
        displayValue = 'none';
        counter = '';
        accountName='';
        sortCode='';
        accountName='';  
        corsBkng = new Booking__c(); 
        
        
    }
    public void receiveInput(){
        System.debug('SelectedPreferences: '+SelectedPreferences);
        System.debug('Genders: '+Genders);
        system.debug(firstname + '   *$*#@**$*$ firstname  ' + lastname + ' lastname &$#*#*# email  ' + email + '   *$*$*$ phone ' + phone);
        System.debug('Twomems :'+twomems);
        System.debug('Salutation:'+salutation);
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
        //Date expDate = Date.valueOf(eDate);
       // if(contId == Null && contId == ''){
        if(isContactExisting == false && newCont == null){
            if(newCont == null )
            {
                newCont = new Contact();
                newCont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
                newCont.Prefered_First_Name__c = firstname;
                newCont.LastName = lastname;
                newCont.Email = email;
                newCont.Phone = phone;
                newCont.MailingPostalCode = postCode;
                newCont.Contact_Prefrence__c = ContactPreference;
                //if(eDate != null){
                    //expDate = Date.valueOf(eDate);
                    //newCont.Expected_Due_Date__c = expDate; 
                //}
                newCont.Branch__c = selectBranch; 
                newCont.Salutation = SelectedPreferences;
                newCont.Gender__c = Genders;
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
                    //snewCont.Expected_Due_Date__c = expDate;
                    snewCont.Gender__c = SGenders;
                    snewCont.Salutation = SSelectedPreferences;   
                    snewCont.Branch__c = selectBranch;
                    snewCont.MailingStreet = streetValue+''+streetValue2+''+streetValue2;
                    snewCont.MailingState = stateValue;
                    snewCont.MailingCity = cityValue;
                    Database.insert(snewCont, false);
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint','Parent, Companion');
                }
                else 
                {
                    System.debug('twomems '+twomems);
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('Individual','Parent');
                    System.debug('membershipTypeMap '+membershipTypeMap);
                }
            }
        }
            
        //}
        // Yet to define the custom metadata, once done the logic can be updated and modified accordingly, hence commenting
        
        else if(contId != null)
        {
            //accntContRel =[SELECT Id,Roles FROM AccountContactRelation where contact.id=:contId limit 1];
            isVolunteer = ContactUtilities.isVolunteerExisting(contId);
            isPractitioner = MembershipUtilties.isPractitioner(firstname, lastname, email);
            //isPractitioner = false;
            //if(accntContRel.id != null || isPractitioner == true){
            if(isVolunteer == true || isPractitioner == true){
                //if(isPractitioner == true){ //accntContRel.Roles == 'Volunteer' || 
                if(twomems == 'true')
                {   
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint','Volunteer/Practitioner');            
                }
                else 
                {
                    System.debug('twomems '+twomems);
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('Individual','Volunteer/Practitioner');
                    System.debug('membershipTypeMap '+membershipTypeMap);
                }
                  
                
            }
         
            else{
                if(twomems == 'true')
                {   
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint','Parent, Companion');            
                }
                else 
                {
                    System.debug('twomems '+twomems);
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('Individual','Parent');
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
                snewCont.MailingStreet = streetValue+''+streetValue2+''+streetValue2;
                snewCont.MailingState = stateValue;
                snewCont.MailingCity = cityValue;
                Database.insert(snewCont, false);
                //membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint','Parent, Companion');
                
            }
            if(isVolunteer == true || isPractitioner == true){
                    //if(isPractitioner == true){ //accntContRel.Roles == 'Volunteer' || 
                if(twomems == 'true')
                {   
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint','Volunteer/Practitioner');            
                }
                else 
                {
                    System.debug('twomems '+twomems);
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('Individual','Volunteer/Practitioner');
                    System.debug('membershipTypeMap '+membershipTypeMap);
                }
                
                
            }
            
            else{
                if(twomems == 'true')
                {   
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('joint','Parent, Companion');            
                }
                else 
                {
                    System.debug('twomems '+twomems);
                    membershipTypeMap = MembershipUtilties.getMembershipTypeMap('Individual','Parent');
                    System.debug('membershipTypeMap '+membershipTypeMap);
                }
            }

        }        
    }
    public PageReference ContactInfo()
    {
        feeAmount = Apexpages.currentPage().getParameters().get('seltdName');
        PageReference redirecContUrl;
        system.debug('*$*$*$  feeAmount   ' + feeAmount);
        membershipInfo = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c, Payment_Processor__c FROM  Membership_Type__mdt where Id =:feeAmount];
        System.debug('Membership##### '+membershipInfo);
        if(membershipInfo != null)
        {
            if(membershipInfo.Payment_Method__c == 'Credit/Debit Card')
            {
                redirecContUrl = PaymentHubCallout();
            }
        }  
        return redirecContUrl;
    }
  
    public void nctBranchs(){
        
        String emails = Apexpages.currentPage().getParameters().get('emailsVal');
        if(contId == null){
            isContactExisting = ContactUtilities.isContactExisting(emails);
            System.debug('isContactExisting: '+isContactExisting);
        }
        
        String units = 'mi';
        postCode = Apexpages.currentPage().getParameters().get('postVal');
        System.debug('postCode: '+postCode);
        branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        branchs =[SELECT Name, Id, RecordTypeId FROM Account where RecordTypeId =:branchRecordTypeId order by Name ASC];
        latlonPostcode =[SELECT Id, BillingPostalCode, BillingLatitude, BillingLongitude FROM Account where BillingPostalCode = :postCode and BillingLatitude != null and BillingLongitude != null limit 1];
        if(latlonPostcode.size()>0){
            Decimal lattitude = latlonPostcode[0].BillingLatitude;
            Decimal longitude = latlonPostcode[0].BillingLongitude; 
 
            //nearestBranchs =[SELECT Id,Name FROM Account where DISTANCE(BillingAddress, GEOLOCATION(lattitude ,longitude), mi) < 30];
            
            String queryString = 'SELECT Id, Name '+
                'FROM Account where (DISTANCE(BillingAddress ,GEOLOCATION('+lattitude+','+longitude+'), \'mi\')< 30) and BillingPostalCode=:postCode order by Name limit 10';
              
            System.Debug('>>>> the value of queryString is ' + queryString);
            try{
                nearestBranchs = database.query(queryString);
            }
            catch(exception e){
                System.debug('Error: 153 : '+e);
            }  
        }
        
    }
    public void PaymentSave()
    {
        system.debug(firstname + '   *$*#@**$*$ firstname  ' + lastname + ' lastname &$#*#*# email  ' + email + '   *$*$*$ phone ' + phone);
        //system.debug(accountNumber + '   *$*#@**$*$ accountName  ' + accountName + '  &$#*#*#  ' + sortCode + '   *$*$*$ newCont ' + newCont.Id);
             
        if(newCont != null)//&& pymtPrfl == null && recDon == null
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
                gftAid.Method__c = 'Online';
                gftAid.gaid__Type__c = membershipInfo.GiftAid_Type__c;
                //gftAid.gaid__Acquisition_Method__c = membershipInfo.GiftAid_Acquisition_Method__c;
                gftAid.gaid__Acquisition_Method__c = acquistion;
                gftAid.gaid__Start_Date__c = system.today();
                gftAid.gaid__Date_Made__c = system.today();
                gftAid.gaid__Active__c = true;
                insert gftAid;            
            } 
            recDon.Name = membershipInfo.Contact_Type__c + ' ' + membershipInfo.Membership__c;
            recDon.npe03__Amount__c = membershipInfo.Installment_Amount__c;
            recDon.npe03__Contact__c = newCont.Id;
            recDon.npe03__Installments__c = membershipInfo.No_of_Installments__c;
            recDon.First_Contact__c = newCont.Id;
            recDon.npe03__Schedule_Type__c = membershipInfo.Schedule_Type__c;
            recDon.npe03__Installments__c = membershipInfo.No_of_Installments__c;
            recDon.npe03__Installment_Period__c = membershipInfo.Installment_Period__c;
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
        list<npe03__Recurring_Donation__c> reccDonList = new list<npe03__Recurring_Donation__c>();
        if(Apexpages.currentPage().getParameters().get('contId') != null && Apexpages.currentPage().getParameters().get('contId') !='')
        {
            system.debug('Apexpages.currentPage().getParameters().get(contId) ---   ' + Apexpages.currentPage().getParameters().get('contId'));
            reccDonList = [select Id, Membership_Number__c,npe03__Contact__c,npsp4hub__Payment_Method__c,
                       npe03__Amount__c,npe03__Installment_Period__c,Membership_type__c, npe03__Contact__r.Prefered_First_Name__c,
                       npe03__Contact__r.LastName,npe03__Contact__r.Email,npe03__Installment_Amount__c,npe03__Contact__r.Phone,
                       npe03__Date_Established__c,npe03__Contact__r.AccountId from npe03__Recurring_Donation__c where npe03__Contact__c =: Apexpages.currentPage().getParameters().get('contId') limit 1];   
            if(reccDonList != null && !reccDonList.isEmpty())
            {
                membershipNumber = reccDonList[0].Membership_Number__c;
                reccDonList[0].Membership_Status__c = 'Confirmed';
                upsert reccDonList;
                system.debug('membershipNumber  ' + membershipNumber);
            }
            else if(reccDonList == null || reccDonList.isEmpty())
            {
                recDon.Name = 'Credit/Debit Card Membership';
                recDon.npe03__Amount__c = 60;
                recDon.npe03__Contact__c = Apexpages.currentPage().getParameters().get('contId');
                recDon.CARE_Payment_Frequency__c = 'One Time';
                recDon.First_Contact__c = Apexpages.currentPage().getParameters().get('contId');
                recDon.npe03__Installment_Period__c = 'Yearly';
                recDon.npsp4hub__Payment_Method__c = 'Credit/Debit Card';
                //recDon.npsp4hub__Payment_Processor__c = 'PaymentHub-BACS';
                //recDon.npsp4hub__Target__c = 'BACS Standard 18';
                recDon.Membership_Status__c = 'Confirmed';
                //recDon.npsp4hub__Payment_Profile__c = pymtPrfl.Id;
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
        //if(contId == null)
        //{
        list<User> UserList = [select Id, Name from User where user.ContactId =: reccDonList[0].npe03__Contact__c and Username =:reccDonList[0].npe03__Contact__r.Email];
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
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Community User creadentials Exists in the System with this Username: '+reccDonList[0].npe03__Contact__r.Email));
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Community User creadentials Exists in the System with this Username: '+reccDonList[0].npe03__Contact__r.Email));
            System.debug('User Exists: '+UserList);
        }
            
        //}        
    }
    public PageReference PaymentHubCallout()
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
        
        tokenRequest.setEndpoint(System.Label.ENDPOINTOAUTH+'client_id='+System.Label.CLIENTID+'&client_secret='+System.Label.CLIENT_SECRET+'&grant_type=password&username='+System.Label.ENDPOINT_USERNAME+'&password='+System.Label.ENDPOINT_PASSWORD);
        
        //tokenRequest.setEndpoint('https://test.salesforce.com/services/oauth2/token?client_id=3MVG95AcBeaB55lVpFY_Rw8rGI.KUCG9dcqi1zRxbXuXhdoYYpgHOQUg01kQrJyfp_yYqnT6F.aEXC1U7n06J&client_secret=5804933462634405366&grant_type=password&username=payment.api@nct.org.uk.preuat&password=payment123rl3GtuRGUj15A1W6ysGuUAT3N');
  
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
        
        paymentHubRequest.setEndpoint(System.Label.SF_INSTANCE+'/services/apexrest/cpm/v1.0/Payment'); 
        //paymentHubRequest.setEndpoint('https://cs102.salesforce.com/services/apexrest/cpm/v1.0/Payment');        
        paymentHubRequest.setHeader('Authorization','Bearer '+accessTokenVo.access_token);  
        //paymentHubRequest.setHeader('Authorization','Bearer '+ UserInfo.getSessionID()); 
        paymentHubRequest.setHeader('Content-Type','application/json; charset=UTF-8');
        paymentHubRequest.setHeader('Accept','application/json');
        
        paymentHubRequest.setHeader('api-token',System.Label.API_TOKEN);
        //paymentHubRequest.setHeader('api-token','IPy3Yvtin0aa2GPIke79Ewp24a0YSt6Daj5HJ9v9IGq2VTDYTWWkSx5jE2Pg54u02j0uHQZ3BwHfxFh8nKfXK4fiqZSQbZuXFQtQfAE926aFrwwVoOxPOJ6MiWSFpMc8b0UrOcbUD9pdcW7x8xNu3CtI5JfukTrRZqNByghsdTnWKLb79XrKpttmtHepMmVPv3QyPZYq');
        paymentHubRequest.setBody(JSON.serialize(paymentReq));
        paymentHubRequest.setMethod('POST'); 
        paymentHubRequest.setTimeout(120000);    
        paymentHubResponse = paymentHubHttp.send(paymentHubRequest);
        System.debug('*$*$*$*$*  RESPONSE =   ' + paymentHubResponse.getBody());
        responseContent = paymentHubResponse.getBody();
        system.debug('*$*$*$* responseContent ===   ' + responseContent);
        redirectURL = responseContent.subString(responseContent.IndexOf('PaymentHub')+28, responseContent.lastIndexOf('PaymentMethod')-3);
        system.debug('*$*$*$** redirectURL =   ' + redirectURL);
        //PageReference pageRefCrdDbt = new PageReference('https://ournct--preuat--c.cs102.visual.force.com/apex/phstr__stripecheckout?failureRedirectURL=https%253A%252F%252Fwww.example.com%252Ferror&id=a2b1j00000002s1AAA&successRedirectURL=https%253A%252F%252Fwww.example.com%252Fsuccess');
        redirectURL += '&nooverride=1';
        //PageReference pageRefCrdDbt = new PageReference('https://preuat-mynct.cs102.force.com/apex/phstr__stripecheckout?failureRedirectURL=https%3A%2F%2Fournct--preuat--c.cs102.visual.force.com%2Fapex%2FnctPaymentHubErrorMsgPage&id=a2b1j000000031FAAQ&successRedirectURL=https%3A%2F%2Fournct--preuat--c.cs102.visual.force.com%2Fapex%2FnctPaymentHubSuccessMsgPage');
        PageReference pageRefCrdDbt = new PageReference(redirectURL);
        pageRefCrdDbt.setRedirect(true);
        system.debug('  *$*$*$** pageRefCrdDbt =   ' + pageRefCrdDbt);
        return pageRefCrdDbt;
    }    
}