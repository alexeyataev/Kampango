public class CareHelper {
    public static final String authKey = 'p1Fm0Y48P4iCehUKyzbsxY9-i78gdx7rG2Iu';
    public static final String sfEnvironmentName = 'SalesforceSBASandbox';
    public static final String source = 'SALESFORCE';
    private static final String branchNumber = '240';
    private static final String userLogname = 'xNCT_ORG_UK';
    public static List<Contact> updateContactList = new List<Contact>();
    public static String sendContact(Contact cont) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint('https://careforce.nct.org.uk:1443/AuthParentForceTest/SFAddUpdateContactWS.pl');
        req.setMethod('GET');
        req.setBody('Source=' + BaseCareApiCall.source
            //+ '&Branch=' + branchNumber
            + '&Surname=' + cont.LastName
            + '&FirstName=' + cont.FirstName
            + (cont.NCT_Number__c != null ? '&ContactNumber=' + cont.NCT_Number__c : '')
            + (cont.Gender__c != null ? '&Gender=' + cont.Gender__c : '')
            + (cont.MailingPostalCode != null ? '&Postcode=' + cont.MailingPostalCode : '')
            + (cont.Email != null ? '&Email=' + cont.Email : '')
            + '&Address=' + cont.MailingStreet
            + '&Town=' + cont.MailingCity
            + '&Country=' + cont.MailingCountry
            + '&UserLogname=' + userLogname
            + '&AuthKey=' + authKey 
            + '&pagename=' + sfEnvironmentName
        );
        system.debug('###sendContact ' + req.getBody());
        res = http.send(req);
        System.debug(res.getBody());
        String contNumber = '';
        if(!res.getBody().contains('"Error"')) {
            ContactOjbect contactObject = (ContactOjbect)JSON.deserialize(res.getBody(), ContactOjbect.class);
            contNumber = contactObject.Contact.ContactNumber;
            system.debug(contactObject);
            if(cont.NCT_Number__c == null) {
                cont.NCT_Number__c = contNumber;
                //update cont;
                updateContactList.add(cont);
            }
        }
        return contNumber;
    }
    public static String sendBankDetails(Contact cont) {
        String sortCode = '200000'; //Do we need a custom field to keep it in SF? How to populate it?
        String accNumber = '55779911'; //Do we need a custom field to keep it in SF? How to populate it?
        String accName = 'LemonBank'; //Do we need a custom field to keep it in SF? How to populate it?
        // I think the bank details will be stored in StepOrange objects but I will try and confirm this later - Steve
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        HttpResponse res = new HttpResponse();
        Http http = new Http();
    
        req.setEndpoint('https://careforce.nct.org.uk:1443/AuthParentForceTest/SFAddBankDetailsWS.pl');
        req.setMethod('GET');
        req.setBody('contactKey=' + cont.NCT_Number__c
            + '&authKey=' + authKey
            + '&pageName=' + sfEnvironmentName
            + '&userLogname=' + userLogname
            + '&source=' + source
            + '&sortCode=' + sortCode
            + '&acctNumber=' + accNumber
            + '&acctName=' + accName
        );
        system.debug('###sendBankDetails ' + req.getBody());
        res = http.send(req);
        System.debug(res.getBody());
        ContactBankAccountObject contactBankAccountObject = (ContactBankAccountObject)JSON.deserialize(res.getBody(), ContactBankAccountObject.class);
        return contactBankAccountObject.ContactBankAccount.BankDetailNumber;  
    }
    public static String addMembership(String paymentMethod, String bankDetailNumber, String claimDay, 
        String contactKey1, String contactKey2, String mType, String amount, String txCode) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        HttpResponse res = new HttpResponse();
        Http http = new Http();
    
        req.setEndpoint('https://careforce.nct.org.uk:1443/AuthParentForceTest/SFAddMembershipWS.pl');
        req.setMethod('GET');
        req.setBody('authKey=' + authKey
            + '&paymentMethod=' + paymentMethod
            + (bankDetailNumber != null ? '&bankDetailNumber=' + bankDetailNumber : '')
            + (claimDay != null ? '&claimDay=' + claimDay : '')
            + '&ga_decl_1=Y'
            + '&ga_decl_2=Y'
            + '&contactKey1=' + contactKey1
            + '&contactKey2=' + contactKey2
            + '&mType=' + mType
            + '&amount=' + amount
            + '&source=' + source
            + '&txCode=' + txCode
            + '&userLogname=' + userLogname
            + '&pageName=' + sfEnvironmentName
        );
        system.debug('###addMembership ' + req.getBody());
        res = http.send(req);
        System.debug(res.getBody()); 
        return res.getBody();
    }
    public static void updateContacts() {
        update updateContactList;
    }
    private class ContactOjbect {
        private ContactDetails Contact {get;set;}
    }
    private class ContactDetails {
        private String ContactKey {get;set;}
        private String ContactNumber {get;set;}
    }
    private class ContactBankAccountObject {
        private ContactBankAccountDetails ContactBankAccount {get;set;}
    }
    private class ContactBankAccountDetails {
        private String ContactKey {get;set;}
        private String BankDetailNumber {get;set;}
        private String Information {get;set;}
    }
}