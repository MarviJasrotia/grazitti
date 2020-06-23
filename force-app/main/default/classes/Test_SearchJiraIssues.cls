@isTest
public class Test_SearchJiraIssues {
    
    @isTest public static void TestScenerio1(){
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DP');
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, '1002', 'task', 'u1', 'sds', 'high', true);
        JiraRelationship__c jr=TestData.createjirarelation(cs.id, ji.id,true);
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        insert setting;   
        
        PageReference pag= Page.SearchJiraIssuesPages;
        Test.setCurrentPage(pag);
        ApexPages.currentPage().getParameters().put('search','Test');
        ApexPages.currentPage().getParameters().put('caseid',cs.id);
        ApexPages.currentPage().getParameters().put('project','-All-');
        ApexPages.currentPage().getParameters().put('ViewRelatedIssuesKey','DP-1');
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpSearchKey ());
        SearchJiraIssues searchjira= new SearchJiraIssues(); 
        SearchJiraIssues.fieldWrapper  Searchfw= new SearchJiraIssues.fieldWrapper();
        
        Searchfw.IssueType='';
        Searchfw.Reporter='';
        Searchfw.Assignee='';
        Searchfw.Priority='';
        Searchfw.projectsName='';
        Searchfw.JsonData='';
        searchjira.linkcasewithjirakey();
        searchjira.SendSearchReqToJIRA();
        searchjira.SendProjectName();
        searchjira.Viewcasewithjirakey();
        Test.stopTest();
        
        System.assertEquals(searchjira.searchText,'Test');
    }
    
    @isTest public static void TestScenerio2(){
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DP');
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, '1002', 'task', 'u1', 'sds', 'high', true);
        JiraRelationship__c jr=TestData.createjirarelation(cs.id, ji.id,true);
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DP';
        setting.LoginSuccess__c=true;
        insert setting;   
        
        PageReference pag= Page.SearchJiraIssuesPages;
        Test.setCurrentPage(pag);
        
        ApexPages.currentPage().getParameters().put('caseid',cs.id);
        ApexPages.currentPage().getParameters().put('project','-All-');
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpSearchKey ());
        SearchJiraIssuesUpgraded searchjira= new SearchJiraIssuesUpgraded(); 
        SearchJiraIssuesUpgraded.fieldWrapper  Searchfw= new SearchJiraIssuesUpgraded.fieldWrapper();
        
        Searchfw.IssueType='';
        searchjira.searchText='test';
        
        searchjira.linkcasewithjirakey();
        searchjira.SendSearchReqToJIRA();
        searchjira.nextPage();
        searchjira.previousPage();
        searchjira.Viewcasewithjirakey();
        Test.stopTest();
        System.assertEquals(searchjira.projectName,null); 
    }    
    @isTest public static void TestScenerio3(){
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DP-1');
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, '1002', 'task', 'u1', 'sds', 'high', true);
        JiraRelationship__c jr=TestData.createjirarelation(cs.id, ji.id,true);
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DP-1';
        setting.LoginSuccess__c=true;
        insert setting;   
        List<String> selectedproject = new List<String>();
        for(Jira_Project__c j:[select id,name from Jira_Project__c]){
            selectedproject.add(j.name);
        }
        PageReference pag= Page.SearchJiraIssuesPages;
        Test.setCurrentPage(pag);
        // ApexPages.currentPage().getParameters().put('search','DP-1');
        ApexPages.currentPage().getParameters().put('caseid',cs.id);
        ApexPages.currentPage().getParameters().put('project','-All-');
        // ApexPages.currentPage().getParameters().put('ViewRelatedIssuesKey','DP-1');
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpSearchKey ());
        SearchJiraIssuesUpgraded searchjira= new SearchJiraIssuesUpgraded(); 
        SearchJiraIssuesUpgraded.fieldWrapper  Searchfw= new SearchJiraIssuesUpgraded.fieldWrapper();
                searchjira.SelectedProjectsSet=selectedproject;

        Searchfw.IssueType='';
        searchjira.searchText='DP-1';
        
        searchjira.linkcasewithjirakey();
        searchjira.SendSearchReqToJIRA();
        searchjira.nextPage();
        searchjira.previousPage();
        searchjira.Viewcasewithjirakey();
        Test.stopTest();
        System.assertEquals(searchjira.projectName,null); 
    }    
    
    @isTest public static void TestScenerio4(){
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DP');
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, '1002', 'task', 'u1', 'sds', 'high', true);
        JiraRelationship__c jr=TestData.createjirarelation(cs.id, ji.id,true);
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DP';
        setting.LoginSuccess__c=true;
        insert setting;   
        
        PageReference pag= Page.SearchJiraIssuesPages;
        Test.setCurrentPage(pag);
        
        ApexPages.currentPage().getParameters().put('caseid',cs.id);
        ApexPages.currentPage().getParameters().put('project','-All-');
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpSearchKey ());
        SearchJiraIssuesUpgraded searchjira= new SearchJiraIssuesUpgraded(); 
        SearchJiraIssuesUpgraded.fieldWrapper  Searchfw= new SearchJiraIssuesUpgraded.fieldWrapper();
        
        Searchfw.IssueType='';
        searchjira.searchText='test+demo';
        
        searchjira.linkcasewithjirakey();
        searchjira.SendSearchReqToJIRA();
        searchjira.nextPage();
        searchjira.previousPage();
        searchjira.Viewcasewithjirakey();
        Test.stopTest();
        System.assertEquals(searchjira.projectName,null); 
    }
    @isTest public static void TestScenerio5(){
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DP');
        Jira_Project__c jp1 = Testdata.createjiraProject('10002', 'jiraproject1', 'DP');
        Jira_Project__c jp2 = Testdata.createjiraProject('10003', 'jiraproject2', 'DP');
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, '1002', 'task', 'u1', 'sds', 'high', true);
        JiraRelationship__c jr=TestData.createjirarelation(cs.id, ji.id,true);
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DP';
        setting.LoginSuccess__c=true;
        insert setting;
        List<String> selectedproject = new List<String>();
        for(Jira_Project__c j:[select id,name from Jira_Project__c]){
            selectedproject.add(j.name);
        }
        List<String> selectedissuetype = new List<String>();
        for(JiraIssue__c issue: [select id,IssueType__c from JiraIssue__c]){
            selectedissuetype.add(issue.IssueType__c);
        }
        PageReference pag= Page.SearchJiraIssuesPages;
        Test.setCurrentPage(pag);
        
        ApexPages.currentPage().getParameters().put('caseid',cs.id);
        ApexPages.currentPage().getParameters().put('project','-All-');
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpSearchKey ());
        SearchJiraIssuesUpgraded searchjira= new SearchJiraIssuesUpgraded(); 
        SearchJiraIssuesUpgraded.fieldWrapper  Searchfw= new SearchJiraIssuesUpgraded.fieldWrapper();
        searchjira.SelectedProjectsSet=selectedproject;
        searchjira.SelectedIssueTypeSet=selectedissuetype;
        Searchfw.IssueType='';
        searchjira.searchText='Test';
        
        searchjira.linkcasewithjirakey();
        searchjira.SendSearchReqToJIRA();
        searchjira.nextPage();
        searchjira.previousPage();
        searchjira.Viewcasewithjirakey();
        Test.stopTest();
        System.assertEquals(searchjira.projectName,null); 
    }  
      @isTest public static void TestScenerio6(){
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DP');
        Jira_Project__c jp1 = Testdata.createjiraProject('10002', 'jiraproject1', 'DP');
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, '1002', 'task', 'u1', 'sds', 'high', true);
        JiraIssue__c ji1=Testdata.createjira('test', 'test', 1213, '1003', 'Bug', 'u1', 'sds', 'high', true);
        JiraIssue__c ji2=Testdata.createjira('test', 'test', 1214, '1004', 'Epic', 'u1', 'sds', 'high', true);
        JiraRelationship__c jr=TestData.createjirarelation(cs.id, ji.id,true);
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DP';
        setting.LoginSuccess__c=true;
        insert setting;
        List<String> selectedproject = new List<String>();
        for(Jira_Project__c j:[select id,name from Jira_Project__c]){
            selectedproject.add(j.name);
        }
        List<String> selectedissuetype = new List<String>();
        for(JiraIssue__c issue: [select id,IssueType__c from JiraIssue__c]){
            selectedissuetype.add(issue.IssueType__c);
        }
        PageReference pag= Page.SearchJiraIssuesPages;
        Test.setCurrentPage(pag);
        
        ApexPages.currentPage().getParameters().put('caseid',cs.id);
        ApexPages.currentPage().getParameters().put('project','-All-');
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpSearchKey ());
        SearchJiraIssuesUpgraded searchjira= new SearchJiraIssuesUpgraded(); 
        SearchJiraIssuesUpgraded.fieldWrapper  Searchfw= new SearchJiraIssuesUpgraded.fieldWrapper();
        searchjira.SelectedProjectsSet=selectedproject;
        searchjira.SelectedIssueTypeSet=selectedissuetype;
        Searchfw.IssueType='';
        searchjira.searchText='Test';
        
        searchjira.linkcasewithjirakey();
        searchjira.SendSearchReqToJIRA();
        searchjira.nextPage();
        searchjira.previousPage();
        searchjira.Viewcasewithjirakey();
        Test.stopTest();
        System.assertEquals(searchjira.projectName,null); 
    }
     @isTest public static void TestScenerio7(){
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DP');
         jp.DefaultIssueType__c = 'Bug';
         update jp;
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, '1002', 'task', 'u1', 'sds', 'high', true);
       
        JiraRelationship__c jr=TestData.createjirarelation(cs.id, ji.id,true);
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DP';
        setting.LoginSuccess__c=true;
        insert setting;
        List<String> selectedproject = new List<String>();
        for(Jira_Project__c j:[select id,name from Jira_Project__c]){
            selectedproject.add(j.name);
        }
        List<String> selectedissuetype = new List<String>();
        for(JiraIssue__c issue: [select id,IssueType__c from JiraIssue__c]){
            selectedissuetype.add(issue.IssueType__c);
        }
        PageReference pag= Page.SearchJiraIssuesPages;
        Test.setCurrentPage(pag);
        
        ApexPages.currentPage().getParameters().put('caseid',cs.id);
        ApexPages.currentPage().getParameters().put('project','-All-');
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpSearchKey ());
        SearchJiraIssuesUpgraded searchjira= new SearchJiraIssuesUpgraded(); 
        SearchJiraIssuesUpgraded.fieldWrapper  Searchfw= new SearchJiraIssuesUpgraded.fieldWrapper();
        searchjira.SelectedProjectsSet=selectedproject;
        searchjira.SelectedIssueTypeSet=selectedissuetype;
        Searchfw.IssueType='';
        searchjira.searchText='Test';
        
        searchjira.linkcasewithjirakey();
        searchjira.SendSearchReqToJIRA();
        searchjira.nextPage();
        searchjira.previousPage();
        searchjira.Viewcasewithjirakey();
        Test.stopTest();
        System.assertEquals(searchjira.projectName,null); 
    }    
}