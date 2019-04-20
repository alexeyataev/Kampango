@isTest
private class MembershipVoTest {
        
	@isTest static void membershipVoMethod(){
        account acct = new account();
        acct.name = 'account details';
        insert acct;
        contact scon = new contact();
        
        contact con = new contact();
        con.FirstName = 'NCT Child';
        con.LastName = 'Trust';
        con.Email = 'nct@gmail.com';
        con.Prefered_First_Name__c = 'NCT';
        con.AccountId = acct.Id;
        insert con;
        
        Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt where Payment_Method__c = 'Credit/Debit Card' limit 1]; 
		list<SelectOption> selectOptions = new list<SelectOption>();
        Map<String, list<sObject>> objects = new Map<String, list<sObject>>();
        Map<String, List<Membership_Type__mdt>> membershipTypes = new Map<String, List<Membership_Type__mdt>>();
        
        MembershipVo  membership = new MembershipVo();
        membership.membershipInfo = membershipDetails;
        membership.membershipNumber = 'Test';
        membership.membershipSource = 'Test';
        membership.membershipSourceOptions = selectOptions;
        membership.membershipTypeMap = membershipTypes;
        membership.nearestBranchs = objects;      
        membership.accountName = 'Nct child';
        membership.accountNumber = '145263777';
        membership.sortCode = 'Test';
        membership.acquistion = 'Verbal';
        membership.eDate = '12-12-2012';
        membership.feeAmount = null;       
        system.assertEquals(membership.sortCode, 'Test');
    }
}