@isTest
private class MembershipContactVoTest{
   static testMethod void membershipContactVoCheck(){
    MembershipContactVo membershipContactVo = new MembershipContactVo();
    MembershipContactVo.SecondContactVo secondContactVo = new MembershipContactVo.SecondContactVo();
    secondContactVo.secondContactFirstName = 'First Name';
    secondContactVo.secondContactLastName = 'Last Name';
    secondContactVo.secondContactEmail = 'first.last@test.com';
    secondContactVo.secondContactPhone = '01234567890';
    secondContactVo.salutationSecondary = 'Mr.';
    secondContactVo.secondContactGenders = 'Male';
       
    system.assertEquals(secondContactVo.secondContactGenders, 'Male');
       
    MembershipContactVo.ContactVo contactVo = new MembershipContactVo.ContactVo();
    contactVo.eDate = '12-12-2012';
    contactVo.streetValue1 = 'Test';
    contactVo.streetValue2 = 'Test';
    contactVo.contactType = 'Individual';
    contactVo.recordType = 'Parent';
    contactVo.acquistion = 'Verbal';
    contactVo.acquistionOptions = new list<SelectOption>();
    contactVo.salutationOptions = new list<SelectOption>();
    contactVo.genderOptions = new list<SelectOption>();
       
    System.assertEquals(contactVo.recordType, 'Parent');
  }
}