/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Zumzum_Purchase_InvoiceTrigger on Zumzum__Purchase_Invoice__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Zumzum__Purchase_Invoice__c.SObjectType);
}