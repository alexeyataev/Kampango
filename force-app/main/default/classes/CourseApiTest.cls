@isTest
public class CourseApiTest {

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
        Id avaliableCourse = [
            SELECT Id 
            FROM Course__c 
            WHERE Remaining_Places__c > 0
        ][0].Id;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/courses/';
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(PARAMS, Map<String, String>.class);
        Map<String, String> headersMap = (Map<String, String>)JSON.deserialize(HEADERS, Map<String, String>.class);
        headersMap.put('Referer', 'https://www.nct.org.uk/course/' + avaliableCourse);
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