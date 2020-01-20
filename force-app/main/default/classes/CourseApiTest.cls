@isTest
public without sharing class CourseApiTest {
    private static final String OWA_VALUE = 'nctcourses@nct.org.uk';
    private static String strURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/courses';
    private static String methodGet = 'GET';

    @TestSetup
    private static void setupTestData() {
        List<OrgWideEmailAddress> addresses = [
            SELECT Id, Address 
            FROM OrgWideEmailAddress
            WHERE Address = :OWA_VALUE
            LIMIT 1
        ];

        String existingAddress = addresses[0].Address;
        
        TestDataFactory.getInstance()
            .buildBranchAccountWithEmails(existingAddress)
            .buildOrganizationAccount('acc5')
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

    private static User getWebSiteUser(){
        return [
            SELECT ID
            FROM USER 
            WHERE Email ='websiteuser@testorg.com'
        ];
    }

    @isTest
    static void searchWrongLocation(){
        RestRequest req = new RestRequest();
        req.requestURI = strURI;
        req.httpMethod = methodGet;
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('location', 'dummy');

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            System.runAs(getWebSiteUser()){
                CourseApi.getCourseData();
            }
        Test.stopTest();

        System.assertEquals(404, res.statusCode);
    }

    @isTest
    static void searchWithoutParams(){
        RestRequest req = new RestRequest();
        req.requestURI = strURI;
        req.httpMethod = methodGet;
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('dummy', 'dummy');

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            System.runAs(getWebSiteUser()){
                CourseApi.getCourseData();
            }
        Test.stopTest();

        System.assertEquals(404, res.statusCode);
    }

    @isTest
    static void searchCourseById() {
        Course__c course = [
            SELECT Id, Name
            FROM Course__c
            LIMIT 1
        ];

        RestRequest req = new RestRequest();
        req.requestURI = strURI;
        req.httpMethod = methodGet;
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('course', course.Name);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            System.runAs(getWebSiteUser()){
                CourseApi.getCourseData();
            }
        Test.stopTest();

        CourseFinderModel model = (CourseFinderModel)System.JSON.deserialize(res.responseBody.toString(), CourseFinderModel.class );

        System.assertEquals(200, res.statusCode);
        System.assertEquals(course.Name, model.Id);      
    }

    @isTest
    static void searchCourseByBranch() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account account = [
            SELECT Id 
            FROM Account
            WHERE RecordTypeId = :recordTypeId 
            LIMIT 1
        ];

        account.Branch_Number__c = '123';
        update account;

        RestRequest req = new RestRequest();
        req.requestURI = strURI;
        req.httpMethod = methodGet;
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('branch', account.Branch_Number__c);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            System.runAs(getWebSiteUser()){
                CourseApi.getCourseData();
            }
        Test.stopTest();

        CoursesBranchModel branchModel = (CoursesBranchModel)JSON.deserialize(res.responseBody.toString(), CoursesBranchModel.class);
        System.assertEquals(200, res.statusCode);
        System.assertEquals(2, branchModel.Courses.size(), 'There should be 2 Course records with at least 1 allocated Session record');
      
    }

    @isTest
    static void createEnquiry() {
        final String HEADERS = '{"Content-Type":"application/x-www-form-urlencoded", "Referer":""}';
        final String PARAMS = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test",' + 
                                            '"duedate":"30/09/2019","firstbaby":"1","address_line1":"Test","address_line2":"",' +
                                            '"additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form",' +
                                            '"twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456",' +
                                            '"town":"London","op":"Send enquiry"}';

        String avaliableCourse = [
            SELECT Id, Name
            FROM Course__c 
        ][0].Name;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/courses/';
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);
        for (String parameter : paramsMap.keySet()) {
            request.addParameter(parameter, paramsMap.get(parameter));
        }
        for (String header : headersMap.keySet()) {
            request.addHeader(header, headersMap.get(header));
        }
        RestContext.request = request;
        RestContext.response = response;

        System.runAs(getWebSiteUser()){
            CourseAPI.createEnquiry();
        }

        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(1, bookings.size());
    }

    @isTest
    static void createEnquiryEmptyCourseName() {
        final String HEADERS = '{"Content-Type":"application/x-www-form-urlencoded", "Referer":""}';
        final String PARAMS = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test",' + 
                                            '"duedate":"30/09/2019","firstbaby":"1","address_line1":"Test","address_line2":"",' +
                                            '"additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form",' +
                                            '"twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456",' +
                                            '"town":"London","op":"Send enquiry"}';

        String avaliableCourse = ''; // missed course name 
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/courses/';
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);
        for (String parameter : paramsMap.keySet()) {
            request.addParameter(parameter, paramsMap.get(parameter));
        }
        for (String header : headersMap.keySet()) {
            request.addHeader(header, headersMap.get(header));
        }
        RestContext.request = request;
        RestContext.response = response;

        System.runAs(getWebSiteUser()){
           CourseAPI.createEnquiry();
           System.assertEquals(HttpStatusCode.SERVER_ERROR, response.statusCode, 'There should be server error');
           Blob responseBlob = (Blob)response.responseBody;
           System.assertEquals(Label.CourseAPIEnqueryParametersSpecifiedNotCorrectly, responseBlob.toString());
        }

        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(0, bookings.size());
    }

    @isTest
    static void createEnquiryMissedCourseId() {
        final String HEADERS = '{"Content-Type":"application/x-www-form-urlencoded", "Referer":""}';
        final String PARAMS = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test",' + 
                                            '"duedate":"30/09/2019","firstbaby":"1","address_line1":"Test","address_line2":"",' +
                                            '"additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form",' +
                                            '"twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456",' +
                                            '"town":"London","op":"Send enquiry"}';

        String avaliableCourse = [
            SELECT Id, Name
            FROM Course__c 
        ][0].Name;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/courses/';
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);

        // Not put courseId
        // paramsMap.put('courseId', avaliableCourse);

        for (String parameter : paramsMap.keySet()) {
            request.addParameter(parameter, paramsMap.get(parameter));
        }
        for (String header : headersMap.keySet()) {
            request.addHeader(header, headersMap.get(header));
        }
        RestContext.request = request;
        RestContext.response = response;

        System.runAs(getWebSiteUser()){
           CourseAPI.createEnquiry();
           System.assertEquals(HttpStatusCode.SERVER_ERROR, response.statusCode, 'There should be server error');
           Blob responseBlob = (Blob)response.responseBody;
           System.assertEquals(Label.CourseAPIEnqueryParametersSpecifiedNotCorrectly, responseBlob.toString());
        }

        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(0, bookings.size());
    }

    @isTest
    static void createEnquiryNotValidCourseName() {
        final String HEADERS = '{"Content-Type":"application/x-www-form-urlencoded", "Referer":""}';
        final String PARAMS = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test",' + 
                                            '"duedate":"30/09/2019","firstbaby":"1","address_line1":"Test","address_line2":"",' +
                                            '"additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form",' +
                                            '"twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456",' +
                                            '"town":"London","op":"Send enquiry"}';

        String avaliableCourse = 'NotValidCourseName'; // not valid course name 
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/courses/';
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);
        for (String parameter : paramsMap.keySet()) {
            request.addParameter(parameter, paramsMap.get(parameter));
        }
        for (String header : headersMap.keySet()) {
            request.addHeader(header, headersMap.get(header));
        }
        RestContext.request = request;
        RestContext.response = response;

        System.runAs(getWebSiteUser()){
           CourseAPI.createEnquiry();
           System.assertEquals(HttpStatusCode.SERVER_ERROR, response.statusCode, 'There should be server error');
           Blob responseBlob = (Blob)response.responseBody;
           System.assertEquals(Label.CourseAPIcourseNotExists, responseBlob.toString());
        }

        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(0, bookings.size());
    }

    @isTest
    static void createEnquiryEmptyParameters() {
        final String HEADERS = '{"Content-Type":"application/x-www-form-urlencoded", "Referer":""}';
        final String PARAMS = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test",' + 
                                            '"duedate":"30/09/2019","firstbaby":"1","address_line1":"Test","address_line2":"",' +
                                            '"additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form",' +
                                            '"twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456",' +
                                            '"town":"London","op":"Send enquiry"}';

        String avaliableCourse = [
            SELECT Id, Name
            FROM Course__c 
        ][0].Name;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/courses/';
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);

        // don't add parameters to the request

        for (String header : headersMap.keySet()) {
            request.addHeader(header, headersMap.get(header));
        }
        RestContext.request = request;
        RestContext.response = response;

        System.runAs(getWebSiteUser()){
            CourseAPI.createEnquiry();
            System.assertEquals(HttpStatusCode.SERVER_ERROR, response.statusCode, 'There should be server error');
            Blob responseBlob = (Blob)response.responseBody;
            System.assertEquals(Label.CourseAPIEnqueryParametersSpecifiedNotCorrectly, responseBlob.toString());
        }

        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(0, bookings.size());
    }

    @isTest
    static void createEnquiryContactWithoutEmail() {
        final String HEADERS = '{"Content-Type":"application/x-www-form-urlencoded", "Referer":""}';
        final String PARAMS = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test",' + 
                                            '"duedate":"30/09/2019","firstbaby":"1","address_line1":"Test","address_line2":"",' +
                                            '"additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form",' +
                                            '"twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456",' +
                                            '"town":"London","op":"Send enquiry"}';

        String avaliableCourse = [
            SELECT Id, Name
            FROM Course__c 
        ][0].Name;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/courses/';
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);

        // removing the required email;
        paramsMap.remove('email');

        for (String parameter : paramsMap.keySet()) {
            request.addParameter(parameter, paramsMap.get(parameter));
        }
        for (String header : headersMap.keySet()) {
            request.addHeader(header, headersMap.get(header));
        }
        RestContext.request = request;
        RestContext.response = response;

        System.runAs(getWebSiteUser()){
            CourseAPI.createEnquiry();
            System.assertEquals(HttpStatusCode.SERVER_ERROR, response.statusCode, 'There should be server error');
            Blob responseBlob = (Blob)response.responseBody;
            System.debug(responseBlob.toString());
            //System.assertEquals(true, isEmailError(responseBlob.toString()), 'Upsert error, as email is required');
        }

        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(0, bookings.size());
    }

    @isTest
    static void createEnquiryPartherWithNotValidEmail() {
        final String HEADERS = '{"Content-Type":"application/x-www-form-urlencoded", "Referer":""}';
        final String PARAMS = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test",' + 
                                            '"duedate":"30/09/2019","firstbaby":"1","address_line1":"Test","address_line2":"",' +
                                            '"additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form",' +
                                            '"twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456",' +
                                            '"town":"London","op":"Send enquiry"}';

        String avaliableCourse = [
            SELECT Id, Name
            FROM Course__c 
        ][0].Name;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/courses/';
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);
        paramsMap.put('partner_first_name', 'Partner');
        paramsMap.put('partner_last_name', 'Partner');
        // Incorrect email
        paramsMap.put('partner_email', 'notValidEmail');

        for (String parameter : paramsMap.keySet()) {
            request.addParameter(parameter, paramsMap.get(parameter));
        }
        for (String header : headersMap.keySet()) {
            request.addHeader(header, headersMap.get(header));
        }
        RestContext.request = request;
        RestContext.response = response;

        System.runAs(getWebSiteUser()){
            CourseAPI.createEnquiry();
            System.assertEquals(HttpStatusCode.SERVER_ERROR, response.statusCode, 'There should be server error');
            Blob responseBlob = (Blob)response.responseBody;
            System.debug(responseBlob.toString());
            System.assertEquals(true, isEmailError(responseBlob.toString()), 'Upsert error');
        }

        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(0, bookings.size());
    }

    private static Boolean isEmailError(String inputErrorText){
        Boolean result = false;
        if (String.isEmpty(inputErrorText)){
            result = false;
            return result;
        }

        if (
            (inputErrorText.contains('MISSING_ARGUMENT') && inputErrorText.contains('Email not specified'))
            ||
            (inputErrorText.contains('INVALID_EMAIL_ADDRESS') && inputErrorText.contains('Email: invalid email address'))
        ) {
            result = true;
        }
        return result;        
    }


    // 2019-09-30 instead of 30/09/2019
    @isTest
    static void createEnquiryAnotherDateFormat() {
        // 2019-09-30 instead of 30/09/2019
        final String HEADERS = '{"Content-Type":"application/x-www-form-urlencoded", "Referer":""}';
        final String PARAMS = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test",' + 
                                            '"duedate":"2019-09-30","firstbaby":"1","address_line1":"Test","address_line2":"",' +
                                            '"additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form",' +
                                            '"twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456",' +
                                            '"town":"London","op":"Send enquiry"}';

        String avaliableCourse = [
            SELECT Id, Name
            FROM Course__c 
        ][0].Name;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/courses/';
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);
        for (String parameter : paramsMap.keySet()) {
            request.addParameter(parameter, paramsMap.get(parameter));
        }
        for (String header : headersMap.keySet()) {
            request.addHeader(header, headersMap.get(header));
        }
        RestContext.request = request;
        RestContext.response = response;

        System.runAs(getWebSiteUser()){
            CourseAPI.createEnquiry();
        }

        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(1, bookings.size());
    }

    @isTest
    static void createEnquiryWrondDateFormat() {
        // 30/30/2019 instead of 30/09/2019
        final String HEADERS = '{"Content-Type":"application/x-www-form-urlencoded", "Referer":""}';
        final String PARAMS = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test",' + 
                                            '"duedate":"30/30/2019","firstbaby":"1","address_line1":"Test","address_line2":"",' +
                                            '"additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form",' +
                                            '"twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456",' +
                                            '"town":"London","op":"Send enquiry"}';

        String avaliableCourse = [
            SELECT Id, Name
            FROM Course__c 
        ][0].Name;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/courses/';
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        paramsMap.put('courseId', avaliableCourse);
        for (String parameter : paramsMap.keySet()) {
            request.addParameter(parameter, paramsMap.get(parameter));
        }
        for (String header : headersMap.keySet()) {
            request.addHeader(header, headersMap.get(header));
        }
        RestContext.request = request;
        RestContext.response = response;

        System.runAs(getWebSiteUser()){
            CourseAPI.createEnquiry();
            System.assertEquals(HttpStatusCode.SERVER_ERROR, response.statusCode, 'There should be server error');
        }

        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(0, bookings.size());
    }
}