/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Zumzum_Sales_InvoiceTrigger on Zumzum__Sales_Invoice__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Zumzum__Sales_Invoice__c.SObjectType);
}