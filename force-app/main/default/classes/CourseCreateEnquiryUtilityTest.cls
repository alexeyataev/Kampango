@IsTest
public with sharing class CourseCreateEnquiryUtilityTest {

    private final static String headers = '{"Content-Type":"application/x-www-form-urlencoded","X-Salesforce-SIP":"35.168.189.83","Accept-Encoding":"gzip","Host":"parentforce--Dev12.cs83.my.salesforce.com","User-Agent":"Workbench/47.0.0","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 256-bits","Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/;q=0.8,application/signed-exchange;v=b3","X-PrettyPrint":"true"}';
    private final static String params = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test","duedate":"30/09/2019","firstbaby":"1","address_line1":"Test","address_line2":"","form_build_id":"form-hKYdyS5gM71NliL9zr-lK05oXgz02gAs0hW_15524uc","url":"","additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form","twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456","town":"London","op":"Send enquiry"}';

    private static final String COURSE_FINAL_STATUS = 'Final';
    private static final String COURSE_DRAFT_STATUS = 'Draft';
    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_RECORDTYPE_NAME  = 'Practitioner';
    

    @TestSetup
    static void createTestData() {
        // TestAccountBuilder accountBuilder = new TestAccountBuilder();
        // Account branch = accountBuilder
        //     .withName('Branch Account')
        //     .withRecordType('Branch')
        //     .insertRecord(true)
        //     .build();

        // TestContactBuilder contactBuilder = new TestContactBuilder();
        // Contact practitioner = contactBuilder
        //     .withRecordType('Practitioner')
        //     .withFirstName('Commander')
        //     .withLastName('Shepard')
        //     .insertRecord(true)
        //     .build();

        // TestLicenceToPracticeBuilder licenceBuilder = new TestLicenceToPracticeBuilder();
        // Licence_To_Practice__c licenceToPractice = licenceBuilder
        //     .withContact(practitioner)
        //     .withLicence('Postnatal Practitioner')
        //     .withStartDate(Date.today())
        //     .withStatus('Full')
        //     .insertRecord(true)
        //     .build();

        // TestCourseBuilder courseBuilder = new TestCourseBuilder();
        // Course__c course = courseBuilder
        //     .withType('Postnatal')
        //     .withSubType('Early Days')
        //     .withStatus('Draft')
        //     .withLicenceToPractice(licenceToPractice)
        //     .withNumberOfPlaces(5)
        //     .withPractitioner(practitioner)
        //     .withAccount(branch)
        //     .insertRecord(true)
        //     .build();
        TestDataFactory.getInstance()
            .buildOrganizationAccount('acct1')
            .buildBranchAccount()
            .buildPractitioner(PRACTITIONER_LASTNAME)
            .buildLicenceToPractice()
            .buildCourse();

    }
    @isTest
    static void createEnquiry_WithoutExistingContact() {
        //Will be changed
        String courseId = [SELECT Id FROM Course__c LIMIT 1].Id;
        System.debug([SELECT Id FROM Course__c LIMIT 1]);

        // RestRequest request = new RestRequest();
        // request.httpMethod = 'POST';
        // request.requestURI = '/services/apexrest/course';
        // request.requestBody = Blob.valueOf(params);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(headers, Map<String, String>.class);
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(params, Map<String, String>.class);

        CourseCreateEnquiryUtility.createEnquiry(courseId, paramsMap);

        List<Contact> createdContact = [SELECT Name, Email FROM Contact WHERE Email =: 'test@test.test'];
        List<Booking__c> bookings = [SELECT Name FROM Booking__c];

        System.assertEquals(1, createdContact.size());
        System.assertEquals(1, bookings.size());

        //System.assertEquals(expected, actual)
    }
}
