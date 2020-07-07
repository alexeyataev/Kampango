/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@SuppressWarnings('PMD.ClassNamingConventions')
//Incident #98 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class dlrs_Zumzum_Sales_InvoiceTest {

    @IsTest
    private static void testTrigger() {
        // Force the dlrs_Zumzum_Sales_InvoiceTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        
        Test.startTest();
        dlrs.RollupService.testHandler(new Zumzum__Sales_Invoice__c());
        Test.stopTest();
    }
}