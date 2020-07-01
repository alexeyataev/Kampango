@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #51 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing class BookingJourneyHelper {
    @InvocableMethod(label='Update Contact')
    public static List<Contact> updateContact(List<Contact> contacts){
        for(Contact contact: contacts){
            contact.npe01__PreferredPhone__c = String.valueOf(contact.npe01__PreferredPhone__c);
            contact.Salutation = String.valueOf(contact.Salutation);
        }
        if(contacts != null && !contacts.isEmpty()){
            try{
                if (Test.isRunningTest()) {
                    upsertContactTestUtility(contacts);
                } else {
                    upsert contacts Id;
                }
            } catch(DmlException ex){
                System.debug(
                    Label.ContactUpdateException + ' ' +
                    ex.getTypeName() + ' ' +
                    ex.getStackTraceString() + ' ' +
                    ex.getMessage()
                );
            }
        }
        return contacts;
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

    private static void upsertContactTestUtility(List<Contact> contacts){
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.DuplicateRuleHeader.AllowSave = true;
        List<Contact> contactsToInsert = new List<Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();
        Map<Id, Contact> existingContactsMap = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Id IN :contacts WITH SECURITY_ENFORCED]);
        for (Contact cont : contacts){
            if (existingContactsMap.containsKey(cont.Id)){
                contactsToUpdate.add(cont);
            } else {
                contactsToInsert.add(cont);
            }
        }
        Database.insert(contactsToInsert, dmlOption);
        Database.update(contactsToUpdate, dmlOption);
    }
}