public with sharing class CareHelper {
    private static final String BASE_URL = Care_Settings__c.getOrgDefaults().Base_Url__c;
    public static AddContactResult sendContact(Contact cont) {
        HttpResponse res = sendHttpRequest('SFAddUpdateContactWS.pl', CareRequestBodyUtil.createSendContactBody(cont));
        ContactObject contactObject = (ContactObject)JSON.deserialize(res.getBody(), ContactObject.class);
        AddContactResult addContactResult = new AddContactResult();
        addContactResult.error = contactObject.error != null ? contactObject.error[0].errorMessage : null;
        addContactResult.nctNumber = contactObject.contact != null ? contactObject.contact.contactNumber : null;
        return addContactResult;
    }
    public static AddBankDetailsResult sendBankDetails(cpm__Installment__c installment, Contact cont) {
        HttpResponse res = sendHttpRequest('SFAddBankDetailsWS.pl', CareRequestBodyUtil.createSendBankDetailsBody(installment, cont));
        ContactBankAccountObject contactBankAccountObject = (ContactBankAccountObject)JSON.deserialize(res.getBody(), ContactBankAccountObject.class);
        AddBankDetailsResult addBankDetailsResult = new AddBankDetailsResult();
        addBankDetailsResult.error = contactBankAccountObject.error != null ? contactBankAccountObject.error[0].errorMessage : null;
        addBankDetailsResult.bankDetailsNumber = contactBankAccountObject.contactBankAccount != null ? contactBankAccountObject.contactBankAccount.bankDetailNumber : null;
        return addBankDetailsResult;
    }
    public static MembershipObject addMembership(cpm__Installment__c installment) {
        HttpResponse res = sendHttpRequest('SFAddMembershipWS.pl', CareRequestBodyUtil.createAddMembershipBody(installment));
        MembershipObject membershipObject = (MembershipObject)JSON.deserialize(res.getBody(), MembershipObject.class);
        return membershipObject;
    }

    @future(callout=true)
    public static void sendMarketingPreferences(String nctNumber, String standardDocumentNumber) {
        HttpResponse res = sendHttpRequest('SFAddDocumentFileWS.pl', CareRequestBodyUtil.createMarketingPreferencesBody(nctNumber, standardDocumentNumber));
        MarketingPreferencesObject marketingPreferencesObject = (MarketingPreferencesObject)JSON.deserialize(res.getBody(), MarketingPreferencesObject.class);
    }

    private static HttpResponse sendHttpRequest(String methodName, String body) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(BASE_URL + methodName);
        req.setMethod('POST');
        req.setBody(body);
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res;
    }

    public abstract class BaseResponse {
        public List<ErrorObject> error {get;set;}
    }

    public class ErrorObject {
        public String errorMessage {get;set;}
        public String errorNumber {get;set;}
    }

    public class MembershipObject extends BaseResponse {
        @testVisible private String status {get;set;}
    }

    @testVisible private class ContactObject extends BaseResponse {
        @testVisible private ContactDetails contact {get;set;}
    }

    @testVisible private class ContactDetails {
        @testVisible private String contactNumber {get;set;}
    }
    
    @testVisible private class ContactBankAccountObject extends BaseResponse {
        @testVisible private ContactBankAccountDetails contactBankAccount {get;set;}
    }

    @testVisible private class MarketingPreferencesObject extends BaseResponse {
        @testVisible private MarketingPreferencesDetails document {get;set;}
    }

    @testVisible private class MarketingPreferencesDetails {
        @testVisible private String standardDocument {get;set;}
        @testVisible private String documentNumber {get;set;}
        @testVisible private String docType {get;set;}
    }

    @testVisible private class ContactBankAccountDetails {
        @testVisible private String contactNumber {get;set;}
        @testVisible private String bankDetailNumber {get;set;}
        @testVisible private String information {get;set;}
    }
}