@isTest
public class Test_SearchJiraComponentController {
    @isTest static void TestScenerio1() {
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        setting.Basic_Authentication__c=true;
        insert setting; 
        Jira_Project__c p= new Jira_Project__c();
        p.Name = 'JIRA Connector';
        p.ProjectKey__c = 'JC';
        p.ProjectId__c = '10001';
        p.DefaultIssueType__c = 'Task';
        p.IssueType__c='Bug,Story,Task,Epic';
        insert p;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpSearchJiraComponentController1 ());
        SearchJiraComponentController.fetchAllProjects();
        test.stopTest();
        System.assertEquals(p.Id!=null, true);
    }
    
    @isTest static void TestScenerio2() {    
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        setting.Basic_Authentication__c=true;
        insert setting; 
        Jira_Project__c p= new Jira_Project__c();
        p.Name = 'JIRA Connector';
        p.ProjectKey__c = 'JC';
        p.ProjectId__c = '10001';
        p.DefaultIssueType__c = 'Task';
        p.IssueType__c='Bug,Story,Task,Epic';
        insert p;
        String searchtext = 'test';
        String componentList = '["JIRA Connector_10004","JIRA Connector_10003","JIRA Connector_10002"]';
        String issueTypeList = '["JIRA Connector_Task","JIRA Connector_Story","JIRA Connector_Bug","JIRA Connector_Epic"]';
        String startAt = null;  
        Integer indxval = null;
        Integer indexv = 0;
        Integer indexvl = 1;
        string projectName = 'JIRA Connector';
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpSearchJiraComponentController2 ());
        SearchJiraComponentController.SendSearchReqToJIRA(searchtext, componentList, issueTypeList, startAt, indxval, projectName);
        SearchJiraComponentController.nextPage(searchtext,componentList,issueTypeList,indexv,projectName);
        
        SearchJiraComponentController.previousPage(searchtext,componentList,issueTypeList,indexvl,projectName);
        test.stopTest();
        System.assertEquals(SearchJiraComponentController.Loaded, true);
    }
    @isTest static void TestScenerio3() {
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        setting.Basic_Authentication__c=true;
        insert setting; 
        Jira_Project__c p= new Jira_Project__c();
        p.Name = 'JIRA Connector';
        p.ProjectKey__c = 'JC';
        p.ProjectId__c = '10001';
        p.DefaultIssueType__c = 'Task';
        p.IssueType__c='Bug,Story,Task,Epic';
        insert p;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpSearchJiraComponentController3 ());
        SearchJiraComponentController.fetchComponents(p.ProjectKey__c);
        test.stopTest();
        system.assertEquals(SearchJiraComponentController.fetchComponents(p.ProjectKey__c) !=null, true);
    }
}