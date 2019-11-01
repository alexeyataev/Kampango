@isTest
public class CareSendMembershipHttpResponseMock implements HttpCalloutMock {
    private String body;
    public CareSendMembershipHttpResponseMock(String body) {
        this.body = body;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}