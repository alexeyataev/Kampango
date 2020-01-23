public with sharing class CareHelper {
    public static AddContactResult sendContact(Contact cont) {
        HttpResponse res = sendHttpRequest('SFAddUpdateContactWS.pl', CareRequestBodyUtil.createSendContactBody(cont));
        CareRequestBodyUtil.ContactOjbect contactObject = (CareRequestBodyUtil.ContactOjbect)JSON.deserialize(res.getBody(), CareRequestBodyUtil.ContactOjbect.class);
        AddContactResult addContactResult = new AddContactResult();
        addContactResult.error = contactObject.error != null ? contactObject.error[0].errorMessage : null;
        addContactResult.nctNumber = contactObject.contact.contactNumber;
        return addContactResult;
    }
    public static AddBankDetailsResult sendBankDetails(cpm__Payment_Profile__c paymentProfile, Contact cont) {
        HttpResponse res = sendHttpRequest('SFAddBankDetailsWS.pl', CareRequestBodyUtil.createSendBankDetailsBody(paymentProfile, cont));
        CareRequestBodyUtil.ContactBankAccountObject contactBankAccountObject = (CareRequestBodyUtil.ContactBankAccountObject)JSON.deserialize(res.getBody(), CareRequestBodyUtil.ContactBankAccountObject.class);
        AddBankDetailsResult addBankDetailsResult = new AddBankDetailsResult();
        addBankDetailsResult.error = contactBankAccountObject.error != null ? contactBankAccountObject.error[0].errorMessage : null;
        addBankDetailsResult.bankDetailsNumber = contactBankAccountObject.contactBankAccount.bankDetailNumber;
        return addBankDetailsResult;
    }
    public static CareRequestBodyUtil.MembershipOjbect addMembership(cpm__Installment__c installment) {
        HttpResponse res = sendHttpRequest('SFAddMembershipWS.pl', CareRequestBodyUtil.createAddMembershipBody(installment));
        CareRequestBodyUtil.MembershipOjbect membershipObject = (CareRequestBodyUtil.MembershipOjbect)JSON.deserialize(res.getBody(), CareRequestBodyUtil.MembershipOjbect.class);
        return membershipObject;
    }
    private static HttpResponse sendHttpRequest(String methodName, String body) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(CareRequestBodyUtil.URL + methodName);
        req.setMethod('POST');
        req.setBody(body);
        Http http = new Http();system.debug(req);system.debug(body);
        HttpResponse res = http.send(req);system.debug(res.getBody());
        return res;
    }
}