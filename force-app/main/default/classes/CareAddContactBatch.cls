global class CareAddContactBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, Email, MailingPostalCode, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE RecordType.Name = \'Client\' AND NCT_Number__c = null');
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){
        Map<Id, String> branchNumberByContactId = new Map<Id, String>();
        Map<String, Id> accountIdByBranchNumber = new Map<String, Id>();

        List<Contact> contUpdateList = new List<Contact>();
        for(Contact cont : scope) {
            CareRequestBodyUtil.ContactDetails responseContact = CareHelper.sendContact(cont);
            String nctNumber = responseContact.contactNumber;
            if (nctNumber != null) {
                cont.NCT_Number__c = nctNumber;
                branchNumberByContactId.put(cont.Id, responseContact.branch);
                contUpdateList.add(cont);
            }
        }
        List<String> branchNumbers = branchNumberByContactId.values();
        List<Account> accounts = [
            SELECT Id 
            FROM Account 
            WHERE AccountNumber IN :branchNumbers
        ];
        for (Account acc : accounts) {
            accountIdByBranchNumber.put(acc.Branch_Number__c, acc.Id);
        }
        for (Contact cont : contUpdateList) {
            String curBranchNumber = branchNumberByContactId.get(cont.Id);
            cont.Account = accountIdByBranchNumber.get(curBranchNumber);
        }
        update contUpdateList;
    }

   global void finish(Database.BatchableContext BC){
   }
}