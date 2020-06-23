/*
* case comments and attachments
*/

@isTest
public class Test_synccommentstojira {
    @testSetup 
    public static void testdata(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        setting.File_Size__c='10 MB';
        insert setting; 
        JiraSalesforceDetail__c jsd = new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        
        JiraSalesforceDetail__c jsd1 = new JiraSalesforceDetail__c();
        jsd1.Name = 'Sync_SF_Comments';
        jsd1.Value__c = 'yes';
        insert jsd1;
        
        JiraSalesforceDetail__c jsd2 = new JiraSalesforceDetail__c();
        jsd2.Name = 'File_Size';
        jsd2.Value__c = '10 MB';
        insert jsd2;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'JiraAutoFileAttach';
        st.IsActive__c = true;
        insert st;
        
        Rule_Set__c rule=Testdata.Newruleset('test', '1', true, 'TP',  'rulename' ,1,True);
        Child_Rule_Set__c child= Testdata.Newchildruleset('STRING','suppliedemail','', 'not equal to', rule,'1',true);
        
        JiraIssue__c ji=Testdata.createjira('TEST', 'qwew', 1212, 'TP-1', 'task', 'u1', 'sds', 'high', true);
        JiraIssue__c ji2=Testdata.createjira('TEST', 'qwew', 1214, 'TP-3', 'task', 'u1', 'sds', 'high', true);
        JiraIssue__c ji1=Testdata.createjira('TESTt', 'qwew', 1213, 'TP-2', 'task', 'u1', 'sds', 'high', true);
        
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        Case cs1 =Testdata.createcase('', Null, 'working', true);
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, true);
        JiraRelationship__c jr2 =Testdata.createjirarelation(cs.id, ji1.id, true);
        JiraRelationship__c jr1= Testdata.createjirarelation(cs1.id, ji1.id, true);
        Jira_Project__c jp= Testdata.createjiraProject('10005','TEST PROJECT','DEV');
        Testdata.CreateJSon(jp.id,jp.ProjectKey__c);
        Jira_ProjectFieldsMapping__c fieldMap=Testdata.createjirafieldmapp(jp.id,false ,'name','Subject','Subject', 'customfield_10020' ,True,  true , 'string',false);
        fieldMap.Salesforce_Object__c='Case';
        insert fieldMap;
        
        CaseComment ccom=new CaseComment();
        ccom.ParentId=cs.id;
        ccom.CommentBody='test 123';
        insert ccom;
        ccom.IsPublished=true;
        Update ccom;
        CaseComment ccom1=new CaseComment();
        ccom1.ParentId=cs.id;
        ccom1.CommentBody='test 123';
        insert ccom1;
        CaseComment c=[select LastModifiedById,LastModifiedBy.name from CaseComment Limit 1];
      
        list<Attachment> listattach =new list<Attachment>();
        
        ContentVersion cv = new ContentVersion();
        
        String data='TEST';
        Blob b = blob.valueof(data); //decoded string
        cv.VersionData = b;
        cv.Title = 'Title';
        cv.PathOnClient  =  'Title';
        insert cv;
        cv= [SELECT Id, ContentDocumentId FROM ContentVersion where id= :cv.id];
        
        ContentDocumentLink Cdl= new ContentDocumentLink();
        cdl.LinkedEntityId=cs.id;
        cdl.ShareType ='I';
        cdl.ContentDocumentId=cv.ContentDocumentId;
        
        insert cdl;
        
        Attachment ac=new Attachment();
        ac.ParentId=cs.id;
        Blob bl=Blob.valueOf('test body');
        ac.Body=bl;
        ac.Name='TEST Attachment';
        listattach.add(ac);
        Attachment ac1=new Attachment();
        ac1.ParentId=cs.id;
        Blob bl1=Blob.valueOf('test body');
        ac1.Body=bl1;
        ac1.Name='TEST Attachment';
        listattach.add(ac1);
        insert listattach;
        CaseJiraHelper__c cj=new CaseJiraHelper__c();
        cj.jiraissueid__c=ji.IssueKey__c;
        cj.Type__c='Comment';
        cj.Name=ccom.id;
        insert cj;
        
        CaseJiraHelper__c cj1=new CaseJiraHelper__c();
        cj1.jiraissueid__c=ji.IssueKey__c;
        cj1.Type__c='Attachment';
        cj1.Name=ac.id;
        insert cj1;
        
        
    }
    @isTest 
    public static void TestScenerio1(){
        case  cs=[select id from case  where status='new' limit 1];
        
        Boolean MapNotEmpty=false;
        PageReference pag= Page.SendCommentsAttachmentCaseToJira;
        Test.setCurrentPage(pag);
        ApexPages.currentPage().getParameters().put('jiraKeys','TP-1;TP-2;TP-3;');
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpcommentattach());
        
        SyncCommentAttachmentsToJira sync=new SyncCommentAttachmentsToJira(sc);
        Map<String,CaseJiraHelper__c> cjmap=new Map<String,CaseJiraHelper__c>();
        cjmap = sync.CjHelper;
        list<SyncCommentAttachmentsToJira.Wrapperclass> JIRAWrapper =new list<SyncCommentAttachmentsToJira.Wrapperclass>(); 
        for(SyncCommentAttachmentsToJira.Wrapperclass wrap: sync.JiraWrapperList){
            wrap.isSelected=true;
            JIRAWrapper.add(wrap);
        }
        list<SyncCommentAttachmentsToJira.Wrapperclass> CommWrapper =new list<SyncCommentAttachmentsToJira.Wrapperclass>(); 
        for(SyncCommentAttachmentsToJira.Wrapperclass wrap:sync.commentWrapperList){
            wrap.isSelected=true;
            CommWrapper.add(wrap);
        }
        list<SyncCommentAttachmentsToJira.Wrapperclass> AttachWrapper =new list<SyncCommentAttachmentsToJira.Wrapperclass>(); 
        for(SyncCommentAttachmentsToJira.Wrapperclass wrap: sync.attachementWrapperList){
            wrap.isSelected=true;
            AttachWrapper.add(wrap);
        }
        sync.attachementWrapperList=AttachWrapper;
        sync.JiraWrapperList=JIRAWrapper;
        sync.commentWrapperList=CommWrapper;
        sync.cancel();
        sync.SendReqToJIRA();
        sync.CjHelper = cjmap;
        if(sync.commentWrapperList!=Null)
        {
            MapNotEmpty=true;
        }
        Test.stopTest();
        System.assertEquals(MapNotEmpty,true);
    }
    public static void TestScenerio1s(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        setting.File_Size__c='10 KB';
        insert setting; 
        case  cs=[select id from case  where status='new' limit 1];
        
        Boolean MapNotEmpty=false;
        PageReference pag= Page.SendCommentsAttachmentCaseToJira;
        Test.setCurrentPage(pag);
        ApexPages.currentPage().getParameters().put('jiraKeys','TP-1;TP-2;TP-3;');
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpcommentattach());
        SyncCommentAttachmentsToJira sync=new SyncCommentAttachmentsToJira(sc);
        list<SyncCommentAttachmentsToJira.Wrapperclass> JIRAWrapper =new list<SyncCommentAttachmentsToJira.Wrapperclass>(); 
        for(SyncCommentAttachmentsToJira.Wrapperclass wrap: sync.JiraWrapperList){
            wrap.isSelected=true;
            JIRAWrapper.add(wrap);
        }
        list<SyncCommentAttachmentsToJira.Wrapperclass> CommWrapper =new list<SyncCommentAttachmentsToJira.Wrapperclass>(); 
        for(SyncCommentAttachmentsToJira.Wrapperclass wrap:sync.commentWrapperList){
            wrap.isSelected=true;
            CommWrapper.add(wrap);
        }
        list<SyncCommentAttachmentsToJira.Wrapperclass> AttachWrapper =new list<SyncCommentAttachmentsToJira.Wrapperclass>(); 
        for(SyncCommentAttachmentsToJira.Wrapperclass wrap: sync.attachementWrapperList){
            wrap.isSelected=true;
            AttachWrapper.add(wrap);
        }
        sync.attachementWrapperList=AttachWrapper;
        sync.commentWrapperList=CommWrapper;
        sync.cancel();
        sync.SendReqToJIRA();
     
        if(sync.commentWrapperList!=Null)
        {
            MapNotEmpty=true;
        }
        Test.stopTest();
        System.assertEquals(MapNotEmpty,true);
    }
    
    
    @isTest 
    public static void TestScenerio2(){
        Boolean MapNotEmpty=false;
        case  cs=[select id from case  where status='new' limit 1];
        PageReference pag= Page.SendCommentsAttachmentCaseToJira;
        Jira_login__c setting=[select id from Jira_login__c where name='JIRA'];
        setting.LoginSuccess__c=false;
        update setting;
        
        Test.setCurrentPage(pag);
        ApexPages.currentPage().getParameters().put('jiraKeys','TP-2;');
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        Test.startTest();
        
        SyncCommentAttachmentsToJira sync=new SyncCommentAttachmentsToJira(sc);
        sync.SendReqToJIRA();
        sync.cancel();
        if(sync.commentWrapperList!=Null)
        {
            MapNotEmpty=true;
        }
        Test.stopTest();
        System.assertEquals(MapNotEmpty,true);
    }
    @isTest 
    public static void TestScenerio3(){
        Boolean MapNotEmpty=false;
        case  cs=[select id from case  where status='new' limit 1];
        PageReference pag= Page.SendCommentsAttachmentCaseToJira;
        Jira_login__c setting=[select id from Jira_login__c where name='JIRA'];
        setting.LoginSuccess__c=false;
        update setting;
        
        
        
        Test.setCurrentPage(pag);
        ApexPages.currentPage().getParameters().put('jiraKeys','TP-2;');
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        Test.startTest();
        
        SyncCommentAttachmentsToJira sync=new SyncCommentAttachmentsToJira(sc);
        sync.SendReqToJIRA();
        if(sync.commentWrapperList!=Null)
        {
            MapNotEmpty=true;
        }
        Test.stopTest();
        System.assertEquals(MapNotEmpty,true);
    }
    @isTest 
    public static void TestScenerio4(){
        Boolean MapNotEmpty=false;
        case  cs=[select id from case  where status='new' limit 1];
        PageReference pag= Page.SendCommentsAttachmentCaseToJira;
        list<StaticResource> st=[SELECT Id, Name, Body FROM StaticResource where name in ('SFDCJiraConnector','TestdataImage','testdata2')];
        Attachment acs1=new Attachment();
        acs1.ParentId=cs.id;
        acs1.Body=st[0].Body;
        acs1.Name='TEST Attachment';
        insert acs1;
        
        Attachment acs2=new Attachment();
        acs2.ParentId=cs.id;
        acs2.Body=st[0].Body;
        acs2.Name='TEST Attachment';
        insert acs2;
        
        Attachment acs3=new Attachment();
        acs3.ParentId=cs.id;
        acs3.Body=st[0].Body;
        acs3.Name='TEST Attachment';
        insert acs3;
        
        
        Test.setCurrentPage(pag);
        ApexPages.currentPage().getParameters().put('jiraKeys','TP-2;');
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        Test.startTest();
        
        SyncCommentAttachmentsToJira sync=new SyncCommentAttachmentsToJira(sc);
        list<SyncCommentAttachmentsToJira.Wrapperclass> CommWrapper =new list<SyncCommentAttachmentsToJira.Wrapperclass>(); 
        for(SyncCommentAttachmentsToJira.Wrapperclass wrap:sync.commentWrapperList){
            wrap.isSelected=true;
            //wrap.recordType='Issue Keys';
            CommWrapper.add(wrap);
        }
        list<SyncCommentAttachmentsToJira.Wrapperclass> AttachWrapper =new list<SyncCommentAttachmentsToJira.Wrapperclass>(); 
        for(SyncCommentAttachmentsToJira.Wrapperclass wrap: sync.attachementWrapperList){
            wrap.isSelected=true;
            //wrap.recordType='Issue Keys';
            AttachWrapper.add(wrap);
        }
        sync.attachementWrapperList=AttachWrapper;
        sync.commentWrapperList=CommWrapper;
        sync.SendReqToJIRA();
        if(sync.commentWrapperList!=Null)
        {
            MapNotEmpty=true;
        }
        Test.stopTest();
        System.assertEquals(MapNotEmpty,true);
    }
    
    
    
}