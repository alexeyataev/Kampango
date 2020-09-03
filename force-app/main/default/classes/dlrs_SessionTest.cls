/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@SuppressWarnings('PMD.ClassNamingConventions')
//Incident #46 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class dlrs_SessionTest
{

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_EMAIL_ADDRESS = 'partnerCommunityUser@ncttest.com';

    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_SessionTrigger to be invoked, fails the test if org config or other Apex code prevents this.

        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME, PRACTITIONER_EMAIL_ADDRESS)
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildReunion();


        List<Session__c> sessions = [
            SELECT id
            FROM Session__c
        ];

        Test.startTest();
        for (Session__c session : sessions) {
            dlrs.RollupService.testHandler(session);
        }
        Test.stopTest();

        List<Course__c> courses = [
            SELECT Count_of_Sessions_Without_Fee_Rates__c  
            FROM Course__c
        ];

        System.assertEquals(2, courses[0].Count_of_Sessions_Without_Fee_Rates__c);

    }
}