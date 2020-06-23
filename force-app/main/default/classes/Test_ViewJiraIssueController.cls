@istest
public class Test_ViewJiraIssueController {
    
    @testSetup 
    public static void testdata(){
        
       Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        insert setting; 
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'UpdateFieldWithData';
        st.IsActive__c = true;
        insert st;
        
        JiraSalesforceDetail__c jsd=new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        
        JiraSalesforceDetail__c jsd1=new JiraSalesforceDetail__c();
        jsd1.Name = 'Edit_Jira_In_SF';
        jsd1.Value__c = 'yes';
        insert jsd1;
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c();
        st1.Name = 'JiraAutoFileAttach';
        st1.IsActive__c = true;
        insert st1;
        
        Rule_Set__c rule=Testdata.Newruleset('test', '1', true, 'DEV',  'rulename' ,1,True);
        Child_Rule_Set__c child= Testdata.Newchildruleset('STRING','suppliedemail','', 'not equal to', rule,'1',true);
        Account ac = new account(name='test');
        insert ac;        
        
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"parent":123,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10028":"TEST","customfield_10029":"TEST","resolutiondate":"2018-04-03T21:49:10.207+0530","lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10203":"2019-07-25T23:00:00.000+0000","customfield_10202":"2019-07-24","customfield_10102":"test",customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"customfield_10100":"TP-1","assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":"TEST","customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';     Ji.Project__c='DEV';
        insert ji;
        JiraIssue__c ji1=Testdata.createjira('test1', 'test1', 10018, '1003', 'Task', 'u1', 'sds', 'high', false);
        ji1.JsonData__c='{"id":"10018","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"parent":123,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10028":"TEST","customfield_10029":"TEST","resolutiondate":"2018-04-03T21:49:10.207+0530","lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10203":"2019-07-25T23:00:00.000+0000","customfield_10202":"2019-07-24","customfield_10102":"test","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"customfield_10100":"TP-1","assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":"TEST","customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}'; Ji1.Project__c='DEV';
        insert ji1;
        
        Case cs =Testdata.createcase('email@test.com', String.ValueOf(ac.id), 'New', true);
        Case cs1 =Testdata.createcase('', String.valueof(ac.id), 'working', true);
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, true);
        JiraRelationship__c jr1= Testdata.createjirarelation(cs.id, ji1.id, true);
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10100';
        pm.Name='Development';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='';
        pm.IssueType__c='Task';
        insert pm;
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
       
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'cascadingselect',null,'Select List Cascading', 'customfield_10206' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        proMap.ReqInIssueTypeData__c='All';
        proMap.IsStatic__c=false;
        //proMap.ProjectissueTypeData__c
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        proMapp.ReqInIssueTypeData__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        proMapp.IsStatic__c=false;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.ReqInIssueTypeData__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.IsStatic__c=false;
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        Jira_ProjectFieldsMapping__c projectMap2 = Testdata.createjirafieldmapp(pm.id,false,'select',null, 'select','customfield_10043' ,true, true ,'select',false);
        projectMap2.jira_project__c=pm.id;
        projectMap2.IsStatic__c=false;
        projectMap2.RelatedProjectIdSet__c = pm.Id;
        projectMap2.IssueTypedata__c='All';
        projectMap2.ReqInIssueTypeData__c='All';
        projectMap2.Salesforce_Object__c='Case';
        projectMap2.Section__c =Section.id;
        jirafieldmap.add(projectMap2);
        
        Jira_ProjectFieldsMapping__c projectMap12 = Testdata.createjirafieldmapp(pm.id,false,'userpicker','AccountId','userpicker', 'customfield_10022' ,true, true ,'userpicker',false);
        projectMap12.jira_project__c=pm.id;
        projectMap12.IsStatic__c=false;
        projectMap12.RelatedProjectIdSet__c = pm.Id;
        projectMap12.IssueTypedata__c='All';
        projectMap12.ReqInIssueTypeData__c='All';
        projectMap12.Salesforce_Object__c='Case';
        projectMap12.Section__c =Section.id;
        jirafieldmap.add(projectMap12);
        
        Jira_ProjectFieldsMapping__c projectMap4 = Testdata.createjirafieldmapp(pm.id,false,'multiuserpicker',null, 'multiuserpicker','customfield_10031' ,true, true,'multiuserpicker' ,false);
        projectMap4.jira_project__c=pm.id;
        projectMap4.RelatedProjectIdSet__c = pm.Id;
        projectMap4.IssueTypedata__c='All';
        projectMap4.ReqInIssueTypeData__c='All';
        projectMap4.Salesforce_Object__c='Case';
        projectMap4.IsStatic__c=false;
        projectMap4.Section__c =Section.id;
        jirafieldmap.add(projectMap4);
        
        Jira_ProjectFieldsMapping__c projectMapv4 = Testdata.createjirafieldmapp(pm.id,false,'multiversion',null,'multiversion', 'customfield_10032' ,true, true,'multiversion' ,false);
        projectMapv4.jira_project__c=pm.id;
        projectMapv4.RelatedProjectIdSet__c = pm.id;
        projectMapv4.IssueTypedata__c='All';
        projectMapv4.ReqInIssueTypeData__c='All';
        projectMapv4.Salesforce_Object__c='Case';
        projectMapv4.IsStatic__c=false;
        projectMapv4.Section__c =Section.id;
        jirafieldmap.add(projectMapv4);
        
        
        Jira_ProjectFieldsMapping__c projectMapv5 = Testdata.createjirafieldmapp(pm.id,false,'id',null,'id', 'customfield_10218' ,true, false,'id' ,false);
        projectMapv5.jira_project__c=pm.id;
        projectMapv5.RelatedProjectIdSet__c = pm.id;
        projectMapv5.IssueTypedata__c='All';
        projectMapv5.ReqInIssueTypeData__c='All';
        projectMapv5.IsStatic__c=false;
        projectMapv5.Salesforce_Object__c='Case';
        projectMapv5.Section__c =Section.id;
       
        jirafieldmap.add(projectMapv5);
        
        Jira_ProjectFieldsMapping__c projectMapv6 = Testdata.createjirafieldmapp(pm.id,false,'datepicker',null,'Date Picker', 'customfield_10202' ,true, false,'datepicker' ,false);
        projectMapv6.jira_project__c=pm.id;
        projectMapv6.RelatedProjectIdSet__c = pm.id;
        projectMapv6.IssueTypedata__c='All';
        projectMapv6.ReqInIssueTypeData__c='All';
        projectMapv6.Salesforce_Object__c='Case';
        projectMapv6.IsStatic__c=false;
        projectMapv6.Section__c =Section.id;
        jirafieldmap.add(projectMapv6);
        
        Jira_ProjectFieldsMapping__c projectMapv7 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv7.jira_project__c=pm.id;
        projectMapv7.RelatedProjectIdSet__c = pm.id;
        projectMapv7.IssueTypedata__c='All';
        projectMapv7.ReqInIssueTypeData__c='All';
        projectMapv7.Salesforce_Object__c='Case';
        projectMapv7.IsStatic__c=false;
        projectMapv7.Section__c =Section.id;
        jirafieldmap.add(projectMapv7);
        
        Jira_ProjectFieldsMapping__c projectMapv8 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv8.jira_project__c=pm.id;
        projectMapv8.RelatedProjectIdSet__c = pm.id;
        projectMapv8.IsStatic__c=false;
        projectMapv8.IssueTypedata__c='All';
        projectMapv8.ReqInIssueTypeData__c='All';
        projectMapv8.Salesforce_Object__c='Case';
        projectMapv8.Section__c =Section.id;
        jirafieldmap.add(projectMapv8);
        
        Jira_ProjectFieldsMapping__c projectMapv9 = Testdata.createjirafieldmapp(pm.id,false,'issuelinks',null,'Linked Issues', 'issuelinks' ,true, true,'issuelinks' ,false);
        projectMapv9.jira_project__c=pm.id;
        projectMapv9.RelatedProjectIdSet__c = pm.id;
        projectMapv9.IssueTypedata__c='All';
        projectMapv9.IsStatic__c=false;
        projectMapv9.ReqInIssueTypeData__c='All';
        projectMapv9.Salesforce_Object__c='Case';
        projectMapv9.Section__c =Section.id;
        jirafieldmap.add(projectMapv9);
        
        Jira_ProjectFieldsMapping__c projectMap9 = Testdata.createjirafieldmapp(pm.id,false,'Epic Name',null,'Epic Name' ,'customfield_10102' ,true, false,'gh-epic-label' ,false);
        projectMap9.jira_project__c=pm.id;
        projectMap9.RelatedProjectIdSet__c = pm.id;
        projectMap9.IssueTypedata__c='All';
        projectMap9.ReqInIssueTypeData__c='All';
        projectMap9.IsStatic__c=false;
        projectMap9.Salesforce_Object__c='Case';
        projectMap9.Section__c =Section.id;
        jirafieldmap.add(projectMap9);
        
        Jira_ProjectFieldsMapping__c projectMap999 = Testdata.createjirafieldmapp(pm.id,false,'Epic link',null,'Epic link' ,'customfield_10100' ,true, false,'gh-epic-link' ,false);
        projectMap999.jira_project__c=pm.id;
        projectMap999.RelatedProjectIdSet__c = pm.id;
        projectMap999.IssueTypedata__c='All';
        projectMap999.ReqInIssueTypeData__c='All';
        projectMap999.Salesforce_Object__c='Case';
        projectMap999.IsStatic__c=false;
        projectMap999.Section__c =Section.id;
        jirafieldmap.add(projectMap999);
        
        Jira_ProjectFieldsMapping__c projectMap09 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'parent','parent' ,true, false,'issuelink' ,false);
        projectMap09.jira_project__c=pm.id;
        projectMap09.RelatedProjectIdSet__c = pm.id;
        projectMap09.IssueTypedata__c='All';
        projectMap09.ReqInIssueTypeData__c='All';
        projectMap09.Salesforce_Object__c='Case';
        projectMap09.IsStatic__c=false;
        projectMap09.Section__c =Section.id;
        jirafieldmap.add(projectMap09);
        
        Jira_ProjectFieldsMapping__c projectMapvv9 = Testdata.createjirafieldmapp(pm.id,false,'datetime',null,'Date Time Picker', 'customfield_10203' ,true, false,'datetime' ,false);
        projectMapvv9.jira_project__c=pm.id;
        projectMapvv9.RelatedProjectIdSet__c = pm.id;
        projectMapvv9.IssueTypedata__c='All';
        projectMapvv9.ReqInIssueTypeData__c='All';
        projectMapvv9.Salesforce_Object__c='Case';
        projectMapvv9.IsStatic__c=false;
        projectMapvv9.Section__c =Section.id;
        jirafieldmap.add(projectMapvv9);
        
        Jira_ProjectFieldsMapping__c projectMapvv11 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'issuelink', 'parent' ,true, false,'issuelink' ,false);
        projectMapvv11.jira_project__c=pm.id;
        projectMapvv11.RelatedProjectIdSet__c = pm.id;
        projectMapvv11.IssueTypedata__c='All';
        projectMapvv11.ReqInIssueTypeData__c='All';
        projectMapvv11.Salesforce_Object__c='Case';
        projectMapvv11.IsStatic__c=false;
        projectMapvv11.Section__c =Section.id;
        jirafieldmap.add(projectMapvv11);
        
        Jira_ProjectFieldsMapping__c projectMapvv12 = Testdata.createjirafieldmapp(pm.id,false,'fixVersions',null,'Fix Version/s', 'fixVersions' ,true, false,'version' ,false);
        projectMapvv12.jira_project__c=pm.id;
        projectMapvv12.RelatedProjectIdSet__c = pm.id;
        projectMapvv12.IssueTypedata__c='All';
        projectMapvv12.ReqInIssueTypeData__c='All';
        projectMapvv12.IsStatic__c=false;
        projectMapvv12.Salesforce_Object__c='Case';
        projectMapvv12.Section__c =Section.id;
        jirafieldmap.add(projectMapvv12);
        insert jirafieldmap;
        
       projectMapv9.IsReportingEnabled__c = true;
        update projectMapv9;
        
        Reporting_Permissions__c RP = New Reporting_Permissions__c(Name='Admin',Profile_Id__c='00e7F000002XGpK');
        Insert RP;
        
    }
    
    
    @istest
    public static void TestScenerio1(){
        PageReference pag= Page.EditAddJiraIssue;
        Test.setCurrentPage(pag);
       
        JiraIssue__c ji=[select id,Summary__c,Priority__c,Jira_Link__c,IssueKey__c,Reporter__c,Status__c,Assignee__c from JiraIssue__c  where Issueid__c=10018 limit 1];
        case cs=[select id,SuppliedEmail from case where status='working' limit 1];
        ApexPages.currentPage().getParameters().put('caseid',cs.id);
        ApexPages.currentPage().getParameters().put('Id',ji.id);
        ApexPages.currentPage().getParameters().put('genericObjectID',NULL);
        ApexPages.currentPage().getParameters().put('issueLinkText','JC-1');
        ApexPages.currentPage().getParameters().put('linktype','relates to');
        ApexPages.currentPage().getParameters().put('epicLinkText','epiclink');
        ApexPages.currentPage().getParameters().put('subtask','true');
        ApexPages.currentPage().getParameters().put('key',ji.issuekey__c);
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ji);
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
  
        ViewJiraIssueController view=new ViewJiraIssueController(sc); 
        view.deleteLink();
        view.Redirectt();
        view.Subtask();
        view.addComment();
        view.deletelinkedjira();
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata());
        ApexPages.currentPage().getParameters().put('genericObjectID',cs.id);
        ViewJiraIssueController view2=new ViewJiraIssueController(sc);
        
        
        Test.stopTest();
        System.assertEquals(view2.HasPermission,true);
    }
    
    @istest
    public static void TestScenerio2(){
        PageReference pag= Page.viewJira;
        Test.setCurrentPage(pag);
        
        JiraIssue__c ji=[select id,Summary__c,Priority__c,Jira_Link__c,IssueKey__c,Reporter__c,Status__c,Assignee__c from JiraIssue__c  where Issueid__c=10018 limit 1];
        case cs=[select id,SuppliedEmail from case where status='working' limit 1];
        ApexPages.currentPage().getParameters().put('caseid',cs.id);
        ApexPages.currentPage().getParameters().put('Id',ji.id);
        ApexPages.currentPage().getParameters().put('genericObjectID',Null);
        ApexPages.currentPage().getParameters().put('issueLinkText','JC-1');
        
        ApexPages.currentPage().getParameters().put('jirakey','TP-1');
        ApexPages.currentPage().getParameters().put('subtask','true');
        ApexPages.currentPage().getParameters().put('key',ji.issuekey__c);
        ApexPages.StandardController sc = new ApexPages.StandardController(ji);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        ViewJiraIssueController view=new ViewJiraIssueController(sc); 
       
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata());
        ApexPages.currentPage().getParameters().put('genericObjectID',cs.id);
        ViewJiraIssueController view2=new ViewJiraIssueController(sc);
        Test.stopTest();
        System.assertEquals(view2.HasPermission,true);
    }
    
   
}