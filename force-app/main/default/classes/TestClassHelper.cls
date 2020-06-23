@isTest
public class TestClassHelper {
    @testSetup
    public static void testdataRandom(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        insert setting;
        JiraSalesforceDetail__c jsDetail2=new JiraSalesforceDetail__c(Name='Jira_Comment_As_Private',Value__c='yes');
        insert jsDetail2;
        JiraSalesforceDetail__c jsDetail1=new JiraSalesforceDetail__c(Name='JiraCommentsSyncToJiraIssue',Value__c='yes');
        insert jsDetail1;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c='Private');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail23 
            = new JiraSalesforceDetail__c(Name='Store_Jira_Comment_in_Case', 
                                          Value__c = 'no');
        insert jsDetail23;
         JiraSalesforceDetail__c jsd = new JiraSalesforceDetail__c();
        jsd.name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'JiraAutoFileAttach';
        st.IsActive__c = true;
        insert st;
        
         JiraSalesforceDetail__c jsd1 = new JiraSalesforceDetail__c();
        jsd1.name = 'Sync_SF_Comments';
        jsd1.Value__c = 'yes';
        insert jsd1;
        
        JiraSalesforceDetail__c jsd2 = new JiraSalesforceDetail__c();
        jsd2.name = 'Auto_SF_Comment_Sync_Type';
        jsd2.Value__c = 'yes';
        insert jsd2;
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c();
        st1.Name = 'AddJiraComments';
        st1.IsActive__c = true;
        insert st1;
    }
    
    
    @isTest 
    public static void testmethod2(){
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DEV');
        Testdata.CreateJSon(jp.id, jp.projectkey__c);
        Jira_ProjectFieldsMapping__c fm= Testdata.createjirafieldmapp(jp.id,false,'name','Subject','customfield_10020', 'customfield_10020' ,True,  true , 'string',FALSE);
        fm.Salesforce_Object__c='Case';
        fm.IsStatic__c=true;
        insert fm;
        FieldsWrapper fw = new FieldsWrapper();
        fw.field=fm;
        String field= fw.fieldType;
        
        fm.Case_Field_Name__c='';
        update fm;
        FieldsWrapper fw1 = new FieldsWrapper(fm);
        fw1.field=fm;
        String field1= fw1.fieldType;
        
        Jira_ProjectFieldMappingHandler cont = new Jira_ProjectFieldMappingHandler();
        cont.bulkbefore();
        cont.beforeinsert(fm);
        cont.beforeupdate(fm,fm);
        cont.beforedelete(fm);
        cont.afterdelete(fm);
        boolean mapNotEmpty=false;
        if(cont.sfobjects.size()>0)
            mapNotEmpty=true;
        
        System.assertEquals(mapNotEmpty,false);
    }
    
 
    @isTest
    public static void testmethod4(){
        list<ProjectWrapper> ProjectWrapperList = new list<ProjectWrapper>();
        boolean mapNotEmpty=false;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        ProjectWrapperList=JiraService.fetchProjectData();
        Test.stopTest();
        if(ProjectWrapperList.size()>0)
            mapNotEmpty=true;
        
        System.assertEquals(mapNotEmpty,true);
        
    }
    @isTest
    public static void testmethod5(){
        boolean mapNotEmpty=false;
        JiraIssue__c ji= Testdata.createjira('summary', 'Descr', 122333, 'Issuekey', 'IssueType', 'assignee', 'priority', 'Priorityname', true);
        JiraIssueComments__c jr=new JiraIssueComments__c();
        jr.Author__c='admin';
        jr.IsPublished__c=false;
        jr.UpdateAuthor__c='admin';
        jr.JiraIssue__c=ji.id;
        jr.CommentBody__c='TEST';
        insert jr;
        jr.CommentBody__c='te';
        update jr;
        JiraCommentHandler jh=new JiraCommentHandler();
        
        if( jh.commentMap.keySet().size()>0)
            mapNotEmpty=true;
        
        System.assertEquals(mapNotEmpty,false);
        
    }
    
    /*@isTest
    public static void testmethod6(){
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DEV');
        Testdata.CreateJSon(jp.id, jp.projectkey__c);
        Jira_ProjectFieldsMapping__c fm= Testdata.createjirafieldmapp(jp.id,false,'name','Subject','customfield_10020', 'customfield_10020' ,True,  true , 'string',FALSE);
       
        FieldsWrapper fw=new FieldsWrapper(fm);
        //ViewJiraLightController.LoginSetting();
        System.assertEquals(1,1);
    }*/
    @isTest
    public static void testmethod7(){
        
        GenerateJiraLogs.CreateLog('ClassName', 'EndPoint', 'Method', 'ResStatusCode', 'ResBody', 'ResStatus', 'ReqBody', 'Body', 'ReferenceId', 'ReqFrom', 'OtherDetails');
        OnPackageInstall postinstall = new OnPackageInstall();
        Test.testInstall(postinstall, null);
        System.assertEquals(postinstall.init,true);
    }
}