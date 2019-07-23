@isTest
global class PaymentProviderHttpResponseMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ResponseCode":"001","IsSuccess":true,"SourceConnector":{"Name":"PaymentHub for NPSP"},"RedirectURL":"http://mynct.test.com/apex/wpayc__worldpaycheckout","PaymentMethod":{"Processor":"PaymentHub-WorldPay","Name":"CreditCard"},"Payment":{"InstallmentId":""},"Payer":{"ContactId":"","ContactDeduplicated":false,"AccountDeduplicated":false}}');
        res.setStatusCode(200);
        return res;
    }
}