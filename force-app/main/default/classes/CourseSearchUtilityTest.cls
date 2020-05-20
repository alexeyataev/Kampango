@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #38 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class CourseSearchUtilityTest {

    private static final Integer COURSES_TO_BUILD = 8;
    private static final String SESSION_DELIVERY_TYPE_VIRTUAL_SUPPORT = 'Virtual Support';
    private static final Integer SESSIONS_TO_BUILD_PER_COURSE = 2;

    @TestSetup
    private static void setupTestDataForTestingSorting() {
        
        TestDataFactory testDataFactoryInstance = TestDataFactory.getInstance();
        testDataFactoryInstance .buildBranchAccount()
                                .buildOrganizationAccount('acc5')
                                .buildPractitioner('Test')
                                .buildPractitionerFeeRate()
                                .buildVenue()
                                .buildRoom()
                                .buildLicenceToPractice()
                                .buildCoursesWithSessions(COURSES_TO_BUILD, SESSIONS_TO_BUILD_PER_COURSE)
                                .buildVirtualSupportSession(SESSION_DELIVERY_TYPE_VIRTUAL_SUPPORT, 1);

        List<Course__c> courses = [
            SELECT Type__c, Sub_Type__c, Status__c, Main_Venue__c, Main_Venue__r.Location__c, Start_Date__c, End_Date__c,
                (
                    SELECT Date__c, Status__c FROM Sessions__r    
                )
            FROM Course__c
            LIMIT :COURSES_TO_BUILD
        ];

        Venue__c mainVenue = [SELECT Id, Name, Location__c FROM Venue__c WHERE Id = :courses[0].Main_Venue__c LIMIT 1];

        List<Course__c> coursesToUpdate = new List<Course__c>();
        List<Session__c> sessionsToUpdate = new List<Session__c>();

        ChangerCourse changerCourse0 = new ChangerCourse(courses[0]);
        changerCourse0.changeType('NCT Signature antenatal course')
                    .changeStartDate(Date.today().addDays(5))
                    .changeEndDate(Date.today().addDays(30));
        coursesToUpdate.add(changerCourse0.course);
        sessionsToUpdate.addAll(changerCourse0.sessions);

        ChangerCourse changerCourse1 = new ChangerCourse(courses[1]);
        changerCourse1.changeType('NCT Essentials antenatal course')
                    .changeStartDate(Date.today().addDays(10))
                    .changeEndDate(Date.today().addDays(40));
        coursesToUpdate.add(changerCourse1.course);
        sessionsToUpdate.addAll(changerCourse1.sessions);

        ChangerCourse changerCourse2 = new ChangerCourse(courses[2]);
        changerCourse2.changeType('NCT Antenatal refresher course')
                    .changeStartDate(Date.today().addDays(70))
                    .changeEndDate(Date.today().addDays(100));
        coursesToUpdate.add(changerCourse2.course);
        sessionsToUpdate.addAll(changerCourse2.sessions);

        ChangerCourse changerCourse3 = new ChangerCourse(courses[3]);
        changerCourse3.changeType('NCT Twins and Multiples workshop')
                    .changeStartDate(Date.today().addDays(1))
                    .changeEndDate(Date.today().addDays(20));
        coursesToUpdate.add(changerCourse3.course);
        sessionsToUpdate.addAll(changerCourse3.sessions);

        ChangerCourse changerCourse4 = new ChangerCourse(courses[4]);
        changerCourse4.changeType('NCT Waterbirth workshop')
                    .changeStartDate(Date.today().addDays(-25))
                    .changeEndDate(Date.today().addDays(50));
        coursesToUpdate.add(changerCourse4.course);
        sessionsToUpdate.addAll(changerCourse4.sessions);

        ChangerCourse changerCourse5 = new ChangerCourse(courses[5]);
        changerCourse5.changeType('NCT Essentials antenatal course')
                    .changeStartDate(Date.today().addDays(1))
                    .changeEndDate(Date.today().addDays(30));
        coursesToUpdate.add(changerCourse5.course);
        sessionsToUpdate.addAll(changerCourse5.sessions);

        ChangerCourse changerCourse6 = new ChangerCourse(courses[6]);
        changerCourse6.changeType('NCT Essentials antenatal course')
                    .changeStartDate(Date.today().addDays(5))
                    .changeEndDate(Date.today().addDays(35));
        coursesToUpdate.add(changerCourse6.course);
        sessionsToUpdate.addAll(changerCourse6.sessions);

        ChangerCourse changerCourse7 = new ChangerCourse(courses[7]);
        changerCourse7.changeType('NCT Early Days course')
                    .changeStartDate(Date.today().addDays(-5))
                    .changeEndDate(Date.today().addDays(30));
        coursesToUpdate.add(changerCourse7.course);
        sessionsToUpdate.addAll(changerCourse7.sessions);

        System.runAs(TestDataFactory.createSysAdminUser()) {
            update coursesToUpdate;
            update sessionsToUpdate;
        }
    
        testDataFactoryInstance.setCoursesToFinalAndSessionsToConfirmed(courses);
        
        testDataFactoryInstance.setCoursesToFinal(courses);                
    }

    @isTest
    static void courseSearchById_WithValidCourseId_CourseCorrectlyReturned() {

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
    static void courseSearchByIdIfFromWebsiteFalse_WithValidCourseId_CourseCorrectlyReturned () {

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
    static void courseSearchById_WithDeletedCourseId_CourseCorrectlyReturned() {

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
    static void courseSearchByBranchId_WithValidBranchId_CorrectCoursesReturned() {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        
        Account account = [
            SELECT Id 
            FROM Account
            WHERE RecordTypeId = :recordTypeId 
            LIMIT 1
        ];

        account.Branch_Number__c = '123';
        update account;

        List<Course__c> expectedCourses = [SELECT Id FROM Course__c WHERE Start_Date__c > TODAY LIMIT :COURSES_TO_BUILD];

        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByBranch(account.Branch_Number__c);
        Test.stopTest();
        
        CoursesBranchModel branchModel = (CoursesBranchModel)JSON.deserialize(response.responseBody.toString(), CoursesBranchModel.class);
        System.assertEquals(200, response.statusCode);
        System.assertEquals(expectedCourses.size(), branchModel.Courses.size(), 'There should be ' + expectedCourses.size() + ' Course records with at least 1 allocated Session record');                             
    }

    @isTest
    static void courseSearchByBranchIdIfFromWebsiteFalse_WithValidBranchId_CorrectCoursesReturned () {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        
        Account account = [
            SELECT Id 
            FROM Account
            WHERE RecordTypeId = :recordTypeId 
            LIMIT 1
        ];

        account.Branch_Number__c = '123';
        update account;

        List<Course__c> expectedCourses = [SELECT Id FROM Course__c LIMIT :COURSES_TO_BUILD];

        Test.startTest();
        List<Course__c> courses = CourseSearchUtility.getCoursesByBranch(account.Branch_Number__c, false);
        Test.stopTest();

        System.assertEquals(expectedCourses.size(), courses.size(), 'There should be ' + expectedCourses.size() + ' Course records with at least 1 allocated Session record');
        System.assertEquals(account.Id, courses[0].Branch__c);
    }

    @isTest
    static void courseSearchByBranchId_WithValidBranchIdButNoCoursesAtBranch_NoCoursesReturned() {
        
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
    static void courseSearchByDateAndDistance_InvalidParams_NoCoursesReturned(){
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

    @isTest
    static void courseSearchByLocation_NoCoursesInRegion_NoCoursesReturned() {

        Map<String, String> params = new Map<String, String>{
            'location' => '51.5,-0.1',
            'radius' => '50'
        };
        RestResponse response = CourseSearchUtility.getCoursesByDateDistance(params);

        System.assertEquals(404, response.statusCode);
    }

    @isTest
    static void courseSearchByLocationIfFromWebsiteFalse_NoCoursesInRegion_NoCoursesReturned() {

        CourseSearchUtility.LocationRequestParameters params = new CourseSearchUtility.LocationRequestParameters(Location.newInstance(51.5, -0.1), 50);
        List<Course__c> courses = CourseSearchUtility.getCoursesByDateDistance(params, null, false);

        System.assertEquals(0, courses.size());
    }

    @isTest
    static void checkCourseSorting_IfNoBirthDueDate_SortedByDistance() {

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
    static void checkCourseSorting_IfBirthDueDateIsToday_CorrectlyOrdered() {

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
    static void checkCourseSorting_IfBirthDueDateIsIn30Days_CorrectlyOrdered() {

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
    static void checkCourseSorting_IfBirthDueDateIsIn60Days_CorrectlyOrdered() {

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
    static void checkCourseSorting_IfBirthDueDateIsIn60DaysSearchRadius10_CorrectlyOrdered() {

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
    static void checkCourseSorting_IfBirthDueDateIsIn60DaysSearchRadius0_NoCourses() {

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
    static void checkCourseSorting_IfBirthDueDateIsIn60DaysSearchRadius20_CorrectlyOrdered() {

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
    static void checkCourseSortingIfBirthDueDateIsIn60DaysSearchRadius30_CorrectlyOrdered() {

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

    @isTest
    static void courseSearchById_WithVirtualSession_FinderCourseOnlineTrue() {

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
        
        System.assertEquals(model.Online, true);
    }

    private class ChangerCourse {
        private Course__c course;
        private List<Session__c> sessions = new List<Session__c>();

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
                'NCT Early Days course',
                'NCT Introducing Solid Foods workshop',
                'NCT Baby Massage course'
            };
            if (postnatalCourseTypes.contains(type)) {
                course.Type__c = 'Postnatal';
            }
            course.Sub_Type__c = type;

            return this;
        }
    }
}