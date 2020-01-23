@isTest
private class CourseFinderModelTest {

    private static void setupTestData() {
        TestDataFactory testDataFactory = TestDataFactory.getInstance();
        testDataFactory.buildBranchAccount()
                       .buildOrganizationAccount('acc5')
                       .buildPractitioner('Test')
                       .buildPractitionerFeeRate()
                       .buildVenue()
                       .buildRoom()
                       .buildLicenceToPractice()
                       .buildCoursesWithSessions(1, 2);
    }

    @isTest
    static void createInstenceCourseFinderModel() {
        setupTestData();
        Course__c course = [
            SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,
                Branch__r.Name, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c, Overbooking_allowed__c,
                Fee__c, Remaining_Places__c, Branch__r.Enquiries_PSA_Phone__c, Start_Date__c, End_Date__c,
                Main_Venue__r.Name, Main_Venue__r.Town__c, Hide_From_Course_Finder__c, Main_Venue__r.Postcode__c,
                Main_Venue__r.County__c, Main_Venue__r.Location__c, Branch__r.Branch_Number__c, Title__c, Summary__c,
                (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c,
                        Specific_Attendee_Type__c, Additional_Information_with_Venue__c
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
