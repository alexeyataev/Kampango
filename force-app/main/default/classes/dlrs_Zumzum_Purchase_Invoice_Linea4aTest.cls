/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Zumzum_Purchase_Invoice_Linea4aTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Zumzum_Purchase_Invoice_La4aTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Zumzum__Purchase_Invoice_Line_Item__c());
    }
}