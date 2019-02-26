@isTest
private class MembershipCrudHelperTest {
    @isTest
    private static void membershipCrudTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName='standarduser@testorg.com.test');
       
            Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt where Payment_Method__c = 'Credit/Debit Card' limit 1];
        npe03__Recurring_Donation__c recDonate = new npe03__Recurring_Donation__c();
        cpm__Payment_Profile__c paymntProfl = new cpm__Payment_Profile__c();
        gaid__Gift_Aid_Declaration__c gftAid = new gaid__Gift_Aid_Declaration__c();
        list<cpm__Payment_Profile__c> paymntProflRecord = new list<cpm__Payment_Profile__c>();
        list<String> accountDetails = new list<String>{'145263777','Santhosh','CD-1234','Written','Enquiry by phone - main NCT'};
        String isGiftAid = 'true';
        
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
         
        cpm__Payment_Profile__c paymntProfile = new cpm__Payment_Profile__c();
  
        MembershipCrudHelper memCrud = new MembershipCrudHelper();
        memCrud.pcont = con;
        memCrud.scont = scon;       
        paymntProfl = memCrud.paymentProfile(accountDetails);
        system.assertEquals(accountDetails[2],paymntProfl.paybacs__Sort_Code__c);      
        gftAid = memCrud.giftAid(isGiftAid,membershipDetails,accountDetails);
        system.assertEquals(true,gftAid.gaid__Active__c);
        id id1= paymntProfl.id;
        list<cpm__Payment_Profile__c> profid =[SELECT id from cpm__Payment_Profile__c WHERE ID=:id1 limit 1];     
        if(profid.size()>0){
            recDonate = new npe03__Recurring_Donation__c();
            recDonate = memCrud.recDonation(membershipDetails,paymntProfile,accountDetails); 
        }    
        system.assertEquals('Pending', recDonate.Membership_Status__c);
    }  
    @isTest
    private static void membershipCrudTest2(){ 
        Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt where Payment_Method__c = 'Direct Debit' limit 1];
        list<cpm__Payment_Profile__c> paymntProflRecord = new list<cpm__Payment_Profile__c>();
        list<gaid__Gift_Aid_Declaration__c> giftAidDeclareRecord = new list<gaid__Gift_Aid_Declaration__c>();
        list<npe03__Recurring_Donation__c> recDonateRecord = new list<npe03__Recurring_Donation__c>();
        
        String isGiftAid = 'true';
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
        system.debug('accountid  ' + con.AccountId);
        insert con;
        cpm__Payment_Profile__c paymentProfile = new cpm__Payment_Profile__c();       
        cpm__Payment_Profile__c paymntProfile = new cpm__Payment_Profile__c();
        paymntProfile.cpm__Contact__c = con.id;
        paymntProfile.cpm__Bank_Account__c = 'NCT Bank';
        paymntProfile.cpm__Holder_Name__c  = 'NCT CHILD CUSTOMER';
        paymntProfile.paybacs__Sort_Code__c = 'CD-1234';
        paymntProflRecord.add(paymntProfile);
        insert paymntProflRecord;
        
        gaid__Gift_Aid_Declaration__c giftAidDeclare = new gaid__Gift_Aid_Declaration__c();
        giftAidDeclare.gaid__Type__c = 'Ongoing';
        giftAidDeclare.gaid__Acquisition_Method__c = 'Written';
        giftAidDeclare.gaid__Active__c = true;
        giftAidDeclare.gaid__Start_Date__c = system.today();
        giftAidDeclare.gaid__Contact__c = con.id;
        giftAidDeclare.gaid__Date_Made__c = system.today();
        giftAidDeclareRecord.add(giftAidDeclare);
        insert giftAidDeclareRecord;
        
        npe03__Recurring_Donation__c recDonate = new npe03__Recurring_Donation__c();
        recDonate.Name = 'NCT Child';
        recDonate.npe03__Amount__c = 60;
        recDonate.npe03__Installment_Period__c = 'Monthly';
        recDonate.CARE_Payment_Frequency__c = 'NCT CHILD TRUST';
        recDonate.First_Payment__c = system.today();
        recDonate.First_Contact__c = con.id; 
        recDonate.Membership_Status__c = 'Pending'; 
        recDonate.Membership_type__c = '18 month - Joint';
        recDonate.npe03__Contact__c = con.id;
        recDonateRecord.add(recDonate);
        insert recDonateRecord;
        
        test.setCreatedDate(paymntProflRecord[0].id, system.date.today());
        test.setCreatedDate(giftAidDeclareRecord[0].id, system.date.today());
        test.setCreatedDate(recDonateRecord[0].id, system.date.today());
        list<String> accountDetails = new list<String>{'145263777','Santhosh','CD-1234','Digital','Enquiry by phone - main NCT'};
        
        MembershipCrudHelper memCrud = new MembershipCrudHelper();
        memCrud.pcont = con;
        memCrud.scont = scon;
        memCrud.paymentProfileRecord = paymntProflRecord;        
        paymntProflRecord[0] = memCrud.paymentProfile(accountDetails);
        system.assertEquals(1,memCrud.paymentProfileRecord.size());             
        memCrud.giftAidDeclarationRecord  = giftAidDeclareRecord;
        giftAidDeclareRecord[0] = memCrud.giftAid(isGiftAid,membershipDetails,accountDetails); 
        system.assertEquals(1,memCrud.giftAidDeclarationRecord.size());
        memCrud.recDonationRecord = recDonateRecord;        
        recDonateRecord[0] = memCrud.recDonation(membershipDetails,paymentProfile,accountDetails);
        system.assertEquals(1,memCrud.recDonationRecord.size());
    }
    @isTest 
    private static void contactnotexists(){
        String isGiftAid = 'true';
        Membership_Type__mdt  membershipDetails = new Membership_Type__mdt();
        gaid__Gift_Aid_Declaration__c gftAid = new gaid__Gift_Aid_Declaration__c();
        cpm__Payment_Profile__c paymntProfl = new cpm__Payment_Profile__c();
        contact con = new contact();
        list<String> accountDetails = new list<String>{'145263777','Santhosh','CD-1234','Text','Enquiry by phone - main NCT'};
        
        MembershipCrudHelper memCrud = new MembershipCrudHelper();
        memCrud.scont = con;
        memCrud.paymentProfile(accountDetails);
        memCrud.giftAid(isGiftAid,membershipDetails,accountDetails);
        system.assertNotEquals(true,gftAid.gaid__Active__c);
        memCrud.recDonation(membershipDetails,paymntProfl,accountDetails);
        
    }
    @isTest
    private static void giftAidRecordCreation1(){
        
        Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt limit 1];
   
        list<gaid__Gift_Aid_Declaration__c> giftAidDeclareRecord = new list<gaid__Gift_Aid_Declaration__c>();
        list<String> accountDetails = new list<String>{'145263777','Santhosh','CD-1234','','Enquiry by phone - main NCT'};
         String isGiftAid = 'true';
        account acct = new account();
        acct.name = 'account details';
        insert acct;
        
        contact con = new contact();
        con.FirstName = 'NCT Child';
        con.LastName = 'Trust';
        con.Email = 'nct@gmail.com';
        con.Prefered_First_Name__c = 'NCT';
        con.AccountId = acct.Id;
        system.debug('accountid  ' + con.AccountId);
        insert con;
        
        gaid__Gift_Aid_Declaration__c giftAidDeclare = new gaid__Gift_Aid_Declaration__c();
        giftAidDeclare.gaid__Type__c = 'Ongoing';
        giftAidDeclare.gaid__Acquisition_Method__c = 'Written';
        giftAidDeclare.gaid__Active__c = true;
        giftAidDeclare.gaid__Start_Date__c = system.today();
        giftAidDeclare.gaid__Contact__c = con.id;
        giftAidDeclare.gaid__Date_Made__c = system.today();
        giftAidDeclareRecord.add(giftAidDeclare);
        insert giftAidDeclareRecord;
        
        test.setCreatedDate(giftAidDeclareRecord[0].id, system.date.today());
        MembershipCrudHelper memCrud = new MembershipCrudHelper();
        memCrud.giftAidDeclarationRecord  = giftAidDeclareRecord;
        memCrud.pcont = con;
        giftAidDeclareRecord[0] = memCrud.giftAid(isGiftAid,membershipDetails,accountDetails);
        system.assertEquals(true,giftAidDeclare.gaid__Active__c);
    }
    @isTest
    private static void giftAidRecordCreation2(){
        Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt limit 1];
    
        gaid__Gift_Aid_Declaration__c gftAid = new gaid__Gift_Aid_Declaration__c();
        
        list<String> accountDetails = new list<String>{'145263777','Santhosh','CD-1234','','Enquiry by phone - main NCT'};
        String isGiftAid = 'true';
        
        account acct = new account();
        acct.name = 'account details';
        insert acct;
        
        contact con = new contact();
        con.FirstName = 'NCT Child';
        con.LastName = 'Trust';
        con.Email = 'nct@gmail.com';
        con.Prefered_First_Name__c = 'NCT';
        con.AccountId = acct.Id;
        insert con;
          
        
         MembershipCrudHelper memCrud = new MembershipCrudHelper();   
        memCrud.pcont = con;
         gftAid = memCrud.giftAid(isGiftAid,membershipDetails,accountDetails);
         system.assertEquals(true,gftAid.gaid__Active__c);
    }  
}