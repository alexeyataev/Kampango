trigger TDTM_Case on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    npsp.TDTM_Config_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Case);
}