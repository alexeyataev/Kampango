/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Estimated_CostsTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Estimated_CostsTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Estimated_Costs__c());
    }
}