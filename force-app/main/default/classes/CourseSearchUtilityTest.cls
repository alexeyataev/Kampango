@isTest
private class CourseSearchUtilityTest {
    
    @TestSetup
    private static void SetupTestData() {
        TestDataFactory testDataFactory = TestDataFactory.getInstance();
        testDataFactory.buildBranchAccount()
                       .buildOrganizationAccount('acc5')
                       .buildPractitioner('Test')
                       .buildVenue()
                       .buildRoom()
                       .buildLicenceToPractice()
                       .buildCoursesWithSessions(2, 2);
    }

    @isTest
    static void CourseSearch_ByReference() {
        Course__c course = [
            SELECT Id 
            FROM Course__c 
            LIMIT 1
            ];

        Test.startTest();
        CourseFinderModel courseFinderModel = CourseSearchUtility.getCourseByReference(course.Id, true);
        Test.stopTest();

        System.assertNotEquals(null, courseFinderModel);                             
    }

    @isTest
    static void CourseSearch_ByBranchId() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account account = [
            SELECT Id 
            FROM Account
            WHERE RecordTypeId = :recordTypeId 
            LIMIT 1
            ];

        Test.startTest();
        List<CourseFinderModel> courseFinderModels = CourseSearchUtility.getCourseByBranch(account.Id);
        System.debug(courseFinderModels);
        Test.stopTest();

        System.assertEquals(2, courseFinderModels.size());                             
    }	 	 
}
