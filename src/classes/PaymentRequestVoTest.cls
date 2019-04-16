@isTest
private class PaymentRequestVoTest {
    @isTest
    private static void paymentTest(){
        
        PaymentRequestVo.SourceConnectorVo sourceConnector = new PaymentRequestVo.SourceConnectorVo();
        sourceConnector.name = 'NCT Child';
        
        PaymentRequestVo.PaymentVo payment = new PaymentRequestVo.PaymentVo();
        payment.amount = 10000;
        payment.name = 'NCT Child Trust';
        
        PaymentRequestVo.ContactVo  contact = new PaymentRequestVo.ContactVo();
        contact.email = 'nct@gmail.com';
        contact.firstName = 'NCT Child';
        contact.lastName = 'Trust';
        
        PaymentRequestVo.PayerVo payer = new PaymentRequestVo.PayerVo();
        payer.allowDeduplication = true;
        payer.contact = contact;
        payer.contactUpdate = 'Yes';
        payer.successURL = 'www.success.com';
        payer.failureURL = 'www.failure.com';
        payer.origin = 'NCT';
        
        PaymentRequestVo paymentRequest = new PaymentRequestVo();        
        paymentRequest.payer = payer;
        paymentRequest.payment = payment;
        paymentRequest.sourceConnector = sourceConnector;
        
        system.assertEquals('NCT Child Trust', payment.name);
        system.assertEquals('NCT Child', sourceConnector.name);
    }

}