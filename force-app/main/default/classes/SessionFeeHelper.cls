@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #56 - https://confluence.nct.org.uk:8443/x/EoSO
public class SessionFeeHelper {
    private static Date earliestSessionDate;
    private static Date latestSessionDate;

    @InvocableMethod
    public static void assignFeeRatesToSessions(List<Session__c> sessions){
        sessions = getExtraSessionData(sessions);
        
        setEarliestAndLatestSessionDates(sessions);

        Set<Id> branchIds = getBranchIdsForSessions(sessions);

        Set<Id> practitionerIds = getPractitionerIdsForSessions(sessions);

        Map<Id, List<Branch_Weighting__c>> branchIdToWeightings = getMapBranchIdToBranchWeightings(branchIds);

        Map<Id, List<Practitioner_Band__c>> practitionerIdToBands = getMapPractitionerIdToBands(practitionerIds);

        Map<Id, Practitioner_Fee_Rate__c> feeRates = new Map<Id, Practitioner_Fee_Rate__c>([SELECT Id, Geographical_Weighting__c, Practitioner_Band__c, Start_Date__c, End_Date__c
                                                        FROM Practitioner_Fee_Rate__c
                                                        WHERE Start_Date__c <= :latestSessionDate 
                                                            AND (End_Date__c = NULL or End_Date__c >= :earliestSessionDate)
                                                        WITH SECURITY_ENFORCED
                                                        ORDER BY Start_Date__c DESC]);
    
        assignAppropriateFeeRatesToSessions(sessions, branchIdToWeightings, practitionerIdToBands, feeRates);
    }

    private static void assignAppropriateFeeRatesToSessions(List<Session__c> sessions, 
                                                                Map<Id, List<Branch_Weighting__c>> branchIdToWeightings,
                                                                Map<Id, List<Practitioner_Band__c>> practitionerIdToBands,
                                                                Map<Id, Practitioner_Fee_Rate__c> feeRates){
        for(Session__c session : sessions){
            Branch_Weighting__c chosenWeighting = getWeightingForSession(session, branchIdToWeightings.get(session.course__r.branch__c));

            Practitioner_Band__c chosenBand = getBandForSession(session, practitionerIdToBands.get(session.Practitioner__c));
            
            Practitioner_Fee_Rate__c chosenRate = getFeeRateForSession(session, chosenWeighting, chosenBand, feeRates.values());

            if (chosenRate != null) {
                session.Practitioner_Fee_Rate__c = chosenRate.Id;
            } else {
                session.Practitioner_Fee_Rate__c = null;
            }
        }                                                         
        update sessions;                                                            
    }

    private static Branch_Weighting__c getWeightingForSession(Session__c session, List<Branch_Weighting__c> possibleWeightings){
        if (possibleWeightings != null) {
            for(Branch_Weighting__c weighting : possibleWeightings){
                if(weighting.Start_Date__c <= session.Fee_Rate_Date__c && 
                    (weighting.End_Date__c == null || weighting.End_Date__c >= session.Fee_Rate_Date__c)){
                        return weighting;
                }
            }
        }
        return null;
    }

    private static Practitioner_Band__c getBandForSession(Session__c session, List<Practitioner_Band__c> possibleBands){
        if (possibleBands != null) {
            for(Practitioner_Band__c band : possibleBands){
                if(band.Start_Date__c <= session.Fee_Rate_Date__c && 
                    (band.End_Date__c == null || band.End_Date__c >= session.Fee_Rate_Date__c)){
                        return band;
                }
            }
        }
        return null;
    }

    private static Practitioner_Fee_Rate__c getFeeRateForSession(Session__c session, Branch_Weighting__c chosenWeighting, Practitioner_Band__c chosenBand, List<Practitioner_Fee_Rate__c> possibleRates){
        if (chosenWeighting != null && chosenBand != null) {
            for(Practitioner_Fee_Rate__c rate : possibleRates){
                if(rate.Geographical_Weighting__c == chosenWeighting.Geographical_Weighting__c && 
                    rate.Practitioner_Band__c == chosenBand.Band__c &&
                    rate.Start_Date__c < = session.Fee_Rate_Date__c &&
                    (rate.End_Date__c == null || rate.End_Date__c >= session.Fee_Rate_Date__c)){
                        return rate;
                }
            }
        }
        return null;
    }

    private static List<Session__c> getExtraSessionData(List<Session__c> sessions){
        Set<Id> sessionIds = new Set<Id>();
        
        for(Session__c session : sessions){
            sessionIds.add(session.Id);
        }

        return [SELECT Id, Fee_Rate_Date__c, Practitioner__c, Course__c, Course__r.Branch__c 
                FROM Session__c 
                WHERE Id IN :sessionIds
                WITH SECURITY_ENFORCED];
    }

    private static void setEarliestAndLatestSessionDates(List<Session__c> sessions){
        for(Session__c session : sessions){
            if(earliestSessionDate == null || earliestSessionDate > session.Fee_Rate_Date__c){
                earliestSessionDate = session.Fee_Rate_Date__c;
            }
            if(latestSessionDate == null || latestSessionDate < session.Fee_Rate_Date__c){
                latestSessionDate = session.Fee_Rate_Date__c;
            }
        }
    }

    private static Set<Id> getBranchIdsForSessions(List<Session__c> sessions){
        Set<Id> branchIds = new Set<Id>();

        for(Session__c session : sessions){
            branchIds.add(session.Course__r.Branch__c);
        }

        return branchIds;
    }

    private static Set<Id> getPractitionerIdsForSessions(List<Session__c> sessions){
        Set<Id> practitionerIds = new Set<Id>();

        for(Session__c session : sessions){
            practitionerIds.add(session.Practitioner__c);
        }

        return practitionerIds;
    }

    private static Map<Id, List<Branch_Weighting__c>> getMapBranchIdToBranchWeightings(Set<Id> branchIds){
        Map<Id, List<Branch_Weighting__c>> branchIdToWeightings = new Map<Id, List<Branch_Weighting__c>>();

        for(Branch_Weighting__c weighting : [SELECT Id, Branch__c, Geographical_Weighting__c, Start_Date__c, End_Date__c 
                                                FROM Branch_Weighting__c 
                                                WHERE Branch__c IN :branchIds
                                                    AND Start_Date__c <= :latestSessionDate 
                                                    AND (End_Date__c = NULL or End_Date__c >= :earliestSessionDate)
                                                WITH SECURITY_ENFORCED
                                                ORDER BY Start_Date__c DESC
                                            ]){
            if(branchIdToWeightings.get(weighting.Branch__c) != null){
                branchIdToWeightings.get(weighting.Branch__c).add(weighting);
            }else{
                List<Branch_Weighting__c> branchWeightings = new List<Branch_Weighting__c>();
                branchWeightings.add(weighting);
                branchIdToWeightings.put(weighting.Branch__c, branchWeightings);
            }
        }

        return branchIdToWeightings;
    }

    private static Map<Id, List<Practitioner_Band__c>> getMapPractitionerIdToBands(Set<Id> practitionerIds){
        Map<Id, List<Practitioner_Band__c>> practitionerIdToBands = new Map<Id, List<Practitioner_Band__c>>();

        for(Practitioner_Band__c band : [SELECT Id, Practitioner__c, Band__c, Start_Date__c, End_Date__c
                                            FROM Practitioner_Band__c
                                            WHERE Practitioner__c IN :practitionerIds
                                                AND Start_Date__c <= :latestSessionDate 
                                                AND (End_Date__c = NULL or End_Date__c >= :earliestSessionDate)
                                            WITH SECURITY_ENFORCED
                                            ORDER BY Start_Date__c DESC
                                        ]){
            if(practitionerIdToBands.get(band.Practitioner__c) != null){
                practitionerIdToBands.get(band.Practitioner__c).add(band);
            }else{
                List<Practitioner_Band__c> practitionerBands = new List<Practitioner_Band__c>();
                practitionerBands.add(band);
                practitionerIdToBands.put(band.Practitioner__c, practitionerBands);                
            }
        }

        return practitionerIdToBands;
    }
}
