@isTest()
public class Test_RefreshScheduler {
    
    public TestMethod Static Void TestData(){
        Test.startTest();
        RefreshScheduler sch1=new RefreshScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Refresh001', sch, sch1);
        Test.stopTest();  
        
        System.assertEquals(sch1.valid,true);
    }
}