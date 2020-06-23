@isTest
public class Test_ProjectSettingController {
    @isTest
    public static void testScenerio1(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=false;
        jira.Basic_Authentication__c=true;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'TP', 'TP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        insert jirafieldmap;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        ProjectSettingController psc = new ProjectSettingController();
        psc.onProjectLoad();
        psc.fetchProjectData();
        psc.saveProjects();
        // psc.SearchIssueType();
        // psc.FilterIssueType();
        //psc.UpdateIssueTypeList();
        psc.AsyncJobDone();
        Test.stopTest();
        system.assertEquals(psc.saveProjects(),null);
    }
    @isTest
    public static void testScenerio2(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=false;
        jira.Basic_Authentication__c=true;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st;
        
        Jira_Project__c pm= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        insert jirafieldmap;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        ProjectSettingController psc = new ProjectSettingController();
        psc.onProjectLoad();
        psc.fetchProjectData();
        psc.projectsList[0].selected=false;
        psc.saveProjects();
        // psc.SearchIssueType();
        // psc.FilterIssueType();
        //psc.UpdateIssueTypeList();
        psc.AsyncJobDone();
        Test.stopTest();
        System.assertEquals(psc.projectsList[0].selected,false);
    }
     @isTest
    public static void testScenerio3(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=false;
        jira.Basic_Authentication__c=true;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st;
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10000';
        pm.Name='TP';
        pm.ProjectKey__c='TP';
        //pm.ProjectId__c = '12050';
        pm.Read__c=TRUE;
        pm.Write__c=TRUE;
        insert pm;
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        insert jirafieldmap;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        ProjectSettingController psc = new ProjectSettingController();
        psc.onProjectLoad();
        psc.fetchProjectData();
        psc.saveProjects();
        // psc.SearchIssueType();
        // psc.FilterIssueType();
        //psc.UpdateIssueTypeList();
        psc.AsyncJobDone();
        Test.stopTest();
        List<Jira_ProjectFieldsMapping__c> jmapList = [SELECT id FROM Jira_ProjectFieldsMapping__c WHERE isStatic__c = true];
        system.assertEquals(jmapList.size()>0, true);
    }
     @isTest
    public static void testScenerio4(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=false;
        jira.Basic_Authentication__c=true;
        jira.Access_Token__c='984594589jdfkjdfkjdfkjfdkjdfkjfdkj';
        insert jira;
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st;
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        ProjectSettingController psc = new ProjectSettingController();
        psc.onProjectLoad();
       
        psc.projectsList[0].selected=true;
        psc.projectsList[0].SelectedIssues='Bug,Sub-task'; 
        psc.projectsList[0].project.DefaultIssueType__c='Bug';
        psc.saveProjects();
        Test.stopTest();
        system.assertEquals(psc.projectsList[0].project.DefaultIssueType__c, 'Bug');
        
    }
}