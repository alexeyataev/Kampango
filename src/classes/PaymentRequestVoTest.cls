@isTest
private class PaymentRequestVoTest {
    @isTest
    private static void paymentTest(){
        
        PaymentRequestVo.PaymentMethodVo paymentMethod = new PaymentRequestVo.PaymentMethodVo();
        paymentMethod.name = 'NCT Child Trust';
        
        PaymentRequestVo.SourceConnectorVo sourceConnector = new PaymentRequestVo.SourceConnectorVo();
        sourceConnector.name = 'NCT Child';
        
        PaymentRequestVo.PaymentVo payment = new PaymentRequestVo.PaymentVo();
        payment.amount = 10000;
        
        PaymentRequestVo.ContactVo  contact = new PaymentRequestVo.ContactVo();
        contact.email = 'nct@gmail.com';
        contact.firstName = 'NCT Child';
        contact.lastName = 'Trust';
        
        PaymentRequestVo.PayerVo payer = new PaymentRequestVo.PayerVo();
        payer.allowDeduplication = true;
        payer.contact = contact;
        payer.contactUpdate = 'Yes';
        
        PaymentRequestVo paymentRequest = new PaymentRequestVo();
        paymentRequest.successURL = 'www.success.com';
        paymentRequest.failureURL = 'www.failure.com';
        paymentRequest.origin = 'NCT';
        paymentRequest.payer = payer;
        paymentRequest.payment = payment;
        paymentRequest.paymentMethod = paymentMethod;
        paymentRequest.sourceConnector = sourceConnector;
        
        system.assertEquals('NCT Child Trust', paymentMethod.name);
        system.assertEquals('NCT Child', sourceConnector.name);
    }

}