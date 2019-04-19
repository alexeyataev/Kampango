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
        
        MembershipBooleanCheckVo.MemberCrudHelper memberCrudHelper = new MembershipBooleanCheckVo.MemberCrudHelper();
        
        memberCrudHelper.accountName = 'Test';
        memberCrudHelper.accountNumber ='123';
        memberCrudHelper.acquistion = 'Verbal';
        memberCrudHelper.isVolunteer = true;
        memberCrudHelper.membershipSource = 'Test';
        memberCrudHelper.pcont = null;
        memberCrudHelper.scont = null;
        memberCrudHelper.sortCode = '123';
        
        System.assertEquals(memberCrudHelper.sortCode, '123');
          
    }

}