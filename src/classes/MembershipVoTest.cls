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
        MembershipVo.MembershipInformation membershipInfo = new MembershipVo.MembershipInformation();
        membershipInfo.membershipInfo = membershipDetails;
        membershipInfo.membershipNumber = 'Test';
        membershipInfo.membershipSource = 'Test';
        membershipInfo.membershipSourceOptions = selectOptions;
        membershipInfo.membershipTypeMap = membershipTypes;
        membershipInfo.nearestBranchs = objects;
        membershipInfo.staffMember = 'Test';
        membershipInfo.acquistion = 'Written';
        membershipInfo.acquistionOptions = selectOptions;
        
        MembershipVo.AccountInfo accountInfo = new MembershipVo.AccountInfo();
        accountInfo.accountName = 'Nct child';
        accountInfo.accountNumber = '145263777';
        accountInfo.sortCode = 'Test';
        accountInfo.feeAmount = con.id;
        accountInfo.recordType = 'Test';
        accountInfo.redirectURL = 'Test';
        accountInfo.contactType = 'Test';
        accountInfo.isGiftAid = 'Test';
        accountInfo.targetCustomer = 'Test';
        accountInfo.sessionProfile = '';
        
        MembershipVo.BooleanCheck booleanChecking = new MembershipVo.BooleanCheck();
        booleanChecking.isContactExisting = true;
        booleanChecking.isMembershipExists = true;
        booleanChecking.displayMbrNoMessage = true;
        booleanChecking.displaySuccessMessage = true;
        booleanChecking.isStaff = true;
        booleanChecking.isVolunteer = true;
        booleanChecking.genderOptions = selectOptions;
        booleanChecking.salutationOptions = selectOptions;
        booleanChecking.twomems = true;

            
        MembershipVo.SecondContactVo secondContact = new MembershipVo.SecondContactVo();
            secondContact.secondContactEmail = 'Test';
            secondContact.secondContactFirstName = 'Test';
            secondContact.secondContactGenders = 'Test';
            secondContact.secondContactLastName = 'Test';
            secondContact.secondContactPhone = '09874657878';
            secondContact.salutationSecondary = 'Test';
            secondContact.eDate = 'today';
            secondContact.streetValue1 = 'Test';
            secondContact.streetValue2 = 'Test';

            
        MembershipVo.MemberCrudHelper memCrud = new MembershipVo.MemberCrudHelper();
        memCrud.pcont = con;
        memCrud.scont = scon;
        memCrud.accountName = 'Santhosh';
        memCrud.accountNumber = '145263777';
        memCrud.sortCode = 'CD-1234';
        memCrud.acquistion = 'Written';
        memCrud.membershipSource = 'Enquiry by phone - main NCT'; 
        memCrud.isVolunteer = true;
        //membership.memberCrud = memCrud;
        membership.BooleanChecking = booleanChecking;
        membership.accountInformation = accountInfo;
        membership.membershipDetails = membershipInfo; 
        membership.secondContact = secondContact;
        
        system.assertEquals('Credit/Debit Card', membershipInfo.membershipInfo.Payment_Method__c);
    }
}