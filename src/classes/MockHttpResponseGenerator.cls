@isTest
public with sharing class MockHttpResponseGenerator implements HttpCalloutMock 
{   
    public HTTPResponse respond(HTTPRequest request) 
    {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"SuccessURL" : "System.Label.PAYMENTSTATUSURL+/nctPaymentHubSuccessMsgPage?contId=+ cont.Id","SourceConnector" : {"Name" : "PaymentHub"},"PaymentMethod" : {"Name" : "Creditcard"},"Payment" : {"Amount" : 25},"Payer" : {"ContactUpdate" : "replace","contact" : {"LastName" : "Contact","FirstName" : "Parent","Email" : "parent@contact.com"}, "AllowDeduplication" : true}, "Origin" : "test","FailureURL" : "System.Label.PAYMENTSTATUSURL+/nctPaymentHubErrorMsgPage"}');
        response.setStatusCode(200);
        return response; 
    }
}