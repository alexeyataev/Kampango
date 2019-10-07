@isTest
private class ViewPortTest {
	@isTest
    private static void testViewPort() {
        ViewPort vp;
        vp = new ViewPort(null);
        System.assertEquals(null, vp.getViewPort());

        vp = new ViewPort('1,2|error');
        System.assertEquals(null, vp.getViewPort());
        
        vp = new ViewPort('51.48166411,-2.69020473|51.43825789,error');
        System.assertEquals(null, vp.getViewPort());
        
        vp = new ViewPort('51.48166411,-2.69020473|51.43825789,-2.56248867');
        List<List<Double>> result = vp.getViewPort();
        System.assertNotEquals(null, result);
        System.assertEquals(51.48166411, result[0][0]);
    }
}