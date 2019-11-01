public with sharing class CareHelper {
    public static final String AUTH_KEY = Care_Settings__c.getOrgDefaults().Auth_Key__c;//'p1Fm0Y48P4iCehUKyzbsxY9-i78gdx7rG2Iu';
    public static final String SF_ENVIRONMENT_NAME = Care_Settings__c.getOrgDefaults().SF_Environment_Name__c;//'SalesforceSBASandbox';
    public static final String SOURCE = Care_Settings__c.getOrgDefaults().Source__c;//'SALESFORCE';
    private static final String BRANCH_NUMBER = Care_Settings__c.getOrgDefaults().Branch_Number__c;//'240';
    private static final String USER_LOG_NAME = Care_Settings__c.getOrgDefaults().User_Log_Name__c;//'xSalesforce';
    private static final String CARE_SUCCESS_STATUS = 'Success';
    private static final String URL = 'https://careforce.nct.org.uk:1443/AuthParentForceTest/';
    public enum AddMembershipStatus {SUCCESS, ERROR}
    public static String sendContact(Contact cont) {
        HttpRequest req = creteHttpRequest('SFAddUpdateContactWS.pl', CareRequestBodyUtil.createSendContactBody(cont));
        Http http = new Http();
        system.debug('###sendContact req' + req.getBody());
        HttpResponse res = http.send(req);
        system.debug('###sendContact res' + res.getBody());
        CareRequestBodyUtil.ContactOjbect contactObject = (CareRequestBodyUtil.ContactOjbect)JSON.deserialize(res.getBody(), CareRequestBodyUtil.ContactOjbect.class);
        String contNumber;
        if(contactObject.error == null) {
            contNumber = contactObject.Contact.ContactNumber;
        }
        return contNumber;
    }
    public static String sendBankDetails(cpm__Payment_Profile__c paymentProfile, Contact cont, String nctNumber) {
        HttpRequest req = creteHttpRequest('SFAddBankDetailsWS.pl', CareRequestBodyUtil.createSendBankDetailsBody(paymentProfile, cont, nctNumber));
        Http http = new Http();
        system.debug('###sendBankDetails req ' + req.getBody());
        HttpResponse res = http.send(req);
        system.debug('###sendBankDetails res ' + res.getBody());
        CareRequestBodyUtil.ContactBankAccountObject contactBankAccountObject = (CareRequestBodyUtil.ContactBankAccountObject)JSON.deserialize(res.getBody(), CareRequestBodyUtil.ContactBankAccountObject.class);
        String bankDetailNumber;
        if(contactBankAccountObject.error == null) {
            bankDetailNumber = contactBankAccountObject.ContactBankAccount.BankDetailNumber;
        }
        return bankDetailNumber;
    }
    public static AddMembershipStatus addMembership(cpm__Installment__c installment) {
        HttpRequest req = creteHttpRequest('SFAddMembershipWS.pl', CareRequestBodyUtil.createAddMembershipBody(installment));
        Http http = new Http();
        system.debug('###addMembership req' + req.getBody());
        HttpResponse res = http.send(req);
        system.debug('###addMembership res' + res.getBody());
        CareRequestBodyUtil.MembershipOjbect careBaseResponse = (CareRequestBodyUtil.MembershipOjbect)JSON.deserialize(res.getBody(), CareRequestBodyUtil.MembershipOjbect.class);
        if(careBaseResponse.error == null && careBaseResponse.status == CARE_SUCCESS_STATUS) {
            return AddMembershipStatus.SUCCESS;
        }
        return AddMembershipStatus.ERROR;
    }
    private static HttpRequest creteHttpRequest(String methodName, String body) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(URL + methodName);
        req.setMethod('POST');
        req.setBody(body);
        return req;
    }
}