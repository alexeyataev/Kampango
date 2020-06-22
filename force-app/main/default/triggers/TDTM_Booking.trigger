trigger TDTM_Booking on Booking__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    dlrs.RollupService.triggerHandler(Booking__c.SObjectType);
    npsp.TDTM_Config_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Booking__c);
}