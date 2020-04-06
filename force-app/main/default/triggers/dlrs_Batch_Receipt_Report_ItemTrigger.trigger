/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Batch_Receipt_Report_ItemTrigger on Batch_Receipt_Report_Item__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Batch_Receipt_Report_Item__c.SObjectType);
}