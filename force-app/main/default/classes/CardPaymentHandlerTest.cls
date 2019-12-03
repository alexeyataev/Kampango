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
        TestAccountBuilder accountBuilderBranch = new TestAccountBuilder();
        Account branch =  accountBuilderBranch.withRecordType('Branch')
            .withName('Test Branch')
            .withBillingPostalCode('qwerty')
            .insertRecord(true)
            .build();
        TestAccountBuilder accountOrganizationBuilder = new TestAccountBuilder();
        Account organization = accountOrganizationBuilder.withRecordType('Organization')
            .withName('Test Organization')           
            .withType('Supplier')
            .insertRecord(true)
            .withBillingEmail('test@test.com')
            .withAccountNumber('test acc number')
            .build();
        TestContactBuilder contactPractitionerBuilder = new TestContactBuilder();
        Contact contact = contactPractitionerBuilder.withRecordType('Practitioner')
            .withAccount(organization)
            .withFirstName('Fname')
            .withLastName('Lname')
            .insertRecord(true)
            .build();
        TestContactBuilder primaryContactBuilder = new TestContactBuilder();
        Contact primaryContact = primaryContactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Test')
            .withLastName('Primary')
            .insertRecord(true)
            .build();
        TestContactBuilder partnerContactBuilder = new TestContactBuilder();
        Contact partnerContact = partnerContactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Test')
            .withLastName('Partner')
            .insertRecord(true)
            .build();
        TestLicenceToPracticeBuilder lisenceBuilder = new TestLicenceToPracticeBuilder();
        Licence_To_Practice__c lisence = lisenceBuilder.withContact(contact)
            .withStartDate(System.today())
            .withStatus('Full')
            .withLicence('Signature Antenatal Teacher')
            .insertRecord(true)
            .build();
        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        Venue__c  venue = venueBuilder.withName('Venue1')
            .insertRecord(true)
            .build();
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        Course__c course = courseBuilder.withType('Postnatal')
            .withSubType('NCT Baby Massage')
            .withFee(100)
            .withNumberOfPlaces(15)
            .withStatus('Draft')
            .withAccount(branch)
            .withLicenceToPractice(lisence)
            .withPractitioner(contact)
            .withMainVenue(venue)
            .insertRecord(true)
            .build();
        TestBookingBuilder  bookingBuilder = new TestBookingBuilder();
        Booking__c booking = bookingBuilder.withCourse(course)
            .withStatus('Reserved')
            .withPrimaryContact(primaryContact)
            .withPartnerContact(partnerContact)
            .withBookingExpiryDate(System.today().addDays(10))
            .insertRecord(true)
            .build();
        TestInstallmentBuilder installmentBuilder = new TestInstallmentBuilder();
        cpm__Installment__c installment = installmentBuilder.withAmount(50)
            .withPrimaryContact(primaryContact.Id)
            .insertRecord(true)
            .build();
        cpm__Installment__c installment2 = installmentBuilder.withAmount(50)
            .withPrimaryContact(primaryContact.Id)
            .insertRecord(true)
            .build();
    }
    @IsTest
    static void testGetPaymentLink(){
        cpm__Installment__c installment = [SELECT Id, cpm__Amount__c, cpm__Contact__c, Sales_Invoice__c FROM cpm__Installment__c LIMIT 1];
        String bookingId = [SELECT Id FROM Booking__c LIMIT 1].Id;
        PaymentApiRequest paymentBody = StepOrangeCardPaymentProvider.createPaymentBody(installment, bookingId);
        StepOrangeCardPaymentProvider.createPaymentRequest(paymentBody);
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        RestContext.response.responseBody = Blob.valueof('{"ResponseCode":"001","IsSuccess":true,"SourceConnector":{"Name":"PaymentHub"},"RedirectURL":"' + responseUrl + '","PaymentMethod":{"Processor":"PaymentHub-WorldPay","Name":"CreditCard"},"Payment":{"InstallmentId":"a2b6E000000IVqQQAW"},"Payer":{"ContactId":"0036E00000quniyQAA","ContactDeduplicated":false,"AccountDeduplicated":false}}');
        Test.startTest();
        CardPaymentUrlResult result = StepOrangeCardPaymentProvider.createPaymentUrlResult();
        Test.stopTest();
        System.assertEquals(result.url, responseUrl);
        System.assertEquals(result.error, null);
    }
    @IsTest
    static void testGetPaymentLinkError(){
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        Test.startTest();
        CardPaymentUrlRequest params = new CardPaymentUrlRequest();
        params.installment = [SELECT Id, cpm__Amount__c, cpm__Contact__c FROM cpm__Installment__c  LIMIT 1];
        params.bookingId   = [SELECT Id FROM Booking__c LIMIT 1].Id;
        List<CardPaymentUrlRequest> paramsFromFlow = new List<CardPaymentUrlRequest>();
        paramsFromFlow.add(params);
        List<CardPaymentUrlResult> result = CardPaymentHandler.getPaymentLink(paramsFromFlow);
        Test.stopTest();
        System.assertNotEquals(result[0].url, responseUrl);
        System.assertEquals(result[0].error, 'SObject row was retrieved via SOQL without querying the requested field: cpm__Installment__c.Sales_Invoice__c');
    }
    @IsTest
    static void testGetPaymentLinkNot1RecordError(){
        String responseUrl = 'http://mynct.test.com/apex/wpayc__worldpaycheckout';
        Test.startTest();
        List<CardPaymentUrlResult> result = CardPaymentHandler.getPaymentLink(new List<CardPaymentUrlRequest>());
        Test.stopTest();
        System.assertNotEquals(result[0].url, responseUrl);
        System.assertEquals(result[0].error, 'List must contain 1 record');
    }
}