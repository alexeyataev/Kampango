@isTest
public without sharing class CourseApiTest {

    private static String strURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/courses';
    private static String methodGet = 'GET';

    @TestSetup
    private static void setupTestData() {
        TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildMainVenue()
            .buildOrganizationAccount('acc5')
            .buildPractitioner('Test')
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCoursesWithSessions(2, 2);
        
        List<Course__c> coursesToFinal = [SELECT Status__c FROM Course__c];
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory.setCoursesToFinal(coursesToFinal);
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
        CourseApi.getCourseData();
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
        CourseApi.getCourseData();
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
        CourseApi.getCourseData();
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

        RestRequest req = new RestRequest();
        req.requestURI = strURI;
        req.httpMethod = methodGet;
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('branch', account.Id);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CourseApi.getCourseData();
        Test.stopTest();

        List<Object> responseObjects = (List<Object>)JSON.deserializeUntyped(res.responseBody.toString());

        System.assertEquals(200, res.statusCode);
        System.assertEquals(1, responseObjects.size());
      
    }      


    private final static String HEADERS = '{"Content-Type":"application/x-www-form-urlencoded", "Referer":""}';
    private final static String PARAMS = '{"email":"test@test.test","hearaboutus":"NCT website or event","first_name":"Test",' + 
                                         '"duedate":"30/09/2019","firstbaby":"1","address_line1":"Test","address_line2":"",' +
                                         '"additioninfo":"","title":"Mr","last_name":"Test","form_id":"course_enquiry_form",' +
                                         '"twinsexpected":"0","county":"UK","postcode":"533537","mobile":"+442072343456",' +
                                         '"town":"London","op":"Send enquiry"}';

    private static void prepareSetupData() {
        TestDataFactory.getInstance()
            .buildOrganizationAccount('acct1')
            .buildBranchAccount()
            .buildPractitioner('Practitioner')
            .buildLicenceToPractice()
            .buildCourse();
    }

    @isTest
    static void createEnquiry() {
        prepareSetupData();
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
        Test.startTest();
        CourseAPI.createEnquiry();
        Test.stopTest();
        List<Booking__c> bookings = [
            SELECT Name
            FROM Booking__c
        ];
        System.assertEquals(1, bookings.size());
    }
}