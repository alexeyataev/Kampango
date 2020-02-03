@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #55 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class PractitionerFeeRateHelper {

    @InvocableMethod
    public static void updateFeesOnAffectedSessions(List<Practitioner_Fee_Rate__c> updatedAndNewRates){

        Set<String> affectedBands = getAffectedBands(updatedAndNewRates);
        Set<String> affectedWeightings = getAffectedWeightings(updatedAndNewRates);
        Date earliestFeeRateStartDate = getEarliestFeeRateStartDate(updatedAndNewRates);
        List<Session__c> potentialSessionsToProcess = getPotentialSessionsToProcess(affectedBands, affectedWeightings, earliestFeeRateStartDate);

        if(potentialSessionsToProcess.size() > 0){
            List<Session__c> sessionsToProcess = refinePotentialSessionList(potentialSessionsToProcess, updatedAndNewRates);

            SessionFeeHelper.assignFeeRatesToSessions(sessionsToProcess);
        }
    }

    private static Set<String> getAffectedBands(List<Practitioner_Fee_Rate__c> updatedAndNewRates){

        Set<String> affectedBands = new Set<String>();
        for(Practitioner_Fee_Rate__c feeRate : updatedAndNewRates){
            affectedBands.add(feeRate.Practitioner_Band__c);
        }

        return affectedBands;
    }

    private static Set<String> getAffectedWeightings(List<Practitioner_Fee_Rate__c> updatedAndNewRates){

        Set<String> affectedWeightings = new Set<String>();
        for(Practitioner_Fee_Rate__c feeRate : updatedAndNewRates){
            affectedWeightings.add(feeRate.Geographical_Weighting__c);
        }

        return affectedWeightings;        
    }

    private static Date getEarliestFeeRateStartDate(List<Practitioner_Fee_Rate__c> updatedAndNewRates){

        Date earliestFeeRateStartDate;
        for(Practitioner_Fee_Rate__c feeRate : updatedAndNewRates){
            if(earliestFeeRateStartDate == null || earliestFeeRateStartDate > feeRate.Start_Date__c){
                earliestFeeRateStartDate = feeRate.Start_Date__c;
            }
        }

        return earliestFeeRateStartDate;
    } 
 
    private static List<Session__c> getPotentialSessionsToProcess(Set<String> affectedBands, Set<String> affectedWeightings, Date earliestFeeRateStartDate){

        return [SELECT  Id,
                        Practitioner_Fee_Rate__r.Practitioner_Band__c,
                        Practitioner_Fee_Rate__r.Geographical_Weighting__c,
                        Date__c
                FROM Session__c
                WHERE Date__c >= :earliestFeeRateStartDate
                    AND ((Practitioner_Fee_Rate__r.Practitioner_Band__c IN :affectedBands
                            AND Practitioner_Fee_Rate__r.Geographical_Weighting__c IN :affectedWeightings)
                        OR Practitioner_Fee_Rate__c = null)
                WITH SECURITY_ENFORCED];
    }

    private static List<Session__c> refinePotentialSessionList(List<Session__c> potentialSessionsToProcess, List<Practitioner_Fee_Rate__c> updatedAndNewRates){

        Set<Session__c> sessionsToProcess = new Set<Session__c>();
        
        for(Session__c potentialSession : potentialSessionsToProcess){
            for(Practitioner_Fee_Rate__c feeRate : updatedAndNewRates){
                if(potentialSession.Date__c > feeRate.Start_Date__c
                    && ((potentialSession.Practitioner_Fee_Rate__r.Practitioner_Band__c == feeRate.Practitioner_Band__c
                            && potentialSession.Practitioner_Fee_Rate__r.Geographical_Weighting__c == feeRate.Geographical_Weighting__c)
                        || potentialSession.Practitioner_Fee_Rate__c == null)){    
                    sessionsToProcess.add(potentialSession);
                }
            }
        }

        return new List<Session__c>(sessionsToProcess);
    }
}