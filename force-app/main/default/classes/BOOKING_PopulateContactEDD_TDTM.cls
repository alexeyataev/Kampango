@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #113 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class BOOKING_PopulateContactEDD_TDTM extends npsp.TDTM_Runnable {
    @SuppressWarnings('PMD.ExcessiveParameterList')
    //Incident #114 - https://confluence.nct.org.uk:8443/x/EoSO
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        List<Booking__c> newBookingList = (List<Booking__c>) triggerNew;
        List<Booking__c> oldBookingList = (List<Booking__c>) triggerOld;
        List<Contact> contactsToUpdate = new List<Contact>();
        
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert || triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            contactsToUpdate.addAll(updateContactsExpectedDueDate(newBookingList, oldBookingList));
        }

        dmlWrapper.objectsToUpdate.addAll(contactsToUpdate);
        return dmlWrapper;
    }

    private List<Contact> updateContactsExpectedDueDate(List<Booking__c> newBookingList, List<Booking__c> oldBookingList) {
        Set<Id> contactIds = new Set<Id>();
        List<Contact> contactsToUpdate = new List<Contact>();
        Map<Id, Booking__c> oldBookingMap = new Map<Id, Booking__c>(oldBookingList);
        Map<Id, Date> contactsWithExpectedDueDates = new Map<Id, Date>();
        for (Booking__c booking : newBookingList) {
            if (!oldBookingMap.containsKey(booking.Id) || oldBookingMap.get(booking.Id).Birth_Due_Date__c != booking.Birth_Due_Date__c) {
                contactsWithExpectedDueDates.putAll(new Map<Id, Date>{
                    booking.Primary_Contact__c => booking.Birth_Due_Date__c,
                    booking.Partner_Contact__c => booking.Birth_Due_Date__c
                });
            }
        }

        for (Contact contact : [SELECT Expected_Due_Date__c FROM Contact WHERE Id IN :contactsWithExpectedDueDates.keySet() WITH SECURITY_ENFORCED]) {
            contact.Expected_Due_Date__c = contactsWithExpectedDueDates.get(contact.Id);
            contactsToUpdate.add(contact);
        }

        return contactsToUpdate;
    }
}
