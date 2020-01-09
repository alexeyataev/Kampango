trigger TDTM_Session_c on Session__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    dlrs.RollupService.triggerHandler(Session__c.SObjectType);
    npsp.TDTM_Config_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Session__c);
}