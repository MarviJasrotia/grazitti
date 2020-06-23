@isTest 
public class Test_JiraAutoAttachment { 
    @testSetup 
    public static void testdata(){
        list<JiraSalesforceDetail__c> JiraSalesforceList= new List<JiraSalesforceDetail__c>();
        Jira_login__c jirasetting= Testdata.createjirasetting('jirauser', true , 'www.Test.com', 'JIRA', 'test', 'test', true, 'testusername', false);
        jirasetting.SyncAttachment__c=true;
        jirasetting.SyncComments__c=true;
        //  jirasetting.AutoSyncCommentType__c = 'private';
        insert jirasetting;
        JiraSalesforceDetail__c jsDetail2=new JiraSalesforceDetail__c(Name='Jira_Comment_As_Private',Value__c='yes');
        JiraSalesforceList.add(jsDetail2);
        JiraSalesforceDetail__c jsDetail1=new JiraSalesforceDetail__c(Name='JiraCommentsSyncToJiraIssue',Value__c='yes');
        JiraSalesforceList.add(jsDetail1);
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',Value__c='Private');
        JiraSalesforceList.add(jsDetail);
        JiraSalesforceDetail__c jsDetail23 
            = new JiraSalesforceDetail__c(Name='Store_Jira_Comment_in_Case', 
                                          Value__c = 'no');
        JiraSalesforceList.add(jsDetail23);

        JiraSalesforceDetail__c jsDetaill = new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',value__c='yes');
        JiraSalesforceList.add(jsDetaill);

        JiraSalesforceDetail__c jsDetaill1 = new JiraSalesforceDetail__c(Name='Sync_SF_Comments',value__c='yes');
        JiraSalesforceList.add(jsDetaill1);
       
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c(Name='JiraAutoAttachment',IsActive__c=true);
        insert st1;
        
        Sinergify_Trigger__c st2 = new Sinergify_Trigger__c(Name='AddJiraComments',IsActive__c=true);
        insert st2;
        
        
        JiraSalesforceDetail__c filesize =new  JiraSalesforceDetail__c();
        filesize.name = 'File_Size';
        filesize.value__c = '10MB';
        JiraSalesforceList.add(filesize);
        insert JiraSalesforceList;        
        
        
        Account ac= new Account();
        ac.Name='Test account';
        insert ac;
        Case cs= Testdata.createcase('TESTACC@testcase.com', ac.id, 'new', false);
        
        insert cs;
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, 'TP-1', 'task', 'u1', 'sds', 'high', true); 
        JiraIssue__c ji1=Testdata.createjira('test', 'test', 1213, 'TP-2', 'task', 'u1', 'sds', 'high', true); 
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, true);
        JiraRelationship__c jr1 =Testdata.createjirarelation(cs.id, ji1.id, true);
        
    }
    
    @isTest public static void TestScenerio1(){
        
        Case cs= [select id from case where status ='new'];
        list<Attachment> AttachList = new List<Attachment>();
        String last4;
        for(Integer i =0;i<3 ;i++){
            Attachment Attach=new Attachment();
            Attach.ParentId=cs.id;
            Blob bl=Blob.valueOf('test body'+ last4);
            Attach.Body=bl;
            Attach.Name='TEST Attachment';
            AttachList.add(Attach) ;
            last4+='==';
        }
        
        JiraIssue__c j=[select Name,IssueKey__c from  JiraIssue__c Limit 1];
        list<CaseJiraHelper__c> cj=new List<CaseJiraHelper__c>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpcommentattach());
        insert AttachList;
        List<Attachment >attch=[Select Id,Name,ParentId from  Attachment ];
        for(Attachment st:attch)
        {
            CaseJiraHelper__c cjhelp=new CaseJiraHelper__c();
            cjhelp.Name=st.id ;
            cjhelp.jiraissueid__c=j.id;
            cj.add(cjhelp);
        } 
        insert cj;
        
        
        AttachmentHandler cm= new AttachmentHandler();
        SObject so;
        cm.afterDelete(so);
        cm.bulkBefore();
        cm.beforeInsert(so);
        cm.beforeUpdate( so,  so);
        cm.beforeDelete( so);
        cm.afterDelete( so);
        cm.bulkAfter();
        cm.afterUpdate(so , so);
        cm.andFinally();
        
        Test.stopTest();
        Boolean Valid=cm.parentattch.contains(AttachList[0].id);
        System.assertEquals(Valid,false);
        /* Set<ID> caseHelperId=new Set<ID>();
CaseJiraHelper__c cs3=new CaseJiraHelper__c(Name='Test',Type__c='Attachment',jiraissueid__c=j.IssueKey__c);
insert cs3;     
caseHelperId.add(cs3.id);

String data= '{"projects":[{"name":"Development","key":"DEV","issuetypes":[{"subtask":false,"name":"Task","id":"10002","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Task","id":"10002","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}},{"subtask":false,"name":"Story","id":"10001","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Story","id":"10001","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"customfield_10218":{"schema":{"type":"id","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:id"},"required":false,"name":"NEW URL FIELD","key":null,"allowedValues":null},"customfield_10219":{"schema":{"type":"datepicker","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"datetime","key":null,"allowedValues":null},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}}],"id":"10000"}]}}';
Blob b = blob.valueof(data); //decoded string
ContentVersion Cv= new ContentVersion();
cv.VersionData = b;
cv.Title = 'DEV_Json.txt';
cv.PathOnClient  = cv.Title;
insert cv;
*/
        // JiraCommentAttachmentService.SendAttachment(attch[0],cv,'121',j,caseHelperId);
        
    }   
    
    @isTest public static void TestScenerio1s(){
        
        Case cs= [select id from case where status ='new'];
        list<Attachment> AttachList = new List<Attachment>();
        String last4;
        for(Integer i =0;i<3 ;i++){
            Attachment Attach=new Attachment();
            Attach.ParentId=cs.id;
            Blob bl=Blob.valueOf('test body'+ last4);
            Attach.Body=bl;
            Attach.Name='TEST Attachment';
            AttachList.add(Attach) ;
            last4+='==';
        }
        
        JiraIssue__c j=[select Name,IssueKey__c from  JiraIssue__c Limit 1];
        list<CaseJiraHelper__c> cj=new List<CaseJiraHelper__c>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpBatchData());
        insert AttachList;
        List<Attachment >attch=[Select Id,Name,ParentId from  Attachment ];
        for(Attachment st:attch)
        {
            CaseJiraHelper__c cjhelp=new CaseJiraHelper__c();
            cjhelp.Name=st.id ;
            cjhelp.jiraissueid__c=j.id;
            cj.add(cjhelp);
        } 
        insert cj;
        
        
        AttachmentHandler cm= new AttachmentHandler();
        SObject so;
        cm.afterDelete(so);
        cm.bulkBefore();
        cm.beforeInsert(so);
        cm.beforeUpdate( so,  so);
        cm.beforeDelete( so);
        cm.afterDelete( so);
        cm.bulkAfter();
        cm.afterUpdate(so , so);
        cm.andFinally();
        
        Test.stopTest();
        Boolean Valid=cm.parentattch.contains(AttachList[0].id);
        System.assertEquals(Valid,false);
        /* Set<ID> caseHelperId=new Set<ID>();
CaseJiraHelper__c cs3=new CaseJiraHelper__c(Name='Test',Type__c='Attachment',jiraissueid__c=j.IssueKey__c);
insert cs3;     
caseHelperId.add(cs3.id);

String data= '{"projects":[{"name":"Development","key":"DEV","issuetypes":[{"subtask":false,"name":"Task","id":"10002","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Task","id":"10002","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}},{"subtask":false,"name":"Story","id":"10001","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Story","id":"10001","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"customfield_10218":{"schema":{"type":"id","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:id"},"required":false,"name":"NEW URL FIELD","key":null,"allowedValues":null},"customfield_10219":{"schema":{"type":"datepicker","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"datetime","key":null,"allowedValues":null},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}}],"id":"10000"}]}}';
Blob b = blob.valueof(data); //decoded string
ContentVersion Cv= new ContentVersion();
cv.VersionData = b;
cv.Title = 'DEV_Json.txt';
cv.PathOnClient  = cv.Title;
insert cv;
*/
        // JiraCommentAttachmentService.SendAttachment(attch[0],cv,'121',j,caseHelperId);
        
    }  
    
    @isTest 
    public static void TestScenerio2(){
        Sinergify_Trigger__c st0 = new Sinergify_Trigger__c();
        st0.Name = 'JiraAutoComment';
        st0.IsActive__c = true;
        insert st0;
        
        Case cs= [select id from case where status ='new'];
        list<CaseComment> commList = new List<CaseComment>();
        for(Integer i =0;i<3 ;i++){
            CaseComment comm=new CaseComment();
            comm.ParentId=cs.id;
            comm.CommentBody='test body';
            commList.add(comm) ;
        }
        JiraIssue__c j=[select Name from  JiraIssue__c Limit 1];
        list<CaseJiraHelper__c> cj=new List<CaseJiraHelper__c>();
        List<casecomment >attch=[Select Id,commentbody,ParentId from  casecomment ];
        for(casecomment st:attch)
        {
            CaseJiraHelper__c cjhelp=new CaseJiraHelper__c();
            cjhelp.Name=st.id ;
            cjhelp.jiraissueid__c=j.id;
            cj.add(cjhelp);
        } 
        insert cj;
        insert commList;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpcommentattach());
        CaseCommentHandler cm= new CaseCommentHandler();
        SObject so;
        cm.afterDelete(so);
        cm.bulkBefore();
        cm.beforeInsert(so);
        cm.beforeUpdate(so,  so);
        cm.beforeDelete(so);
        cm.afterDelete(so);
        cm.afterUpdate(so,so);
        cm.bulkAfter();
        cm.andFinally();  
        Boolean Valid=cm.CaseCommentIds.contains(commList[0].id);
        Test.stopTest();
        
        System.assertEquals(Valid,false);
    } 
    @isTest
    public static void TestScenerio3(){
        
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.SyncComments__c=true;
        //  setting.AutoSyncCommentType__c='public';
        insert setting; 
        
        JiraSalesforceDetail__c settingPublic =new  JiraSalesforceDetail__c();
        settingPublic.name = 'AutoSyncCommentType';
        settingPublic.value__c = 'public';
        insert settingPublic;
        
        Community objcommunity = [ SELECT Id,Name FROM Community Where Name='Internal Zone' ];
        idea ideaobj=new Idea(Title='TestIdea',Body='Test Body',Status='Active',communityID=objcommunity.id);
        insert ideaobj;
        
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        Ji.Project__c='DEV';
        insert ji;
        
        JiraRelationship__c jr=new JiraRelationship__c(JiraIssue__c=ji.id,IdeaRelation__c=ideaobj.id);
        insert jr;
        
        JiraIssueComments__c jc=new JiraIssueComments__c(CommentBody__c='comment Body', JiraId__c='10019',Author__c='Grazitti', JiraIssue__c=ji.id ,IsPublished__c=false);
        insert jc;
        jc.CommentBody__c='NewTest';
        update jc;
        
        IdeaComment  com=new IdeaComment(IdeaId=ideaobj.id, CommentBody='Test');
        insert com;
        
        JiraCommentHandler jc1=new JiraCommentHandler();
        jc1.beforeInsert(jc);
        jc1.beforeUpdate(jc,jc);
        jc1.beforeDelete(jc);
        jc1.afterDelete(jc);
        jc1.afterUpdate(jc,jc);
        jc1.afterInsert(jc);
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata());
        Test.StopTest();
        System.assertEquals(jc.id !=null, true);
        
    }
    
    @isTest
    public static void TestScenerio5(){
        Jira_login__c jirasetting= Testdata.createjirasetting('jirauser', true , 'www.Test.com', 'JIRA', 'test', 'test', true, 'testusername', false);
        jirasetting.SyncAttachment__c=true;
        
        jirasetting.SyncComments__c=true;
        //  jirasetting.AutoSyncCommentType__c = 'private';
        insert jirasetting;
        
        JiraSalesforceDetail__c settingPublic =new  JiraSalesforceDetail__c();
        settingPublic.name = 'AutoSyncCommentType';
        settingPublic.value__c = 'private';
        insert settingPublic;
        
        Account ac= new Account();
        ac.Name='Test account';
        insert ac;
        Case cs= Testdata.createcase('TESTACC@testcase.com', ac.id, 'new', false);  
        insert cs;
        
        Set<ID> linkedCaseid=new Set<ID>();
        linkedCaseid.add(cs.id);
        
        Community objcommunity = [ SELECT Id,Name FROM Community Where Name='Internal Zone' ];
        idea ideaobj=new Idea(Title='TestIdea',Body='Test Body',Status='Active',communityID=objcommunity.id);
        insert ideaobj;
        
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        Ji.Project__c='DEV';
        insert ji;
        String data= '{"projects":[{"name":"Development","key":"DEV","issuetypes":[{"subtask":false,"name":"Task","id":"10002","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Task","id":"10002","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}},{"subtask":false,"name":"Story","id":"10001","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Story","id":"10001","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"customfield_10218":{"schema":{"type":"id","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:id"},"required":false,"name":"NEW URL FIELD","key":null,"allowedValues":null},"customfield_10219":{"schema":{"type":"datepicker","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"datetime","key":null,"allowedValues":null},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}}],"id":"10000"}]}}';
            Blob b = blob.valueof(data); //decoded string
        
        ContentVersion Cv= new ContentVersion();
        cv.VersionData = b;
        cv.Title = 'DEV_Json.txt';
        cv.PathOnClient  = cv.Title;
        insert cv; 
        
        JiraRelationship__c jr=new JiraRelationship__c(JiraIssue__c=ji.id,IdeaRelation__c=ideaobj.id);
        jr.CaseRelation__c=cs.id;
        insert jr;
        
        Set<ID> FinalVersion=new Set<ID>();
        FinalVersion.add(cv.id);
        
        String last5;
        Attachment Attach=new Attachment();
        Attach.ParentId=cs.id;
        last5+='==';
        Blob bl=Blob.valueOf('test body'+ last5);
        Attach.Body=bl;
        Attach.Name='TEST Attachment';
        
        insert Attach;
        list<Attachment> AttachList = new List<Attachment>();
        String last4;
        for(Integer i =0;i<3 ;i++){
            Attachment Attach1=new Attachment();
            Attach1.ParentId=cs.id;
            Blob bl1=Blob.valueOf('test body'+ last4);
            Attach1.Body=bl1;
            Attach1.Name='TEST Attachment';
            AttachList.add(Attach1) ;
            last4+='==';
        }
        
        insert AttachList;
        CaseJiraHelper__c cjh=new CaseJiraHelper__c();
        cjh.Name=cv.id ;
        cjh.jiraissueid__c=ji.id;
        insert cjh;
        
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpcommentattach());
        JiraAutoSyncHelper.SendFilesToJira(linkedCaseid, FinalVersion);
        Test.StopTest();  
        System.assertEquals(Cv.id != null && cs.id != null, true);
    }
    
}