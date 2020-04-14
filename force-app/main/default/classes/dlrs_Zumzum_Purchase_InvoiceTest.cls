/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@SuppressWarnings('PMD.ClassNamingConventions')
//Incident #76 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class dlrs_Zumzum_Purchase_InvoiceTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Zumzum_Purchase_InvoiceTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Zumzum__Purchase_Invoice__c());
    }
}