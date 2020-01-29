@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #54 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class PractitionerBandFeeHelper {

    @InvocableMethod
    public static void updateFeesOnAffectedSessions(List<Practitioner_Band__c> updatedAndNewBands){
        Set<Id> practitionerIds = getPractitionerIDs(updatedAndNewBands);

        Date earliestBandStartDate = getEarliestBandStartDate(updatedAndNewBands);

        List<Session__c> sessionsToProcess = getPotentiallyAffectedSessions(practitionerIds, earliestBandStartDate);

        SessionFeeHelper.assignFeeRatesToSessions(sessionsToProcess);
    }

    private static Set<Id> getPractitionerIDs(List<Practitioner_Band__c> updatedAndNewBands){
        Set<Id> practitionerIds = new Set<Id>();

        for(Practitioner_Band__c band : updatedAndNewBands){
            practitionerIds.add(band.practitioner__c);
        }

        return practitionerIds;
    }

    private static Date getEarliestBandStartDate(List<Practitioner_Band__c> updatedAndNewBands){
        Date earliestBandStartDate;
        for(Practitioner_Band__c band : updatedAndNewBands){
            if(earliestBandStartDate == null || earliestBandStartDate > band.Start_Date__c){
                earliestBandStartDate = band.Start_Date__c;
            }
        }
        return earliestBandStartDate;
    }

    private static List<Session__c> getPotentiallyAffectedSessions(Set<Id> practitionerIds, Date earliestBandStartDate){
        return [SELECT Id 
                FROM Session__c 
                WHERE Practitioner__c IN :practitionerIds
                    AND Date__c >= :earliestBandStartDate];
    }
}
