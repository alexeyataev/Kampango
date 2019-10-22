@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class CareHelper {
    public static final String AUTH_KEY = Care_Settings__c.getOrgDefaults().Auth_Key__c;//'p1Fm0Y48P4iCehUKyzbsxY9-i78gdx7rG2Iu';
    public static final String SF_ENVIRONMENT_NAME = Care_Settings__c.getOrgDefaults().SF_Environment_Name__c;//'SalesforceSBASandbox';
    public static final String SOURCE = Care_Settings__c.getOrgDefaults().Source__c;//'SALESFORCE';
    private static final String BRANCH_NUMBER = Care_Settings__c.getOrgDefaults().Branch_Number__c;//'240';
    private static final String USER_LOG_NAME = Care_Settings__c.getOrgDefaults().User_Log_Name__c;//'xSalesforce';
    public static List<Contact> updateContactList = new List<Contact>();
    public static String sendContact(Contact cont) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint('https://careforce.nct.org.uk:1443/AuthParentForceTest/SFAddUpdateContactWS.pl');
        req.setMethod('POST');
        req.setBody('source=' + SOURCE
            + '&Branch=' + BRANCH_NUMBER
            + '&surname=' + cont.LastName
            + '&firstName=' + cont.FirstName
            + (cont.NCT_Number__c != null ? '&contactNumber=' + cont.NCT_Number__c : '')
            + (cont.Gender__c != null ? '&gender=' + cont.Gender__c : '')
            + (cont.Email != null ? '&email=' + cont.Email : '')
            + (cont.MailingPostalCode != null ? '&postcode=' + cont.MailingPostalCode : '')
            + '&address=' + cont.MailingStreet
            + '&town=' + cont.MailingCity
            + '&country=' + cont.MailingCountry
            + '&userLogname=' + BRANCH_NUMBER
            + '&authKey=' + AUTH_KEY 
            + '&pagename=' + SF_ENVIRONMENT_NAME
        );
        /*AddUpdateContactRequest addUpdateContactRequest = new AddUpdateContactRequest();
        addUpdateContactRequest.authKey = authKey;
        addUpdateContactRequest.pagename = sfEnvironmentName;
        addUpdateContactRequest.source = source;
        addUpdateContactRequest.branch = branchNumber;
        addUpdateContactRequest.userLogname = userLogname;
        addUpdateContactRequest.surname = cont.LastName;
        addUpdateContactRequest.firstName = cont.FirstName;
        addUpdateContactRequest.contactNumber = cont.NCT_Number__c;
        addUpdateContactRequest.gender = cont.Gender__c;
        addUpdateContactRequest.postcode = cont.MailingPostalCode;
        addUpdateContactRequest.email = cont.Email;
        addUpdateContactRequest.address = cont.MailingStreet;
        addUpdateContactRequest.town = cont.MailingCity;
        addUpdateContactRequest.country = cont.MailingCountry;
        req.setBody(JSON.serialize(addUpdateContactRequest, true));*/
        system.debug('###sendContact ' + req.getBody());
        res = http.send(req);
        System.debug(res.getBody());
        ContactOjbect contactObject = (ContactOjbect)JSON.deserialize(res.getBody(), ContactOjbect.class);
        String contNumber = contactObject.Contact.ContactNumber;
        if(cont.NCT_Number__c == null) {
            cont.NCT_Number__c = contNumber;
            updateContactList.add(cont);
        }
        return contNumber;
    }
    public static String sendBankDetails(cpm__Payment_Profile__c paymentProfile, Contact cont, String nctNumber) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint('https://careforce.nct.org.uk:1443/AuthParentForceTest/SFAddBankDetailsWS.pl');
        req.setMethod('GET');
        req.setBody('contactKey=' + (cont.NCT_Number__c != null ? cont.NCT_Number__c : nctNumber)
            + '&authKey=' + AUTH_KEY
            + '&pageName=' + SF_ENVIRONMENT_NAME
            + '&userLogname=' + BRANCH_NUMBER
            + '&source=' + SOURCE
            + '&sortCode=' + paymentProfile.paybacs__Sort_Code__c
            + '&acctNumber=' + paymentProfile.cpm__Bank_Account__c
            + '&acctName=' + paymentProfile.cpm__Holder_Name__c
        );
        system.debug('###sendBankDetails ' + req.getBody());
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        ContactBankAccountObject contactBankAccountObject = (ContactBankAccountObject)JSON.deserialize(res.getBody(), ContactBankAccountObject.class);
        return contactBankAccountObject.ContactBankAccount.BankDetailNumber;  
    }
    public static List<MembershipResultObject> addMembership(cpm__Installment__c installment) {
        //String paymentMethod, String bankDetailNumber, String claimDay, String contactKey1, String contactKey2, String mType, String amount, String txCode
        Map<String, String> paymentMethodMap = new Map<String, String> {
            'CreditCard' => 'CC',
            'Care Membership' => 'DDQ'
        };
        String paymentMethod = paymentMethodMap.get(installment.cpm__Payment_Method__c);
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        HttpResponse res = new HttpResponse();
        Http http = new Http();
    
        req.setEndpoint('https://careforce.nct.org.uk:1443/AuthParentForceTest/SFAddMembershipWS.pl');
        req.setMethod('GET');
        req.setBody('authKey=' + AUTH_KEY
            + (paymentMethod != null ? '&paymentMethod=' + paymentMethod : '')
            + (installment.Bank_Details_Number__c != null ? '&bankDetailNumber=' + installment.Bank_Details_Number__c : '')
            + '&claimDay=3'
            + '&ga_decl_1=' + installment.ga_decl_1__c
            + '&ga_decl_2=' + installment.ga_decl_2__c
            + '&contactKey1=' + installment.cpm__Contact__r.NCT_Number__c
            + (installment.Partner_Contact__r.NCT_Number__c != null ? '&contactKey2=' + installment.Partner_Contact__r.NCT_Number__c : '')
            + (installment.Membership_Type__c != null ? '&mType=' + installment.Membership_Type__c : '')
            + '&amount=' + String.valueOf(installment.cpm__Amount__c)
            + '&source=' + SOURCE
            + '&txCode=' + installment.Id
            + '&userLogname=' + BRANCH_NUMBER
            + '&pageName=' + SF_ENVIRONMENT_NAME
        );
        system.debug('###addMembership ' + req.getBody());
        res = http.send(req);
        System.debug(res.getBody());
        MembershipResultObject membershipResultObject = new MembershipResultObject();
        if(res.getBody().contains('"Error"')) {
            //return new List<String> {'error', 'Could not add membership'};
            membershipResultObject.messageType = 'error';
            membershipResultObject.messageText = 'Сould not add membership';
            return new List<MembershipResultObject> {membershipResultObject};
        }
        //return new List<String> {'membershipbody', res.getBody()};
        membershipResultObject.messageType = 'success';
        membershipResultObject.messageText = res.getBody();
        return new List<MembershipResultObject> {membershipResultObject};
    }
    public static void updateContacts() {
        update updateContactList;
    }
    /*private abstract class CareBaseRequest {
        private String authKey {get;set;}
        private String pagename {get;set;}
        private String source {get;set;}
        private String branch {get;set;}
        private String userLogname {get;set;}
    }
    private class AddUpdateContactRequest extends CareBaseRequest {
        private String surname {get;set;}
        private String firstName {get;set;}
        private String contactNumber {get;set;}
        private String gender {get;set;}
        private String postcode {get;set;}
        private String email {get;set;}
        private String address {get;set;}
        private String town {get;set;}
        private String country {get;set;}
    }*/
    private class ContactOjbect {
        private ContactDetails contact {get;set;}
    }
    private class ContactDetails {
        private String contactKey {get;set;}
        private String contactNumber {get;set;}
    }
    private class ContactBankAccountObject {
        private ContactBankAccountDetails contactBankAccount {get;set;}
    }
    private class ContactBankAccountDetails {
        private String contactNumber {get;set;}
        private String bankDetailNumber {get;set;}
        private String information {get;set;}
    }
}