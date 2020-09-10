trigger TDTM_ZumzumPurchaseInvoice on Zumzum__Purchase_Invoice__c (before delete, before insert, before update, after delete, after insert, after undelete, after update) {
    npsp.TDTM_Config_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Zumzum__Purchase_Invoice__c);
}