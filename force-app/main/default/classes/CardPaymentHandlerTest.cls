@IsTest
public class CardPaymentHandlerTest
{
    @IsTest
    static void testGetPaymentLink() {
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        CardPaymentParameters cardPaymentParameters = new CardPaymentParameters();
        cardPaymentParameters.amount = 60;
        cardPaymentParameters.contactId = 'primaryContact.Id';
        cardPaymentParameters.salesInvoiceId = 'salesInvoice.Id';
        PaymentApiRequest paymentBody = FinDockCardPaymentProvider.createPaymentBody(cardPaymentParameters);
        FinDockCardPaymentProvider.createPaymentRequest(paymentBody);
        RestContext.response.responseBody = Blob.valueof('{"RedirectURL":"' + responseUrl + '"}');
        Test.startTest();
        CardPaymentUrlResult cardPaymentUrlResult = FinDockCardPaymentProvider.createPaymentUrlResult();
        Test.stopTest();
        System.assertEquals(cardPaymentUrlResult.url, responseUrl);
        System.assertEquals(cardPaymentUrlResult.error, null);
    }
    @IsTest
    static void testGetPaymentPlanLink() {
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        CardPaymentParameters cardPaymentParameters = new CardPaymentParameters();
        cardPaymentParameters.amount = 30;
        cardPaymentParameters.amountRecurring = 30;
        cardPaymentParameters.contactId = 'primaryContact.Id';
        cardPaymentParameters.paymentPlanStartDate = Date.today() + 1;
        cardPaymentParameters.paymentPlanEndDate = Date.today() + 100;
        cardPaymentParameters.salesInvoiceId = 'salesInvoice.Id';
        PaymentApiRequest paymentBody = FinDockCardPaymentProvider.createPaymentPlanBody(cardPaymentParameters);
        FinDockCardPaymentProvider.createPaymentRequest(paymentBody);
        RestContext.response.responseBody = Blob.valueof('{"RedirectURL":"' + responseUrl + '"}');
        Test.startTest();
        CardPaymentUrlResult cardPaymentUrlResult = FinDockCardPaymentProvider.createPaymentUrlResult();
        Test.stopTest();
        System.assertEquals(cardPaymentUrlResult.url, responseUrl);
        System.assertEquals(cardPaymentUrlResult.error, null);
    }
    @IsTest
    static void testGetPaymentLinkError(){
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        Test.startTest();
        List<CardPaymentUrlResult> cardPaymentUrlResult = CardPaymentHandler.getPaymentLink(new List<CardPaymentParameters> {null});
        Test.stopTest();
        System.assertNotEquals(cardPaymentUrlResult[0].url, responseUrl);
        System.assertEquals(cardPaymentUrlResult[0].error, 'Attempt to de-reference a null object');
    }
    @IsTest
    static void testGetPaymentPlanLinkError(){
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        Test.startTest();
        List<CardPaymentUrlResult> cardPaymentUrlResult = CardPaymentPlanHandler.getPaymentLink(new List<CardPaymentParameters> {null});
        Test.stopTest();
        System.assertNotEquals(cardPaymentUrlResult[0].url, responseUrl);
        System.assertEquals(cardPaymentUrlResult[0].error, 'Attempt to de-reference a null object');
    }
    @IsTest
    static void testGetPaymentLinkNot1RecordError(){
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        Test.startTest();
        List<CardPaymentUrlResult> result = CardPaymentHandler.getPaymentLink(new List<CardPaymentParameters> {new CardPaymentParameters(), new CardPaymentParameters()});
        Test.stopTest();
        System.assertNotEquals(result[0].url, responseUrl);
        System.assertEquals(result[0].error, 'List must contain 1 record');
    }
    @IsTest
    static void testGetPaymentPlanLinkNot1RecordError(){
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        Test.startTest();
        List<CardPaymentUrlResult> result = CardPaymentPlanHandler.getPaymentLink(new List<CardPaymentParameters> {new CardPaymentParameters(), new CardPaymentParameters()});
        Test.stopTest();
        System.assertNotEquals(result[0].url, responseUrl);
        System.assertEquals(result[0].error, 'List must contain 1 record');
    }
}