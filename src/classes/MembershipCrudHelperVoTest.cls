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
        
        
        MembershipCrudHelperVo.MembershipUtilitiesVo membershipUtilitiesVo = new MembershipCrudHelperVo.MembershipUtilitiesVo();
        membershipUtilitiesVo.acquistion = 'Verbal';
        membershipUtilitiesVo.eDate = '12-12-2012';
        membershipUtilitiesVo.feeAmount = null;
        membershipUtilitiesVo.recordType = 'Parent';
        
        System.assertEquals(membershipUtilitiesVo.recordType, 'Parent');
    }
}