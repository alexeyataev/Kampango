@isTest
public without sharing class TestDataFactory {

    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String PRACTITIONER_RECORDTYPE_NAME  = 'Practitioner';
    private static final String PRACTITIONER_LASTNAME = 'Practitioner';
    private static final String PRACTITIONER_LASTNAME_TWO = 'Practitioner2';
    private static final String PRACTITIONER_USERNAME = 'ncttest@test.com';

    public static List<Course__c> courses = new List<Course__c>();
    public static List<Session__c> sessions = new List<Session__c>();

    private Account account;
    private Contact practitioner;
    private Course_Assignment__c courseAssignment;
    private Venue__c venue;
    private Room__c room;
    private Licence_To_Practice__c licenceToPractice;
    private Course__c course;
    private Session__c session;

    private static TestDataFactory instance;

    public static TestDataFactory getInstance() {
        if (instance == NULL) {
            instance = new TestDataFactory();
        }
        return instance;
    }

    public TestDataFactory buildBranchAccount() {
        TestAccountBuilder accountBranchBuilder = new TestAccountBuilder();
        account =  accountBranchBuilder
            .withRecordType('Branch')
            .insertRecord(true)
            .build();
        return this;
    }
    public TestDataFactory buildPractitioner() {
        TestContactBuilder practitionerContactBuilder = new TestContactBuilder();
        practitioner = practitionerContactBuilder
            .withRecordType(PRACTITIONER_RECORDTYPE_NAME)
            .withAccount(account)
            .withLastName(PRACTITIONER_LASTNAME)
            .insertRecord(true)
            .build();
        return this;
    }
    public TestDataFactory buildPractitionerTwo() {
        TestContactBuilder practitionerContactBuilder = new TestContactBuilder();
        practitionerContactBuilder
            .withRecordType(PRACTITIONER_RECORDTYPE_NAME)
            .withAccount(account)
            .withLastName(PRACTITIONER_LASTNAME_TWO)
            .insertRecord(true)
            .build();
        return this;
    }
    public TestDataFactory buildVenue() {
        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        venue = venueBuilder
            .insertRecord(true)
            .build();
        return this;
    }
    public TestDataFactory buildRoom() {
        TestRoomBuilder roomBuilder = new TestRoomBuilder();
        room = roomBuilder
            .withVenue(venue)
            .insertRecord(true)
            .build();
        return this;
    }
    public TestDataFactory buildLicenceToPractice() {
        TestLicenceToPracticeBuilder licenceToPracticeBuilder = new TestLicenceToPracticeBuilder();
        licenceToPractice = licenceToPracticeBuilder
            .withContact(practitioner)
            .insertRecord(true)
            .build();
        return this;
    }
    public TestDataFactory buildCourse() {
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        course = courseBuilder
            .withAccount(account)
            .withPractitioner(practitioner)
            .withLicenceToPractice(licenceToPractice)
            .insertRecord(true)
            .build();
        return this;
    }
    public TestDataFactory buildCourseAssignment() {
        TestCourseAssignmentBuilder courseAssignmentBuilder = new TestCourseAssignmentBuilder();
        courseAssignment = courseAssignmentBuilder
            .withCourse(course)
            .insertRecord(true)
            .build();
        return this;
    }
    public TestDataFactory buildSession() {
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        session = sessionBuilder
            .withCourse(course)
            .withVenue(venue)
            .withRoom(room)
            .withStatus(SESSION_PROVISIONAL_STATUS)
            .withPractitioner(practitioner)
            .withPractitionerLicence(licenceToPractice)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildEstimatedCosts() {
        TestEstimatedCostsBuilder estimatedCostsBuilder = new TestEstimatedCostsBuilder();
        estimatedCostsBuilder
            .withCourse(course)
            .insertRecord(true)
            .build();
        estimatedCostsBuilder
            .withCourse(course)
            .withType('Venue')
            .insertRecord(true)
            .build();
        estimatedCostsBuilder
            .withCourse(course)
            .withType('Practitioner Fee')
            .insertRecord(true)
            .build();
        return this;
    }


    public TestDataFactory buildCoursesWithSessions(Integer numberOfCourses, Integer numberOfSessions) {
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        for(Integer i = 0; i < numberOfCourses; i++){
            courses.add(courseBuilder
                .withAccount(account)
                .withPractitioner(practitioner)
                .withLicenceToPractice(licenceToPractice)
                .insertRecord(true)
                .build());
        }

        for(Integer i = 0; i < numberOfCourses; i++) {
            TestEstimatedCostsBuilder estimatedCostsBuilder = new TestEstimatedCostsBuilder();
            estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Travel')
                .insertRecord(true)
                .build();
            estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Venue')
                .insertRecord(true)
                .build();
            estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Practitioner Fee')
                .insertRecord(true)
                .build();
        }

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();

        for(Integer i = 0; i < numberOfSessions; i++) {
            sessions.add(sessionBuilder
                .withCourse(courses[i / 2])
                .withVenue(venue)
                .withRoom(room)
                .withStatus('Provisional')
                .withPractitioner(practitioner)
                .withPractitionerLicence(licenceToPractice)
                .insertRecord(true)
                .build());
        }
        return this;
    }
    public static User createSysAdminUser() {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User sysAdminUser = new User(
            alias = 'sysAdmin',
            email = 'sysAdmin.email@fakemail.com',
            emailencodingkey = 'UTF-8',
            lastname = 'NCTtest',
            languagelocalekey = Userinfo.getLanguage(),
            localesidkey = Userinfo.getLocale(),
            profileid = sysAdminProfile.Id,
            timezonesidkey = Userinfo.getTimeZone().getID(),
            username = 'NCTtest.sysAdmin.username@nct.com'
        );

        insert sysAdminUser;
        return sysAdminUser;
    }

    public static User ConvertPractitionerToPartnerCommunityUser(String lastName) {
        User admin = TestDataFactory.createSysAdminUser();
        UserRole testRole;
        User portalAccountOwner;

        System.runAs(admin) {
            testRole = new UserRole(Name = 'testRole');
            insert testRole;

            portalAccountOwner = new User(
                UserRoleId = testRole.Id,
                ProfileId = [SELECT Id FROM Profile WHERE name = 'System Administrator'].Id,
                Username = 'nctTestNct@test.com',
                Alias = 'batman',
                Email = 'NCTtestNCT123@NCTtestNCT.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Bruce',
                Lastname = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
            );
            insert portalAccountOwner;
        }

        Account account = [SELECT ID FROM Account LIMIT 1];
        account.IsPartner = true;
        account.OwnerId = portalAccountOwner.Id;
        update account;

        Contact practitioner = [SELECT Id FROM Contact WHERE LastName = :lastName];
        practitioner.AccountId = account.Id;
        update practitioner;

        User practitionerCommunityUser = new User(
            Username = PRACTITIONER_USERNAME,
            ContactId = practitioner.Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name =:PRACTITIONER_LASTNAME LIMIT 1].Id,
            Alias = 'NCTtest',
            Email = 'NCTtestNCT@NCTtestNCT.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'NCTtestNCT',
            CommunityNickname = 'NCTtestNCT',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert practitionerCommunityUser;

        return practitionerCommunityUser;
    }

    public TestDataFactory setSessionsToConfirmed(List<Session__c> sessions){
        for(Session__c aSession : sessions){
            aSession.Status__c = 'Confirmed';
        }
        update sessions;
        return this;
    }
}