@isTest
private class CourseFinderModelOrderedTest {

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
    static void createInstenceCourseFinderModel() {
        setupTestData();
        Course__c course = [
            SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,  
                Branch__r.Name, Branch__r.Branch_Key__c, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c,
                Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, Branch__r.Enquiries_PSA_Phone__c,
                Main_Practitioner__r.Email, Main_Practitioner__r.Phone, Main_Venue__r.Name, Main_Venue__r.Town__c,
                Main_Venue__r.County__c, Main_Venue__r.Location__c, Main_Venue__r.Map_Link__c,
                (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c, Specific_Attendee_Type__c 
                    FROM Sessions__r
                )
            FROM Course__c
            LIMIT 1
        ];

        Test.startTest();
        CourseFinderModelOrdered modelOrdered = new CourseFinderModelOrdered(course);
        modelOrdered.Order = 1;
        modelOrdered.Rank = 1;
        Test.stopTest();

        System.assertNotEquals(null, modelOrdered);
        System.assertEquals(1, modelOrdered.Order);
        System.assertEquals(1, modelOrdered.Rank);
    }
}