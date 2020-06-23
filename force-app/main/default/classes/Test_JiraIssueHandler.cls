@isTest
public class Test_JiraIssueHandler {
    
    @isTest
    public static void TestScenerio1(){
        String OrgNameSpace=null;
        if(OrgNameSpace==null){
            OrgNameSpace=''; 
        }
        List<JiraSalesforceDetail__c> jsDetails = new List<JiraSalesforceDetail__c>();
        
        JiraSalesforceDetail__c jsDetail1 
            = new JiraSalesforceDetail__c(Name='SalesForceDomain', 
                                          Value__c = 'http://grz_sfjira-developer-edition.ap0.force.com');
        jsDetails.add(jsDetail1 );
        JiraSalesforceDetail__c jsDetail2 
            = new JiraSalesforceDetail__c(Name='CreateLinks', 
                                          Value__c = 'yes');
        jsDetails.add(jsDetail2 );
        insert jsDetails;
        boolean CreateLinks;
        if(jsDetail2.Name == 'CreateLinks' && jsDetail2.Value__c.toLowerCase() =='http://grz_sfjira-developer-edition.ap0.force.com' ){
            CreateLinks = true;
        }
        
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.LoginSuccess__c=true;
        
        insert setting; 
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st1;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'JiraIssueTrigger';
        st.IsActive__c = true;
        insert st;
        
        Rule_Set__c rule=Testdata.Newruleset('test', '1', true, 'DEV',  'rulename' ,1,True);
        Child_Rule_Set__c child= Testdata.Newchildruleset('STRING','suppliedemail','', 'not equal to', rule,'1',true);
        Account ac = new account(name='test');
        insert ac;
        Case cs1 =Testdata.createcase('', String.valueof(ac.id), 'working', true);
        Case cs =Testdata.createcase('email@test.com', String.ValueOf(ac.id), 'New', true);
        String accKey1 = createCaseNumKey(cs.id, 'TP-1057');
        String val='[http://grz_sfjira-developer-edition.ap0.force.com/apex/Grz_Sf__detailPage?id=' + accKey1+']';
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, 'TP-1057', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"key":"TP-1057","id":"11765","fields":{"customfield_10215":"'+ '00001002 [view |  https://grzsfjira-developer-edition.ap8.force.com/apex/Grz_Sf__detailPage?id=WLIO/ORztuKYLVI13FrZfUzO02EwIVi9i/dtcvhlOZu/LwyQC/hf7lmWnWI5m/J3BQ392CMiBfsHlxTqsi845A==] ' +'"}}';
        ji.name='Test';
        Ji.Project__c='DEV';
        insert ji;
        JiraIssue__c ji1=Testdata.createjira('test1', 'test1', 10018, 'TP-1056', 'Task', 'u1', 'sds', 'high', false);
        ji1.JsonData__c='{"key":"TP-1056","id":"11765","fields":{"customfield_10218":"'+ '' +'"}}';
        Ji1.Project__c='DEV';
        insert ji1;
        
        
        JiraRelationship__c jr1= Testdata.createjirarelation(cs1.id, ji1.id, true);
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='Development';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='Sub-Task';
        insert pm;
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
        promap.Salesforce_Object__c='Idea';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Idea';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Account';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        Jira_ProjectFieldsMapping__c projectMap2 = Testdata.createjirafieldmapp(pm.id,false,'select',null, 'select','customfield_10043' ,true, true ,'select',false);
        projectMap2.jira_project__c=pm.id;
        projectMap2.RelatedProjectIdSet__c = pm.Id;
        projectMap2.IssueTypedata__c='All';
        projectMap2.Salesforce_Object__c='Account';
        projectMap2.Section__c =Section.id;
        jirafieldmap.add(projectMap2);
        
        Jira_ProjectFieldsMapping__c projectMap12 = Testdata.createjirafieldmapp(pm.id,false,'userpicker','AccountId','userpicker', 'customfield_10022' ,true, true ,'userpicker',false);
        projectMap12.jira_project__c=pm.id;
        projectMap12.RelatedProjectIdSet__c = pm.Id;
        projectMap12.IssueTypedata__c='All';
        projectMap12.Salesforce_Object__c='Account';
        projectMap12.Section__c =Section.id;
        jirafieldmap.add(projectMap12);
        
        Jira_ProjectFieldsMapping__c projectMap4 = Testdata.createjirafieldmapp(pm.id,false,'multiuserpicker',null, 'multiuserpicker','customfield_10031' ,true, true,'multiuserpicker' ,false);
        projectMap4.jira_project__c=pm.id;
        projectMap4.RelatedProjectIdSet__c = pm.Id;
        projectMap4.IssueTypedata__c='All';
        projectMap4.Salesforce_Object__c='Case';
        projectMap4.Section__c =Section.id;
        jirafieldmap.add(projectMap4);
        
        Jira_ProjectFieldsMapping__c projectMapv4 = Testdata.createjirafieldmapp(pm.id,false,'multiversion',null,'multiversion', 'customfield_10032' ,true, true,'multiversion' ,false);
        projectMapv4.jira_project__c=pm.id;
        projectMapv4.RelatedProjectIdSet__c = pm.id;
        projectMapv4.IssueTypedata__c='All';
        projectMapv4.Salesforce_Object__c='Case';
        projectMapv4.Section__c =Section.id;
        jirafieldmap.add(projectMapv4);
        
        
        Jira_ProjectFieldsMapping__c projectMapv5 = Testdata.createjirafieldmapp(pm.id,false,'id',null,'id', 'customfield_10218' ,true, false,'id' ,false);
        projectMapv5.jira_project__c=pm.id;
        projectMapv5.RelatedProjectIdSet__c = pm.id;
        projectMapv5.IssueTypedata__c='All';
        projectMapv5.Salesforce_Object__c='Case';
        projectMapv5.Section__c =Section.id;
        
        jirafieldmap.add(projectMapv5);
        
        Jira_ProjectFieldsMapping__c projectMapv6 = Testdata.createjirafieldmapp(pm.id,false,'Sf links',null,'Salesforce Account Names', 'customfield_10215' ,true, false,'textarea' ,false);
        projectMapv6.jira_project__c=pm.id;
        projectMapv6.RelatedProjectIdSet__c = pm.id;
        projectMapv6.IssueTypedata__c='All';
        projectMapv6.Salesforce_Object__c='Case';
        projectMapv6.Section__c =Section.id;
        projectMapv6.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv6);
        
        Jira_ProjectFieldsMapping__c projectMapv7 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv7.jira_project__c=pm.id;
        projectMapv7.RelatedProjectIdSet__c = pm.id;
        projectMapv7.IssueTypedata__c='All';
        projectMapv7.Salesforce_Object__c='Case';
        projectMapv7.Section__c =Section.id;
        //projectMapv7.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv7);
        
        Jira_ProjectFieldsMapping__c projectMapv8 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv8.jira_project__c=pm.id;
        projectMapv8.RelatedProjectIdSet__c = pm.id;
        projectMapv8.IssueTypedata__c='All';
        projectMapv8.Salesforce_Object__c='Case';
        projectMapv8.Section__c =Section.id;
        //projectMapv8.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv8);
        
        Jira_ProjectFieldsMapping__c projectMapv9 = Testdata.createjirafieldmapp(pm.id,false,'issuelinks',null,'Linked Issues', 'issuelinks' ,true, true,'issuelinks' ,false);
        projectMapv9.jira_project__c=pm.id;
        projectMapv9.RelatedProjectIdSet__c = pm.id;
        projectMapv9.IssueTypedata__c='All';
        projectMapv9.Salesforce_Object__c='Case';
        projectMapv9.Section__c =Section.id;
        //projectMapv9.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv9);
        
        Jira_ProjectFieldsMapping__c projectMap9 = Testdata.createjirafieldmapp(pm.id,false,'Epic Name',null,'Epic Name' ,'customfield_10102' ,true, false,'gh-epic-label' ,false);
        projectMap9.jira_project__c=pm.id;
        projectMap9.RelatedProjectIdSet__c = pm.id;
        projectMap9.IssueTypedata__c='All';
        projectMap9.Salesforce_Object__c='Case';
        projectMap9.Section__c =Section.id;
        //projectMap9.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap9);
        
        Jira_ProjectFieldsMapping__c projectMap999 = Testdata.createjirafieldmapp(pm.id,false,'Epic link',null,'Epic link' ,'customfield_10100' ,true, false,'gh-epic-link' ,false);
        projectMap999.jira_project__c=pm.id;
        projectMap999.RelatedProjectIdSet__c = pm.id;
        projectMap999.IssueTypedata__c='All';
        projectMap999.Salesforce_Object__c='Case';
        projectMap999.Section__c =Section.id;
        //projectMap999.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap999);
        
        Jira_ProjectFieldsMapping__c projectMap09 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'parent','parent' ,true, false,'issuelink' ,false);
        projectMap09.jira_project__c=pm.id;
        projectMap09.RelatedProjectIdSet__c = pm.id;
        projectMap09.IssueTypedata__c='All';
        projectMap09.Salesforce_Object__c='Case';
        projectMap09.Section__c =Section.id;
        //projectMap09.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap09);
        
        Jira_ProjectFieldsMapping__c projectMapvv9 = Testdata.createjirafieldmapp(pm.id,false,'datetime',null,'Date Time Picker', 'customfield_10203' ,true, false,'datetime' ,false);
        projectMapvv9.jira_project__c=pm.id;
        projectMapvv9.RelatedProjectIdSet__c = pm.id;
        projectMapvv9.IssueTypedata__c='All';
        projectMapvv9.Salesforce_Object__c='Case';
        projectMapvv9.Section__c =Section.id;
        //projectMapvv9.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapvv9);
        
        Jira_ProjectFieldsMapping__c projectMapvv11 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'issuelink', 'parent' ,true, false,'issuelink' ,false);
        projectMapvv11.jira_project__c=pm.id;
        projectMapvv11.RelatedProjectIdSet__c = pm.id;
        projectMapvv11.IssueTypedata__c='All';
        projectMapvv11.Salesforce_Object__c='Case';
        projectMapvv11.Section__c =Section.id;
        jirafieldmap.add(projectMapvv11);
        
        Jira_ProjectFieldsMapping__c projectMapvv12 = Testdata.createjirafieldmapp(pm.id,false,'fixVersions',null,'Fix Version/s', 'fixVersions' ,true, false,'version' ,false);
        projectMapvv12.jira_project__c=pm.id;
        projectMapvv12.RelatedProjectIdSet__c = pm.id;
        projectMapvv12.IssueTypedata__c='All';
        projectMapvv12.Salesforce_Object__c='Case';
        projectMapvv12.Section__c =Section.id;
        jirafieldmap.add(projectMapvv12);
        
        insert jirafieldmap;
        
        projectMapv9.IsReportingEnabled__c = true;
        update projectMapv9;
        
        Reporting_Permissions__c RP = New Reporting_Permissions__c(Name='Admin',Profile_Id__c='00e7F000002XGpK');
        Insert RP;
        
        
        
        case cs2=[select id,SuppliedEmail from case where status='New' limit 1];
        JiraIssue__c jii=[select id,Name,Summary__c,Priority__c,JsonData__c,Jira_Link__c,IssueKey__c,Reporter__c,Status__c,Assignee__c from JiraIssue__c  where Issueid__c=10019 limit 1];
        
        Case cs3 = Testdata.createcase('testemail@test.com', ac.Id, 'In Progress', true);
        
        cs3  = [SELECT Id, CaseNumber FROM Case WHERE Id = :cs3.Id];
        String caseNumKey = createCaseNumKey(cs2.Id, 'GC-1057');
        
        JiraIssue__c ji4 = createJiraIssue('GC-1057', caseNumKey,cs.CaseNumber);
        insert ji4;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        
        jii.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10215":"'+ cs2.id +'"}}';
        
        update jii;
        
        Community objcommunity = [ SELECT Id,Name FROM Community Where Name='Internal Zone' ];
        idea ideaobj=new Idea(Title='TestIdea',Body='Test Body',Status='Active',communityID=objcommunity.id);
        insert ideaobj;
        idea is1=[select id, Title from idea limit 1];
        JiraIssue__c jiii=[select id,Name,Summary__c,Priority__c,JsonData__c,Jira_Link__c,IssueKey__c,Reporter__c,Status__c,Assignee__c from JiraIssue__c  where Issueid__c=10019 limit 1];
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata1());
        jiii.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10215":"'+ is1.id+'"}}';
        update jiii;
        
        JiraIssueHandler j=new JiraIssueHandler();
        j.bulkBefore();
        j.beforeInsert(jii);
        j.beforeUpdate(jii,jiii);
        j.beforeDelete(jii);
        j.afterDelete(jii);
        
        test.stopTest();
        System.assertEquals(jiii.Name,'Test');
    }
 @isTest
    public static void TestScenerio2(){
        String OrgNameSpace=null;
        if(OrgNameSpace==null){
            OrgNameSpace=''; 
        }
        List<JiraSalesforceDetail__c> jsDetails = new List<JiraSalesforceDetail__c>();
        
        JiraSalesforceDetail__c jsDetail1 
            = new JiraSalesforceDetail__c(Name='SalesForceDomain', 
                                          Value__c = 'http://grz_sfjira-developer-edition.ap0.force.com');
        jsDetails.add(jsDetail1 );
        JiraSalesforceDetail__c jsDetail2 
            = new JiraSalesforceDetail__c(Name='CreateLinks', 
                                          Value__c = 'yes');
        jsDetails.add(jsDetail2 );
        insert jsDetails;
        boolean CreateLinks;
        if(jsDetail2.Name == 'CreateLinks' && jsDetail2.Value__c.toLowerCase() =='http://grz_sfjira-developer-edition.ap0.force.com' ){
            CreateLinks = true;
        }
        
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.LoginSuccess__c=true;
        
        insert setting; 
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st1;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'JiraIssueTrigger';
        st.IsActive__c = true;
        insert st;
        
        Rule_Set__c rule=Testdata.Newruleset('test', '1', true, 'DEV',  'rulename' ,1,True);
        Child_Rule_Set__c child= Testdata.Newchildruleset('STRING','suppliedemail','', 'not equal to', rule,'1',true);
        Account ac = new account(name='test');
        insert ac;
        Case cs1 =Testdata.createcase('', String.valueof(ac.id), 'working', true);
        Case cs =Testdata.createcase('email@test.com', String.ValueOf(ac.id), 'New', true);
        String accKey1 = createCaseNumKey(cs.id, 'TP-1057');
        String val='[http://grz_sfjira-developer-edition.ap0.force.com/apex/Grz_Sf__detailPage?id=' + accKey1+']';
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, 'TP-1057', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"key":"TP-1057","id":"11765","fields":{"customfield_10215":"'+ '00001002 [view |  https://grzsfjira-developer-edition.ap8.force.com/apex/Grz_Sf__detailPage?id=WLIO/ORztuKYLVI13FrZfUzO02EwIVi9i/dtcvhlOZu/LwyQC/hf7lmWnWI5m/J3BQ392CMiBfsHlxTqsi845A==] ' +'"}}';
        ji.name='Test';
        Ji.Project__c='DEV';
        insert ji;
        JiraIssue__c ji1=Testdata.createjira('test1', 'test1', 10018, 'TP-1056', 'Task', 'u1', 'sds', 'high', false);
        ji1.JsonData__c='{"key":"TP-1056","id":"11765","fields":{"customfield_10218":"'+ '' +'"}}';
        Ji1.Project__c='DEV';
        insert ji1;
        
        
        JiraRelationship__c jr1= Testdata.createjirarelation(cs1.id, ji1.id, true);
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='Development';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='Sub-Task';
        insert pm;
        
        Jira_Project__c pm1 =new Jira_Project__c();
        pm1.ProjectId__c='10002';
        pm1.Name='QA';
        pm1.ProjectKey__c='QA';
        pm1.Subtask__c='Sub-Task';
        insert pm1;
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c);
        Testdata.CreateJSon(pm1.id,pm1.ProjectKey__c);
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        Testdata.CreateStaticFields(pm.id);
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.IsStatic__c=false;
        proMap.ReqInIssueTypeData__c='All';
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='idea';
        proMap.Section__c =Section.id;
        proMap.Enable_Record_Mapping__c=true;
        proMap.IsReportingEnabled__c = true;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm1.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm1.Id;
        proMapp.jira_project__c=pm1.Id;
        proMapp.IsStatic__c=false;
        proMapp.ReqInIssueTypeData__c='All';
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='idea';
        promapp.Enable_Record_Mapping__c=true;
        promapp.IsReportingEnabled__c = true;
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        proMap1.IsStatic__c=false;
        proMap1.ReqInIssueTypeData__c='All';
        promap1.Salesforce_Object__c='account';
        proMap1.Section__c =Section.id;
        proMap1.Enable_Record_Mapping__c=true;
        proMap1.IsReportingEnabled__c = true;
        jirafieldmap.add(proMap1);
        
        Jira_ProjectFieldsMapping__c projectMap2 = Testdata.createjirafieldmapp(pm.id,false,'select',null, 'select','customfield_10043' ,true, true ,'select',false);
        projectMap2.jira_project__c=pm.id;
        projectMap2.RelatedProjectIdSet__c = pm.Id;
        projectMap2.IsStatic__c=false;
        projectMap2.ReqInIssueTypeData__c='All';
        projectMap2.IssueTypedata__c='All';
        projectMap2.Salesforce_Object__c='account';
        projectMap2.Section__c =Section.id;
        projectMap2.Enable_Record_Mapping__c=true;
        projectMap2.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMap2);
        
        Jira_ProjectFieldsMapping__c projectMap12 = Testdata.createjirafieldmapp(pm.id,false,'userpicker','AccountId','userpicker', 'customfield_10022' ,true, true ,'userpicker',false);
        projectMap12.jira_project__c=pm.id;
        projectMap12.RelatedProjectIdSet__c = pm.Id;
        projectMap12.IsStatic__c=false;
        projectMap12.ReqInIssueTypeData__c='All';
        projectMap12.IssueTypedata__c='All';
        projectMap12.Salesforce_Object__c='account';
        projectMap12.Section__c =Section.id;
        projectMap12.Enable_Record_Mapping__c=true;
        projectMap12.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMap12);
        
        Jira_ProjectFieldsMapping__c projectMap4 = Testdata.createjirafieldmapp(pm.id,false,'multiuserpicker',null, 'multiuserpicker','customfield_10031' ,true, true,'multiuserpicker' ,false);
        projectMap4.jira_project__c=pm.id;
        projectMap4.RelatedProjectIdSet__c = pm.Id;
        projectMap4.IsStatic__c=false;
        projectMap4.ReqInIssueTypeData__c='All';
        projectMap4.IssueTypedata__c='All';
        projectMap4.Salesforce_Object__c='case';
        projectMap4.Section__c =Section.id;
        projectMap4.Enable_Record_Mapping__c=true;
        projectMap4.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMap4);
        
        Jira_ProjectFieldsMapping__c projectMapv4 = Testdata.createjirafieldmapp(pm.id,false,'multiversion',null,'multiversion', 'customfield_10032' ,true, true,'multiversion' ,false);
        projectMapv4.jira_project__c=pm.id;
        projectMapv4.RelatedProjectIdSet__c = pm.id;
        projectMapv4.IsStatic__c=false;
        projectMapv4.ReqInIssueTypeData__c='All';
        projectMapv4.IssueTypedata__c='All';
        projectMapv4.Salesforce_Object__c='case';
        projectMapv4.Section__c =Section.id;
        projectMapv4.Enable_Record_Mapping__c=true;
        projectMapv4.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMapv4);
        
        
        Jira_ProjectFieldsMapping__c projectMapv5 = Testdata.createjirafieldmapp(pm.id,false,'id',null,'id', 'customfield_10218' ,true, false,'id' ,false);
        projectMapv5.jira_project__c=pm.id;
        projectMapv5.RelatedProjectIdSet__c = pm.id;
        projectMapv5.IsStatic__c=false;
        projectMapv5.ReqInIssueTypeData__c='All';
        projectMapv5.IssueTypedata__c='All';
        projectMapv5.Salesforce_Object__c='case';
        projectMapv5.Section__c =Section.id;
        projectMapv5.Enable_Record_Mapping__c=true;
        projectMapv5.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMapv5);
        
        Jira_ProjectFieldsMapping__c projectMapv6 = Testdata.createjirafieldmapp(pm.id,false,'Sf links',null,'Salesforce Account Names', 'customfield_10215' ,true, false,'textarea' ,false);
        projectMapv6.jira_project__c=pm.id;
        projectMapv6.RelatedProjectIdSet__c = pm.id;
        projectMapv6.IsStatic__c=false;
        projectMapv6.ReqInIssueTypeData__c='All';
        projectMapv6.IssueTypedata__c='All';
        projectMapv6.Salesforce_Object__c='case';
        projectMapv6.Section__c =Section.id;
        projectMapv6.Enable_Record_Mapping__c=true;
        projectMapv6.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMapv6);
        
        Jira_ProjectFieldsMapping__c projectMapv7 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv7.jira_project__c=pm.id;
        projectMapv7.RelatedProjectIdSet__c = pm.id;
        projectMapv7.IsStatic__c=false;
        projectMapv7.ReqInIssueTypeData__c='All';
        projectMapv7.IssueTypedata__c='All';
        projectMapv7.Salesforce_Object__c='case';
        projectMapv7.Section__c =Section.id;
        projectMapv7.Enable_Record_Mapping__c=true;
        projectMapv7.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMapv7);
        
        Jira_ProjectFieldsMapping__c projectMapv8 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv8.jira_project__c=pm.id;
        projectMapv8.RelatedProjectIdSet__c = pm.id;
        projectMapv8.IsStatic__c=false;
        projectMapv8.ReqInIssueTypeData__c='All';
        projectMapv8.IssueTypedata__c='All';
        projectMapv8.Salesforce_Object__c='case';
        projectMapv8.Section__c =Section.id;
        projectMapv8.Enable_Record_Mapping__c=true;
        projectMapv8.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMapv8);
        
        Jira_ProjectFieldsMapping__c projectMapv9 = Testdata.createjirafieldmapp(pm.id,false,'issuelinks',null,'Linked Issues', 'issuelinks' ,true, true,'issuelinks' ,false);
        projectMapv9.jira_project__c=pm.id;
        projectMapv9.RelatedProjectIdSet__c = pm.id;
        projectMapv9.IsStatic__c=false;
        projectMapv9.ReqInIssueTypeData__c='All';
        projectMapv9.IssueTypedata__c='All';
        projectMapv9.Salesforce_Object__c='case';
        projectMapv9.Section__c =Section.id;
        projectMapv9.Enable_Record_Mapping__c=true;
        projectMapv9.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMapv9);
        
        Jira_ProjectFieldsMapping__c projectMap9 = Testdata.createjirafieldmapp(pm.id,false,'Epic Name',null,'Epic Name' ,'customfield_10102' ,true, false,'gh-epic-label' ,false);
        projectMap9.jira_project__c=pm.id;
        projectMap9.RelatedProjectIdSet__c = pm.id;
        projectMap9.IsStatic__c=false;
        projectMap9.ReqInIssueTypeData__c='All';
        projectMap9.IssueTypedata__c='All';
        projectMap9.Salesforce_Object__c='case';
        projectMap9.Section__c =Section.id;
        projectMap9.Enable_Record_Mapping__c=true;
        projectMap9.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMap9);
        
        Jira_ProjectFieldsMapping__c projectMap999 = Testdata.createjirafieldmapp(pm.id,false,'Epic link',null,'Epic link' ,'customfield_10100' ,true, false,'gh-epic-link' ,false);
        projectMap999.jira_project__c=pm.id;
        projectMap999.RelatedProjectIdSet__c = pm.id;
        projectMap999.IsStatic__c=false;
        projectMap999.ReqInIssueTypeData__c='All';
        projectMap999.IssueTypedata__c='All';
        projectMap999.Salesforce_Object__c='case';
        projectMap999.Section__c =Section.id;
        projectMap999.Enable_Record_Mapping__c=true;
        projectMap999.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMap999);
        
        Jira_ProjectFieldsMapping__c projectMap09 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'parent','parent' ,true, false,'issuelink' ,false);
        projectMap09.jira_project__c=pm.id;
        projectMap09.RelatedProjectIdSet__c = pm.id;
        projectMap09.IsStatic__c=false;
        projectMap09.ReqInIssueTypeData__c='All';
        projectMap09.IssueTypedata__c='All';
        projectMap09.Salesforce_Object__c='case';
        projectMap09.Section__c =Section.id;
        projectMap09.Enable_Record_Mapping__c=true;
        projectMap09.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMap09);
        
        Jira_ProjectFieldsMapping__c projectMapvv9 = Testdata.createjirafieldmapp(pm.id,false,'datetime',null,'Date Time Picker', 'customfield_10203' ,true, false,'datetime' ,false);
        projectMapvv9.jira_project__c=pm.id;
        projectMapvv9.RelatedProjectIdSet__c = pm.id;
        projectMapvv9.IsStatic__c=false;
        projectMapvv9.ReqInIssueTypeData__c='All';
        projectMapvv9.IssueTypedata__c='All';
        projectMapvv9.Salesforce_Object__c='case';
        projectMapvv9.Section__c =Section.id;
        projectMapvv9.Enable_Record_Mapping__c=true;
        projectMapvv9.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMapvv9);
        
        Jira_ProjectFieldsMapping__c projectMapvv11 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'issuelink', 'parent' ,true, false,'issuelink' ,false);
        projectMapvv11.jira_project__c=pm.id;
        projectMapvv11.RelatedProjectIdSet__c = pm.id;
        projectMapvv11.IsStatic__c=false;
        projectMapvv11.ReqInIssueTypeData__c='All';
        projectMapvv11.IssueTypedata__c='All';
        projectMapvv11.Salesforce_Object__c='case';
        projectMapvv11.Section__c =Section.id;
        projectMapvv11.Enable_Record_Mapping__c=true;
        projectMapvv11.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMapvv11);
        
        Jira_ProjectFieldsMapping__c projectMapvv12 = Testdata.createjirafieldmapp(pm.id,false,'fixVersions',null,'Fix Version/s', 'fixVersions' ,true, false,'version' ,false);
        projectMapvv12.jira_project__c=pm.id;
        projectMapvv12.RelatedProjectIdSet__c = pm.id;
        projectMapvv12.IsStatic__c=false;
        projectMapvv12.ReqInIssueTypeData__c='All';
        projectMapvv12.IssueTypedata__c='All';
        projectMapvv12.Salesforce_Object__c='case';
        projectMapvv12.Section__c =Section.id;
        projectMapvv12.Enable_Record_Mapping__c=true;
        projectMapvv12.IsReportingEnabled__c = true;
        jirafieldmap.add(projectMapvv12);
        
        insert jirafieldmap;
        
        projectMapv9.IsReportingEnabled__c = true;
        update projectMapv9;
        
        Reporting_Permissions__c RP = New Reporting_Permissions__c(Name='Admin',Profile_Id__c='00e7F000002XGpK');
        Insert RP;
        
        
        case cs2=[select id,SuppliedEmail from case where status='New' limit 1];
        JiraIssue__c jii=[select id,Name,Summary__c,Priority__c,JsonData__c,Jira_Link__c,IssueKey__c,Reporter__c,Status__c,Assignee__c from JiraIssue__c  where Issueid__c=10019 limit 1];
        
        Case cs3 = Testdata.createcase('testemail@test.com', ac.Id, 'In Progress', true);
        
        cs3  = [SELECT Id, CaseNumber FROM Case WHERE Id = :cs3.Id];
        String caseNumKey = createCaseNumKey(cs2.Id, 'GC-1057');
        
        JiraIssue__c ji4 = createJiraIssue('GC-1057', caseNumKey,cs.CaseNumber);
        insert ji4;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        
        jii.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10215":"'+ cs2.id +'"}}';
        
        update jii;
        
        Community objcommunity = [ SELECT Id,Name FROM Community Where Name='Internal Zone' ];
        idea ideaobj=new Idea(Title='TestIdea',Body='Test Body',Status='Active',communityID=objcommunity.id);
        insert ideaobj;
        idea is1=[select id, Title from idea limit 1];
        JiraIssue__c jiii=[select id,Name,Summary__c,Priority__c,JsonData__c,Jira_Link__c,IssueKey__c,Reporter__c,Status__c,Assignee__c from JiraIssue__c  where Issueid__c=10019 limit 1];
        //test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata1());
        jiii.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10215":"'+ is1.id+'"}}';
        update jiii;
        
        JiraIssueHandler j=new JiraIssueHandler();
        j.bulkBefore();
        j.beforeInsert(jii);
        j.beforeUpdate(jii,jiii);
        j.beforeDelete(jii);
        j.afterDelete(jii);
        
        test.stopTest();
        System.assertEquals(jiii.Name,'Test');
    }    
    
    @isTest
    public static void TestScenerio0(){
       
        List<JiraSalesforceDetail__c> jsDetails = new List<JiraSalesforceDetail__c>();
        
        JiraSalesforceDetail__c jsDetail1 
            = new JiraSalesforceDetail__c(Name='SalesForceDomain', 
                                          Value__c = 'http://grz_sfjira-developer-edition.ap0.force.com');
        jsDetails.add(jsDetail1 );
        JiraSalesforceDetail__c jsDetail2 
            = new JiraSalesforceDetail__c(Name='CreateLinks', 
                                          Value__c = 'yes');
        jsDetails.add(jsDetail2 );
        insert jsDetails;
        boolean CreateLinks;
        if(jsDetail2.Name == 'CreateLinks' && jsDetail2.Value__c.toLowerCase() =='http://grz_sfjira-developer-edition.ap0.force.com' ){
            CreateLinks = true;
        }
        
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.LoginSuccess__c=true;
        
        insert setting; 
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st1;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'JiraIssueTrigger';
        st.IsActive__c = true;
        insert st;
        
        Rule_Set__c rule=Testdata.Newruleset('test', '1', true, 'DEV',  'rulename' ,1,True);
        Child_Rule_Set__c child= Testdata.Newchildruleset('STRING','suppliedemail','', 'not equal to', rule,'1',true);
        Account ac = new account(name='test');
        insert ac;
        Case cs1 =Testdata.createcase('', String.valueof(ac.id), 'working', true);
        Case cs =Testdata.createcase('email@test.com', String.ValueOf(ac.id), 'New', true);
        String accKey1 = createCaseNumKey(cs.id, 'TP-1057');
        String val='[http://grz_sfjira-developer-edition.ap0.force.com/apex/Grz_Sf__detailPage?id=' + accKey1+']';
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, 'TP-1057', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"key":"TP-1057","id":"11765","fields":{"customfield_10215":"'+ '00001002 [view |  https://grzsfjira-developer-edition.ap8.force.com/apex/Grz_Sf__detailPage?id=WLIO/ORztuKYLVI13FrZfUzO02EwIVi9i/dtcvhlOZu/LwyQC/hf7lmWnWI5m/J3BQ392CMiBfsHlxTqsi845A==] ' +'"}}';
        ji.name='Test';
        Ji.Project__c='DEV';
        insert ji;
        JiraIssue__c ji1=Testdata.createjira('test1', 'test1', 10018, 'TP-1056', 'Task', 'u1', 'sds', 'high', false);
        ji1.JsonData__c='{"key":"TP-1056","id":"11765","fields":{"customfield_10218":"'+ '' +'"}}';
        Ji1.Project__c='DEV';
        insert ji1;
        
        
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, true);
        JiraRelationship__c jr1= Testdata.createjirarelation(cs1.id, ji1.id, true);
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='Development';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='Sub-Task';
        insert pm;
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
        promap.Salesforce_Object__c='Idea';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Idea';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Account';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        Jira_ProjectFieldsMapping__c projectMap2 = Testdata.createjirafieldmapp(pm.id,false,'select',null, 'select','customfield_10043' ,true, true ,'select',false);
        projectMap2.jira_project__c=pm.id;
        projectMap2.RelatedProjectIdSet__c = pm.Id;
        projectMap2.IssueTypedata__c='All';
        projectMap2.Salesforce_Object__c='Account';
        projectMap2.Section__c =Section.id;
        jirafieldmap.add(projectMap2);
        
        Jira_ProjectFieldsMapping__c projectMap12 = Testdata.createjirafieldmapp(pm.id,false,'userpicker','AccountId','userpicker', 'customfield_10022' ,true, true ,'userpicker',false);
        projectMap12.jira_project__c=pm.id;
        projectMap12.RelatedProjectIdSet__c = pm.Id;
        projectMap12.IssueTypedata__c='All';
        projectMap12.Salesforce_Object__c='Account';
        projectMap12.Section__c =Section.id;
        jirafieldmap.add(projectMap12);
        
        Jira_ProjectFieldsMapping__c projectMap4 = Testdata.createjirafieldmapp(pm.id,false,'multiuserpicker',null, 'multiuserpicker','customfield_10031' ,true, true,'multiuserpicker' ,false);
        projectMap4.jira_project__c=pm.id;
        projectMap4.RelatedProjectIdSet__c = pm.Id;
        projectMap4.IssueTypedata__c='All';
        projectMap4.Salesforce_Object__c='Case';
        projectMap4.Section__c =Section.id;
        jirafieldmap.add(projectMap4);
        
        Jira_ProjectFieldsMapping__c projectMapv4 = Testdata.createjirafieldmapp(pm.id,false,'multiversion',null,'multiversion', 'customfield_10032' ,true, true,'multiversion' ,false);
        projectMapv4.jira_project__c=pm.id;
        projectMapv4.RelatedProjectIdSet__c = pm.id;
        projectMapv4.IssueTypedata__c='All';
        projectMapv4.Salesforce_Object__c='Case';
        projectMapv4.Section__c =Section.id;
        jirafieldmap.add(projectMapv4);
        
        
        Jira_ProjectFieldsMapping__c projectMapv5 = Testdata.createjirafieldmapp(pm.id,false,'id',null,'id', 'customfield_10218' ,true, false,'id' ,false);
        projectMapv5.jira_project__c=pm.id;
        projectMapv5.RelatedProjectIdSet__c = pm.id;
        projectMapv5.IssueTypedata__c='All';
        projectMapv5.Salesforce_Object__c='Case';
        projectMapv5.Section__c =Section.id;
        
        jirafieldmap.add(projectMapv5);
        
        Jira_ProjectFieldsMapping__c projectMapv6 = Testdata.createjirafieldmapp(pm.id,false,'Sf links',null,'Salesforce Account Names', 'customfield_10215' ,true, false,'textarea' ,false);
        projectMapv6.jira_project__c=pm.id;
        projectMapv6.RelatedProjectIdSet__c = pm.id;
        projectMapv6.IssueTypedata__c='All';
        projectMapv6.Salesforce_Object__c='Case';
        projectMapv6.Section__c =Section.id;
        //projectMapv6.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv6);
        
        Jira_ProjectFieldsMapping__c projectMapv7 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv7.jira_project__c=pm.id;
        projectMapv7.RelatedProjectIdSet__c = pm.id;
        projectMapv7.IssueTypedata__c='All';
        projectMapv7.Salesforce_Object__c='Case';
        projectMapv7.Section__c =Section.id;
        //projectMapv7.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv7);
        
        Jira_ProjectFieldsMapping__c projectMapv8 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv8.jira_project__c=pm.id;
        projectMapv8.RelatedProjectIdSet__c = pm.id;
        projectMapv8.IssueTypedata__c='All';
        projectMapv8.Salesforce_Object__c='Case';
        projectMapv8.Section__c =Section.id;
        //projectMapv8.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv8);
        
        Jira_ProjectFieldsMapping__c projectMapv9 = Testdata.createjirafieldmapp(pm.id,false,'issuelinks',null,'Linked Issues', 'issuelinks' ,true, true,'issuelinks' ,false);
        projectMapv9.jira_project__c=pm.id;
        projectMapv9.RelatedProjectIdSet__c = pm.id;
        projectMapv9.IssueTypedata__c='All';
        projectMapv9.Salesforce_Object__c='Case';
        projectMapv9.Section__c =Section.id;
        //projectMapv9.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv9);
        
        Jira_ProjectFieldsMapping__c projectMap9 = Testdata.createjirafieldmapp(pm.id,false,'Epic Name',null,'Epic Name' ,'customfield_10102' ,true, false,'gh-epic-label' ,false);
        projectMap9.jira_project__c=pm.id;
        projectMap9.RelatedProjectIdSet__c = pm.id;
        projectMap9.IssueTypedata__c='All';
        projectMap9.Salesforce_Object__c='Case';
        projectMap9.Section__c =Section.id;
        //projectMap9.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap9);
        
        Jira_ProjectFieldsMapping__c projectMap999 = Testdata.createjirafieldmapp(pm.id,false,'Epic link',null,'Epic link' ,'customfield_10100' ,true, false,'gh-epic-link' ,false);
        projectMap999.jira_project__c=pm.id;
        projectMap999.RelatedProjectIdSet__c = pm.id;
        projectMap999.IssueTypedata__c='All';
        projectMap999.Salesforce_Object__c='Case';
        projectMap999.Section__c =Section.id;
        //projectMap999.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap999);
        
        Jira_ProjectFieldsMapping__c projectMap09 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'parent','parent' ,true, false,'issuelink' ,false);
        projectMap09.jira_project__c=pm.id;
        projectMap09.RelatedProjectIdSet__c = pm.id;
        projectMap09.IssueTypedata__c='All';
        projectMap09.Salesforce_Object__c='Case';
        projectMap09.Section__c =Section.id;
        //projectMap09.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap09);
        
        Jira_ProjectFieldsMapping__c projectMapvv9 = Testdata.createjirafieldmapp(pm.id,false,'datetime',null,'Date Time Picker', 'customfield_10203' ,true, false,'datetime' ,false);
        projectMapvv9.jira_project__c=pm.id;
        projectMapvv9.RelatedProjectIdSet__c = pm.id;
        projectMapvv9.IssueTypedata__c='All';
        projectMapvv9.Salesforce_Object__c='Case';
        projectMapvv9.Section__c =Section.id;
        //projectMapvv9.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapvv9);
        
        Jira_ProjectFieldsMapping__c projectMapvv11 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'issuelink', 'parent' ,true, false,'issuelink' ,false);
        projectMapvv11.jira_project__c=pm.id;
        projectMapvv11.RelatedProjectIdSet__c = pm.id;
        projectMapvv11.IssueTypedata__c='All';
        projectMapvv11.Salesforce_Object__c='Case';
        projectMapvv11.Section__c =Section.id;
        jirafieldmap.add(projectMapvv11);
        
        Jira_ProjectFieldsMapping__c projectMapvv12 = Testdata.createjirafieldmapp(pm.id,false,'fixVersions',null,'Fix Version/s', 'fixVersions' ,true, false,'version' ,false);
        projectMapvv12.jira_project__c=pm.id;
        projectMapvv12.RelatedProjectIdSet__c = pm.id;
        projectMapvv12.IssueTypedata__c='All';
        projectMapvv12.Salesforce_Object__c='Case';
        projectMapvv12.Section__c =Section.id;
        jirafieldmap.add(projectMapvv12);
        
        insert jirafieldmap;
        
       // projectMapv9.IsReportingEnabled__c = true;
       // update projectMapv9;
        
        Reporting_Permissions__c RP = New Reporting_Permissions__c(Name='Admin',Profile_Id__c='00e7F000002XGpK');
        Insert RP;
        
        
        
        case cs2=[select id,SuppliedEmail from case where status='New' limit 1];
        JiraIssue__c jii=[select id,Name,Summary__c,Priority__c,JsonData__c,Jira_Link__c,IssueKey__c,Reporter__c,Status__c,Assignee__c from JiraIssue__c  where Issueid__c=10019 limit 1];
        
        Case cs3 = Testdata.createcase('testemail@test.com', ac.Id, 'In Progress', true);
        
        cs3  = [SELECT Id, CaseNumber FROM Case WHERE Id = :cs3.Id];
        String caseNumKey = createCaseNumKey(cs2.Id, 'GC-1057');
        
        JiraIssue__c ji4 = createJiraIssue('GC-1057', caseNumKey,cs.CaseNumber);
        insert ji4;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        
        jii.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10215":"'+ cs2.id +'"}}';
        
        update jii;
        
        Community objcommunity = [ SELECT Id,Name FROM Community Where Name='Internal Zone' ];
        idea ideaobj=new Idea(Title='TestIdea',Body='Test Body',Status='Active',communityID=objcommunity.id);
        insert ideaobj;
        idea is1=[select id, Title from idea limit 1];
        JiraIssue__c jiii=[select id,Name,Summary__c,Priority__c,JsonData__c,Jira_Link__c,IssueKey__c,Reporter__c,Status__c,Assignee__c from JiraIssue__c  where Issueid__c=10019 limit 1];
        //test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata1());
        jiii.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10215":"'+ is1.id+'"}}';
        update jiii;
        
        JiraIssueHandler j=new JiraIssueHandler();
        j.bulkBefore();
        j.beforeInsert(jii);
        j.beforeUpdate(jii,jiii);
        j.beforeDelete(jii);
        j.afterDelete(jii);
        
        test.stopTest();
        System.assertEquals(jiii.Name,'Test');
    }    
   
    public static String createCaseNumKey(String Num, String issueKey) {
        Datetime dateGMT=System.now();
        dateGMT=dateGMT.addMinutes(1);
        string time1=String.valueof(dateGMT);
        String temp11=Num+','+time1+','+issuekey;
        temp11=temp11.replaceAll(' ','----');
        Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
        Blob clearData=Blob.valueOf(temp11);
        String caseNumKey=EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', encryptionKey, clearData));
        
        return caseNumKey;
    }
    public static JiraIssue__c createJiraIssue(String name, String caseNumKey,String CaseVal) {
        JiraIssue__c ji = new JiraIssue__c();
        ji.Name=name;
        String val='http://grz_sfjira-developer-edition.ap0.force.com/apex/Grz_Sf__detailPage?id=' + caseNumKey;
        
        ji.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"Customfield_10502":"' + val + '"}}';
        ji.IssueId__c=121212;
        ji.IssueKey__c=name; 
        ji.IssueType__c='Task';
        return ji;
    }
}