public with sharing class BranchWeightingHelper {
   private static Date earliestWeightingStartDate;

   @InvocableMethod
   public static void updateFeesOnAffectedSessions(List<Branch_Weighting__c> updatedAndNewWeightings){
       getEarliestWeightingStartDate(updatedAndNewWeightings);

       Set<Id> branchIds = getBranchIds(updatedAndNewWeightings);
       List<Session__c> sessionsToProcess = getPotentiallyAffectedSessions(branchIds, earliestWeightingStartDate);
       SessionFeeHelper.assignFeeRatesToSessions(sessionsToProcess);
   }

   private static Set<Id> getBranchIds(List<Branch_Weighting__c> updatedAndNewWeightings){
       Set<Id> branchIds = new Set<Id>();
       for(Branch_Weighting__c weighting : updatedAndNewWeightings){
           branchIds.add(weighting.Branch__c);
       }
       return branchIds;
   }

   private static void getEarliestWeightingStartDate(List<Branch_Weighting__c> updatedAndNewWeightings){
       Date earliestWeightingStartDate;
       for(Branch_Weighting__c weighting : updatedAndNewWeightings){
           if(earliestWeightingStartDate == null || earliestWeightingStartDate > weighting.Start_Date__c){
               earliestWeightingStartDate = weighting.Start_Date__c;
           }
       }
   }

   private static List<Session__c> getPotentiallyAffectedSessions(Set<Id> branchIds, Date earliestWeightingStartDate){
       return [SELECT Id
               FROM Session__c
               WHERE Course__r.Branch__c IN :branchIds
                   AND Date__c >= :earliestWeightingStartDate];
   }
}