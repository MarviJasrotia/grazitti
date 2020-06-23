@istest
public class UpdateJiraFromRelationBatchTest {
    
    @isTest
    public static void TestScenario1(){
        
    Jira_login__c sett = New Jira_login__c(Password__c = '1Q5hR1GNASY9GSDGDZextLVQ9HtT62Spf3enB68SA7w=',Name ='JIRA');
        insert sett;
        
        Jira_login__c setting=new Jira_login__c();// Testdata.createjirasetting('display',true, 'www.test.com', 'JIRAaa', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        setting.Basic_Authentication__c=true;
        setting.JIRA_Comments_Sync_Enable_SF__c=true;
        setting.DisplayName__c='display';
        setting.End_Point__c='www.test.com';
        setting.Name='JIRA';
        Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
        Blob clearData=Blob.valueOf('password');
        setting.Password__c=EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', encryptionKey, clearData));
        setting.SyncServer__c=false;
        setting.License_Key__c='license';
        setting.username__c='username';        
        insert setting;
        
       // CaseNumberField__c cus = New CaseNumberField__c(JiraFieldApi__c = 'customfield_10017',name='FieldApi');
      //  insert cus;
        Map<String,String> validKeys = New Map<String,String>();
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='jiraproject';
        pm.ProjectKey__c='GC';
        pm.IssueType__c = 'Improvement,New Feature,Bug,Task';
        insert pm;
        
        Jira_Project__c pm1 =new Jira_Project__c();
        pm1.ProjectId__c='10021';
        pm1.Name='jiraproject';
        pm1.ProjectKey__c='DEV';
        pm1.IssueType__c = 'Improvement,New Feature,Bug,Task';
        insert pm1;
        
        list<Case> caseList=new  list<Case>();
        Case cs1=new Case(Subject='Test',Description='Desc',Status='New',origin='Phone');
        Case cs=new Case(Subject='Test',Description='Desc',Status='New',origin='Phone');
        
        Insert caseList;
        
        Set<String> caseSet=new Set<String>();
        caseSet.add(cs1.id);
        caseSet.add(cs.id);
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'Labels',null,'labels', 'labels' ,true, true ,'labels',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        jirafieldmap.add(proMap1);
        
        insert jirafieldmap;
        
        validKeys.put(pm.ProjectKey__c , pm.IssueType__c);
        validKeys.put(pm1.ProjectKey__c , pm1.IssueType__c);
      
        
        Account ac=new Account();
        ac.name='test';
        insert ac;
        
        String json_str = '{"key":"GC-1057","id":"11765","fields":{"customfield_10020":"'+ ac.id +'"}}';
        
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, '1002', 'task', 'u1', 'sds', 'high', false);
        ji.name = '1002';
        ji.JsonData__c= json_str;
        ji.Project__c = null;
       
        insert ji;
        
        Map<String,Map<String,Set<String>>> UpdateJiraToObjectToObjectIds=new  Map<String,Map<String,Set<String>>>();
        Map<String,Set<String>> tempData=New Map<String,Set<String>>();
        tempData.put(jirafieldmap[0].id,caseSet);
        UpdateJiraToObjectToObjectIds.put(ji.Name,tempData);
        
        List<JiraIssue__c> batchSet = New List<JiraIssue__c>();
        For(JiraIssue__c Jiss :[Select Id,jsondata__c,issueKey__c From JiraIssue__c]){
            batchSet.add(Jiss);
        }
        Test.StartTest(); 
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        UpdateJiraFromRelationBatch myBatch = New UpdateJiraFromRelationBatch(UpdateJiraToObjectToObjectIds);
        
        
        ID batchprocessid = Database.executeBatch(myBatch);
        Test.stopTest();
        List<JiraIssue__c> JIraIssuelist=[SELECT Name From JiraIssue__c ];
        
        System.assertEquals(JIraIssuelist[0].Name,'1002');
      
    }
    
}