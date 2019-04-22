@isTest
private class PaymentRequestVoTest {
    @isTest
    private static void paymentTest(){
        
        
        PaymentRequestVo.PaymentVo payment = new PaymentRequestVo.PaymentVo();
        payment.amount = 10000;
        
        PaymentRequestVo.PaymentMethodVo paymentMethod = new PaymentRequestVo.PaymentMethodVo();
        
        PaymentRequestVo.SourceConnectorVo sourceConnector = new PaymentRequestVo.SourceConnectorVo();               
        
        PaymentRequestVo.ContactVo  contact = new PaymentRequestVo.ContactVo();
        contact.email = 'nct@gmail.com';
        contact.firstName = 'NCT Child';
        contact.lastName = 'Trust';
        
        PaymentRequestVo.PayerVo payer = new PaymentRequestVo.PayerVo();
        payer.contact = contact;

        
        PaymentRequestVo paymentRequest = new PaymentRequestVo();
        paymentRequest.successURL = 'www.success.com';
        paymentRequest.paymentMethod = paymentMethod;
        paymentRequest.payment = payment;
        paymentRequest.payer = payer;
        paymentRequest.sourceConnector = sourceConnector;
        
        system.assertEquals(10000, payment.amount);
        system.assertEquals('Trust', contact.lastName);
    }

}