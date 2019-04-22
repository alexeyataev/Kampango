@isTest
private class MembershipContactVoTest{
   static testMethod void membershipContactVoCheck(){
       
       
    MembershipContactVo membershipContactVo = new MembershipContactVo();
    membershipContactVo.acquistionOptions = null;     
    membershipContactVo.genderOptions = null;
    membershipContactVo.salutationOptions = null;
    membershipContactVo.staffMember = '';
    membershipContactVo.streetValue1 = '';
    membershipContactVo.streetValue2 = '';
       
    System.assertEquals(membershipContactVo.streetValue2, '');
        
    MembershipContactVo.SecondContactVo secondContactVo = new MembershipContactVo.SecondContactVo();
    secondContactVo.secondContactFirstName = 'First Name';
    secondContactVo.secondContactLastName = 'Last Name';
    secondContactVo.secondContactEmail = 'first.last@test.com';
    secondContactVo.secondContactPhone = '01234567890';
    secondContactVo.salutationSecondary = 'Mr.';
    secondContactVo.secondContactGenders = 'Male';
       
    system.assertEquals(secondContactVo.secondContactGenders, 'Male');
       
    
  }
}