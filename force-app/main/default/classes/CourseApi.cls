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
        } else if (isByLocation(paramsSet)) {
            // CourseSearchUtility.getCourseByDateDistance(next params viewports, radius, location birth);
        } else {
            RestContext.response.statusCode = 404;
            RestContext.response.responseBody = Blob.valueOf('{ "Error" : course does not exist }');
        }
        
        RestContext.response.addHeader('Content-Type', 'application/json');
    }
    
    private static Boolean isByLocation(Set<String> paramsSet){
        Boolean result = false;

        if (
            paramsSet.contains('viewports') &&
            paramsSet.contains('radius') &&
            paramsSet.contains('location') &&
            paramsSet.contains('birth')
        ) {
        	result = true;
        }

        return result;
    }
    
    @HttpPost
    global static void createEnquiry() {
        RestRequest request = RestContext.request;
        String courseNumber = CourseCreateEnquiryUtility.getCourseIdFromHeaders();
        CourseCreateEnquiryUtility.createEnquiry(courseNumber, request.params);
    }
}