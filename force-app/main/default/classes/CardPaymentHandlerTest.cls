@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
public class CardPaymentHandlerTest
{
    private static final String RESPONSE_URL = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
    private static final String LIST_EXCEPTION = '1 card payment parameter must be passed';
    @IsTest
    static void GetPaymentLink_OneOffPaymentOptionChosen_PaymentUrlReturned() {
        CardPaymentParameters cardPaymentParameters = new CardPaymentParameters();
        cardPaymentParameters.amount = 60;
        cardPaymentParameters.contactId = 'primaryContact.Id';
        cardPaymentParameters.salesInvoiceId = 'salesInvoice.Id';
        PaymentApiRequest paymentBody = FinDockCardPaymentProvider.createPaymentBody(cardPaymentParameters);
        FinDockCardPaymentProvider.createPaymentRequest(paymentBody);
        RestContext.response.responseBody = Blob.valueof('{"RedirectURL":"' + RESPONSE_URL + '"}');
        Test.startTest();
        CardPaymentUrlResult cardPaymentUrlResult = FinDockCardPaymentProvider.createPaymentUrlResult();
        Test.stopTest();
        System.assertEquals(cardPaymentUrlResult.url, RESPONSE_URL);
        System.assertEquals(cardPaymentUrlResult.error, null);
    }
    @IsTest
    static void GetPaymentPlanLink_PaymentPlanOptionChosen_PaymentUrlReturned() {
        CardPaymentParameters cardPaymentParameters = new CardPaymentParameters();
        cardPaymentParameters.amount = 30;
        cardPaymentParameters.amountRecurring = 30;
        cardPaymentParameters.contactId = 'primaryContact.Id';
        cardPaymentParameters.paymentPlanStartDate = Date.today() + 1;
        cardPaymentParameters.paymentPlanEndDate = Date.today() + 100;
        cardPaymentParameters.salesInvoiceId = 'salesInvoice.Id';
        PaymentApiRequest paymentBody = FinDockCardPaymentProvider.createPaymentPlanBody(cardPaymentParameters);
        FinDockCardPaymentProvider.createPaymentRequest(paymentBody);
        RestContext.response.responseBody = Blob.valueof('{"RedirectURL":"' + RESPONSE_URL + '"}');
        Test.startTest();
        CardPaymentUrlResult cardPaymentUrlResult = FinDockCardPaymentProvider.createPaymentUrlResult();
        Test.stopTest();
        System.assertEquals(cardPaymentUrlResult.url, RESPONSE_URL);
        System.assertEquals(cardPaymentUrlResult.error, null);
    }
    @IsTest
    static void GetPaymentLinkGenericException_ParameterNullPassed_ExceptionThrown(){
        Test.startTest();
        List<CardPaymentUrlResult> cardPaymentUrlResult = CardPaymentHandler.getPaymentLink(null);
        Test.stopTest();
        System.assertNotEquals(cardPaymentUrlResult[0].url, RESPONSE_URL);
        System.assertEquals(cardPaymentUrlResult[0].error, LIST_EXCEPTION);
    }
    @IsTest
    static void GetPaymentLinkGenericException_ParameterNullListPassed_ExceptionThrown(){
        Test.startTest();
        List<CardPaymentUrlResult> cardPaymentUrlResult = CardPaymentHandler.getPaymentLink(new List<CardPaymentParameters> {null});
        Test.stopTest();
        System.assertNotEquals(cardPaymentUrlResult[0].url, RESPONSE_URL);
        System.assertEquals(cardPaymentUrlResult[0].error, LIST_EXCEPTION);
    }
    @IsTest
    static void GetPaymentPlanLinkGenericException_ParameterNullPassed_ExceptionThrown(){
        Test.startTest();
        List<CardPaymentUrlResult> cardPaymentUrlResult = CardPaymentPlanHandler.getPaymentLink(null);
        Test.stopTest();
        System.assertNotEquals(cardPaymentUrlResult[0].url, RESPONSE_URL);
        System.assertEquals(cardPaymentUrlResult[0].error, LIST_EXCEPTION);
    }
    @IsTest
    static void GetPaymentPlanLinkGenericException_ParameterNullListPassed_ExceptionThrown(){
        Test.startTest();
        List<CardPaymentUrlResult> cardPaymentUrlResult = CardPaymentPlanHandler.getPaymentLink(new List<CardPaymentParameters> {null});
        Test.stopTest();
        System.assertNotEquals(cardPaymentUrlResult[0].url, RESPONSE_URL);
        System.assertEquals(cardPaymentUrlResult[0].error, LIST_EXCEPTION);
    }
    @IsTest
    static void GetPaymentLinkListParameterNotValid_ListParameterTwoValues_ListExceptionThrown(){
        Test.startTest();
        List<CardPaymentUrlResult> result = CardPaymentHandler.getPaymentLink(new List<CardPaymentParameters> {new CardPaymentParameters(), new CardPaymentParameters()});
        Test.stopTest();
        System.assertNotEquals(result[0].url, RESPONSE_URL);
        System.assertEquals(result[0].error, LIST_EXCEPTION);
    }
    @IsTest
    static void GetPaymentPlanLinkListParameterNotValid_ListParameterTwoValues_ListExceptionThrown(){
        Test.startTest();
        List<CardPaymentUrlResult> result = CardPaymentPlanHandler.getPaymentLink(new List<CardPaymentParameters> {new CardPaymentParameters(), new CardPaymentParameters()});
        Test.stopTest();
        System.assertNotEquals(result[0].url, RESPONSE_URL);
        System.assertEquals(result[0].error, LIST_EXCEPTION);
    }
}