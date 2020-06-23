/*
 * For SyncCommentsFilesToJira
 */
@isTest
public class Test_SyncCommentsFilesToJira{

    @istest 
    public static void testScenerio1(){
      
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.File_Size__c ='10.00 MB';
        insert setting; 
        
         JiraSalesforceDetail__c jsd=new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        
        JiraSalesforceDetail__c jsd1=new JiraSalesforceDetail__c();
        jsd1.Name = 'Sync_SF_Comments';
        jsd1.Value__c = 'yes';
        insert jsd1;
        
         JiraSalesforceDetail__c jsd2=new JiraSalesforceDetail__c();
        jsd2.Name = 'File_Size';
        jsd2.Value__c = '1 MB';
        insert jsd2;
        
        JiraSalesforceDetail__c jsd3=new JiraSalesforceDetail__c();
        jsd3.Name = 'Auto_SF_Comment_Sync_Type';
        jsd3.Value__c = 'Case';
        insert jsd3;
        
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c();
        st1.Name = 'JiraAutoFileAttach';
        st1.IsActive__c = true;
        insert st1;
        
        Sinergify_Trigger__c st2 = new Sinergify_Trigger__c();
        st2.Name = 'AddJiraComments';
        st2.IsActive__c = true;
        insert st2;
       
        JiraIssue__c ji=Testdata.createjira('test1', 'test1', 10018, '1003', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10018","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        ji.Project__c='DEV';
        insert ji;
        Account ac = new account(name='test');
        insert ac; 
        Case cs1 =Testdata.createcase('email@test.com', String.ValueOf(ac.id), 'New', true);
        ApexPages.StandardController sc = new ApexPages.StandardController(ji);
        
        ContentVersion cv= new ContentVersion();
        cv.VersionData=Blob.valueOf('test body');
        cv.Title='TEST Attachment';
        cv.PathOnClient='TEST Attachment';
        insert cv;
        ContentVersion cd= new ContentVersion();
        cd=[select id , ContentDocumentid from ContentVersion where id=:cv.id limit 1 ];
        ContentDocumentLink cdl= new ContentDocumentLink();
        cdl.ContentDocumentId=cd.ContentDocumentid;
        cdl.LinkedEntityId=ji.id;
        cdl.ShareType='v';
        insert cdl;
        
        JiraIssueComments__c jc=new JiraIssueComments__c(CommentBody__c='<br>ksvkjssnvsvnsvnsdv',CommentId__c='8112',IsPublished__c=true,JiraId__c='10018',JiraIssue__c=ji.id);
        insert jc;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpViewKey());
        SyncCommentsFilesToJira sync=new SyncCommentsFilesToJira(sc); 
        
        for(SyncCommentsFilesToJira.wrapperclass wc:sync.commentWrapperList){ 
            wc.isSelected=true;
        } 
        for(SyncCommentsFilesToJira.wrapperclass wc:sync.attachementWrapperList){
            wc.isSelected=true;
        } 
        sync.SendReqToJIRA();
         
        
        Test.StopTest();
        System.assertEquals(Sync.CommentIdSet.isEmpty(),false); 
    }
 
    
}