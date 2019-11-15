@IsTest
public class CardPaymentHandlerTest
{
    @testSetup static void createInstallment() {
        Parentforce_Community_Settings__c parentforceCommunitySettings = new Parentforce_Community_Settings__c();
        parentforceCommunitySettings.Base_Url__c = 'http://mynct.test.com';
        parentforceCommunitySettings.API_Token__c = '12345';
        parentforceCommunitySettings.SetupOwnerId = UserInfo.getOrganizationId();
        insert parentforceCommunitySettings;
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account account =  accountBuilder
            .withRecordType('Household Account')
            .insertRecord(true)
            .build();
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Test')
            .withLastName('Primary')
            .insertRecord(true)
            .build();
        TestPaymentProfileBuilder paymentProfileBuilder = new TestPaymentProfileBuilder();
        cpm__Payment_Profile__c paymentProfile = paymentProfileBuilder.withContact(primaryContact)
            .withSortCode('1111')
            .withBankAccount('2222')
            .withHolderName('test')
            .insertRecord(true)
            .build();
        TestInstallmentBuilder installmentBuilder = new TestInstallmentBuilder();
        cpm__Installment__c installment = installmentBuilder.withAmount(50)
            .withPrimaryContact(primaryContact)
            .withPaymentProfile(paymentProfile)
            .insertRecord(true)
            .build();
    }
    @IsTest
    static void testGetPaymentLink(){
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        Test.startTest();
        List<cpm__Installment__c> installmentList = [SELECT Id, cpm__Amount__c, cpm__Contact__c, Sales_Invoice__c FROM cpm__Installment__c];
        PaymentApiRequest paymentBody = StepOrangeCardPaymentProvider.createPaymentBody(installmentList[0]);
        StepOrangeCardPaymentProvider.createPaymentRequest(paymentBody);
        RestContext.response.responseBody = Blob.valueof('{"ResponseCode":"001","IsSuccess":true,"SourceConnector":{"Name":"PaymentHub"},"RedirectURL":"' + responseUrl + '","PaymentMethod":{"Processor":"PaymentHub-WorldPay","Name":"CreditCard"},"Payment":{"InstallmentId":"a2b6E000000IVqQQAW"},"Payer":{"ContactId":"0036E00000quniyQAA","ContactDeduplicated":false,"AccountDeduplicated":false}}');
        CardPaymentUrlResult result = StepOrangeCardPaymentProvider.createPaymentUrlResult();
        System.assertEquals(result.url, responseUrl);
        System.assertEquals(result.error, null);
        Test.stopTest();
    }
    @IsTest
    static void testGetPaymentLinkError(){
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        Test.startTest();
        List<cpm__Installment__c> installmentList = [SELECT Id, cpm__Amount__c, cpm__Contact__c FROM cpm__Installment__c];
        List<CardPaymentUrlResult> result = CardPaymentHandler.getPaymentLink(installmentList);
        System.assertEquals(result[0].url, null);
        System.assertNotEquals(result[0].error, null);
        Test.stopTest();
    }
}