@isTest
private class CourseFinderModelOrderedTest {

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

    private static Course__c getCourse() {
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

        return course;
    }

    @isTest
    static void createInstanceCourseFinderModelIfOneToOne() {
        setupTestData();
        Course__c course = getCourse();
        course.Sub_Type__c = 'One to One';
        update course;
        
        Test.startTest();
        CourseFinderModelOrdered modelOrdered = new CourseFinderModelOrdered(course, Date.today());
        modelOrdered.Order = 1;
        Test.stopTest();

        System.assertNotEquals(null, modelOrdered);
        System.assertEquals(CourseFinderModelOrdered.INAPPROPRIATE_RANK, modelOrdered.Rank);
    }

    @isTest
    static void createInstanceCourseFinderModelIfBirthDueDateEqualNull() {
        setupTestData();
        Course__c course = getCourse();

        Test.startTest();
        CourseFinderModelOrdered modelOrdered = new CourseFinderModelOrdered(course, null);
        modelOrdered.Order = 1;
        Test.stopTest();

        System.assertNotEquals(null, modelOrdered);
        System.assertEquals(CourseFinderModelOrdered.INAPPROPRIATE_RANK, modelOrdered.Rank);
    }

    @isTest
    static void createInstanceCourseFinderModelIfStartDateNull() {
        setupTestData();
        Course__c course = getCourse();
        List<Session__c> sessions = [
            SELECT Date__c 
            FROM Session__c
            WHERE Course__c =: course.Id
        ];

        delete sessions;

        Course__c updatedCourse = getCourse();
        
        Test.startTest();
        CourseFinderModelOrdered modelOrdered = new CourseFinderModelOrdered(updatedCourse, Date.today());
        modelOrdered.Order = 1;
        Test.stopTest();

        System.assertNotEquals(null, modelOrdered);
        System.assertEquals(CourseFinderModelOrdered.INAPPROPRIATE_RANK, modelOrdered.Rank);
    }

    @isTest
    static void createInstanceCourseFinderModelIfEndDateNull() {
        setupTestData();
        Course__c course = getCourse();
        List<Session__c> sessions = [
            SELECT Date__c 
            FROM Session__c
            WHERE Course__c =: course.Id
        ];

        delete sessions;

        Course__c updatedCourse = getCourse();

        Test.startTest();
        CourseFinderModelOrdered modelOrdered = new CourseFinderModelOrdered(updatedCourse, Date.today());
        modelOrdered.Order = 1;
        Test.stopTest();

        System.assertNotEquals(null, modelOrdered);
        System.assertEquals(CourseFinderModelOrdered.INAPPROPRIATE_RANK, modelOrdered.Rank);
    }

    @isTest
    static void createInstanceCourseFinderModelIfNCTSignatureAntenatalIfGap30Days() {
        setupTestData();
        Course__c course = getCourse();

        course.Sub_Type__c = 'NCT Signature antenatal course';
    
        update course;

        Test.startTest();
        CourseFinderModelOrdered modelOrdered = new CourseFinderModelOrdered(course, Date.today().addDays(30));
        modelOrdered.Order = 1;
        Test.stopTest();

        System.assertNotEquals(null, modelOrdered);
        System.assertEquals(1, modelOrdered.Rank);
    }

    @isTest
    static void createInstanceCourseFinderModelIfNCTSignatureAntenatalIfGap100Days() {
        setupTestData();
        Course__c course = getCourse();

        course.Sub_Type__c = 'NCT Signature antenatal course';
    
        update course;

        Test.startTest();
        CourseFinderModelOrdered modelOrdered = new CourseFinderModelOrdered(course, Date.today().addDays(100));
        modelOrdered.Order = 1;
        Test.stopTest();

        System.assertNotEquals(null, modelOrdered);
        System.assertEquals(5, modelOrdered.Rank);
    }

    @isTest
    static void createInstanceCourseFinderModelIfBabyMassageIfGap30Days() {
        setupTestData();
        Course__c course = getCourse();

        course.Type__c = 'Postnatal';
        course.Sub_Type__c = 'NCT Baby Massage course';
        update course;

        Test.startTest();
        CourseFinderModelOrdered modelOrdered = new CourseFinderModelOrdered(course, Date.today().addDays(30));
        modelOrdered.Order = 1;
        Test.stopTest();

        System.assertNotEquals(null, modelOrdered);
        System.assertEquals(6, modelOrdered.Rank);
    }

    @isTest
    static void createInstanceCourseFinderModelIfBabyMassageIfGap100Days() {
        setupTestData();
        Course__c course = getCourse();

        course.Type__c = 'Postnatal';
        course.Sub_Type__c = 'NCT Baby Massage course';
        update course;
       
        Test.startTest();
        CourseFinderModelOrdered modelOrdered = new CourseFinderModelOrdered(course, Date.today().addDays(100));
        modelOrdered.Order = 1;
        Test.stopTest();

        System.assertNotEquals(null, modelOrdered);
        System.assertEquals(1, modelOrdered.Rank);
    }
}