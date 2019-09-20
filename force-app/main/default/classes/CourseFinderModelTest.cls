@isTest
private class CourseFinderModelTest {

    @TestSetup
    private static void setupTestData() {
        TestDataFactory testDataFactory = TestDataFactory.getInstance();
        testDataFactory.buildBranchAccount()
                       .buildOrganizationAccount('acc5')
                       .buildPractitioner('Test')
                       .buildVenue()
                       .buildRoom()
                       .buildLicenceToPractice()
                       .buildCoursesWithSessions(1, 2);
    }

    @isTest
    static void CreateInstenceCourseFinderModel() {
        Course__c course = [
            SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,  
                Branch__r.Name, Branch__r.Branch_Key__c, Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, 
                Main_Practitioner__r.Email, Main_Practitioner__r.Phone, Main_Venue__r.Name, Main_Venue__r.Town__c,
                Main_Venue__r.County__c, Main_Venue__r.Map_Link__c, 
                (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c 
                    FROM Sessions__r
                )
            FROM Course__c
            LIMIT 1
        ];

        Test.startTest();
        CourseFinderModel courseFinderModel = new CourseFinderModel(course);
        Test.stopTest();

        System.assertNotEquals(null, courseFinderModel);                             
    }
}
