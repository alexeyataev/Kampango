
final String BeforeInsert = 'BeforeInsert';
final String BeforeUpdate = 'BeforeUpdate';
final String BeforeDelete = 'BeforeDelete';
final String AfterInsert = 'AfterInsert';
final String AfterUpdate = 'AfterUpdate';
final String AfterDelete = 'AfterDelete';
final String AfterUndelete = 'AfterUndelete';

Map<String, npsp__Trigger_Handler__c> triggerHandlerMap = new Map<String, npsp__Trigger_Handler__c>();

triggerHandlerMap.put (
        'EXPENSESHEET_ConvertEStoPI_TDTM',
        new npsp__Trigger_Handler__c (
            npsp__Object__c = 'Zumzum__Expense_Sheet__c',
            npsp__Trigger_Action__c = getValidActionString(new String[] { AfterUpdate }),
            npsp__Load_Order__c = 0,
            npsp__Active__c = true
        )
);

triggerHandlerMap.put (
    'SESSION_RevertCourseToDraft_TDTM',
    new npsp__Trigger_Handler__c (
        npsp__Object__c = 'Session__c',
        npsp__Trigger_Action__c = getValidActionString(new String[] { AfterInsert, AfterUpdate, AfterDelete }),
        npsp__Load_Order__c = 0,
        npsp__Active__c = true
    )
);

triggerHandlerMap.put (
    'SESSION_InvalidateCAs_TDTM',
    new npsp__Trigger_Handler__c (
        npsp__Object__c = 'Session__c',
        npsp__Trigger_Action__c = getValidActionString(new String[] { AfterInsert, AfterUpdate, AfterDelete }),
        npsp__Load_Order__c = 1,
        npsp__Active__c = true
    )
);

triggerHandlerMap.put (
    'SESSION_RevertToProvisional_TDTM',
    new npsp__Trigger_Handler__c (
        npsp__Object__c = 'Session__c',
        npsp__Trigger_Action__c = getValidActionString(new String[] { BeforeUpdate }),
        npsp__Load_Order__c = 2,
        npsp__Active__c = true
    )
);

triggerHandlerMap.put (
    'SESSION_TrackDeletedRecord_TDTM',
    new npsp__Trigger_Handler__c (
        npsp__Object__c = 'Session__c',
        npsp__Trigger_Action__c = getValidActionString(new String[] { AfterDelete }),
        npsp__Load_Order__c = 3,
        npsp__Active__c = true
    )
);

triggerHandlerMap.put (
    'Task_PreventDeletion_TDTM',
    new npsp__Trigger_Handler__c (
        npsp__Object__c = 'Task',
        npsp__Trigger_Action__c = getValidActionString(new String[] { BeforeDelete }),
        npsp__Load_Order__c = 1,
        npsp__Active__c = true
    )
);

triggerHandlerMap.put (
    'ChatterPost_PreventDeletion_TDTM',
    new npsp__Trigger_Handler__c (
        npsp__Object__c = 'FeedItem',
        npsp__Trigger_Action__c = getValidActionString(new String[] { BeforeDelete }),
        npsp__Load_Order__c = 0,
        npsp__Active__c = true
    )
);

triggerHandlerMap.put (
    'BOOKING_EncryptValidationCode_TDTM',
    new npsp__Trigger_Handler__c (
        npsp__Object__c = 'Booking__c',
        npsp__Trigger_Action__c = getValidActionString(new String[] { AfterInsert, AfterUpdate }),
        npsp__Load_Order__c = 1,
        npsp__Active__c = true
    )
);

List<npsp__Trigger_Handler__c> triggerHandlerList = [
    SELECT npsp__Class__c
    FROM npsp__Trigger_Handler__c
    WHERE npsp__Class__c IN :triggerHandlerMap.keySet()
];

Set<String> uniqTriggerClassNameSet = new Set<String>();
for (npsp__Trigger_Handler__c triggerRecord :triggerHandlerList) {
    uniqTriggerClassNameSet.add(triggerRecord.npsp__Class__c);
}

List<npsp__Trigger_Handler__c> newTriggerHandlerRecordsList = new List<npsp__Trigger_Handler__c>();
 for (String triggerName : triggerHandlerMap.keySet()) {

     if (!uniqTriggerClassNameSet.contains(triggerName)) {
        npsp__Trigger_Handler__c triggerHandlerRecord = triggerHandlerMap.get(triggerName);

        triggerHandlerRecord.npsp__Class__c = triggerName;
        triggerHandlerRecord.Name = triggerName;

        newTriggerHandlerRecordsList.add(triggerHandlerRecord);
     }
}

private String getValidActionString(List<String> actionList) {
    return String.join(actionList, ';');
}

insert newTriggerHandlerRecordsList;