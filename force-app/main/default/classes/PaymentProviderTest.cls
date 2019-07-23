@IsTest
public class PaymentProviderTest 
{
    @IsTest
    static void testGetPaymentLink(){
        Test.setMock(HttpCalloutMock.class, new PaymentProviderHttpResponseMock());
        Test.startTest();
        List<List<String>> params = new List<List<String>>();
        params.add(new List<String>{'contactId', '50'});
        List<String> responseList = PaymentHandler.getPaymentLink(params);
        system.assertEquals(responseList[0], 'http://mynct.test.com/apex/wpayc__worldpaycheckout');
        Test.stopTest();
    }
}