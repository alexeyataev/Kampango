@isTest
private class AcessTokenResponseVoTest {
    @isTest
    private static void acessTokenTest(){
        AcessTokenResponseVo acessToken = new AcessTokenResponseVo();
        acessToken.accessToken = '';
        acessToken.id = '';
        acessToken.instanceurl = 'www.google.com';
        acessToken.issuedat = '20-04-2019';
        acessToken.signature = 'done';
        acessToken.tokentype = 'string';
        system.assertEquals('', acessToken.accessToken);
        system.assertEquals('20-04-2019', acessToken.issuedat);
    }
      
}