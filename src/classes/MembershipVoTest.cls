@isTest
	private class MembershipVoTest {
        
	@isTest static void MembershipVoMethod(){
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
        membership.accountName = 'Nct child';
        membership.accountNumber = '145263777';
        membership.acquistion = 'Written';
        membership.acquistionOptions = selectOptions;
        membership.cityValue = 'Test';
        membership.contactType = 'Test'; 
        membership.displayMbrNoMessage = true;
        membership.displaySuccessMessage = true;
        membership.contId = con.id;
        membership.counter = 'Test'; 
        membership.doNotCallOpt = true; 
        membership.displayValue = 'Test';
        membership.eDate = 'today';
        membership.email = 'Test';
        membership.emailOpt = true;
        membership.etSpecific = true;
        membership.expDate = system.date.today();
        membership.feeAmount = con.id;
        membership.firstname = 'Test';
        membership.genderOptions = selectOptions;
        membership.genders = 'Test';
        membership.genderValue = 'Test';
        membership.isContactExisting = true;
        membership.isMembershipExists = true;
        membership.isGiftAid = 'Test';
        membership.isPractitioner = true;
        membership.isStaff = true;
        membership.isVolunteer = true;
        membership.lastname = 'Nct childs';
        membership.lifeMembership = true;
        membership.membershipInfo = membershipDetails;
        membership.membershipNumber = 'Test';
        membership.membershipSource = 'Test';
        membership.membershipSourceOptions = selectOptions;
        membership.membershipTypeMap = membershipTypes;
         membership.nearestBranchs = objects;
      
            membership.phone = 'Test';
            membership.postCode = 'Test';
            membership.postOpt = true;
            membership.primaryContact = con;
            membership.recordType = 'Test';
            membership.redirectURL = 'Test';
            membership.salutation = 'Test';
            membership.salutationOptions = selectOptions;
            membership.salutationPrimary = 'Test';
            membership.salutationSecondary = 'Test';
            membership.secondaryContact = con;
            membership.secondContactEmail = 'Test';
            membership.secondContactFirstName = 'Test';
            membership.secondContactGenders = 'Test';
            membership.secondContactLastName = 'Test';
            membership.secondContactPhone = 'Test';
            membership.selectBranch = con.id;
            membership.sessionProfile = '';
           
            membership.smsOpt = false;
            membership.sortCode = 'Test';
            membership.staffMember = 'Test'; 
            membership.stateValue = 'Test';
            membership.streetValue = 'Test';
            membership.streetValue1 = 'Test';
            membership.streetValue2 = 'Test';
            membership.targetCustomer = 'Test';
            membership.twomem = true;
            membership.twomems = true;
        system.assertEquals('Credit/Debit Card', membership.membershipInfo.Payment_Method__c);
        system.assertEquals('Nct childs', membership.lastname);
    }
}