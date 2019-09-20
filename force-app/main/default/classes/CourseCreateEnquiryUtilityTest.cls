@isTest
private class CourseCreateEnquiryUtilityTest {

    private final static String HEADERS = '{"Content-Type":"application/x-www-form-urlencoded"}';
    private final static String PARAMS = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test",' + 
                                         '"duedate":"30/09/2019","firstbaby":"1","address_line1":"Test","address_line2":"",' +
                                         '"additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form",' +
                                         '"twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456",' +
                                         '"town":"London","op":"Send enquiry"}';
    @testSetup
    static void createTestData() {
        TestDataFactory.getInstance()
            .buildOrganizationAccount('acct1')
            .buildBranchAccount()
            .buildPractitioner('Practitioner')
            .buildLicenceToPractice()
            .buildCourse();
    }

    @isTest
    static void createEnquiryWithoutExistingContact() {
        String courseId = [SELECT Id FROM Course__c LIMIT 1].Id;
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(params, Map<String, String>.class);
        CourseCreateEnquiryUtility.createEnquiry(courseId, paramsMap);
        List<Contact> createdContact = [
            SELECT Name, Email 
            FROM Contact 
            WHERE Email =: 'test@test.test'
        ];
        List<Booking__c> bookings = [
            SELECT Name 
            FROM Booking__c
        ];
        System.assertEquals(1, createdContact.size());
        System.assertEquals(1, bookings.size());
    }

    @isTest
    static void createEnquiryWithExistingContact() {
        Account account = new Account(
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(),
            Name = 'Test Household'
        );
        insert account;
        Contact existingContact = new Contact(
            LastName = 'Test',  
            FirstName = 'Test', 
            Email = 'test@test.test',
            MailingCity = 'London',
            MailingStreet = '221B Baker Street',
            MailingPostalCode = 'E1 7AE',
            Phone = '+447911123456',
            AccountId = account.Id,
            RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId()
        );
        insert existingContact;
        String courseId = [
            SELECT Id 
            FROM Course__c 
            LIMIT 1
        ].Id;
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(params, Map<String, String>.class);
        CourseCreateEnquiryUtility.createEnquiry(courseId, paramsMap);
        List<Booking__c> bookings = [
            SELECT Name 
            FROM Booking__c 
            WHERE Primary_Contact__c != null
        ];
        List<Contact> contacts = [
            SELECT Name 
            FROM Contact 
            WHERE Email =: existingContact.Email
        ];
        System.assertEquals(1 , bookings.size());
        System.assertEquals(1, contacts.size());
    }

    @isTest
    static void createEnquiryWithExistingPartner() {
        Account accountPartner = new Account(
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(),
            Name = 'Partner Household'
        );
        insert accountPartner;
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact partner = contactBuilder
            .withRecordType('Contact')
            .withLastName('Partner')
            .withFirstName('Partner')
            .withAccount(accountPartner)
            .insertRecord(false)
            .build();
        partner.Email = 'partner@partner.partner';
        insert partner;
        Account account = new Account(
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(),
            Name = 'Test Household'
        );
        insert account;
        Contact existingContact = new Contact(
            LastName = 'Test',  
            FirstName = 'Test', 
            Email = 'test@test.test',
            MailingCity = 'London',
            MailingStreet = '221B Baker Street',
            MailingPostalCode = 'E1 7AE',
            Phone = '+447911123456',
            AccountId = account.Id,
            RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId()
        );
        insert existingContact;
        String courseId = [
            SELECT Id 
            FROM Course__c 
            LIMIT 1
        ].Id;
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(params, Map<String, String>.class);
        paramsMap.put('partner_first_name', 'Partner');
        paramsMap.put('partner_last_name', 'Partner');
        paramsMap.put('partner_email', 'partner@partner.partner');
        CourseCreateEnquiryUtility.createEnquiry(courseId, paramsMap);
        List<Contact> partners = [
            SELECT Name, Email
            FROM Contact
            WHERE Email =: paramsMap.get('partner_email')
        ];
        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
            WHERE Partner_Contact__c != null
        ];
        System.assertEquals(1, partners.size());
        System.assertEquals(1, bookings.size());
    }

    @isTest
    static void createEnquiryWithoutExistingPartner() {
        Account account = new Account(
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(),
            Name = 'Test Household'
        );
        insert account;
        Contact existingContact = new Contact(
            LastName = 'Test',  
            FirstName = 'Test', 
            Email = 'test@test.test',
            MailingCity = 'London',
            MailingStreet = '221B Baker Street',
            MailingPostalCode = 'E1 7AE',
            Phone = '+447911123456',
            AccountId = account.Id,
            RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId()
        );
        insert existingContact;
        String courseId = [
            SELECT Id 
            FROM Course__c 
            LIMIT 1
        ].Id;
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(params, Map<String, String>.class);
        paramsMap.put('partner_first_name', 'Partner');
        paramsMap.put('partner_last_name', 'Partner');
        paramsMap.put('partner_email', 'partner@partner.partner');
        CourseCreateEnquiryUtility.createEnquiry(courseId, paramsMap);
        List<Contact> partners = [
            SELECT Name, Email
            FROM Contact
            WHERE Email =: paramsMap.get('partner_email')
        ];
        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
            WHERE Partner_Contact__c != null
        ];
        System.assertEquals(1, partners.size());
        System.assertEquals(1, bookings.size());
    }

    @isTest
    static void createEnquiry() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/courses/';
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(params, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(params, Map<String, String>.class);
        for (String parameter : paramsMap.keySet()) {
            request.addParameter(parameter, paramsMap.get(parameter));
        }
        for (String header : headersMap.keySet()) {
            request.addHeader(header, paramsMap.get(header));
        }
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        CourseAPI.createEnquiry();
        Test.stopTest();
        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(0, bookings.size());
    }
}
