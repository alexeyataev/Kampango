trigger TDTM_PaymentRunLineItem on Payment_Run_Line_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    npsp.TDTM_Config_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Payment_Run_Line_Item__c);
}