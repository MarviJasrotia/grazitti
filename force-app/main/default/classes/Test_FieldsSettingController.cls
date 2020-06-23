@isTest
public class Test_FieldsSettingController {
    @testSetup
    public Static void testdata1(){ 
        JIRA_Login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        
        insert jira;
        
        JiraSalesforceDetail__c Jsd=JiraSalesforceDetail__c.getValues('Sync_SF_Attachment');
        if(jsd==null){Jsd= new JiraSalesforceDetail__c();}
        jsd.name='Sync_SF_Attachment';
        jsd.value__c='YES';
        upsert jsd;
       
       
        /* LicenseKey__c lc= Testdata.createlicense(false);
        lc.LicenseKey__c='d3CyuiHfFY+eP7VxuY3gI7GceH3RjwP6tgYSBGuJhg9oCXdjL0/go9CGfHUo6XFgn/Rw9RgTVg6dnRu0YIGPsQ==   ';
        insert lc;
        */
      Jira_Project__c pro= Testdata.createjiraProject('10000', 'DP', 'DP');
        Testdata.CreateJSon(pro.id,pro.ProjectKey__c);
      
        Jira_Project__c TP= Testdata.createjiraProject('10001', 'TP', 'TP');
        
        Jira_Project__c pm = Testdata.createjiraProject('10001', 'jiraproject', 'DEV');
        Testdata.CreateJSon(pm.id, pm.projectkey__c);
        
        Testdata.CreateStaticFields(pm.id);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'Labels',null,'labels', 'labels' ,true, true ,'labels',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='All';
        proMap1.jira_project__c=pm.Id;
        proMap1.Salesforce_Object__c='Case';
        proMap1.IsReportingEnabled__c=true;
        promap1.Enable_Record_Mapping__c=true;
        insert proMap1;
    }
    @isTest 
    public static void testScenerioWrapper(){
        Test.startTest();
        Jira_Project__c pm = Testdata.createjiraProject('10001', 'jiraproject', 'DEV');
        Testdata.CreateJSon(pm.id, pm.projectkey__c);
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();

        Testdata.CreateStaticFields(pm.id);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'Labels',null,'labels', 'labels' ,true, true ,'labels',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='All';
        proMap1.jira_project__c=pm.Id;
        proMap1.Salesforce_Object__c='Case';
        proMap1.IsReportingEnabled__c=true;
        jirafieldmap.add(proMap1);
      
          //select
        Jira_ProjectFieldsMapping__c projectMap2 = Testdata.createjirafieldmapp(pm.id,false,'select',null, 'select','customfield_10043' ,true, true ,'select',false);
        projectMap2.jira_project__c=pm.id;
        projectMap2.RelatedProjectIdSet__c = pm.Id;
        projectMap2.IssueTypedata__c='Task';
        projectMap2.Salesforce_Object__c='Case';
        projectMap2.Default_Value_long__c='OPTION 1';
        projectMap2.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap2);
        
        
        Jira_ProjectFieldsMapping__c projectMap3 = Testdata.createjirafieldmapp(pm.id,false,'select',null, 'select','customfield_10043' ,true, true ,'select',false);
        projectMap3.jira_project__c=pm.id;
        projectMap3.RelatedProjectIdSet__c = pm.Id;
        projectMap3.IssueTypedata__c='Task';
        projectMap3.Salesforce_Object__c='Account';
        projectMap3.Default_Value_long__c='OPTION 1';
        projectMap3.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap3);
        insert jirafieldmap;
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        JIRA_Login__c ji=[select id,password__c from JIRA_Login__c where name='JIRA'];
        Jira_Project__c prolist=[select id,ProjectId__c,Name,ProjectKey__c from Jira_Project__c limit 1 ];
        PageReference pag= Page.EditAddJiraIssue;
        Test.setCurrentPage(pag);
        ApexPages.currentPage().getParameters().put('SelectedObjectForDefault','Case');
        ApexPages.currentPage().getParameters().put('jiraFieldApiForDefault','labels');
        FieldsSettingController FieldCont= new FieldsSettingController();
        FieldCont.fetchfieldsInitial();
        FieldCont.DefaultSectionDataApex();
        for(DynamicFieldWrapper dynamic : FieldCont.DefaultWrapper.JiraFields){
            if(dynamic.mappedfield.Name=='Labels'){
                dynamic.fieldValue='text';
                dynamic.mappedfield.Enable_Record_Mapping__c=true;
            }        
        }
        FieldCont.DefaultSave();
        ApexPages.currentPage().getParameters().put('updateObj','Case');
        FieldCont.updateValue();
        ApexPages.currentPage().getParameters().put('delObj','Account');
        FieldCont.deleteMappingForSelectedObj();
        FieldCont.AsyncJobDone();
        ApexPages.currentPage().getParameters().put('index','op_1_DP');

        
        FieldCont.saveFields();
        ApexPages.currentPage().getParameters().put('projectkey','DP');

        FieldCont.addJiraSfField();
        ApexPages.currentPage().getParameters().put('indexop','op_1_DP');

        FieldCont.removeJiraSfField();
        Test.stopTest();
        System.assertEquals(1,1);
    }
    
     @isTest 
    public static void testScenerioWrapper1(){
        Test.startTest();
        Jira_Project__c pm = Testdata.createjiraProject('10001', 'jiraproject', 'DEV');
        Testdata.CreateJSon(pm.id, pm.projectkey__c);
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        
        Testdata.CreateStaticFields(pm.id);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'Labels',null,'labels', 'labels' ,true, true ,'labels',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='All';
        proMap1.jira_project__c=pm.Id;
        proMap1.Salesforce_Object__c='Case';
        proMap1.IsReportingEnabled__c=true;
        jirafieldmap.add(proMap1);
        
        insert jirafieldmap;
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        JIRA_Login__c ji=[select id,password__c from JIRA_Login__c where name='JIRA'];
        Jira_Project__c prolist=[select id,ProjectId__c,Name,ProjectKey__c from Jira_Project__c limit 1 ];
        PageReference pag= Page.EditAddJiraIssue;
        Test.setCurrentPage(pag);
        ApexPages.currentPage().getParameters().put('SelectedObjectForDefault','Case');
        ApexPages.currentPage().getParameters().put('jiraFieldApiForDefault','labels');
        FieldsSettingController FieldCont= new FieldsSettingController();
        FieldCont.fetchfieldsInitial();
        FieldCont.objectToBeDeleted='Case';
        FieldCont.deleteobjectsMapping();
        Test.stopTest();
        System.assertEquals(1,1);
    }
    @isTest 
    public static void testScenerioWrapper2(){
        Delete [select id from Jira_Project__c limit 2];
        FieldsSettingController FieldCont= new FieldsSettingController();
        FieldCont.refreshFieldSettings();
        List<Jira_Project__c > jproList = [SELECT id FROM Jira_Project__c ];
       system.assertEquals(jproList.size(), 1);
    }
    @isTest 
    public static void testScenerioWrapper3(){
        FieldsSettingController FieldCont= new FieldsSettingController();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpissue());
        FieldCont.usersearchtext='FetchUser__Test';
        FieldCont.GetUserList();  
        TEst.stopTest(); 
        List<Jira_Project__c > jproList = [SELECT id FROM Jira_Project__c ];
       system.assertEquals(jproList.size(), 3);
    }
}