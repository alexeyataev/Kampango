trigger TDTM_Estimated_Costs on Estimated_Costs__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //will trigger Estimated_Costs_TDTM class
    npsp.TDTM_Config_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Estimated_Costs__c);
}