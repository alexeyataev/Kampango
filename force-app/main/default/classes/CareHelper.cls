public with sharing class CareHelper {
    private static final String BASE_URL = Care_Settings__c.getOrgDefaults().Base_Url__c;
    private static final String HTTP_STATUS_OK = 'OK';
    private final static Integer ERROR_LOG_SIZE = 30000;
    public static final String SUCCESS_STATUS = 'Success';
    public static final String FAILURE_STATUS = 'Failure';
    public static Integer timeoutLimit = 120000;
    public static AddContactResult sendContact(Contact cont) {
        String requestBody = CareRequestBodyUtil.createSendContactBody(cont);
        HttpResponse res = sendHttpRequest('SFAddUpdateContactWS.pl', requestBody);
        AddContactResult addContactResult = new AddContactResult();
        if(res.getStatus() == HTTP_STATUS_OK) {
            ContactObject contactObject = (ContactObject)JSON.deserialize(res.getBody(), ContactObject.class);
            if(contactObject.error != null) {
                String errorLog = createErrorLog(BASE_URL + 'SFAddUpdateContactWS.pl', requestBody, contactObject.error[0].errorMessage);
                addContactResult.error = addErrorLog(errorLog, cont.Care_Error_Log__c);
            }
            addContactResult.nctNumber = contactObject.contact != null ? contactObject.contact.contactNumber : null;
        } else {
            String errorLog = createErrorLog(BASE_URL + 'SFAddUpdateContactWS.pl', requestBody, res.getBody());
            addContactResult.error = addErrorLog(errorLog, cont.Care_Error_Log__c);
        }
        return addContactResult;
    }
    public static AddBankDetailsResult sendBankDetails(cpm__Installment__c installment, Contact cont) {
        String requestBody = CareRequestBodyUtil.createSendBankDetailsBody(installment, cont);
        HttpResponse res = sendHttpRequest('SFAddBankDetailsWS.pl', requestBody);
        AddBankDetailsResult addBankDetailsResult = new AddBankDetailsResult();
        if(res.getStatus() == HTTP_STATUS_OK) {
            ContactBankAccountObject contactBankAccountObject = (ContactBankAccountObject)JSON.deserialize(res.getBody(), ContactBankAccountObject.class);
            if(contactBankAccountObject.error != null) {
                String errorLog = createErrorLog(BASE_URL + 'SFAddBankDetailsWS.pl', requestBody, contactBankAccountObject.error[0].errorMessage);
                addBankDetailsResult.error = addErrorLog(errorLog, installment.Care_Error_Log__c);
            }
            addBankDetailsResult.bankDetailsNumber = contactBankAccountObject.contactBankAccount != null ? contactBankAccountObject.contactBankAccount.bankDetailNumber : null;
        } else {
            String errorLog = createErrorLog(BASE_URL + 'SFAddBankDetailsWS.pl', requestBody, res.getBody());
            addBankDetailsResult.error = addErrorLog(errorLog, installment.Care_Error_Log__c);
        }
        return addBankDetailsResult;
    }
    public static MembershipObject addMembership(cpm__Installment__c installment) {
        String requestBody = CareRequestBodyUtil.createAddMembershipBody(installment);
        HttpResponse res = sendHttpRequest('SFAddMembershipWS.pl', requestBody);
        MembershipObject membershipObject = new MembershipObject();
        if(res.getStatus() == HTTP_STATUS_OK) {
            membershipObject = (MembershipObject)JSON.deserialize(res.getBody(), MembershipObject.class);
            if(membershipObject.error != null) {
                String errorLog = createErrorLog(BASE_URL + 'SFAddMembershipWS.pl', requestBody, membershipObject.error[0].errorMessage);
                membershipObject.error[0].errorMessage = addErrorLog(errorLog, installment.Care_Error_Log__c);
            }
        } else {
            ErrorObject errorObject = new ErrorObject();
            String errorLog = createErrorLog(BASE_URL + 'SFAddMembershipWS.pl', requestBody, res.getBody());
            errorObject.errorMessage = addErrorLog(errorLog, installment.Care_Error_Log__c);
            membershipObject.error = new List<ErrorObject> {errorObject};
        }
        return membershipObject;
    }

    public static MarketingPreferencesObject sendMarketingPreferences(Contact cont, String standardDocumentNumber, Boolean marketingPreferenceGranted) {
        String requestBody = CareRequestBodyUtil.createMarketingPreferencesBody(cont.NCT_Number__c, standardDocumentNumber, marketingPreferenceGranted);
        HttpResponse res = sendHttpRequest('SFAddDocumentFileWS.pl', requestBody);
        MarketingPreferencesObject marketingPreferencesObject = new MarketingPreferencesObject();
        if(res.getStatus() == HTTP_STATUS_OK) {
            marketingPreferencesObject = (MarketingPreferencesObject)JSON.deserialize(res.getBody(), MarketingPreferencesObject.class);
            if(marketingPreferencesObject.error != null) {
                String errorLog = createErrorLog(BASE_URL + 'SFAddDocumentFileWS.pl', requestBody, marketingPreferencesObject.error[0].errorMessage);
                marketingPreferencesObject.error[0].errorMessage = errorLog;
            }
        } else {
            ErrorObject errorObject = new ErrorObject();
            errorObject.errorMessage = createErrorLog(BASE_URL + 'SFAddDocumentFileWS.pl', requestBody, res.getBody());
            marketingPreferencesObject.error = new List<ErrorObject> {errorObject};
        }
        return marketingPreferencesObject;
    }

    private static String createErrorLog(String requestUrl, String requestBody, String errorMessage) {
        String textToAdd = 'Time: ' + Datetime.now() + '\r\nURL: ' + requestUrl + '\r\nBody:\r\n' + requestBody + '\r\nResponse:\r\n' + errorMessage;
        return textToAdd;
    }

    public static String addErrorLog(String textToAdd, String oldLogText) {
        String newLogText = oldLogText == null ? textToAdd : textToAdd + '\r\n\r\n' + oldLogText;
        if(newLogText.length() > ERROR_LOG_SIZE) {
            newLogText = newLogText.substring(0, ERROR_LOG_SIZE);
        }
        return newLogText;
    }

    private static HttpResponse sendHttpRequest(String methodName, String body) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(timeoutLimit);
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

    public class MarketingPreferencesObject extends BaseResponse {
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