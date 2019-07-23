@IsTest
public class PaymentProviderTest 
{
    @testSetup   
    static void setup()
    {
        Parentforce_Community_Settings__c parentforceCommunitySettings = new Parentforce_Community_Settings__c();
        parentforceCommunitySettings.Base_Url__c = 'http://mynct.test.com';
        parentforceCommunitySettings.API_Token__c = '12345';
        parentforceCommunitySettings.SetupOwnerId = UserInfo.getOrganizationId();
        insert parentforceCommunitySettings;
    }
    @IsTest
    static void testGetPaymentLink(){
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        Test.setMock(HttpCalloutMock.class, new PaymentProviderHttpResponseMock(responseUrl));
        Test.startTest();
        List<List<String>> params = new List<List<String>>();
        params.add(new List<String>{'contactId', '50'});
        List<String> responseList = FlowPaymentHandler.getPaymentLink(params);
        system.assertEquals(responseList[0], responseUrl);
        Test.stopTest();
    }
}