public without sharing class BookingJourneyHelper {

    @InvocableMethod(label='Update Contact')
    public static List<Contact> updateContact(List<Contact> contacts){
        for(Contact contact: contacts){
            contact.npe01__PreferredPhone__c = String.valueOf(contact.npe01__PreferredPhone__c);
            contact.Salutation = String.valueOf(contact.Salutation);
        }
        if(contacts != null && !contacts.isEmpty()){
            try{
                upsert contacts Id;
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

    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #51 - https://confluence.nct.org.uk:8443/x/EoSO
    @AuraEnabled(cacheable=true)
    public static Individual retrieveMarketingPreferences(String individualId){
        List<Individual> individuals = new List<Individual>();
        if(String.isNotBlank(individualId)){
            individuals = [
                SELECT Email__c, Post__c, SMS__c, Telephone__c
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

}