@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #64 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing class AddMarketingPreferencesToCare {

    private static final Map<String, String> MARKETING_PREFERENCES_DOCUMENT_MAP = new Map<String, String> {
        'Email__c' => 'GDPR007',
        'SMS__c' => 'GDPR008',
        'Post__c' => 'GDPR009',
        'Telephone__c' => 'GDPR010'
    };

    @InvocableMethod
    public static void addMarketingPreferences(List<Params> paramInstance) {
        Boolean marketingPreferenceGranted = false;
        List<Contact> contactList = [
            SELECT  Nct_Number__c,
                    Individual.Email__c,
                    Individual.SMS__c,
                    Individual.Telephone__c,
                    Individual.Post__c
            FROM Contact
            WHERE(Id =: paramInstance[0].contactId AND Nct_Number__c != null)
            LIMIT 1
        ];

        if(!contactList.isEmpty()) {
            for(String individualField : MARKETING_PREFERENCES_DOCUMENT_MAP.keySet() ) {
                CareHelper.sendMarketingPreferences(contactList[0].Nct_Number__c, MARKETING_PREFERENCES_DOCUMENT_MAP.get(individualField), (Boolean)contactList[0].Individual.get(individualField));
            }
        }
    }

    public class Params {
        @InvocableVariable public String contactId;
    }
}