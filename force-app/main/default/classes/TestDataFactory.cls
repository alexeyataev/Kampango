@isTest
public without sharing class TestDataFactory {

    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String SESSION_CONFIRMED_STATUS = 'Confirmed';
    private static final String SESSION_REUNION_TYPE = 'Reunion';
    private static final String PRACTITIONER_RECORDTYPE_NAME  = 'Practitioner';
    private static final String CLIENT_RECORDTYPE_NAME  = 'Client';
    private static final String PRACTITIONER_PROFILE_NAME = 'Practitioner';
    private static final String PRACTITIONER_USERNAME = 'ncttest@test.com';
    private static final String PORTAL_ACCOUNT_OWNER_USERNAME = 'portalAccountOwner@ncttest.com';
    private static final String SYSTEM_ADMIN_USERNAME = 'NCTtest.sysAdmin.username@ncttest.com';
    private static final String ENQUIRY_PSA_USERNAME = 'NCTtest.enquiryPSA.username@ncttest.com';
    private static final String PSA_MANAGER_USERNAME = 'NCTtest.PSAmanager.username@ncttest.com';
    private static final String PORTAL_ACCOUNT_USER_EMAIL = 'portalAccountUserNCT@ncttest.com';
    private static final String PARTNER_COMMUNITY_USER_EMAIL = 'partnerCommunityUser@ncttest.com';
    private static final String TEST_BILLING_EMAIL = 'billingEmail@ncttest.com';
    private static final String COMMUNITY_NICKNAME_ONE = 'NICKNAME_ONE';
    private static final String COMMUNITY_NICKNAME_TWO = 'NICKNAME_TWO';
    private static final String ACCOUNT_BRANCH_RECORDTYPE = 'Branch';
    private static final String ACCOUNT_ORGANIZATION_RECORDTYPE = 'Organization';
    private static final String PRACTITIONER_BAND = 'A';
    private static final String BRANCH_WEIGHTING = 'Standard';
    private static final Set<String> PRACTITIONER_BAND_SET = new Set<String>{'A', 'B', 'C', 'D'}; 
    private static final Set<String> BRANCH_WEIGHTING_SET = new Set<String>{'Standard', 'Fringe', 'London'};
    private static final Decimal BASIC_PRACTITIONER_HOURLY_RATE = 30; 

    public static List<Course__c> courses = new List<Course__c>();
    public static List<Session__c> sessions = new List<Session__c>();
    public static List<User> users = new List<User>();
    public static List<User> enquiryPSAUsers = new List<User>();
    public static List<User> psaManagers = new List<User>();
    private List<Contact> practitioners = new List<Contact>();
    private Account branchAccount;
    private static Account organizationAccount;
    private Course_Assignment__c courseAssignment;
    private Venue__c venue;
    private Venue_Contact__c venueContact;
    private Room__c room;
    private Licence_To_Practice__c licenceToPractice;
    private Course__c course;
    private Session__c session;
    private Session__c reunion;
    private Booking__c booking;
    private Contact parentHost;
    private Contact partnertHost;
    private Practitioner_Fee_Rate__c practitionerFeeRate;
    private List<Practitioner_Fee_Rate__c> practitionerFeeRates = new List<Practitioner_Fee_Rate__c>();
    private List<Practitioner_Band__c> practitionerBands = new List<Practitioner_Band__c>();
    private Branch_Weighting__c branchWeighting;

    private static TestDataFactory instance;

    public static TestDataFactory getInstance() {
        if (instance == NULL) {
            instance = new TestDataFactory();
        }
        return instance;
    }

    public TestDataFactory buildBranchAccount() {
        TestAccountBuilder accountBranchBuilder = new TestAccountBuilder();
        branchAccount =  accountBranchBuilder
            .withRecordType(ACCOUNT_BRANCH_RECORDTYPE)
            .insertRecord(true)
            .build();
        TestBranchWeightingBuilder branchWeightingBuilder = new TestBranchWeightingBuilder();
        branchWeighting = branchWeightingBuilder
            .withBranch(branchAccount)
            .withWeighting(BRANCH_WEIGHTING)
            .insertRecord(true)
            .build();    
        return this;
    }

    public TestDataFactory buildBranchAccountWithEnquiryPSA() {
        TestAccountBuilder accountBranchBuilder = new TestAccountBuilder();
        branchAccount =  accountBranchBuilder
            .withRecordType(ACCOUNT_BRANCH_RECORDTYPE)
            .withEnquiriesPSA(enquiryPSAUsers[0].Id)
            .insertRecord(true)
            .build();
        TestBranchWeightingBuilder branchWeightingBuilder = new TestBranchWeightingBuilder();
        branchWeighting = branchWeightingBuilder
            .withBranch(branchAccount)
            .withWeighting(BRANCH_WEIGHTING)
            .insertRecord(true)
            .build();    
        return this;
    }

    //used for any emails that use Org-Wide Address in "From"
    public TestDataFactory buildBranchAccountWithEmails(String orgWideAddress) {
        TestAccountBuilder accountBranchBuilder = new TestAccountBuilder();
        branchAccount =  accountBranchBuilder
            .withRecordType(ACCOUNT_BRANCH_RECORDTYPE)
            .withCapacityPSAemail(orgWideAddress)
            .withEnquiriesPSAemail(orgWideAddress)
            .insertRecord(true)
            .build();
        TestBranchWeightingBuilder branchWeightingBuilder = new TestBranchWeightingBuilder();
        branchWeighting = branchWeightingBuilder
            .withBranch(branchAccount)
            .withWeighting(BRANCH_WEIGHTING)
            .insertRecord(true)
            .build();    
        return this;
    }

    public TestDataFactory buildBooking(String status){
        TestBookingBuilder bookingBuilder = new TestBookingBuilder();
        booking = bookingBuilder.withCourse(course)
            .withStatus(status)
            .withPrimaryContact(parentHost)
            .withPartnerContact(partnertHost)
            .withBookingExpiryDate(System.today().addDays(3))
            .ignoreDuplicateRules(true)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildBookingWithoutExpiryDate(String status){
        TestBookingBuilder bookingBuilder = new TestBookingBuilder();
        booking = bookingBuilder.withCourse(course)
            .withStatus(status)
            .withPrimaryContact(parentHost)
            .withPartnerContact(partnertHost)
            .ignoreDuplicateRules(true)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildOrganizationAccount(String accountNumber) {
        TestAccountBuilder accountBranchBuilder = new TestAccountBuilder();
        organizationAccount = accountBranchBuilder
            .withRecordType(ACCOUNT_ORGANIZATION_RECORDTYPE)
            .withName('John Smith')
            .withType('Supplier')
            .withAccountNumber(accountNumber)
            .withBillingEmail(TEST_BILLING_EMAIL)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildParentHost(String lastName, String email) {
        TestContactBuilder parentHostBuilder = new TestContactBuilder();
        parentHost = parentHostBuilder
            .withRecordType(CLIENT_RECORDTYPE_NAME)
            .withEmail(email)
            .withLastName(lastName)
            .ignoreDuplicateRules(true)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildPartnertHost(String lastName, String email) {
        TestContactBuilder partnerHostBuilder = new TestContactBuilder();
        partnertHost = partnerHostBuilder
            .withRecordType(CLIENT_RECORDTYPE_NAME)
            .withEmail(email)
            .withLastName(lastName)
            .insertRecord(true)
            .ignoreDuplicateRules(true)
            .build();
        return this;
    }

    public TestDataFactory buildPractitioner(String lastName) {
        return buildPractitioner(lastName, null);
    }

    public TestDataFactory buildPractitioner(String lastName, String email) {
       TestContactBuilder practitionerContactBuilder = new TestContactBuilder();
       Contact practitioner = practitionerContactBuilder
           .withRecordType(PRACTITIONER_RECORDTYPE_NAME)
           .withAccount(organizationAccount)
           .withLastName(lastName)
           .withEmail(email)
           .insertRecord(true)
           .ignoreDuplicateRules(true)
           .build();
       practitioners.add(practitioner);
       TestPractitionerBandBuilder practitionerBandBuilder = new TestPractitionerBandBuilder();
       Practitioner_Band__c practitionerBand = practitionerBandBuilder
           .withPractitionerContact(practitioner)
           .withBand(PRACTITIONER_BAND)
           .insertRecord(true)
           .build();
       practitionerBands.add(practitionerBand);
       return this;
   }

    public TestDataFactory buildPractitionerFeeRate(){
        TestPractitionerFeeRateBuilder feeRateBuilder = new TestPractitionerFeeRateBuilder();
        practitionerFeeRate = feeRateBuilder
            .withBand(PRACTITIONER_BAND)
            .withWeighting(BRANCH_WEIGHTING)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildPractitionerFeeRateSet(){
        List<Practitioner_Fee_Rate__c> practitionerFeeRatesToInsert = new List<Practitioner_Fee_Rate__c>();
        Decimal weightingCorrection = 0;
        TestPractitionerFeeRateBuilder feeRateBuilder = new TestPractitionerFeeRateBuilder();
        for (String weighting: BRANCH_WEIGHTING_SET) {
            Decimal bandCorrection = 0;
            for (String band : PRACTITIONER_BAND_SET) {
                practitionerFeeRatesToInsert.add(feeRateBuilder
                .withBand(band)
                .withWeighting(weighting)
                .withHourlyRate(BASIC_PRACTITIONER_HOURLY_RATE + weightingCorrection + bandCorrection)
                .insertRecord(false)
                .build());
                bandCorrection += 5;
            }
            weightingCorrection += 1;
        }

        insert practitionerFeeRatesToInsert;
        practitionerFeeRates.addAll(practitionerFeeRatesToInsert);
        return this;
    }

    public TestDataFactory buildVenue() {
        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        venue = venueBuilder
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildVenueWithName(String name) {
        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        venue = venueBuilder
            .withName(name)
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

    public TestDataFactory buildVenueContact() {
        TestVenueContactBuilder venueContactBuilder = new TestVenueContactBuilder();
        venueContact = venueContactBuilder
            .withContact(practitioners[0])
            .withVenue(venue)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildLicenceToPractice() {
        return buildLicenceToPractice(practitioners[0]);
    }
    
    public TestDataFactory buildLicenceToPractice(Contact practitioner) {
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
            .withAccount(branchAccount)
            .withPractitioner(practitioners[0])
            .withMainVenue(venue)
            .withLicenceToPractice(licenceToPractice)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildCourseWithStatus(String status) {
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        course = courseBuilder
            .withAccount(branchAccount)
            .withPractitioner(practitioners[0])
            .withMainVenue(venue)
            .withStatus(status)
            .withLicenceToPractice(licenceToPractice)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildCourseWithFee(Integer fee) {
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        course = courseBuilder
            .withAccount(branchAccount)
            .withPractitioner(practitioners[0])
            .withMainVenue(venue)
            .withFee(fee)
            .withLicenceToPractice(licenceToPractice)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildGiftAidDeclaration() {
        TestGiftAidDeclarationBuilder giftAidDeclaration = new TestGiftAidDeclarationBuilder();
        giftAidDeclaration.withActive(true)
            .withContact(parentHost)
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

    public TestDataFactory buildCourseWithTypeAndSubType(String type, String subtype) {
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        course = courseBuilder
            .withAccount(branchAccount)
            .withPractitioner(practitioners[0])
            .withLicenceToPractice(licenceToPractice)
            .withType(type)
            .withSubType(subtype)
            .withMainVenue(venue)
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
            .withPractitioner(practitioners[0])
            .withPractitionerFeeRate(practitionerFeeRate)
            .withPractitionerLicence(licenceToPractice)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildConfirmedSession() {
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        session = sessionBuilder
            .withCourse(course)
            .withVenue(venue)
            .withRoom(room)
            .withStatus(SESSION_CONFIRMED_STATUS)
            .withPractitioner(practitioners[0])
            .withPractitionerFeeRate(practitionerFeeRate)
            .withPractitionerLicence(licenceToPractice)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildReunion() {
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        reunion = sessionBuilder
            .withCourse(course)
            .withType('Reunion')
            .withVenue(venue)
            .withRoom(room)
            .withStatus(SESSION_PROVISIONAL_STATUS)
            .withPractitioner(practitioners[0])
            .withPractitionerFeeRate(practitionerFeeRate)
            .withPractitionerLicence(licenceToPractice)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildSessionWithTypeAndStatus(String sessionType, String sessionStatus) {
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        session = sessionBuilder
            .withCourse(course)
            .withVenue(venue)
            .withRoom(room)
            .withType(sessionType)
            .withStatus(sessionStatus)
            .withPractitioner(practitioners[0])
            .withPractitionerFeeRate(practitionerFeeRate)
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
        return this;
    }

    public TestDataFactory buildCoursesWithSessions(Integer numberOfCourses, Integer numberOfSessions) {
        List<Course__c> coursesToInsert = new List<Course__c>();
        List<Session__c> sessionsToInsert = new List<Session__c>();
        List<Estimated_Costs__c> costsToInsert = new List<Estimated_Costs__c>();
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        for(Integer i = 0; i < numberOfCourses; i++) {
            coursesToInsert.add(courseBuilder
                .withAccount(branchAccount)
                .withFee(100)
                .withPractitioner(practitioners[0])
                .withLicenceToPractice(licenceToPractice)
                .withMainVenue(venue)
                .insertRecord(false)
                .build());
        }
        insert coursesToInsert;

        courses.addAll(coursesToInsert);
        for(Integer i = 0; i < numberOfCourses; i++) {
            TestEstimatedCostsBuilder estimatedCostsBuilder = new TestEstimatedCostsBuilder();
            costsToInsert.add(estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Travel')
                .insertRecord(false)
                .build());
            costsToInsert.add(estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Venue')
                .insertRecord(false)
                .build());
        }
        insert costsToInsert;
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        for(Integer iCourses = 0; iCourses < numberOfCourses; iCourses++) {
            for(Integer iSessions = 0; iSessions < numberOfSessions; iSessions++) {
                sessionsToInsert.add(sessionBuilder
                    .withCourse(courses[iCourses])
                    .withVenue(venue)
                    .withRoom(room)
                    .withPractitioner(practitioners[0])
                    .withPractitionerFeeRate(practitionerFeeRate)
                    .withPractitionerLicence(licenceToPractice)
                    .withStatus(SESSION_PROVISIONAL_STATUS)
                    .insertRecord(false)
                    .build());
            }
        }

        insert sessionsToInsert;
        sessions.addAll(sessionsToInsert);
        return this;
    }
    
    public TestDataFactory buildCoursesWithChoseNumberAndStatusSessions(Integer numberOfCourses, Integer numberOfProvisionSession, Integer numberOfConfirmedSession) {
        List<Course__c> coursesToInsert = new List<Course__c>();
        List<Session__c> sessionsToInsert = new List<Session__c>();
        List<Estimated_Costs__c> costsToInsert = new List<Estimated_Costs__c>();
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        for(Integer i = 0; i < numberOfCourses; i++) {
            coursesToInsert.add(courseBuilder
                .withAccount(branchAccount)
                .withFee(100)
                .withPractitioner(practitioners[0])
                .withLicenceToPractice(licenceToPractice)
                .withMainVenue(venue)
                .insertRecord(false)
                .build());
        }
        insert coursesToInsert;

        courses.addAll(coursesToInsert);
        for(Integer i = 0; i < numberOfCourses; i++) {
            TestEstimatedCostsBuilder estimatedCostsBuilder = new TestEstimatedCostsBuilder();
            costsToInsert.add(estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Travel')
                .insertRecord(false)
                .build());
            costsToInsert.add(estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Venue')
                .insertRecord(false)
                .build());
        }

        List<String> sessionStatusList = new List<String>();
        for(Integer i = 0; i < numberOfProvisionSession; i++) {
            sessionStatusList.add(SESSION_PROVISIONAL_STATUS);
        }

        for(Integer i = 0; i < numberOfConfirmedSession; i++) {
            sessionStatusList.add(SESSION_CONFIRMED_STATUS);
        }

        insert costsToInsert;
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        for(Integer iCourses = 0; iCourses < numberOfCourses; iCourses++) {
            for(Integer iSessions = 0; iSessions < numberOfProvisionSession + numberOfConfirmedSession; iSessions++) {
                sessionsToInsert.add(sessionBuilder
                    .withCourse(courses[iCourses])
                    .withVenue(venue)
                    .withRoom(room)
                    .withPractitioner(practitioners[0])
                    .withPractitionerFeeRate(practitionerFeeRate)
                    .withPractitionerLicence(licenceToPractice)
                    .withStatus(sessionStatusList.get(iSessions))
                    .insertRecord(false)
                    .build());
            }
        }

        insert sessionsToInsert;
        sessions.addAll(sessionsToInsert);
        return this;
    }

    public TestDataFactory createEnquiryPSA() {
        TestUserBuilder userBuilder = new TestUserBuilder();
        enquiryPSAUsers.add(userBuilder
            .withProfile([SELECT Id FROM Profile WHERE Name = 'Enquiry PSA'].Id)
            .withUsername(ENQUIRY_PSA_USERNAME)
            .insertRecord(true)
            .build());

        return this;
    }

    public TestDataFactory createPSAmanager() {
        TestUserBuilder userBuilder = new TestUserBuilder();
        psaManagers.add(userBuilder
            .withProfile([SELECT Id FROM Profile WHERE Name = 'PSA Manager'].Id)
            .withUsername(PSA_MANAGER_USERNAME)
            .insertRecord(true)
            .build());

        return this;
    }
    
    public TestDataFactory buildCoursesWithReunionSessions(Integer numberOfCourses, Integer numberOfSessions) {
        List<Course__c> coursesToInsert = new List<Course__c>();
        List<Session__c> sessionsToInsert = new List<Session__c>();
        List<Estimated_Costs__c> costsToInsert = new List<Estimated_Costs__c>();
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        for(Integer i = 0; i < numberOfCourses; i++) {
            coursesToInsert.add(courseBuilder
                .withAccount(branchAccount)
                .withFee(100)
                .withPractitioner(practitioners[0])
                .withLicenceToPractice(licenceToPractice)
                .withMainVenue(venue)
                .insertRecord(false)
                .build());
        }
        insert coursesToInsert;

        courses.addAll(coursesToInsert);
        for(Integer i = 0; i < numberOfCourses; i++) {
            TestEstimatedCostsBuilder estimatedCostsBuilder = new TestEstimatedCostsBuilder();
            costsToInsert.add(estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Travel')
                .insertRecord(false)
                .build());
            costsToInsert.add(estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Venue')
                .insertRecord(false)
                .build());
        }
        insert costsToInsert;
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        for(Integer iCourses = 0; iCourses < numberOfCourses; iCourses++) {
            for(Integer iSessions = 0; iSessions < numberOfSessions; iSessions++) {
                sessionsToInsert.add(sessionBuilder
                    .withCourse(courses[iCourses])
                    .withVenue(venue)
                    .withRoom(room)
                    .withPractitioner(practitioners[0])
                    .withPractitionerFeeRate(practitionerFeeRate)
                    .withPractitionerLicence(licenceToPractice)
                    .withType('Reunion')
                    .withStatus('Provisional')
                    .insertRecord(false)
                    .build());
            }
        }

        insert sessionsToInsert;
        sessions.addAll(sessionsToInsert);
        return this;
    }

    public static User assignPermissionSetToUser(String permissionSetName, User userInstance) {	

        PermissionSet permissionInstance = [	
            SELECT Id 	
            FROM PermissionSet	
            WHERE Name = :permissionSetName	
            LIMIT 1	
        ];	

        insert new PermissionSetAssignment(AssigneeId = userInstance.Id, PermissionSetId = permissionInstance.Id);	

    return userInstance;	
    }
    
    public static User createSysAdminUser() {
        TestUserBuilder userBuilder = new TestUserBuilder();
        users.add(userBuilder
            .withProfile([SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id)
            .withUsername(SYSTEM_ADMIN_USERNAME)
            .insertRecord(true)
            .build());
        return users[0];
    }

    public static User convertPractitionerToPartnerCommunityUser() {

        System.runAs(createSysAdminUser()) {
            UserRole testRole = new UserRole(Name = 'testRole');
            insert testRole;

            TestUserBuilder userBuilder = new TestUserBuilder();
            users.add((userBuilder
                .withUsername(PORTAL_ACCOUNT_OWNER_USERNAME)
                .withUserRoleId(testRole.Id)
                .withProfile([SELECT Id FROM Profile WHERE Name = 'Finance'].Id)
                .withEmail(PORTAL_ACCOUNT_USER_EMAIL)
                .withCommunityNickName(COMMUNITY_NICKNAME_ONE)
                .withAlias('AcOwner')
                .insertRecord(true)
                .build()));
        }

        TestDataFactory testDataFactory = TestDataFactory.getInstance();
        testDataFactory.buildOrganizationAccount('acc5');
        organizationAccount.IsPartner = true;
        organizationAccount.OwnerId = users[1].Id;
        update organizationAccount;

        Contact practitioner = [SELECT Id, Name FROM Contact WHERE Name = 'John Smith' LIMIT 1];
        practitioner.AccountId = organizationAccount.Id;
        update practitioner;

        TestUserBuilder userBuilder = new TestUserBuilder();
        users.add((userBuilder
            .withUsername(PRACTITIONER_USERNAME)
            .withContactId(practitioner.Id)
            .withProfile([SELECT Id FROM Profile WHERE Name =:PRACTITIONER_PROFILE_NAME LIMIT 1].Id)
            .withCommunityNickName(COMMUNITY_NICKNAME_TWO)
            .withEmail(PARTNER_COMMUNITY_USER_EMAIL)
            .insertRecord(true)
            .build()));

        return users[2];
    }

    public static void changeOwnerOfAllCourseAssignments(User practitionerCommunityUser) {

        List<Course_Assignment__c> courseAssignments = [
            SELECT OwnerId, Course__c
            FROM Course_Assignment__c
            LIMIT 100
        ];

        for (Course_Assignment__c aCourseAssignment : courseAssignments) {
            aCourseAssignment.OwnerId = practitionerCommunityUser.Id;
        }
        update courseAssignments;
    }

    public TestDataFactory setSessionsToConfirmed(List<Session__c> sessions){
        for(Session__c aSession : sessions){
            aSession.Status__c = 'Confirmed';
        }
        update sessions;
        return this;
    }

    public TestDataFactory setSessionsToProvisional(List<Session__c> sessions) {
        for(Session__c session : sessions) {
            session.Status__c = 'Provisional';
        }
        update sessions;
        return this;
    }

    public TestDataFactory setCoursesToFinalAndSessionsToConfirmed(List<Course__c> courses) {
        List<Session__c> sessions = new List<Session__c>();
        for (Course__c course : courses) {
            course.Status__c = 'Final';
            if (course.Sessions__r.isEmpty()) {
                continue;
            } else {
                sessions.addAll(course.Sessions__r);
            }
        }
        for (Session__c session : sessions) {
            session.Status__c = 'Confirmed';
        }
        update sessions;
        update courses;
        return this;
    }
  
    public TestDataFactory setCourseToFinal(){
        course.Status__c = 'Final';
        update course;
        return this;
    }

    public TestDataFactory setCoursesToFinal(List<Course__c> courses){
        for(Course__c course : courses){
            course.Status__c = 'Final';
        }
        update courses;
        return this;
    }
    
    public TestDataFactory setCoursesWithSessionsToFinal(List<Course__c> courses){
        for(Course__c course : courses){
            if (course.Sessions__r.isEmpty()) {
                continue;
            }
            course.Status__c = 'Final';
        }
        update courses;
        return this;
    }

    public TestDataFactory setMainVenueToCourses(Venue__c venue, List<Course__c> courses) {
        for (Course__c course : courses) {
            course.Main_Venue__c = venue.Id;
        }
        update courses;
        return this;
    }

}