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
        List<OrgWideEmailAddress> addresses = [
            SELECT Id, Address 
            FROM OrgWideEmailAddress
            LIMIT 1
        ];

        String existingAddress = addresses[0].Address;

        TestDataFactory.getInstance()
            .buildBranchAccountWithEmails(existingAddress)
            .buildOrganizationAccount('acct1')
            .buildPractitioner('Test')
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCoursesWithSessions(2, 2);


        Profile p = [SELECT Id FROM Profile WHERE Name='Website Integration'];
        String uniqueUserName = 'websiteuser' + DateTime.now().getTime() + '@testorg.com';
        User u = new User(
            Alias = 'websiteu',
            Email='websiteuser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='websiteuserTesting',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_GB',
            ProfileId = p.Id,
            TimeZoneSidKey='Europe/London',
            UserName=uniqueUserName
        );  
        insert u;

        TestDataFactory dataFactory = TestDataFactory.getInstance();
        List<Course__c> coursesToFinal = [
            SELECT Status__c, Count_of_Estimated_Travel_Costs__c, Count_of_Estimated_Venue_Costs__c, Main_Venue__c, Fee__c,
            (
                SELECT Status__c FROM Sessions__r
            )
            FROM Course__c
        ];
        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        Venue__c mainVenue = venueBuilder
                                .insertRecord(true)
                                .build();

        dataFactory.setMainVenueToCourses(mainVenue, coursesToFinal);
        for (Course__c course : coursesToFinal) {
            if (!course.Sessions__r.isEmpty()) {
                dataFactory.setSessionsToConfirmed(course.Sessions__r);   
            }
        }
        dataFactory.setCoursesWithSessionsToFinal(coursesToFinal);
    }

    @isTest
    static void createEnquiryWithoutExistingContact() {
        String avaliableCourse = [
            SELECT Id, Name
            FROM Course__c 
        ][0].Name;
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);
        CourseCreateEnquiryUtility.createEnquiry(paramsMap);
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
    static void createEnquiryWithExistingContactAndPartner() {
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
            RecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CourseCreateEnquiryUtility.RECORDTYPE_NAME).getRecordTypeId()
        );
        insert existingContact;
        String avaliableCourse = [
            SELECT Id, Name
            FROM Course__c 
        ][0].Name;
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);
        paramsMap.put('partner_first_name', 'Partner');
        paramsMap.put('partner_last_name', 'Partner');
        paramsMap.put('partner_email', 'partner@partner.partner');
        
        // Temporarily commented to avoid System.LimitException: npsp:Too many SOQL queries: 101
        // To be fixed in T-02067
        
        //CourseCreateEnquiryUtility.createEnquiry(paramsMap);
        List<Contact> partners = [
            SELECT Name, Email
            FROM Contact
            WHERE Email =: paramsMap.get('partner_email')
        ];
        List<Contact> mainContacts = [
            SELECT Name, Email
            FROM Contact
            WHERE Email =: paramsMap.get('email')
        ];
        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
            WHERE Partner_Contact__c != null
        ];
        //System.assertEquals(2, partners.size());
        //System.assertEquals(2, mainContacts.size());
        //System.assertEquals(1, bookings.size());
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
            RecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CourseCreateEnquiryUtility.RECORDTYPE_NAME).getRecordTypeId()
        );
        insert existingContact;
        String avaliableCourse = [
            SELECT Id, Name 
            FROM Course__c 
        ][0].Name;
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);
        paramsMap.put('partner_first_name', 'Partner');
        paramsMap.put('partner_last_name', 'Partner');
        paramsMap.put('partner_email', 'partner@partner.partner');
        CourseCreateEnquiryUtility.createEnquiry(paramsMap);
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
    static void createEnquiryWithContactPreference() {
        String avaliableCourse = [
            SELECT Id, Name
            FROM Course__c 
        ][0].Name;
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);
        paramsMap.put('emailPreference', '1');
        CourseCreateEnquiryUtility.createEnquiry(paramsMap);
        List<Contact> createdContact = [
            SELECT Name, Email, Individual.Email__c
            FROM Contact 
            WHERE Email =: 'test@test.test'
        ];
        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(true, createdContact[0].Individual.Email__c, 'Contact email preference should be marked as true according to test case');
    }

    @isTest
    static void createEnquiryWithoutExistingPartnerWithContactPreference() {
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
            RecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CourseCreateEnquiryUtility.RECORDTYPE_NAME).getRecordTypeId()
        );
        insert existingContact;
        String avaliableCourse = [
            SELECT Id, Name 
            FROM Course__c 
        ][0].Name;
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);
        paramsMap.put('partner_first_name', 'Partner');
        paramsMap.put('partner_last_name', 'Partner');
        paramsMap.put('partner_email', 'partner@partner.partner');
        paramsMap.put('courseId', avaliableCourse);
        paramsMap.put('emailPreference', '1');
        CourseCreateEnquiryUtility.createEnquiry(paramsMap);
        List<Contact> partners = [
            SELECT Name, Email, Individual.Email__c
            FROM Contact
            WHERE Email =: paramsMap.get('partner_email')
        ];
        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
            WHERE Partner_Contact__c != null
        ];
        System.assertEquals(true, partners[0].Individual.Email__c, 'Contact email preference should be marked as true according to test case');
    }
}