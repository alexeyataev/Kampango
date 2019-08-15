@IsTest
public class FlowPaymentHandlerTest 
{
    @testSetup   
    static void setup()
    {
        Parentforce_Community_Settings__c parentforceCommunitySettings = new Parentforce_Community_Settings__c();
        parentforceCommunitySettings.Base_Url__c = 'http://mynct.test.com';
        parentforceCommunitySettings.API_Token__c = '12345';
        parentforceCommunitySettings.SetupOwnerId = UserInfo.getOrganizationId();
        insert parentforceCommunitySettings;

        Account testBranch = new Account();
        testBranch.Name = 'testBranch';
        testBranch.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Branch'].Id;
        insert testBranch;
        Contact testPractitioner = new Contact();
        testPractitioner.AccountId = testBranch.Id;
        testPractitioner.LastName = 'testPractitioner';
        testPractitioner.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Practitioner'].Id;
        insert testPractitioner;
        Licence_To_Practice__c testLicense = new Licence_To_Practice__c();
        testLicense.Contact__c = testPractitioner.Id;
        testLicense.Licence__c = 'Breastfeeding Counsellor';
        testLicense.Start_Date__c = Date.today() - 30;
        testLicense.Status__c = 'Full';
        insert testLicense;
        Course__c testCourse = new Course__c();
        testCourse.Branch__c = testBranch.Id;
        testCourse.Number_of_places__c = 5;
        testCourse.Sub_Type__c = 'Waterbirth';
        testCourse.Type__c = 'Antenatal';
        testCourse.Main_Practitioner_Licence__c = testLicense.Id;
        insert testCourse;
        Contact testContact = new Contact();
        testContact.FirstName = 'test';
        testContact.LastName = 'testContact';
        testContact.MailingCity = 'London';
        testContact.MailingPostalCode = '533537';
        testContact.Email = 'test@test.com';
        testContact.MailingCountry = 'GB';
        testContact.MailingStreet = 'test 1';
        testContact.MailingState = 'test';
        testContact.Phone = '11111111';
        testContact.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Clients'].Id;
        insert testContact;
        cpm__Payment_Profile__c testPaymentProfile = new cpm__Payment_Profile__c();
        testPaymentProfile.cpm__Contact__c = testContact.Id;
        insert testPaymentProfile;
        Booking__c testBooking = new Booking__c();
        testBooking.Birth_Due_Date__c = Date.today() + 30;
        testBooking.Course__c = testCourse.Id;
        testBooking.Primary_Contact__c = testContact.Id;
        insert testBooking;
    }
    @IsTest
    static void testCourseCardOneoff(){
        String responseBody = '{"ResponseCode":"001","IsSuccess":true,"SourceConnector":{"Name":"PaymentHub for NPSP"},"RedirectURL":"http://mynct.test.com/apex/wpayc__worldpaycheckout","PaymentMethod":{"Processor":"PaymentHub-WorldPay","Name":"CreditCard"},"Payment":{"InstallmentId":""},"Payer":{"ContactId":"","ContactDeduplicated":false,"AccountDeduplicated":false}}';
        Test.setMock(HttpCalloutMock.class, new FlowPaymentHandlerHttpResponseMock(responseBody, null, null, null));
        Test.startTest();
        Booking__c testBooking = [SELECT Id FROM Booking__c LIMIT 1];
        List<String> result = FlowPaymentHandler.invokePaymentMethod(new List<List<String>> {new List<String>{'course', testBooking.Id, 'card', 'false'}});
        system.assertEquals(result[0], 'http://mynct.test.com/apex/wpayc__worldpaycheckout');
        Test.stopTest();
    }
    @IsTest
    static void testCourseCardRecurring(){
        String responseBody = '{"ResponseCode":"001","IsSuccess":true,"SourceConnector":{"Name":"PaymentHub for NPSP"},"RedirectURL":"http://mynct.test.com/apex/wpayc__worldpaycheckout","PaymentMethod":{"Processor":"PaymentHub-WorldPay","Name":"CreditCard"},"Payment":{"InstallmentId":""},"Payer":{"ContactId":"","ContactDeduplicated":false,"AccountDeduplicated":false}}';
        Test.setMock(HttpCalloutMock.class, new FlowPaymentHandlerHttpResponseMock(responseBody, null, null, null));
        Test.startTest();
        Booking__c testBooking = [SELECT Id FROM Booking__c LIMIT 1];
        List<String> result = FlowPaymentHandler.invokePaymentMethod(new List<List<String>> {new List<String>{'course', testBooking.Id, 'card', 'true'}});
        system.assertEquals(result[0], 'http://mynct.test.com/apex/wpayc__worldpaycheckout');
        Test.stopTest();
    }
    @IsTest
    static void testCourseDdRecurring(){
        String responseContact = '{"Contact": {"Action":"Update","AddressNumber": "26663333","ContactKey": "3325458","ContactNumber": "3325458","EmailAddress": "ncttst+alexandr.popok_greencouchconsulting.com@gmail.com","EmailInvalid": "N","PrimaryPhoneNumber": "","SecondaryPhoneNumber": "","AmendedBy": "xNCT_ORG_UK","AmendedOn": "2019-08-15 00:00:00.000"}}';
        String responseBank = '{"ContactBankAccount": {"ContactKey": "3325458","BankDetailNumber": "346278","Information": "Matched existing account!"}}';
        Test.setMock(HttpCalloutMock.class, new FlowPaymentHandlerHttpResponseMock(null, responseContact, responseBank, null));
        Test.startTest();
        Booking__c testBooking = [SELECT Id FROM Booking__c LIMIT 1];
        List<String> result = FlowPaymentHandler.invokePaymentMethod(new List<List<String>> {new List<String>{'course', testBooking.Id, 'dd', 'true'}});
        system.assertEquals(result[0], '');
        system.assertEquals([SELECT NCT_Number__c FROM Contact WHERE LastName = 'testContact' LIMIT 1].NCT_Number__c, '3325458');
        Test.stopTest();
    }
    @IsTest
    static void testMembershipCardOneoff(){
        String responseBody = '{"ResponseCode":"001","IsSuccess":true,"SourceConnector":{"Name":"PaymentHub for NPSP"},"RedirectURL":"http://mynct.test.com/apex/wpayc__worldpaycheckout","PaymentMethod":{"Processor":"PaymentHub-WorldPay","Name":"CreditCard"},"Payment":{"InstallmentId":""},"Payer":{"ContactId":"","ContactDeduplicated":false,"AccountDeduplicated":false}}';
        String responseContact = '{"Contact": {"Action":"Update","AddressNumber": "26663333","ContactKey": "3325458","ContactNumber": "3325458","EmailAddress": "ncttst+alexandr.popok_greencouchconsulting.com@gmail.com","EmailInvalid": "N","PrimaryPhoneNumber": "","SecondaryPhoneNumber": "","AmendedBy": "xNCT_ORG_UK","AmendedOn": "2019-08-15 00:00:00.000"}}';
        String responseBank = '{"ContactBankAccount": {"ContactKey": "3325458","BankDetailNumber": "346278","Information": "Matched existing account!"}}';
        String responseMembership = '{"Membership": {"Status": "Success","ContactNumber_1": "3325458","MembershipType": "EJ","Amount": "57","RenewalDate": "2020-07-10","AmountTendered": "57"}}';
        Test.setMock(HttpCalloutMock.class, new FlowPaymentHandlerHttpResponseMock(responseBody, responseContact, responseBank, responseMembership));
        Test.startTest();
        Booking__c testBooking = [SELECT Id FROM Booking__c LIMIT 1];
        List<String> result = FlowPaymentHandler.invokePaymentMethod(new List<List<String>> {new List<String>{'membership', testBooking.Id, 'card', 'false', 'E', '57', '00000'}});
        system.assertEquals(result[0], 'http://mynct.test.com/apex/wpayc__worldpaycheckout');
        system.assertEquals([SELECT NCT_Number__c FROM Contact WHERE LastName = 'testContact' LIMIT 1].NCT_Number__c, '3325458');
        Test.stopTest();
    }
    @IsTest
    static void testMembershipDdRecurring(){
        String responseBody = '{"ResponseCode":"001","IsSuccess":true,"SourceConnector":{"Name":"PaymentHub for NPSP"},"RedirectURL":"http://mynct.test.com/apex/wpayc__worldpaycheckout","PaymentMethod":{"Processor":"PaymentHub-WorldPay","Name":"CreditCard"},"Payment":{"InstallmentId":""},"Payer":{"ContactId":"","ContactDeduplicated":false,"AccountDeduplicated":false}}';
        String responseContact = '{"Contact": {"Action":"Update","AddressNumber": "26663333","ContactKey": "3325458","ContactNumber": "3325458","EmailAddress": "ncttst+alexandr.popok_greencouchconsulting.com@gmail.com","EmailInvalid": "N","PrimaryPhoneNumber": "","SecondaryPhoneNumber": "","AmendedBy": "xNCT_ORG_UK","AmendedOn": "2019-08-15 00:00:00.000"}}';
        String responseBank = '{"ContactBankAccount": {"ContactKey": "3325458","BankDetailNumber": "346278","Information": "Matched existing account!"}}';
        String responseMembership = '{"Membership": {"Status": "Success","ContactNumber_1": "3325458","MembershipType": "EJ","Amount": "57","RenewalDate": "2020-07-10","AmountTendered": "57"}}';
        Test.setMock(HttpCalloutMock.class, new FlowPaymentHandlerHttpResponseMock(responseBody, responseContact, responseBank, responseMembership));
        Test.startTest();
        Booking__c testBooking = [SELECT Id FROM Booking__c LIMIT 1];
        List<String> result = FlowPaymentHandler.invokePaymentMethod(new List<List<String>> {new List<String>{'membership', testBooking.Id, 'dd', 'true', 'E', '57', '00000'}});
        system.assertEquals(result[0], '');
        system.assertEquals([SELECT NCT_Number__c FROM Contact WHERE LastName = 'testContact' LIMIT 1].NCT_Number__c, '3325458');
        Test.stopTest();
    }
}