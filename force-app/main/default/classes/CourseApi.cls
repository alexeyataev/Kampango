@RestResource(urlMapping='/course')
global without sharing class CourseAPI {

    global static String getCourseById() {

        return null;

    }
    global static String getCourseByBranch() {

        return null;

    }
    global static String getCourseByDateDistance() {

        return null;

    }
    @HttpPost
    global static String createEnquiry() {
        RestRequest request = RestContext.request;
        String courseNumber = CourseCreateEnquiryUtility.getCourseIdFromHeaders();
        System.debug(JSON.serialize(request.headers));
        System.debug(JSON.serialize(request.params));
        CourseCreateEnquiryUtility.createEnquiry(courseNumber, request.params);
        return null;
    }
}