@isTest
public class Test_ViewJiraSearchController {
    
    @isTest 
    public static void ViewViewJiraSearch(){
       Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        insert setting; 
        
        JiraSalesforceDetail__c jsd = new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'JiraAutoFileAttach';
        st.IsActive__c = true;
        insert st;
        
        Rule_Set__c rule=Testdata.Newruleset('test', '1', true, 'DEV',  'rulename' ,1,True);
        Child_Rule_Set__c child= Testdata.Newchildruleset('STRING','suppliedemail','', 'not equal to', rule,'1',true);
        Account ac = new account(name='test');
        insert ac;        
        
        JiraIssue__c ji=Testdata.createjira('testing of Jira Test Class', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"parent":123,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution:check,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10028":"TEST","customfield_10029":"TEST","resolutiondate":"2018-04-03T21:49:10.207+0530","lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10203":"2019-07-25T23:00:00.000+0000","customfield_10202":"2019-07-24","customfield_10102":"test",customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"customfield_10100":"TP-1","assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":"TEST","customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';     Ji.Project__c='DEV';
        insert ji;
        JiraIssue__c ji1=Testdata.createjira('testing of Jira Test Class', 'test1', 10018, '1003', 'Task', 'u1', 'sds', 'high', false);
        ji1.JsonData__c='{"id":"10018","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"parent":123,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution:check,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10028":"TEST","customfield_10029":"TEST","resolutiondate":"2018-04-03T21:49:10.207+0530","lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10203":"2019-07-25T23:00:00.000+0000","customfield_10202":"2019-07-24","customfield_10102":"test","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"customfield_10100":"TP-1","assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":"TEST","customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}'; Ji1.Project__c='DEV';
        insert ji1;
        
        
        Case cs =Testdata.createcase('email@test.com', String.ValueOf(ac.id), 'New', true);
        Case cs1 =Testdata.createcase('', String.valueof(ac.id), 'working', true);
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, true);
        JiraRelationship__c jr1= Testdata.createjirarelation(cs.id, ji1.id, true);
        Jira_Project__c pm= Testdata.createjiraProject('10001', 'DEV', 'DEV');
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Testdata.CreateStaticFields(pm.id);
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        proMap.IsStatic__c=false;
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        promap.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IsStatic__c=false;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        promapp.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        proMap1.IsStatic__c=false;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        proMap1.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(proMap1);
        
        Jira_ProjectFieldsMapping__c projectMap2 = Testdata.createjirafieldmapp(pm.id,false,'select',null, 'select','customfield_10043' ,true, true ,'select',false);
        projectMap2.jira_project__c=pm.id;
        projectMap2.RelatedProjectIdSet__c = pm.Id;
        projectMap2.IssueTypedata__c='All';
        projectMap2.IsStatic__c=false;
        projectMap2.Salesforce_Object__c='Case';
        projectMap2.Section__c =Section.id;
        projectMap2.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap2);
        
        Jira_ProjectFieldsMapping__c projectMap12 = Testdata.createjirafieldmapp(pm.id,false,'userpicker','AccountId','userpicker', 'customfield_10022' ,true, true ,'userpicker',false);
        projectMap12.jira_project__c=pm.id;
        projectMap12.IsStatic__c=false;
        projectMap12.RelatedProjectIdSet__c = pm.Id;
        projectMap12.IssueTypedata__c='All';
        projectMap12.Salesforce_Object__c='Case';
        projectMap12.Section__c =Section.id;
        projectMap12.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap12);
        
        Jira_ProjectFieldsMapping__c projectMap4 = Testdata.createjirafieldmapp(pm.id,false,'multiuserpicker',null, 'multiuserpicker','customfield_10031' ,true, true,'multiuserpicker' ,false);
        projectMap4.jira_project__c=pm.id;
        projectMap4.RelatedProjectIdSet__c = pm.Id;
        projectMap4.IsStatic__c=false;
        projectMap4.IssueTypedata__c='All';
        projectMap4.Salesforce_Object__c='Case';
        projectMap4.Section__c =Section.id;
        projectMap4.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap4);
        
        Jira_ProjectFieldsMapping__c projectMapv4 = Testdata.createjirafieldmapp(pm.id,false,'multiversion',null,'multiversion', 'customfield_10032' ,true, true,'multiversion' ,false);
        projectMapv4.jira_project__c=pm.id;
        projectMapv4.IsStatic__c=false;
        projectMapv4.RelatedProjectIdSet__c = pm.id;
        projectMapv4.IssueTypedata__c='All';
        projectMapv4.Salesforce_Object__c='Case';
        projectMapv4.Section__c =Section.id;
        projectMapv4.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv4);
        
        
        Jira_ProjectFieldsMapping__c projectMapv5 = Testdata.createjirafieldmapp(pm.id,false,'id',null,'id', 'customfield_10218' ,true, false,'id' ,false);
        projectMapv5.jira_project__c=pm.id;
        projectMapv5.RelatedProjectIdSet__c = pm.id;
        projectMapv5.IsStatic__c=false;
        projectMapv5.IssueTypedata__c='All';
        projectMapv5.Salesforce_Object__c='Case';
        projectMapv5.Section__c =Section.id;
       projectMapv5.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv5);
        
        Jira_ProjectFieldsMapping__c projectMapv6 = Testdata.createjirafieldmapp(pm.id,false,'datepicker',null,'Date Picker', 'customfield_10202' ,true, false,'datepicker' ,false);
        projectMapv6.jira_project__c=pm.id;
        projectMapv6.RelatedProjectIdSet__c = pm.id;
        projectMapv6.IssueTypedata__c='All';
        projectMapv6.IsStatic__c=false;
        projectMapv6.Salesforce_Object__c='Case';
        projectMapv6.Section__c =Section.id;
        projectMapv6.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv6);
        
        Jira_ProjectFieldsMapping__c projectMapv7 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv7.jira_project__c=pm.id;
        projectMapv7.RelatedProjectIdSet__c = pm.id;
        projectMapv7.IsStatic__c=false;
        projectMapv7.IssueTypedata__c='All';
        projectMapv7.Salesforce_Object__c='Case';
        projectMapv7.Section__c =Section.id;
        projectMapv7.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv7);
        
        Jira_ProjectFieldsMapping__c projectMapv8 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv8.jira_project__c=pm.id;
        projectMapv8.RelatedProjectIdSet__c = pm.id;
        projectMapv8.IssueTypedata__c='All';
        projectMapv8.IsStatic__c=false;
        projectMapv8.Salesforce_Object__c='Case';
        projectMapv8.Section__c =Section.id;
        projectMapv8.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv8);
        
        Jira_ProjectFieldsMapping__c projectMapv9 = Testdata.createjirafieldmapp(pm.id,false,'issuelinks',null,'Linked Issues', 'issuelinks' ,true, true,'issuelinks' ,false);
        projectMapv9.jira_project__c=pm.id;
        projectMapv9.RelatedProjectIdSet__c = pm.id;
        projectMapv9.IssueTypedata__c='All';
        projectMapv9.IsStatic__c=false;
        projectMapv9.Salesforce_Object__c='Case';
        projectMapv9.Section__c =Section.id;
        projectMapv9.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv9);
        
        Jira_ProjectFieldsMapping__c projectMap9 = Testdata.createjirafieldmapp(pm.id,false,'Epic Name',null,'Epic Name' ,'resolutiondate' ,true, false,'gh-epic-label' ,false);
        projectMap9.jira_project__c=pm.id;
        projectMap9.RelatedProjectIdSet__c = pm.id;
        projectMap9.IssueTypedata__c='All';
        projectMap9.IsStatic__c=false;
        projectMap9.Salesforce_Object__c='Case';
        projectMap9.Section__c =Section.id;
        projectMap9.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap9);
        
        Jira_ProjectFieldsMapping__c projectMap999 = Testdata.createjirafieldmapp(pm.id,false,'Epic link',null,'Epic link' ,'assignee' ,true, false,'gh-epic-link' ,false);
        //createjirafieldmapp(id projectid,Boolean IsRequired,String name,String casename,String jirafieldname, String jirafieldapiname ,Boolean Editable, Boolean isArray ,String datatype,Boolean mode)
        projectMap999.jira_project__c=pm.id;
        projectMap999.IsStatic__c=false;
        projectMap999.RelatedProjectIdSet__c = pm.id;
        projectMap999.IssueTypedata__c='All';
        projectMap999.Salesforce_Object__c='Case';
        projectMap999.Section__c =Section.id;
        projectMap999.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap999);
        
        Jira_ProjectFieldsMapping__c projectMap09 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'parent','parent' ,true, false,'issuelink' ,false);
        projectMap09.jira_project__c=pm.id;
        projectMap09.RelatedProjectIdSet__c = pm.id;
        projectMap09.IsStatic__c=false;
        projectMap09.IssueTypedata__c='All';
        projectMap09.Salesforce_Object__c='Case';
        projectMap09.Section__c =Section.id;
        projectMap09.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap09);
        
        Jira_ProjectFieldsMapping__c projectMapvv9 = Testdata.createjirafieldmapp(pm.id,false,'datetime',null,'Date Time Picker', 'customfield_10203' ,true, false,'datetime' ,false);
        projectMapvv9.jira_project__c=pm.id;
        projectMapvv9.RelatedProjectIdSet__c = pm.id;
        projectMapvv9.IsStatic__c=false;
        projectMapvv9.IssueTypedata__c='All';
        projectMapvv9.Salesforce_Object__c='Case';
        projectMapvv9.Section__c =Section.id;
        projectMapvv9.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapvv9);
        
        Jira_ProjectFieldsMapping__c projectMapvv11 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'issuelink', 'parent' ,true, false,'issuelink' ,false);
        projectMapvv11.jira_project__c=pm.id;
        projectMapvv11.RelatedProjectIdSet__c = pm.id;
        projectMapvv11.IssueTypedata__c='All';
        projectMapvv11.IsStatic__c=false;
        projectMapvv11.Salesforce_Object__c='Case';
        projectMapvv11.Section__c =Section.id;
        projectMapvv11.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapvv11);
        
        Jira_ProjectFieldsMapping__c projectMapvv12 = Testdata.createjirafieldmapp(pm.id,false,'fixVersions',null,'Fix Version/s', 'fixVersions' ,true, false,'version' ,false);
        projectMapvv12.jira_project__c=pm.id;
        projectMapvv12.RelatedProjectIdSet__c = pm.id;
        projectMapvv12.IsStatic__c=false;
        projectMapvv12.IssueTypedata__c='All';
        projectMapvv12.Salesforce_Object__c='Case';
        projectMapvv12.Section__c =Section.id;
        projectMapvv12.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapvv12);
        
        insert jirafieldmap;
        
      // projectMapv9.IsReportingEnabled__c = true;
       //update projectMapv9;
        
       // Reporting_Permissions__c RP = New Reporting_Permissions__c(Name='Admin',Profile_Id__c='00e7F000002XGpK');
      // Insert RP;
        
        projectMapv9.IsReportingEnabled__c = true;
        update projectMapv9;
        
        List<Jira_ProjectFieldsMapping__c> li=[Select id,Salesforce_Object__c from Jira_ProjectFieldsMapping__c ];
        boolean NotEmpty=false;
        PageReference pag= Page.ViewSearchJira;
        Test.setCurrentPage(pag);
        ApexPages.currentPage().getParameters().put('id','DEV-19');
        ApexPages.currentPage().getParameters().put('Objectid',cs.id);
        ApexPages.currentPage().getParameters().put('mode','clone');
        ApexPages.currentPage().getParameters().put('key',ji.IssueKey__c);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpViewKey());
        HttpRequest req =CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+ji.IssueKey__c,'GET' ,'application/json');
        HttpResponse res= JiraService.getResponse(req);
        
        ViewJiraSearchController viewJira1 = new ViewJiraSearchController();
//test coverage
       viewJira1.jira.Name='DEV';
        viewJira1.jira.Description__c='description';
         viewJira1.jira.IssueId__c=10004;
         viewJira1.jira.IssueKey__c='DEV-19';
        viewJira1.jira.IssueType__c='Bug';
          viewJira1.jira.Priority__c='Highest';
         //  viewJira.jira.Project_Id__c='10001';
           viewJira1.jira.Project__c='Development';
            viewJira1.jira.Reporter__c='admin';
            viewJira1.jira.Status__c='To Do';
            viewJira1.jira.Summary__c='CLONE-Subject';
         //  viewJira1.jira.ResolutionDate__c= DateTime.parse('03/04/2018');
            viewJira1.jira.Resolution__c='submit';
          //  viewJira.jira.Created__c='2018-04-03T14:31:00.361+0530';
            viewJira1.jira.Assignee__c='admin';
 	 //test coverage
        viewJira1.save();
        viewJira1.link();
        viewJira1.deletelink();
        if(viewJira1.JiraIssue!=null){
            NotEmpty=true;
        }
        Test.stopTest();
        System.assertEquals(NotEmpty,true);
    }
  
       @isTest 
    public static void ViewViewJiraSearch1(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        insert setting; 
        
        JiraSalesforceDetail__c jsd = new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'JiraAutoFileAttach';
        st.IsActive__c = true;
        insert st;
        
        
        Rule_Set__c rule=Testdata.Newruleset('test', '1', true, 'DEV',  'rulename' ,1,True);
        Child_Rule_Set__c child= Testdata.Newchildruleset('STRING','suppliedemail','', 'not equal to', rule,'1',true);
        Account ac = new account(name='test');
        insert ac;        
        
        JiraIssue__c ji=Testdata.createjira('testing of Jira Test Class', 'test', 10019, 'TP-1', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"parent":123,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10028":"TEST","customfield_10029":"TEST","resolutiondate":"2018-04-03T21:49:10.207+0530","lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10203":"2019-07-25T23:00:00.000+0000","customfield_10202":"2019-07-24","customfield_10102":"test",customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"customfield_10100":"TP-1","assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":"TEST","customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';     Ji.Project__c='DEV';
        insert ji;
        JiraIssue__c ji1=Testdata.createjira('testing of Jira Test Class', 'test1', 10018, '1003', 'Task', 'u1', 'sds', 'high', false);
        ji1.JsonData__c='{"id":"10018","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"parent":123,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10028":"TEST","customfield_10029":"TEST","resolutiondate":"2018-04-03T21:49:10.207+0530","lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10203":"2019-07-25T23:00:00.000+0000","customfield_10202":"2019-07-24","customfield_10102":"test","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"customfield_10100":"TP-1","assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":"TEST","customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}'; Ji1.Project__c='DEV';
        insert ji1;
        
        Case cs =Testdata.createcase('email@test.com', String.ValueOf(ac.id), 'New', true);
        Case cs1 =Testdata.createcase('', String.valueof(ac.id), 'working', true);
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, true);
        JiraRelationship__c jr1= Testdata.createjirarelation(cs.id, ji1.id, true);
        Jira_Project__c pm= Testdata.createjiraProject('10001', 'DEV', 'DEV');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        Testdata.CreateStaticFields(pm.id);
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        promap.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        promapp.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        proMap1.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(proMap1);
        
        Jira_ProjectFieldsMapping__c projectMap2 = Testdata.createjirafieldmapp(pm.id,false,'select',null, 'select','customfield_10043' ,true, true ,'select',false);
        projectMap2.jira_project__c=pm.id;
        projectMap2.RelatedProjectIdSet__c = pm.Id;
        projectMap2.IssueTypedata__c='All';
        projectMap2.Salesforce_Object__c='Case';
        projectMap2.Section__c =Section.id;
        projectMap2.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap2);
        
        Jira_ProjectFieldsMapping__c projectMap12 = Testdata.createjirafieldmapp(pm.id,false,'userpicker','AccountId','userpicker', 'customfield_10022' ,true, true ,'userpicker',false);
        projectMap12.jira_project__c=pm.id;
        projectMap12.RelatedProjectIdSet__c = pm.Id;
        projectMap12.IssueTypedata__c='All';
        projectMap12.Salesforce_Object__c='Case';
        projectMap12.Section__c =Section.id;
        projectMap12.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap12);
        
        Jira_ProjectFieldsMapping__c projectMap4 = Testdata.createjirafieldmapp(pm.id,false,'multiuserpicker',null, 'multiuserpicker','customfield_10031' ,true, true,'multiuserpicker' ,false);
        projectMap4.jira_project__c=pm.id;
        projectMap4.RelatedProjectIdSet__c = pm.Id;
        projectMap4.IssueTypedata__c='All';
        projectMap4.Salesforce_Object__c='Case';
        projectMap4.Section__c =Section.id;
        projectMap4.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap4);
        
        Jira_ProjectFieldsMapping__c projectMapv4 = Testdata.createjirafieldmapp(pm.id,false,'multiversion',null,'multiversion', 'customfield_10032' ,true, true,'multiversion' ,false);
        projectMapv4.jira_project__c=pm.id;
        projectMapv4.RelatedProjectIdSet__c = pm.id;
        projectMapv4.IssueTypedata__c='All';
        projectMapv4.Salesforce_Object__c='Case';
        projectMapv4.Section__c =Section.id;
        projectMapv4.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv4);
        
        
        Jira_ProjectFieldsMapping__c projectMapv5 = Testdata.createjirafieldmapp(pm.id,false,'id',null,'id', 'customfield_10218' ,true, false,'id' ,false);
        projectMapv5.jira_project__c=pm.id;
        projectMapv5.RelatedProjectIdSet__c = pm.id;
        projectMapv5.IssueTypedata__c='All';
        projectMapv5.Salesforce_Object__c='Case';
        projectMapv5.Section__c =Section.id;
       projectMapv5.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv5);
        
        Jira_ProjectFieldsMapping__c projectMapv6 = Testdata.createjirafieldmapp(pm.id,false,'datepicker',null,'Date Picker', 'customfield_10202' ,true, false,'datepicker' ,false);
        projectMapv6.jira_project__c=pm.id;
        projectMapv6.RelatedProjectIdSet__c = pm.id;
        projectMapv6.IssueTypedata__c='All';
        projectMapv6.Salesforce_Object__c='Case';
        projectMapv6.Section__c =Section.id;
        projectMapv6.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv6);
        
        Jira_ProjectFieldsMapping__c projectMapv7 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv7.jira_project__c=pm.id;
        projectMapv7.RelatedProjectIdSet__c = pm.id;
        projectMapv7.IssueTypedata__c='All';
        projectMapv7.Salesforce_Object__c='Case';
        projectMapv7.Section__c =Section.id;
        projectMapv7.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv7);
        
        Jira_ProjectFieldsMapping__c projectMapv8 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv8.jira_project__c=pm.id;
        projectMapv8.RelatedProjectIdSet__c = pm.id;
        projectMapv8.IssueTypedata__c='All';
        projectMapv8.Salesforce_Object__c='Case';
        projectMapv8.Section__c =Section.id;
        projectMapv8.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv8);
        
        Jira_ProjectFieldsMapping__c projectMapv9 = Testdata.createjirafieldmapp(pm.id,false,'issuelinks',null,'Linked Issues', 'issuelinks' ,true, true,'issuelinks' ,false);
        projectMapv9.jira_project__c=pm.id;
        projectMapv9.RelatedProjectIdSet__c = pm.id;
        projectMapv9.IssueTypedata__c='All';
        projectMapv9.Salesforce_Object__c='Case';
        projectMapv9.Section__c =Section.id;
        projectMapv9.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapv9);
        
        Jira_ProjectFieldsMapping__c projectMap9 = Testdata.createjirafieldmapp(pm.id,false,'Epic Name',null,'Epic Name' ,'customfield_10102' ,true, false,'gh-epic-label' ,false);
        projectMap9.jira_project__c=pm.id;
        projectMap9.RelatedProjectIdSet__c = pm.id;
        projectMap9.IssueTypedata__c='All';
        projectMap9.Salesforce_Object__c='Case';
        projectMap9.Section__c =Section.id;
        projectMap9.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap9);
        
        Jira_ProjectFieldsMapping__c projectMap999 = Testdata.createjirafieldmapp(pm.id,false,'Epic link',null,'Epic link' ,'customfield_10100' ,true, false,'gh-epic-link' ,false);
        projectMap999.jira_project__c=pm.id;
        projectMap999.RelatedProjectIdSet__c = pm.id;
        projectMap999.IssueTypedata__c='All';
        projectMap999.Salesforce_Object__c='Case';
        projectMap999.Section__c =Section.id;
        projectMap999.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap999);
        
        Jira_ProjectFieldsMapping__c projectMap09 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'parent','parent' ,true, false,'issuelink' ,false);
        projectMap09.jira_project__c=pm.id;
        projectMap09.RelatedProjectIdSet__c = pm.id;
        projectMap09.IssueTypedata__c='All';
        projectMap09.Salesforce_Object__c='Case';
        projectMap09.Section__c =Section.id;
        projectMap09.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMap09);
        
        Jira_ProjectFieldsMapping__c projectMapvv9 = Testdata.createjirafieldmapp(pm.id,false,'datetime',null,'Date Time Picker', 'customfield_10203' ,true, false,'datetime' ,false);
        projectMapvv9.jira_project__c=pm.id;
        projectMapvv9.RelatedProjectIdSet__c = pm.id;
        projectMapvv9.IssueTypedata__c='All';
        projectMapvv9.Salesforce_Object__c='Case';
        projectMapvv9.Section__c =Section.id;
        projectMapvv9.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapvv9);
        
        Jira_ProjectFieldsMapping__c projectMapvv11 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'issuelink', 'parent' ,true, false,'issuelink' ,false);
        projectMapvv11.jira_project__c=pm.id;
        projectMapvv11.RelatedProjectIdSet__c = pm.id;
        projectMapvv11.IssueTypedata__c='All';
        projectMapvv11.Salesforce_Object__c='Case';
        projectMapvv11.Section__c =Section.id;
        projectMapvv11.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapvv11);
        
        Jira_ProjectFieldsMapping__c projectMapvv12 = Testdata.createjirafieldmapp(pm.id,false,'fixVersions',null,'Fix Version/s', 'fixVersions' ,true, false,'version' ,false);
        projectMapvv12.jira_project__c=pm.id;
        projectMapvv12.RelatedProjectIdSet__c = pm.id;
        projectMapvv12.IssueTypedata__c='All';
        projectMapvv12.Salesforce_Object__c='Case';
        projectMapvv12.Section__c =Section.id;
        projectMapvv12.IsReportingEnabled__c=TRUE;
        jirafieldmap.add(projectMapvv12);
        
        insert jirafieldmap;
        
        projectMapv9.IsReportingEnabled__c = true;
        update projectMapv9;
    
        
        List<Jira_ProjectFieldsMapping__c> li=[Select id,Salesforce_Object__c from Jira_ProjectFieldsMapping__c ];
        boolean NotEmpty=false;
        PageReference pag= Page.ViewSearchJira;
        Test.setCurrentPage(pag);
        ApexPages.currentPage().getParameters().put('id','TP-1');
        ApexPages.currentPage().getParameters().put('Objectid',cs.id);
        ApexPages.currentPage().getParameters().put('mode','clone');
        ApexPages.currentPage().getParameters().put('key',ji.IssueKey__c);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpissue());
        HttpRequest req =CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+ji.IssueKey__c ,'GET' ,'application/json');
        HttpResponse res= JiraService.getResponse(req);
        
        ViewJiraSearchController viewJira = new ViewJiraSearchController();
        viewJira.save();
        viewJira.link();
        viewJira.deletelink();
         if(viewJira.JiraIssue!=null){
            NotEmpty=true;
        }
        Test.stopTest();
        System.assertEquals(NotEmpty,true);
    }
 
}