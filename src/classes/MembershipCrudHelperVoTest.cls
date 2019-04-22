@isTest
private class MembershipCrudHelperVoTest {
    @isTest static void membershipCrudHelperVoMethod(){
        
        MembershipCrudHelperVo membershipCrudHelperVo = new MembershipCrudHelperVo();
        
        membershipCrudHelperVo.accountName = 'Test';
        membershipCrudHelperVo.accountNumber = '123';
        membershipCrudHelperVo.acquistion = 'Test';
        membershipCrudHelperVo.isVolunteer = true;
        membershipCrudHelperVo.membershipSource = 'Test';
        membershipCrudHelperVo.pcont = null;
        membershipCrudHelperVo.scont = null;
        membershipCrudHelperVo.sortCode	= '123';
        
        System.assertEquals(membershipCrudHelperVo.sortCode, '123');
    }
}