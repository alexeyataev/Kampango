trigger TDTM_BatchReceiptReportItem on Batch_Receipt_Report_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //will trigger BatchReceiptReportItem_TDTM class
    npsp.TDTM_Config_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Batch_Receipt_Report_Item__c);
}