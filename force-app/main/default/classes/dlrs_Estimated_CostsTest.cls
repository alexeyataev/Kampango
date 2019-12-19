/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
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
                    .buildReunion();

         List<Estimated_Costs__c> estimatedCosts = [
            SELECT Id 
            FROM Estimated_Costs__c 
            ];

        dlrs.RollupService.testHandler(estimatedCosts.get(0));
    }
}