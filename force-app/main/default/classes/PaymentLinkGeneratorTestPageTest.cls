@IsTest
public class PaymentLinkGeneratorTestPageTest
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
    static void testPaymentLinkGeneratorTestPage(){
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        Test.setMock(HttpCalloutMock.class, new PaymentLinkGeneratorTestPageMock(responseUrl));
        Test.startTest();
        PaymentLinkGeneratorTestPageController.contactId = '';
        PaymentLinkGeneratorTestPageController.amount = '';
        PaymentLinkGeneratorTestPageController.generateLink();
        system.assert(PaymentLinkGeneratorTestPageController.url != null);
        Test.stopTest();
    }
}