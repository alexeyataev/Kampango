@isTest
public class CareSendMembershipHttpResponseMock implements HttpCalloutMock {
    private String body;
    private static final Integer HTTP_SUCCESS_RESPONSE = 200;
    public CareSendMembershipHttpResponseMock(String body) {
        this.body = body;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(HTTP_SUCCESS_RESPONSE);
        return res;
    }
}