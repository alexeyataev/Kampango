public with sharing class NctPaymentHubPageController
{
    public Contact newCont {get;set;}
    public cpm__Payment_Profile__c pymtPrfl {get;set;}
    public npe03__Recurring_Donation__c recDon {get;set;}
    public gaid__Gift_Aid_Declaration__c gftAid {get;set;}
    public Booking__c corsBkng {get;set;}
    public string memberType {get;set;}
   
    public boolean pymSelSec  {get;set;}
    public boolean contInfoSec  {get;set;}
    public boolean pymtInfoSec  {get;set;}
    public boolean confmInfoSec {get;set;}
    public boolean thankYouSec {get;set;}
    public boolean feeFieldVisibility {get;set;}
    public string feeAmount {get;set;}
    public string membershipNumber {get;set;}
    public string courseBookingNo {get;set;}
    public string redirectURL {get;set;} 
    public Id courseId {get;set;}
    public Course__c cors;
    // added by MembershipFormController
    public String addressline1 {get; set;}
    public String textAddress2 {get; set;}
    public String textAddress3 {get; set;}
    public String textTown {get; set;} 
    public String county {get; set;} 
  
   public String postalCode {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}

    public NctPaymentHubPageController()
    {
        courseId = ApexPages.currentPage().getParameters().get('id');
        User u = new User();
         u.PostalCode = postalCode;
    
        newCont = new Contact();
        pymtPrfl = new cpm__Payment_Profile__c();
        recDon = new npe03__Recurring_Donation__c();
        gftAid = new gaid__Gift_Aid_Declaration__c();
        corsBkng = new Booking__c();
       
        contInfoSec = true;
        feeFieldVisibility = false;
        pymSelSec = false;
        pymtInfoSec = false;
        confmInfoSec = false;
        thankYouSec = false;
        if(courseId != null)
        {
            feeFieldVisibility = true;
            cors = [select Id, Fee__c from Course__c where Id=:courseId];
            if(cors != null)
            {
                feeAmount = '£'+string.valueOf(cors.Fee__c);
            }
        }
    }
    
    public PageReference contactSave()
    {
        PageReference redirecContUrl;
       
            newCont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
           
            contInfoSec = false;
            pymSelSec = true;
            redirecContUrl = null;
             
        return redirecContUrl;
    }
    public PageReference paymentSel()
    {        
        PageReference redirectUrl;
        contInfoSec = false;
        pymSelSec = false;
        if(memberType.contains('Direct Debit'))
        {
            pymtInfoSec = true;
            insert newCont;
            if(courseId != null)
            {                            
                corsBkng.First_Contact__c = newCont.Id;
                corsBkng.Status__c = 'Installment';
                corsBkng.Course__c = courseId;
                corsBkng.Payment_Date__c = system.today();
                corsBkng.Payment_Method__c = memberType;
                corsBkng.Cost__c = cors.Fee__c;
                corsBkng.Due_Date__c = system.today()-1;
                insert corsBkng;
            }            
            redirectUrl = null;
        }
        else if(memberType.contains('Credit/Debit Card'))
        {
            system.debug('*$*$**$* memberType  ' + memberType);
            redirectUrl = paymentHubCallout(); 
            if(courseId != null)
            {  
                newCont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
                insert newCont;
                corsBkng.First_Contact__c = newCont.Id;
                corsBkng.Status__c = 'Paid';
                corsBkng.Course__c = courseId;
                corsBkng.Payment_Date__c = system.today();
                corsBkng.Payment_Method__c = 'Credit/Debit Card(£57)';
                corsBkng.Cost__c = cors.Fee__c;
                corsBkng.Due_Date__c = system.today()-1;
                insert corsBkng;
            }
        }
        return redirectUrl;
    }
    public void paymentSave()
    {
        feeAmount = memberType.substringBetween('(', ')');
        pymtPrfl.RecordTypeId = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();
        pymtPrfl.cpm__Contact__c = newCont.Id;
        insert pymtPrfl;
        
        gftAid.gaid__Contact__c= newCont.Id;
       
        gftAid.Method__c = 'Online';
        gftAid.gaid__Type__c = 'Single';
        gftAid.Declaration_Number__c = 56443323;
        gftAid.gaid__Active__c = true;
        insert gftAid;
        
        recDon.Name = memberType;
        recDon.npe03__Amount__c = 60;
        recDon.npe03__Contact__c = newCont.Id;
        recDon.CARE_Payment_Frequency__c = 'Monthly';
        recDon.Direct_Debit_Key__c = 432321323;
        recDon.First_Contact_Key__c = 12233342;
        recDon.Recurring_Donations_Key__c = 75664543;
        recDon.First_Contact__c = newCont.Id;
        recDon.npe03__Installment_Period__c = 'Monthly';
        recDon.npsp4hub__Payment_Method__c = 'Direct Debit';
        recDon.npsp4hub__Payment_Processor__c = 'PaymentHub-BACS';
        recDon.npsp4hub__Target__c = 'BACS Standard 18';
        recDon.npsp4hub__Payment_Profile__c = pymtPrfl.Id;
        Insert recDon;
        
        contInfoSec = false;
        pymSelSec = false;
        pymtInfoSec = false;
        confmInfoSec = true;
    }
    
    public void thankYouSec()
    {
        confmInfoSec = false;
        thankYouSec = true;
        system.debug('RECCURRING DONATION   ' + recDon.Id);
        if(recDon.Id != null)
        {
            
            npe03__Recurring_Donation__c reccDon = [select Id, Membership_Number__c from npe03__Recurring_Donation__c where Id =: recDon.Id];
            system.debug('RECCURRING DONATION record  ' + reccDon);
            if(reccDon != null)
            {
                membershipNumber = reccDon.Membership_Number__c;
                system.debug('membershipNumber  ' + membershipNumber);
            }
        }
        
        if(courseId != null && corsBkng != null)
        {
            Booking__c crsBkng = [select Id, Name from Booking__c where Id =: corsBkng.Id];
            if(crsBkng != null)
            {
                courseBookingNo = crsBkng.Name;
                system.debug('*$*$* courseBookingNo  ' + courseBookingNo);
            }
        }        
    }
    public PageReference paymentHubCallout()
    {
        if(memberType != '' && memberType != null)
        {
           feeAmount = memberType.substringBetween('(', ')'); 
        }
        
        string responseContent;
        
        HttpRequest tokenRequest = new HttpRequest();
        HttpResponse tokenResponse = new HttpResponse();
        Http tokenHttp = new Http();
        
        tokenRequest.setEndpoint('https://test.salesforce.com/services/oauth2/token?client_id=3MVG95AcBeaB55lVpFY_Rw8rGI.KUCG9dcqi1zRxbXuXhdoYYpgHOQUg01kQrJyfp_yYqnT6F.aEXC1U7n06J&client_secret=5804933462634405366&grant_type=password&username=payment.api@nct.org.uk.preuat&password=payment123rl3GtuRGUj15A1W6ysGuUAT3N');
  
        tokenRequest.setMethod('POST'); 
        tokenRequest.setTimeout(120000);    
        tokenResponse = tokenHttp.send(tokenRequest);

        AcessTokenResponseVo accessTokenVo = (AcessTokenResponseVo) JSON.deserialize(tokenResponse.getBody(),AcessTokenResponseVo.class);

        
        PaymentRequestVo paymentReq = new PaymentRequestVo();
        paymentReq.SuccessURL='https://preuat-mynct.cs102.force.com/nctPaymentHubSuccessMsgPage';
        paymentReq.FailureURL='https://preuat-mynct.cs102.force.com/nctPaymentHubErrorMsgPage';
        paymentReq.Origin='test';
 
        PaymentRequestVo.ContactVo cvo = new PaymentRequestVo.ContactVo();
        cvo.Email = newCont.Email;
        
        cvo.FirstName = newCont.Prefered_First_Name__c;
        cvo.LastName = newCont.LastName;
 
        PaymentRequestVo.PayerVo payerReq = new PaymentRequestVo.PayerVo();
        payerReq.AllowDeduplication=true;
        payerReq.contact = cvo;
        payerReq.ContactUpdate ='replace';
        paymentReq.Payer = payerReq;
 
        PaymentRequestVo.PaymentVo payment = new PaymentRequestVo.PaymentVo();
        system.debug('*$*$**$*$ feeAmount  ' + feeAmount);
        feeAmount = feeAmount.substring(feeAmount.lastIndexOf('£')+1, feeAmount.lastIndexOf('£')+2);        
        payment.Amount=decimal.valueOf(feeAmount);
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
        paymentHubRequest.setEndpoint('https://cs102.salesforce.com/services/apexrest/cpm/v1.0/Payment');        
        paymentHubRequest.setHeader('Authorization','Bearer '+accessTokenVo.access_token);  
        
        paymentHubRequest.setHeader('Content-Type','application/json; charset=UTF-8');
        paymentHubRequest.setHeader('Accept','application/json');
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
        //PageReference pageRefCrdDbt = new PageReference('https://ournct--preuat--c.cs102.visual.force.com/apex/phstr__stripecheckout?failureRedirectURL=https%253A%252F%252Fwww.example.com%252Ferror&id=a2b1j00000002s1AAA&successRedirectURL=https%253A%252F%252Fwww.example.com%252Fsuccess');
        redirectURL += '&nooverride=1';
        //PageReference pageRefCrdDbt = new PageReference('https://preuat-mynct.cs102.force.com/apex/phstr__stripecheckout?failureRedirectURL=https%3A%2F%2Fournct--preuat--c.cs102.visual.force.com%2Fapex%2FnctPaymentHubErrorMsgPage&id=a2b1j000000031FAAQ&successRedirectURL=https%3A%2F%2Fournct--preuat--c.cs102.visual.force.com%2Fapex%2FnctPaymentHubSuccessMsgPage');
        PageReference pageRefCrdDbt = new PageReference(redirectURL);
        pageRefCrdDbt.setRedirect(true);
        system.debug('  *$*$*$** pageRefCrdDbt =   ' + pageRefCrdDbt);
        return pageRefCrdDbt;
    }
/*test*/
}