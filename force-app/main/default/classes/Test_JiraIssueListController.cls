@isTest
public class Test_JiraIssueListController {
    @testSetup 
    public static void testdata(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        insert setting; 
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st1;
        Rule_Set__c rule=Testdata.Newruleset('test', '1', true, 'TP',  'rulename' ,1,True);
        Child_Rule_Set__c child= Testdata.Newchildruleset('STRING','suppliedemail','', 'not equal to', rule,'1',true);
        
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, '1002', 'task', 'u1', 'sds', 'high', true);
        JiraIssue__c ji1=Testdata.createjira('test1', 'test1', 1213, '1003', 'task', 'u1', 'sds', 'high', true);
        
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        
        Case cs1 =Testdata.createcase('', Null, 'working', true);
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, true);
        JiraRelationship__c jr1= Testdata.createjirarelation(cs1.id, ji1.id, true);
        
        cs.Last_Comment_JIRA_Issue__c=jr.id;
        update cs;
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DEV');
        Testdata.CreateJSon(jp.id, jp.projectkey__c);
        Jira_ProjectFieldsMapping__c field= Testdata.createjirafieldmapp(jp.id,false ,'name','Subject','Subject', 'customfield_10020' ,True,  true , 'string',FALSE);
        field.salesforce_Object__c='Case';
        insert field;
    }
    
    @isTest 
    public static void TestScenerio1(){
        Test.startTest();
        case cs=[select id from case where status='New' limit 1];
        JiraIssue__c ji=[select id from JiraIssue__c  where Issueid__c=1212 limit 1];
        // JiraRelationship__c jr =[SELECT Id, JiraIssue__c, JiraIssue__r.IssueType__c, JiraIssue__r.Status__c, JiraIssue__r.IssueId__c, JiraIssue__r.IssueKey__c,JiraIssue__r.Assignee__c, JiraIssue__r.description__c, JiraIssue__r.Priority__c, JiraIssue__r.Reporter__c, JiraIssue__r.Summary__c, Jira_Case__c FROM JiraRelationship__c where  JiraIssue__c=:ji.id  and Jira_Case__c  =:cs.id limit 1];
        //String obj='case';
        //String query='SELECT Id, JiraIssue__c'+obj +'Relation__c  FROM JiraRelationship__c where JiraIssue__c=:'+ji.id +'and' + obj+'Relation__c=:' +cs.id +'limit 1' ;
        //JiraRelationship__c jrr=database.query(query);
        JiraRelationship__c jrr=[SELECT Id, JiraIssue__c, CaseRelation__c  FROM JiraRelationship__c where JiraIssue__c=:ji.id and CaseRelation__c=:cs.id  limit 1];
        jirarelationship__c jr;
        PageReference pag= Page.JIRAIssuesList;
        Test.setCurrentPage(pag);
        ApexPages.currentPage().getParameters().put('caseid',cs.id); 
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        JiraIssueListController jilist=new JiraIssueListController(sc);
        JiraIssueListController.JiraWrapper jirawrap =new JiraIssueListController.JiraWrapper(true,jrr,'resolution','fix versions');
        list<JiraIssueListController.JiraWrapper> listjwrap=new list<JiraIssueListController.JiraWrapper>();
        // listjwrap=jilist.jiraIssuesList;
        
        
        listjwrap.add(jirawrap);
        jilist.jiraIssuesList=listjwrap;
        
        jilist.unlinkIssues();
        
        Test.stopTest();
        List<jirarelationship__c> JrList =[select id, name from jirarelationship__c limit 2];
        System.assertEquals(JrList.size(),1);        
    }
    
    
}