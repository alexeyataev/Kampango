@isTest
public class SendMembershipHttpResponseMock implements HttpCalloutMock {
    private String body;
    private static final Integer HTTP_SUCCESS_STATUS_CODE = 200;
    private static final String HTTP_SUCCESS_STATUS = 'OK';
    public SendMembershipHttpResponseMock(CareHelper.BaseResponse baseResponse) {
        this.body = JSON.serialize(baseResponse);
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(HTTP_SUCCESS_STATUS_CODE);
        res.setStatus(HTTP_SUCCESS_STATUS);
        return res;
    }
}