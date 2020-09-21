@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #51 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing class BookingJourneyHelper {
    @InvocableMethod(label='Update Contact')
    public static void updateContact(List<BookingFlowContactDetailsParams> params){

        BookingFlowContactDetailsParams bookingFlowParams = params[0];
        System.debug(params);

        System.debug('bookingRecord:  ' + bookingFlowParams.bookingRecord);
        System.debug('individualRecord:  ' + bookingFlowParams.individualRecord);
        System.debug('partnerContact:  ' + bookingFlowParams.partnerContact);
        System.debug('primaryContact:  ' + bookingFlowParams.primaryContact);

        
        // for(Contact contact: contacts){
        //     contact.npe01__PreferredPhone__c = String.valueOf(contact.npe01__PreferredPhone__c);
        //     contact.Salutation = String.valueOf(contact.Salutation);
        //     contact.Country__c = String.valueOf(contact.Country__c);
        // }

        

        // if(contacts != null && !contacts.isEmpty()){
        //     Database.UpsertResult result = Database.upsert(contacts[0], Contact.Fields.Id, false);
        //     Database.DMLOptions dmlOption = new Database.DMLOptions();
        //     if (!result.isSuccess()) {
        //         Boolean isDuplicateError = checkForDuplicateError(result.errors);
        //         if (!isDuplicateError) {
        //             throw new BookingJourneyException(JSON.serialize(result.getErrors()));
        //         }
        //         List<sObject> duplicates = getDuplicateRecords(result.errors);
        //         if (duplicates.size() == 1) {
        //             contacts[0].Id = duplicates[0].Id;
        //             Database.update(contacts[0], false);
        //         }
        //         if (duplicates.size() > 1) {
        //             Database.insert(contacts[0], dmlOption);
        //         }
        //     }
        // }
        // return contacts;
    }

    @AuraEnabled(cacheable=true)
    public static Individual retrieveMarketingPreferences(String individualId){
        List<Individual> individuals = new List<Individual>();
        if(String.isNotBlank(individualId)){
            individuals = [
                SELECT Has_Opted_In_Email__c, Has_Opted_In_Post__c, Has_Opted_In_SMS__c, Has_Opted_In_Telephone__c
                FROM Individual
                WHERE Id = :individualId
                WITH SECURITY_ENFORCED
            ];
        }
        if(individuals != null && !individuals.isEmpty()){
            return individuals[0];
        } else {
            return null;
        }
    }

    private static List<sObject> getDuplicateRecords(List<Database.Error> errors) {
        List<sObject> duplicateRecords = new List<sObject>();
        for (Database.Error  error : errors) {
            Database.DuplicateError duplicateError = (Database.DuplicateError)error;
            Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
            Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
            Datacloud.MatchRecord[] matchRecords;

            for (Datacloud.MatchResult match : matchResults) {
                matchRecords = match.getMatchRecords();
                for (Datacloud.MatchRecord matchRecord : matchRecords) {
                    duplicateRecords.add(matchRecord.getRecord());
                }
            }
        }
        return duplicateRecords;
    }

    private static Boolean checkForDuplicateError(List<Database.Error> errors) {
        Boolean result = true;
        for (Database.Error error : errors) {
            if (error.getStatusCode() != StatusCode.DUPLICATES_DETECTED) {
                result = false;
            }
        }
        return result;
    }

    public class BookingJourneyException extends Exception {}
}