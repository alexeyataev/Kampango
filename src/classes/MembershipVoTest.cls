@isTest
private class MembershipVoTest {
    @isTest
    private static void membership(){
        
        MembershipVo.ContactVo contact = new MembershipVo.ContactVo();
        contact.salutation = 'Mr.';
        contact.email = 'nct@gmail.com';
        contact.firstName = 'NCT';
        contact.gender = 'Male';
        contact.lastName = 'Trust';
        contact.mobile = '7865544345';
        contact.nctBranch = '';
        contact.phone = '78687687676';
        contact.dob = '16-04-2019';
        
        MembershipVo.AddressVo address = new MembershipVo.AddressVo();
        address.addressLine1 = 'Street1';
        address.addressLine2 = 'Street2';
        address.addressLine3 = 'Street3';
        address.building = 'Building1';
        address.city = 'London';
        address.postCode = 'Sw11';
        address.state = 'Europe';
        
        MembershipVo.DirectDebitVo directDebit = new MembershipVo.DirectDebitVo();
        directDebit.accountName = 'NCT Child';
        directDebit.accountNumber = 'M-40027923';
        directDebit.colletionDate = '25-07-2019';
        directDebit.paymentDate = '16-04-2019';
        directDebit.sortCode = 'Sw11';
        
        MembershipVo.MarketingPreferenceVo marketingPreference = new MembershipVo.MarketingPreferenceVo();
        marketingPreference.email = 'Nct@gmail.com';
        marketingPreference.phone = true;
        marketingPreference.post = 'Sw123';
        marketingPreference.sms = 'message';
        
        
        
        MembershipVo membership = new MembershipVo();
        membership.membershipInfo = new Membership_Type__mdt();
        membership.isVolunteer = true;
        membership.isGiftAidSelected = true;
        membership.isJointMembership = false;
        membership.isPractitioner = false;
        membership.membershipType = '18 month - Individual';
        membership.paymentMethod = 'Credit Card';
        membership.membershipNumber = 'M-40027923';
        membership.keepMeUpdated = true;
        membership.address = address;
        membership.primaryContact = contact;
        membership.secondaryContact = contact;
        membership.directDebitDetails = directDebit;
        membership.marketingPreference = marketingPreference;
        system.assertEquals('18 month - Individual', membership.membershipType);
        system.assertEquals('M-40027923',membership.membershipNumber);
    }

}