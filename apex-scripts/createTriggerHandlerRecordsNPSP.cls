
final String BeforeInsert = 'BeforeInsert';
final String BeforeUpdate = 'BeforeUpdate';
final String BeforeDelete = 'BeforeDelete';
final String AfterInsert = 'AfterInsert';
final String AfterUpdate = 'AfterUpdate';
final String AfterDelete = 'AfterDelete';
final String AfterUndelete = 'AfterUndelete';

List<npsp__Trigger_Handler__c> triggerHandlerList = new List<npsp__Trigger_Handler__c>();

triggerHandlerList.add (
    new npsp__Trigger_Handler__c (
        npsp__Class__c = 'EXPENSESHEET_ConvertEStoPI_TDTM',
        npsp__Object__c = 'Zumzum__Expense_Sheet__c',
        npsp__Trigger_Action__c = getValidActionString(new String[] { AfterUpdate }),
        npsp__Load_Order__c = 0,
        npsp__Active__c = true
    )
);

triggerHandlerList.add (
    new npsp__Trigger_Handler__c (
        npsp__Class__c = 'SESSION_RevertCourseToDraft_TDTM',
        npsp__Object__c = 'Session__c',
        npsp__Trigger_Action__c = getValidActionString(new String[] { AfterInsert, AfterUpdate, AfterDelete }),
        npsp__Load_Order__c = 0,
        npsp__Active__c = true
    )
);

triggerHandlerList.add (
    new npsp__Trigger_Handler__c (
        npsp__Class__c = 'SESSION_InvalidateCAs_TDTM',
        npsp__Object__c = 'Session__c',
        npsp__Trigger_Action__c = getValidActionString(new String[] { AfterInsert, AfterUpdate, AfterDelete }),
        npsp__Load_Order__c = 1,
        npsp__Active__c = true
    )
);

triggerHandlerList.add (
    new npsp__Trigger_Handler__c (
        npsp__Class__c = 'SESSION_RevertToProvisional_TDTM',
        npsp__Object__c = 'Session__c',
        npsp__Trigger_Action__c = getValidActionString(new String[] { BeforeUpdate }),
        npsp__Load_Order__c = 2,
        npsp__Active__c = true
    )
);

triggerHandlerList.add (
    new npsp__Trigger_Handler__c (
        npsp__Class__c = 'SESSION_TrackDeletedRecord_TDTM',
        npsp__Object__c = 'Session__c',
        npsp__Trigger_Action__c = getValidActionString(new String[] { AfterDelete }),
        npsp__Load_Order__c = 3,
        npsp__Active__c = true
    )
);

triggerHandlerList.add (
    new npsp__Trigger_Handler__c (
        npsp__Class__c = 'Task_PreventDeletion_TDTM',
        npsp__Object__c = 'Task',
        npsp__Trigger_Action__c = getValidActionString(new String[] { BeforeDelete }),
        npsp__Load_Order__c = 1,
        npsp__Active__c = true
    )
);

triggerHandlerList.add (
    new npsp__Trigger_Handler__c (
        npsp__Class__c = 'ChatterPost_PreventDeletion_TDTM',
        npsp__Object__c = 'FeedItem',
        npsp__Trigger_Action__c = getValidActionString(new String[] { BeforeDelete }),
        npsp__Load_Order__c = 0,
        npsp__Active__c = true
    )
);

triggerHandlerList.add (
    new npsp__Trigger_Handler__c (
        npsp__Class__c = 'BOOKING_EncryptValidationCode_TDTM',
        npsp__Object__c = 'Booking__c',
        npsp__Trigger_Action__c = getValidActionString(new String[] { AfterInsert, AfterUpdate }),
        npsp__Load_Order__c = 1,
        npsp__Active__c = true
    )
);

private String getValidActionString(List<String> actionList) {
    return String.join(actionList, ';');
}

for (npsp__Trigger_Handler__c triggerRecord : triggerHandlerList) {
    triggerRecord.Unique_Class_Name__c = triggerRecord.npsp__Class__c;
}

upsert triggerHandlerList Unique_Class_Name__c;



