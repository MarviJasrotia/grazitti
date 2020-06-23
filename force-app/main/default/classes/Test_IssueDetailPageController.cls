@isTest
public class Test_IssueDetailPageController {
    @testSetup 
    public static void testdata(){
        Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', true);
        
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, 'TJC-26', 'task', 'u1', 'sds', 'high', true);
        JiraIssue__c ji1=Testdata.createjira('test1', 'test1', 1213, '1003', 'task', 'u1', 'sds', 'high', true);
        
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        Case cs1 =Testdata.createcase('', Null, 'working', true);
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, true);
        JiraRelationship__c jr1= Testdata.createjirarelation(cs1.id, ji1.id, true);
    }
    
    @isTest 
    public static void TestScenerio1(){
        case cs=[select id,SuppliedEmail from case where status='new' limit 1];
        PageReference pag= Page.IssueDetailPage;
        Test.setCurrentPage(pag);
        Test.startTest();
        JiraIssue__c ji=[select id from JiraIssue__c  where Issueid__c=1212 limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ji);
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        IssueDetailPageController Is=new IssueDetailPageController(sc);
        Test.stopTest();
        System.assertEquals(IS.jiraIssueId,ji.Id);
        
    }
}