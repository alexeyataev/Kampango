trigger TDTM_ZumzumSalesInvoice on  Zumzum__Sales_Invoice__c
(before delete, before insert, before update, after delete, after insert, after undelete, after update) {

//will trigger ZumzumSalesInvoice_TDTM class;
npsp.TDTM_Config_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Zumzum__Sales_Invoice__c);
}