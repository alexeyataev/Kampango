public with sharing class CareHelper {
    public static String sendContact(Contact cont) {
        HttpRequest req = creteHttpRequest('SFAddUpdateContactWS.pl', CareRequestBodyUtil.createSendContactBody(cont));
        Http http = new Http();
        HttpResponse res = http.send(req);
        CareRequestBodyUtil.ContactOjbect contactObject = (CareRequestBodyUtil.ContactOjbect)JSON.deserialize(res.getBody(), CareRequestBodyUtil.ContactOjbect.class);
        String contNumber;
        if(contactObject.error == null) {
            contNumber = contactObject.Contact.ContactNumber;
        }
        return contNumber;
    }
    public static String sendBankDetails(cpm__Payment_Profile__c paymentProfile, Contact cont) {
        HttpRequest req = creteHttpRequest('SFAddBankDetailsWS.pl', CareRequestBodyUtil.createSendBankDetailsBody(paymentProfile, cont));
        Http http = new Http();
        HttpResponse res = http.send(req);
        CareRequestBodyUtil.ContactBankAccountObject contactBankAccountObject = (CareRequestBodyUtil.ContactBankAccountObject)JSON.deserialize(res.getBody(), CareRequestBodyUtil.ContactBankAccountObject.class);
        String bankDetailNumber;
        if(contactBankAccountObject.error == null) {
            bankDetailNumber = contactBankAccountObject.ContactBankAccount.BankDetailNumber;
        }
        return bankDetailNumber;
    }
    public static CareRequestBodyUtil.MembershipOjbect addMembership(cpm__Installment__c installment) {
        HttpRequest req = creteHttpRequest('SFAddMembershipWS.pl', CareRequestBodyUtil.createAddMembershipBody(installment));
        Http http = new Http();
        HttpResponse res = http.send(req);
        CareRequestBodyUtil.MembershipOjbect membershipObject = (CareRequestBodyUtil.MembershipOjbect)JSON.deserialize(res.getBody(), CareRequestBodyUtil.MembershipOjbect.class);
        return membershipObject;
    }
    private static HttpRequest creteHttpRequest(String methodName, String body) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(CareRequestBodyUtil.URL + methodName);
        req.setMethod('POST');
        req.setBody(body);
        return req;
    }
}