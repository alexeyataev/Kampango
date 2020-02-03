@SuppressWarnings('PMD.VariableNamingConventions')
public with sharing class CareRequestBodyUtil {
    public static final String AUTH_KEY = Care_Settings__c.getOrgDefaults().Auth_Key__c;
    public static final String SF_ENVIRONMENT_NAME = Care_Settings__c.getOrgDefaults().SF_Environment_Name__c;
    public static final String SOURCE = Care_Settings__c.getOrgDefaults().Source__c;
    public static final String URL = Care_Settings__c.getOrgDefaults().Url__c;
    private static final String USER_LOG_NAME = Care_Settings__c.getOrgDefaults().User_Log_Name__c;
    private static final String CLAIM_DAY = '3';
    public static String createSendContactBody(Contact cont) {
        AddUpdateContactRequest addUpdateContactRequest = new AddUpdateContactRequest();
        addUpdateContactRequest.authKey = AUTH_KEY;
        addUpdateContactRequest.pagename = SF_ENVIRONMENT_NAME;
        addUpdateContactRequest.source = SOURCE;
        addUpdateContactRequest.branch = cont.Branch__r.Branch_Number__c;
        addUpdateContactRequest.userLogname = USER_LOG_NAME;
        addUpdateContactRequest.surname = cont.LastName;
        addUpdateContactRequest.firstName = cont.FirstName;
        addUpdateContactRequest.contactNumber = cont.NCT_Number__c;
        addUpdateContactRequest.gender = cont.Gender__c;
        addUpdateContactRequest.postcode = cont.MailingPostalCode;
        addUpdateContactRequest.email = cont.Email;
        addUpdateContactRequest.address = cont.MailingStreet;
        addUpdateContactRequest.town = cont.MailingCity;
        addUpdateContactRequest.country = cont.MailingCountry;
        return JSON.serialize(addUpdateContactRequest, true);
    }
    public static String createSendBankDetailsBody(cpm__Payment_Profile__c paymentProfile, Contact cont) {
        AddBankDetailsRequest addBankDetailsRequest = new AddBankDetailsRequest();
        addBankDetailsRequest.authKey = AUTH_KEY;
        addBankDetailsRequest.pagename = SF_ENVIRONMENT_NAME;
        addBankDetailsRequest.source = SOURCE;
        addBankDetailsRequest.branch = cont.Branch__r.Branch_Number__c;
        addBankDetailsRequest.userLogname = USER_LOG_NAME;
        addBankDetailsRequest.sortCode = paymentProfile.paybacs__Sort_Code__c;
        addBankDetailsRequest.acctNumber = paymentProfile.cpm__Bank_Account__c;
        addBankDetailsRequest.acctName = paymentProfile.cpm__Holder_Name__c;
        addBankDetailsRequest.contactKey = cont.NCT_Number__c;
        return JSON.serialize(addBankDetailsRequest, true);
    }
    public static String createAddMembershipBody(cpm__Installment__c installment) {
        Map<String, String> paymentMethodMap = new Map<String, String> {
            'CreditCard' => 'CC',
            'Care Membership' => 'DDQ'
        };
        String paymentMethod = paymentMethodMap.get(installment.cpm__Payment_Method__c);
        AddMembership addMembership = new AddMembership();
        addMembership.authKey = AUTH_KEY;
        addMembership.pagename = SF_ENVIRONMENT_NAME;
        addMembership.source = SOURCE;
        addMembership.branch = installment.cpm__Contact__r.Branch__r.Branch_Number__c;
        addMembership.userLogname = USER_LOG_NAME;
        addMembership.paymentMethod = paymentMethod;
        addMembership.bankDetailNumber = installment.Bank_Details_Number__c;
        addMembership.claimDay = CLAIM_DAY;
        addMembership.ga_decl_1 = installment.ga_decl_1__c;
        addMembership.ga_decl_2 = installment.ga_decl_2__c;
        addMembership.contactKey1 = installment.cpm__Contact__r.NCT_Number__c;
        addMembership.contactKey2 = installment.Partner_Contact__r.NCT_Number__c;
        addMembership.mType = installment.Membership_Type__c;
        addMembership.amount = String.valueOf(installment.cpm__Amount__c);
        addMembership.txCode = installment.Id;
        return JSON.serialize(addMembership, true);
    }
    private abstract class BaseRequest {
        private String authKey {get;set;}
        private String pagename {get;set;}
        private String source {get;set;}
        private String branch {get;set;}
        private String userLogname {get;set;}
    }
    private class AddUpdateContactRequest extends BaseRequest {
        private String surname {get;set;}
        private String firstName {get;set;}
        private String contactNumber {get;set;}
        private String gender {get;set;}
        private String postcode {get;set;}
        private String email {get;set;}
        private String address {get;set;}
        private String town {get;set;}
        private String country {get;set;}
    }
    private class AddBankDetailsRequest extends BaseRequest {
        private String sortCode {get;set;}
        private String acctNumber {get;set;}
        private String acctName {get;set;}
        private String contactKey {get;set;}
    }
    private class AddMembership extends BaseRequest {
        private String paymentMethod {get;set;}
        private String bankDetailNumber {get;set;}
        private String claimDay {get;set;}
        private String ga_decl_1 {get;set;}
        private String ga_decl_2 {get;set;}
        private String contactKey1 {get;set;}
        private String contactKey2 {get;set;}
        private String mType {get;set;}
        private String amount {get;set;}
        private String txCode {get;set;}
    }
    private abstract class BaseResponse {
        public List<ErrorObject> error {get;set;}
    }
    public class ErrorObject {
        public String errorMessage {get;set;}
        public String errorNumber {get;set;}
    }
    public class ContactOjbect extends BaseResponse {
        public ContactDetails contact {get;set;}
    }
    public class ContactDetails {
        public String contactNumber {get;set;}
    }
    public class ContactBankAccountObject extends BaseResponse {
        public ContactBankAccountDetails contactBankAccount {get;set;}
    }
    public class ContactBankAccountDetails {
        public String contactNumber {get;set;}
        public String bankDetailNumber {get;set;}
        public String information {get;set;}
    }
    public class MembershipOjbect extends BaseResponse {
        public String status {get;set;}
    }
}