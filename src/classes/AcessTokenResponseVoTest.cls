@isTest
private class AcessTokenResponseVoTest {
    @isTest
    private static void acessTokenTest(){
        AcessTokenResponseVo acessToken = new AcessTokenResponseVo();
        acessToken.accessToken = '0011j000006upMPSDFGAThJKNV578GHH';
        acessToken.id = Label.UserHomeControllerTestID;
        acessToken.instanceurl = 'www.google.com';
        acessToken.issuedat = '20-04-2019';
        acessToken.signature = 'done';
        acessToken.tokentype = 'string';
        system.assertEquals('0011j000006upMPSDFGAThJKNV578GHH', acessToken.accessToken);
        system.assertEquals('20-04-2019', acessToken.issuedat);
    }
      
}