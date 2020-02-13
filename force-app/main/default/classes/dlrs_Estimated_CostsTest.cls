/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@SuppressWarnings('PMD.ClassNamingConventions')
//Incident #45 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class dlrs_Estimated_CostsTest
{

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_EMAIL_ADDRESS = 'partnerCommunityUser@ncttest.com';

    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Estimated_CostsTrigger to be invoked, fails the test if org config or other Apex code prevents this.

        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME, PRACTITIONER_EMAIL_ADDRESS)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildSessionWithTypeAndStatus('Reunion', 'Confirmed');

         List<Estimated_Costs__c> estimated_Costs = [
            SELECT Id 
            FROM Estimated_Costs__c 
            ];

        Test.startTest();
        dlrs.RollupService.testHandler(estimated_Costs.get(0));
        Test.stopTest();

        List<Course__c> courses = [
            SELECT Count_of_Estimated_Travel_Costs__c, Count_of_Estimated_Venue_Costs__c  
            FROM Course__c
        ];

        System.assertEquals(1, courses[0].Count_of_Estimated_Travel_Costs__c);
        System.assertEquals(1, courses[0].Count_of_Estimated_Venue_Costs__c);

    }
}