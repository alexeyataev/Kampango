@isTest
private class MembershipBooleanCheckVoTest {
    
    static testMethod void membershipContactVoCheck(){
        
        MembershipBooleanCheckVo membershipBooleanCheckVo = new MembershipBooleanCheckVo();
        
        membershipBooleanCheckVo.displayMbrNoMessage = true;
        membershipBooleanCheckVo.displaySuccessMessage = true;
        membershipBooleanCheckVo.isCompanionContactExisting = true;
        membershipBooleanCheckVo.isContactExisting = true;
        membershipBooleanCheckVo.isGiftAid = 'false';
        membershipBooleanCheckVo.isMembershipExists = true;
        membershipBooleanCheckVo.isStaff = false;
        membershipBooleanCheckVo.isVolunteer = true;
        membershipBooleanCheckVo.twomems = true;
        
        System.assertEquals(membershipBooleanCheckVo.twomems, true);
        
       MembershipBooleanCheckVo.AccountDetails accountDetails = new MembershipBooleanCheckVo.AccountDetails();
       accountDetails.redirectURL = '';
       accountDetails.sessionProfile = '';
       accountDetails.targetCustomer = '';
       
       System.assertEquals(accountDetails.sessionProfile, '');
           
          
    }

}