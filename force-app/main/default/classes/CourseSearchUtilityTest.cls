@isTest
private class CourseSearchUtilityTest {
    
    private static void setupTestData() {
        TestDataFactory.getInstance()
                       .buildBranchAccount()
                       .buildOrganizationAccount('acc5')
                       .buildPractitioner('Test')
                       .buildPractitionerFeeRate()
                       .buildVenue()
                       .buildRoom()
                       .buildLicenceToPractice()
                       .buildCoursesWithSessions(2, 2);

        TestDataFactory dataFactory = TestDataFactory.getInstance();
        List<Course__c> coursesToFinal = [
            SELECT Status__c, Count_of_Estimated_Travel_Costs__c, Count_of_Estimated_Venue_Costs__c, Main_Venue__c, Fee__c,
            (
                SELECT Status__c FROM Sessions__r
            )
            FROM Course__c
        ];

        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        Venue__c mainVenue = venueBuilder
                                .insertRecord(true)
                                .build();

        dataFactory.setMainVenueToCourses(mainVenue, coursesToFinal);

        for (Course__c course : coursesToFinal) {
            if (!course.Sessions__r.isEmpty()) {
                dataFactory.setSessionsToConfirmed(course.Sessions__r);   
            }
        }
        dataFactory.setCoursesWithSessionsToFinal(coursesToFinal);
    }

    private static void setupTestDataForTestingSorting() {
        
        TestDataFactory testDataFactor = TestDataFactory.getInstance();
        testDataFactor.buildBranchAccount()
                      .buildOrganizationAccount('acc5')
                      .buildPractitioner('Test')
                      .buildPractitionerFeeRate()
                      .buildVenue()
                      .buildRoom()
                      .buildLicenceToPractice()
                      .buildCoursesWithSessions(8, 2);

        List<Course__c> courses = [
            SELECT Type__c, Sub_Type__c, Status__c, Main_Venue__r.Location__c, Start_Date__c, End_Date__c,
                (
                    SELECT Date__c, Status__c FROM Sessions__r    
                )
            FROM Course__c
            LIMIT 10
        ];

        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        Venue__c mainVenue = venueBuilder
                                .insertRecord(true)
                                .build();

        testDataFactor.setMainVenueToCourses(mainVenue, courses);

        testDataFactor.setCoursesToFinalAndSessionsToConfirmed(courses);
        
        testDataFactor.setCoursesToFinal(courses);

        List<Course__c> coursesToUpdate = new List<Course__c>();
        List<Session__c> sessionsToUpdate = new List<Session__c>();
        Set<Venue__c> venuesToUpdate = new Set<Venue__c>(); 

        ChangerCourse changerCourse0 = new ChangerCourse(courses[0]);
        changerCourse0.changeType('NCT Signature Antenatal')
                    .changeLocation(Location.newInstance(50.501, -0.101))
                    .changeStartDate(Date.today().addDays(5))
                    .changeEndDate(Date.today().addDays(30));
        coursesToUpdate.add(changerCourse0.course);
        sessionsToUpdate.addAll(changerCourse0.sessions);
        venuesToUpdate.add(changerCourse0.venue);

        ChangerCourse changerCourse1 = new ChangerCourse(courses[1]);
        changerCourse1.changeType('NCT Essentials Antenatal')
                    .changeLocation(Location.newInstance(50.501, -0.101))
                    .changeStartDate(Date.today().addDays(10))
                    .changeEndDate(Date.today().addDays(40));
        coursesToUpdate.add(changerCourse1.course);
        sessionsToUpdate.addAll(changerCourse1.sessions);
        venuesToUpdate.add(changerCourse1.venue);

        ChangerCourse changerCourse2 = new ChangerCourse(courses[2]);
        changerCourse2.changeType('NCT Antenatal Refresher')
                    .changeLocation(Location.newInstance(50.501, -0.101))
                    .changeStartDate(Date.today().addDays(70))
                    .changeEndDate(Date.today().addDays(100));
        coursesToUpdate.add(changerCourse2.course);
        sessionsToUpdate.addAll(changerCourse2.sessions);
        venuesToUpdate.add(changerCourse2.venue);

        ChangerCourse changerCourse3 = new ChangerCourse(courses[3]);
        changerCourse3.changeType('Twins and Multiples')
                    .changeLocation(Location.newInstance(50.501, -0.101))
                    .changeStartDate(Date.today().addDays(1))
                    .changeEndDate(Date.today().addDays(20));
        coursesToUpdate.add(changerCourse3.course);
        sessionsToUpdate.addAll(changerCourse3.sessions);
        venuesToUpdate.add(changerCourse3.venue);

        ChangerCourse changerCourse4 = new ChangerCourse(courses[4]);
        changerCourse4.changeType('Waterbirth')
                    .changeLocation(Location.newInstance(50.501, -0.101))
                    .changeStartDate(Date.today().addDays(-25))
                    .changeEndDate(Date.today().addDays(50));
        coursesToUpdate.add(changerCourse4.course);
        sessionsToUpdate.addAll(changerCourse4.sessions);
        venuesToUpdate.add(changerCourse4.venue);

        ChangerCourse changerCourse5 = new ChangerCourse(courses[5]);
        changerCourse5.changeType('NCT Essentials Antenatal')
                    .changeLocation(Location.newInstance(50.501, -0.101))
                    .changeStartDate(Date.today().addDays(1))
                    .changeEndDate(Date.today().addDays(30));
        coursesToUpdate.add(changerCourse5.course);
        sessionsToUpdate.addAll(changerCourse5.sessions);
        venuesToUpdate.add(changerCourse5.venue);

        ChangerCourse changerCourse6 = new ChangerCourse(courses[6]);
        changerCourse6.changeType('NCT Essentials Antenatal')
                    .changeLocation(Location.newInstance(50.501, -0.101))
                    .changeStartDate(Date.today().addDays(5))
                    .changeEndDate(Date.today().addDays(35));
        coursesToUpdate.add(changerCourse6.course);
        sessionsToUpdate.addAll(changerCourse6.sessions);
        venuesToUpdate.add(changerCourse6.venue);

        ChangerCourse changerCourse7 = new ChangerCourse(courses[7]);
        changerCourse7.changeType('Early Days')
                    .changeLocation(Location.newInstance(50.501, -0.101))
                    .changeStartDate(Date.today().addDays(-5))
                    .changeEndDate(Date.today().addDays(30));
        coursesToUpdate.add(changerCourse7.course);
        sessionsToUpdate.addAll(changerCourse7.sessions);
        venuesToUpdate.add(changerCourse7.venue);

        System.runAs(TestDataFactory.createSysAdminUser()) {
            update coursesToUpdate;
            update sessionsToUpdate;
            update new List<Venue__c>(venuesToUpdate);
        }
                 
    }

    @isTest
    static void courseSearchById() {
        setupTestData();

        Course__c course = [
            SELECT Name
            FROM Course__c
            LIMIT 1
        ];

        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCourseById(course.Name);
        Test.stopTest();
        CourseFinderModel model = (CourseFinderModel)System.JSON.deserialize(response.responseBody.toString(), CourseFinderModel.class );
        
        System.assertEquals(200, response.statusCode);
        System.assertEquals(course.Name, model.Id);
    }

    @isTest
    static void courseSearchByIdIfFromWebsiteFalse () {
        setupTestData();

        Course__c course = [
            SELECT Name
            FROM Course__c
            LIMIT 1
        ];

        Test.startTest();
        Course__c recievedCourse = CourseSearchUtility.getCourseById(course.Name, false);
        Test.stopTest();
        
        System.assertEquals(course.Name, recievedCourse.Name);
    }

    @isTest
    static void courseSearchByIdIfNoCourse() {
        setupTestData();

        Course__c course = [
            SELECT Id 
            FROM Course__c 
            LIMIT 1
        ];
        delete course;
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCourseById(course.Id);
        Test.stopTest();

        System.assertEquals(404, response.statusCode);                             
    }

    @isTest
    static void courseSearchByBranchId() {
        setupTestData();

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        
        Account account = [
            SELECT Id 
            FROM Account
            WHERE RecordTypeId = :recordTypeId 
            LIMIT 1
        ];

        account.Branch_Number__c = '123';
        update account;

        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByBranch(account.Branch_Number__c);
        Test.stopTest();
        
        CoursesBranchModel branchModel = (CoursesBranchModel)JSON.deserialize(response.responseBody.toString(), CoursesBranchModel.class);
        System.assertEquals(200, response.statusCode);
        System.assertEquals(2, branchModel.Courses.size(), 'There should be 2 Course records with at least 1 allocated Session record');                             
    }

    @isTest
    static void courseSearchByBranchIdIfFromWebsiteFalse () {
        setupTestData();

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        
        Account account = [
            SELECT Id 
            FROM Account
            WHERE RecordTypeId = :recordTypeId 
            LIMIT 1
        ];

        account.Branch_Number__c = '123';
        update account;

        Test.startTest();
        List<Course__c> courses = CourseSearchUtility.getCoursesByBranch(account.Branch_Number__c, false);
        Test.stopTest();

        System.assertEquals(2, courses.size(), 'There should be 2 Course records with at least 1 allocated Session record');
        System.assertEquals(account.Id, courses[0].Branch__c);
    }

    @isTest
    static void courseSearchByBranchIdIfNoBranchCourses() {
        setupTestData();
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
    
        Account account = [
            SELECT Id 
            FROM Account
            WHERE RecordTypeId = :recordTypeId 
            LIMIT 1
        ];

        account.Branch_Number__c = '123';
        update account;        
            
        List<Course__c> courses = [
            SELECT Id
            FROM Course__c
            WHERE Branch__c = :account.Id
        ];

        delete courses;

        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByBranch(account.Branch_Number__c);
        Test.stopTest();

        System.assertEquals(404, response.statusCode);                             
    }	 	 	 

    @isTest
    static void courseSearchByLocationParams(){
        Map<String, String> params = null;
        CourseSearchUtility.getCoursesByDateDistance(params);

        params = new Map<String, String>{'location' => ''};
        CourseSearchUtility.getCoursesByDateDistance(params);

        params.put('birth', 'a');
        CourseSearchUtility.getCoursesByDateDistance(params);

        params.put('location', '50.a,-0.1');
        CourseSearchUtility.getCoursesByDateDistance(params);

        params.put('location', '50.5,-0.1');
        CourseSearchUtility.getCoursesByDateDistance(params);

        params.put('radius', '');
        CourseSearchUtility.getCoursesByDateDistance(params);

        params.put('radius', 'b');
        CourseSearchUtility.getCoursesByDateDistance(params);

        params.put('radius', '50');
        RestResponse response = CourseSearchUtility.getCoursesByDateDistance(params);

        System.assertEquals(404, response.statusCode);
    }

    private static void addLocationToVenue(){
        List<Venue__c> venues = [
            SELECT Id, Location__c
            FROM
            Venue__c
        ];

        System.assertEquals(2, venues.size());
        Location loc = Location.newInstance(50.501, -0.101);
        venues[0].Location__latitude__s = loc.latitude;
        venues[0].Location__longitude__s = loc.longitude;
        update venues;
    }

    @isTest
    static void courseSearchByLocation() {
        setupTestData();
        addLocationToVenue();

        Map<String, String> params = new Map<String, String>{
            'location' => '50.5,-0.1',
            'radius' => '50'
        };
        RestResponse response = CourseSearchUtility.getCoursesByDateDistance(params);

        System.assertEquals(404, response.statusCode);
    }

    @isTest
    static void courseSearchByLocationIfFromWebsiteFalse() {
        setupTestData();
        addLocationToVenue();

        List<Course__c> courses = CourseSearchUtility.getCoursesByDateDistance(Location.newInstance(50.5, -0.1), 50, null, false);

        System.assertEquals(0, courses.size());
    }

    @isTest
    static void checkCourseSortingIfNoBirthDuoDate() {
        setupTestDataForTestingSorting();

        Map<String, String> params = new Map<String, String>{
            'location' => '50.5,-0.1'
        };
        
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByDateDistance(params);
        Test.stopTest();
        
        CoursesDateDistanceModel sortedModel = (CoursesDateDistanceModel)JSON.deserialize(response.responseBody.toString(), CoursesDateDistanceModel.class);

        System.assertEquals(1, sortedModel.Courses.size());
        System.assertEquals(4, sortedModel.LowestRankIncluded);
        System.assertEquals(4, sortedModel.SuggestedLowestRank);
        System.assertEquals(4, sortedModel.Courses[0].Rank);
        System.assertEquals(1, sortedModel.Courses[0].Order);
                       
    }

    @isTest
    static void checkCourseSortingIfBirthDuoDateIsToday() {
        setupTestDataForTestingSorting();

        Map<String, String> params = new Map<String, String>{
            'location' => '50.5,-0.1',
            'birth' => String.valueOf(Date.today())
        };
        
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByDateDistance(params);
        Test.stopTest();
        
        System.assertEquals(404, response.statusCode);                     
    }

    @isTest
    static void checkCourseSortingIfBirthDuoDateIsTodayAddDays30() {
        setupTestDataForTestingSorting();

        Map<String, String> params = new Map<String, String>{
            'location' => '50.5,-0.1',
            'birth' => String.valueOf(Date.today().addDays(30))
        };
        
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByDateDistance(params);
        Test.stopTest();
        
        CoursesDateDistanceModel sortedModel = (CoursesDateDistanceModel)JSON.deserialize(response.responseBody.toString(), CoursesDateDistanceModel.class);
        
        System.assertEquals(1, sortedModel.Courses.size());
        System.assertEquals(4, sortedModel.LowestRankIncluded);
        System.assertEquals(4, sortedModel.SuggestedLowestRank);
        System.assertEquals(4, sortedModel.Courses[0].Rank);
        System.assertEquals(1, sortedModel.Courses[0].Order);                     
    }

    @isTest
    static void checkCourseSortingIfBirthDuoDateIsTodayAddDays60() {
        setupTestDataForTestingSorting();

        Map<String, String> params = new Map<String, String>{
            'location' => '50.5,-0.1',
            'birth' => String.valueOf(Date.today().addDays(60))
        };
        
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByDateDistance(params);
        Test.stopTest();
        
        CoursesDateDistanceModel sortedModel = (CoursesDateDistanceModel)JSON.deserialize(response.responseBody.toString(), CoursesDateDistanceModel.class);

        System.assertEquals(5, sortedModel.Courses.size());
        System.assertEquals(2, sortedModel.LowestRankIncluded);
        System.assertEquals(2, sortedModel.SuggestedLowestRank);
        System.assertEquals(1, sortedModel.Courses[0].Rank);
        System.assertEquals(1, sortedModel.Courses[0].Order);
        System.assertEquals(5, sortedModel.Courses[4].Order);                      
    }

    @isTest
    static void checkCourseSortingIfBirthDuoDateIsTodayAddDays60Radius10() {
        setupTestDataForTestingSorting();

        Map<String, String> params = new Map<String, String>{
            'location' => '50.5,-0.1',
            'birth' => String.valueOf(Date.today().addDays(60)),
            'radius'=> '10'
        };
        
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByDateDistance(params);
        Test.stopTest();
        
        CoursesDateDistanceModel sortedModel = (CoursesDateDistanceModel)JSON.deserialize(response.responseBody.toString(), CoursesDateDistanceModel.class);

        System.assertEquals(5, sortedModel.Courses.size());
        System.assertEquals(2, sortedModel.LowestRankIncluded);
        System.assertEquals(2, sortedModel.SuggestedLowestRank);
        System.assertEquals(1, sortedModel.Courses[0].Rank);
        System.assertEquals(1, sortedModel.Courses[0].Order);
        System.assertEquals(5, sortedModel.Courses[4].Order);                      
    }

    @isTest
    static void checkCourseSortingIfBirthDuoDateIsTodayAddDays60Radius0() {
        setupTestDataForTestingSorting();

        Map<String, String> params = new Map<String, String>{
            'location' => '50.5,-0.1',
            'birth' => String.valueOf(Date.today().addDays(60)),
            'radius'=> '0'
        };
        
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByDateDistance(params);
        Test.stopTest();
        
        System.assertEquals(500, response.statusCode); 
                     
    }

    @isTest
    static void checkCourseSortingIfBirthDuoDateIsTodayAddDays60Radius20() {
        setupTestDataForTestingSorting();

        Map<String, String> params = new Map<String, String>{
            'location' => '50.5,-0.1',
            'birth' => String.valueOf(Date.today().addDays(60)),
            'radius'=> '20'
        };
        
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByDateDistance(params);
        Test.stopTest();
        
        CoursesDateDistanceModel sortedModel = (CoursesDateDistanceModel)JSON.deserialize(response.responseBody.toString(), CoursesDateDistanceModel.class);

        System.assertEquals(5, sortedModel.Courses.size());
        System.assertEquals(2, sortedModel.LowestRankIncluded);
        System.assertEquals(2, sortedModel.SuggestedLowestRank);
        System.assertEquals(1, sortedModel.Courses[0].Rank);
        System.assertEquals(1, sortedModel.Courses[0].Order);
        System.assertEquals(5, sortedModel.Courses[4].Order);                      
    }

    @isTest
    static void checkCourseSortingIfBirthDuoDateIsTodayAddDays60Radius30() {
        setupTestDataForTestingSorting();

        Map<String, String> params = new Map<String, String>{
            'location' => '50.5,-0.1',
            'birth' => String.valueOf(Date.today().addDays(60)),
            'radius'=> '30'
        };
        
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByDateDistance(params);
        Test.stopTest();
        
        CoursesDateDistanceModel sortedModel = (CoursesDateDistanceModel)JSON.deserialize(response.responseBody.toString(), CoursesDateDistanceModel.class);

        System.assertEquals(5, sortedModel.Courses.size());
        System.assertEquals(2, sortedModel.LowestRankIncluded);
        System.assertEquals(2, sortedModel.SuggestedLowestRank);
        System.assertEquals(1, sortedModel.Courses[0].Rank);
        System.assertEquals(1, sortedModel.Courses[0].Order);
        System.assertEquals(5, sortedModel.Courses[4].Order);                      
    }

    private class ChangerCourse {
        private Course__c course;
        private List<Session__c> sessions = new List<Session__c>();
        private Venue__c venue;

        private ChangerCourse(Course__c course) {
            this.course = course;
        }

        private ChangerCourse changeEndDate(Date endDate) {
            course.Sessions__r[course.Sessions__r.size() - 1].Date__c = endDate;
            sessions.add(course.Sessions__r[course.Sessions__r.size() - 1]);
            return this;
        }

        private ChangerCourse changeStartDate(Date startDate) {
            course.Sessions__r[0].Date__c = startDate;
            sessions.add(course.Sessions__r[0]);
            return this;
        }

        private ChangerCourse changeType(String type) {
            List<String> postnatalCourseTypes = new List<String>{
                'Early Days',
                'Introducing Solids',
                'Baby Massage'
            };
            if (postnatalCourseTypes.contains(type)) {
                course.Type__c = 'Postnatal';
            }
            course.Sub_Type__c = type;

            return this;
        }

        private ChangerCourse changeLocation(Location loc) {           
            venue = [
                SELECT Location__c
                FROM Venue__c
                WHERE Id = :course.Main_Venue__c];

            venue.Location__latitude__s = loc.latitude;
            venue.Location__longitude__s = loc.longitude;

            return this;
        }
    }
}