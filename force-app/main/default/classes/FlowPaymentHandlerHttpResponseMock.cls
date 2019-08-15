@isTest
public class FlowPaymentHandlerHttpResponseMock implements HttpCalloutMock {
    private String responseBody;
    private String responseContact;
    private String responseBank;
    private String responseMembership;
    public FlowPaymentHandlerHttpResponseMock(String responseBody, String responseContact, String responseBank, String responseMembership) {
        this.responseBody = responseBody;
        this.responseContact = responseContact;
        this.responseBank = responseBank;
        this.responseMembership = responseMembership;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        system.debug(req.getEndpoint());
        if(req.getEndpoint().endsWith('SFAddUpdateContactWS.pl')) {
            res.setBody(responseContact);
        } else if(req.getEndpoint().endsWith('SFAddBankDetailsWS.pl')) {
            res.setBody(responseBank);
        } else if(req.getEndpoint().endsWith('SFAddMembershipWS.pl')) {
            res.setBody(responseMembership);
        } else {
            res.setBody(responseBody);
        }
        res.setStatusCode(200);
        return res;
    }
}