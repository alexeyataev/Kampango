trigger TDTM_ZumzumPurchaseInvoice_La4V on Zumzum__Purchase_Invoice_Line_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //will trigger ZumzumPurchaseInvoiceLa4V_TDTM class;
    npsp.TDTM_Config_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Zumzum__Purchase_Invoice_Line_Item__c);
}