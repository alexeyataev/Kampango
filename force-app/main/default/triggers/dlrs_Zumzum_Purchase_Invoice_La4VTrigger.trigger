/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Zumzum_Purchase_Invoice_La4VTrigger on Zumzum__Purchase_Invoice_Line_Item__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Zumzum__Purchase_Invoice_Line_Item__c.SObjectType);
}