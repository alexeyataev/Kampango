@isTest
public class SendMembershipHttpResponseMock implements HttpCalloutMock {
    private String body;
    private Integer httpSuccessStatusCode;
    private String httpSuccessStatus;
    public SendMembershipHttpResponseMock(CareHelper.BaseResponse baseResponse) {
        this.body = JSON.serialize(baseResponse);
        httpSuccessStatusCode = 200;
        httpSuccessStatus = 'OK';
    }
    public SendMembershipHttpResponseMock(String body, Boolean isSuccess) {
        this.body = body;
        httpSuccessStatusCode = isSuccess ? 200 : 400;
        httpSuccessStatus = isSuccess ? 'OK' : 'Not Found';
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(httpSuccessStatusCode);
        res.setStatus(httpSuccessStatus);
        return res;
    }
}