@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #64 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing class AddMarketingPreferencesToCare {

    private static final Map<String, String> MARKETING_PREFERENCES_DOCUMENT_MAP = new Map<String, String> {
        'Has_Opted_In_Email__c' => 'GDPR007',
        'Has_Opted_In_SMS__c' => 'GDPR008',
        'Has_Opted_In_Post__c' => 'GDPR009',
        'Has_Opted_In_Telephone__c' => 'GDPR010'
    };

    @InvocableMethod
    public static void addMarketingPreferencesAction(List<Params> paramInstance) {
        addMarketingPreferencesFuture(paramInstance[0].contactId);
    }

    public static List<MarketingPreferencesResult> addMarketingPreferencesForContact(Contact cont) {
        List<MarketingPreferencesResult> marketingPreferencesResultList = new List<MarketingPreferencesResult>();
        if(cont.NCT_Number__c != null && cont.Individual != null) {
            for(String individualField : MARKETING_PREFERENCES_DOCUMENT_MAP.keySet()) {
                CareHelper.MarketingPreferencesObject marketingPreferencesObject = CareHelper.sendMarketingPreferences(cont, MARKETING_PREFERENCES_DOCUMENT_MAP.get(individualField), (Boolean)cont.Individual.get(individualField));
                if(marketingPreferencesObject.error != null) {
                    marketingPreferencesResultList.add(new MarketingPreferencesResult(individualField, CareHelper.FAILURE_STATUS, marketingPreferencesObject.error[0].errorMessage));
                }
            }
        }
        return marketingPreferencesResultList;
    }

    public static String getErrorLog(List<AddMarketingPreferencesToCare.MarketingPreferencesResult> marketingPreferencesResultList) {
        String marketingPreferencesError = '';
        for(AddMarketingPreferencesToCare.MarketingPreferencesResult marketingPreferencesResult : marketingPreferencesResultList) {
            if(marketingPreferencesResult.status == CareHelper.FAILURE_STATUS) {
                marketingPreferencesError = marketingPreferencesError + marketingPreferencesResult.errorMessage + '\r\n\r\n';
            }
        }
        return marketingPreferencesError;
    }

    @future(callout=true)
    private static void addMarketingPreferencesFuture(Id contactId){
        List<Contact> contactList = [
            SELECT  Care_Error_Log__c,
                    Individual.Has_Opted_In_Email__c,
                    Individual.Has_Opted_In_Post__c,
                    Individual.Has_Opted_In_SMS__c,
                    Individual.Has_Opted_In_Telephone__c,
                    Nct_Number__c
            FROM Contact
            WHERE Id =: contactId
        ];
        if(!contactList.isEmpty()) {
            List<AddMarketingPreferencesToCare.MarketingPreferencesResult> marketingPreferencesResultList = addMarketingPreferencesForContact(contactList[0]);
            String marketingPreferencesError = AddMarketingPreferencesToCare.getErrorLog(marketingPreferencesResultList);
            if(marketingPreferencesError != '') {
                contactList[0].Care_Status__c = CareHelper.FAILURE_STATUS;
                contactList[0].Care_Error_Log__c = CareHelper.addErrorLog(marketingPreferencesError, contactList[0].Care_Error_Log__c);
                update contactList;
            }
        }
    }

    public class Params {
        @InvocableVariable public String contactId;
    }
    
    public class MarketingPreferencesResult {
        public String fieldName;
        public String status;
        public String errorMessage;
        public MarketingPreferencesResult(String fieldName, String status, String errorMessage) {
            this.fieldName = fieldName;
            this.status = status;
            this.errorMessage = errorMessage;
        }
    }
}