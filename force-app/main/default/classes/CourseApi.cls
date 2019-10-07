@RestResource(urlMapping='/courses/*')
global class CourseApi {
    @HttpGet
    global static void getCourseStaff() {
        Set <String> paramsSet = RestContext.request.params.keySet();

        if (paramsSet.contains('course')){
            String courseId = RestContext.request.params.get('course');
            RestResponse response = CourseSearchUtility.getCourseById(courseId);
            RestContext.response.statusCode = response.statusCode;
            RestContext.response.responseBody = response.responseBody;
        } else if (paramsSet.contains('branch')) {
            String branchId = RestContext.request.params.get('branch');
            RestResponse response = CourseSearchUtility.getCoursesByBranch(branchId);
            RestContext.response.statusCode = response.statusCode;
            RestContext.response.responseBody = response.responseBody;
        } else if (paramsSet.contains('location')) {
            RestResponse response = CourseSearchUtility.getCoursesByDateDistance(RestContext.request.params);
            RestContext.response.statusCode = response.statusCode;
            RestContext.response.responseBody = response.responseBody;
        } else {
            RestContext.response.statusCode = 404;
            RestContext.response.responseBody = Blob.valueOf(System.Label.CourseAPIcourseNotExists);
        }
        
        RestContext.response.addHeader('Content-Type', 'application/json');
    }
    
    @HttpPost
    global static void createEnquiry() {
        RestRequest request = RestContext.request;
        String courseNumber = CourseCreateEnquiryUtility.getCourseName(request.params);
        try {
            CourseCreateEnquiryUtility.createEnquiry(courseNumber, request.params);      
        } catch (CourseCreateEnquiryUtility.CreateEnquiryException ex) {
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf(ex.getMessage());
        }
    }
}