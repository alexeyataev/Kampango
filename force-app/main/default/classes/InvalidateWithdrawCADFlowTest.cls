// @SuppressWarnings('PMD.MethodNamingConventions')
// //Incident #42 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class InvalidateWithdrawCADFlowTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String CANCELLATION_REASON = 'Low bookings - 0 bookings';
    private static final String COURSE_ASSIGNMENT_DRAFT_STATUS = 'Draft';
    private static final String COURSE_ASSIGNMENT_WITHDRAWN_STATUS = 'Withdrawn';

    @TestSetup 
    private static void testSetup() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .createEnquiryPSA()
                    .buildBranchAccountWithEnquiryPSA()
                    .buildPractitioner(PRACTITIONER_LASTNAME)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession();
        List<Session__c> provisionalNonReunionSessions = [
            SELECT Id 
            FROM Session__c 
            WHERE Status__c = 'Provisional' 
                AND Type__c <> 'Reunion'
            ];    

        List<Course__c> listDraftCourses = [
            SELECT Id 
            FROM Course__c 
            WHERE Status__c = 'Draft'];

        dataFactory .SetSessionsToConfirmed(provisionalNonReunionSessions)
                    .SetCoursesToFinal(listDraftCourses)
                    .buildCourseAssignment();

        User practitionerCommunityUser = TestDataFactory.convertPractitionerToPartnerCommunityUser();
        TestDataFactory.changeOwnerOfAllCourseAssignments(practitionerCommunityUser);
    }

    @isTest
    static void InvalidateWithdrawCAD_CourseCancelled_CADWithdrawn() {

        Course__c course = [
			SELECT Id, Status__c
			FROM Course__c
			LIMIT 1
        ];
        
        Course_Assignment__c courseAssignment = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Course__c = :course.Id
            LIMIT 1
        ];

        Test.startTest();
            course.Status__c = 'Cancelled';
            course.Cancellation_Reason__c = CANCELLATION_REASON;
            update course;
        Test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c, Course__r.Status__c
            FROM Course_Assignment__c
            WHERE Course__c = :course.Id
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_DRAFT_STATUS, courseAssignment.Status__c);
        System.assertEquals(COURSE_ASSIGNMENT_WITHDRAWN_STATUS, courseAssignmentToTest.Status__c);
    }
}

