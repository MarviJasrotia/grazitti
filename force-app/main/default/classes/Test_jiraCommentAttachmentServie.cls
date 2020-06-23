@isTest
public class Test_jiraCommentAttachmentServie {
    @isTest
    public Static Void TestData0(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.SyncComments__c=true;
        // setting.AutoSyncCommentType__c='public';
        insert setting; 
        
                JiraSalesforceDetail__c jsDetail = new JiraSalesforceDetail__c(Name='File_Size',Value__c='10 MB');
        insert jsDetail;


        JiraSalesforceDetail__c jsd = new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        
        JiraSalesforceDetail__c settingPublic =new  JiraSalesforceDetail__c();
        settingPublic.name = 'Auto_SF_Comment_Sync_Type';
        settingPublic.value__c = 'private';
        insert settingPublic;
        
        Sinergify_Trigger__c sint=new Sinergify_Trigger__c();
        sint.Name='AddJiraComments';
        sint.IsActive__c = true;
        insert sint;
        
        Account ac= new Account();
        ac.Name='Test account';
        insert ac;
        Case cs= Testdata.createcase('TESTACC@testcase.com', ac.id, 'new', false);
        insert cs;
        
        JiraIssue__c ji=Testdata.createjira('test1', 'test1', 10018, '1003', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10018","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        ji.Project__c='DEV';
        insert ji;
        String last5;
        Attachment Attach=new Attachment();
        Attach.ParentId=cs.id;
        Blob bl=Blob.valueOf('test body'+ last5);
        Attach.Body=bl;
        Attach.Name='TEST Attachment';
        last5+='==';
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
        
        List<CaseJiraHelper__c> cj=new List<CaseJiraHelper__c>();
        for(Attachment st:AttachList)
        {
            CaseJiraHelper__c cjhelp=new CaseJiraHelper__c();
            cjhelp.Name=st.id ;
            cjhelp.jiraissueid__c=ji.id;
            cj.add(cjhelp);
        } 
        insert cj;
        
        Set<Id> csnew=new Set<ID>();
        csnew.add(cj[0].id);
        csnew.add(cj[1].id);
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='DEV';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='subtaskkkkkkkkkkkkkkkkkkkkk';
        insert pm;
        
        String data= '{"projects":[{"name":"Development","key":"DEV","issuetypes":[{"subtask":false,"name":"Task","id":"10002","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Task","id":"10002","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}},{"subtask":false,"name":"Story","id":"10001","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Story","id":"10001","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"customfield_10218":{"schema":{"type":"id","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:id"},"required":false,"name":"NEW URL FIELD","key":null,"allowedValues":null},"customfield_10219":{"schema":{"type":"datepicker","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"datetime","key":null,"allowedValues":null},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}}],"id":"10000"}]}}';
            Blob b = blob.valueof(data); //decoded string
        ContentVersion Cv= new ContentVersion();
        cv.VersionData = b;
        cv.Title = +'DEV_Json.txt';
        cv.PathOnClient  =   cv.Title;
        
        upsert cv;
        
        List<ContentVersion > ContentList = [SELECT Id, VersionNumber, ContentBodyId, VersionData, FileExtension, FileType, Title, Description, FirstPublishLocationId FROM ContentVersion];
        List<ContentVersion> contantVersionList=new List<ContentVersion>();
        List<String> contentVersionId=new List<String>();
        for(ContentVersion  attch:ContentList){
            contantVersionList.add(attch);
            contentVersionId.add(attch.id);
        }
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        JiraCommentAttachmentService.SendAttachment(attach,ContentList,contentVersionId,ji,csnew);
        Test.StopTest();
        List<Attachment> atList =[Select id FROM Attachment];
        system.assertEquals(atList.size() != 0,true);
    }
    @isTest
    public Static Void TestData1(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.SyncComments__c=true;
        //  setting.AutoSyncCommentType__c='public';
        insert setting; 
        
        JiraSalesforceDetail__c jsd1 = new JiraSalesforceDetail__c();
        jsd1.Name = 'Sync_SF_Comments';
        jsd1.Value__c = 'yes';
        insert jsd1;
        
        JiraSalesforceDetail__c jsd = new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        
        JiraSalesforceDetail__c settingPublic =new  JiraSalesforceDetail__c();
        settingPublic.name = 'Auto_SF_Comment_Sync_Type';
        settingPublic.value__c = 'private';
        insert settingPublic;
        
        Sinergify_Trigger__c sint=new Sinergify_Trigger__c();
        sint.Name='AddJiraComments';
        sint.IsActive__c = true;
        insert sint;
        JiraSalesforceDetail__c jsDetail = new JiraSalesforceDetail__c(Name='File_Size',Value__c='10 MB');
        insert jsDetail;

        
        Account ac= new Account();
        ac.Name='Test account';
        insert ac;
        Case cs= Testdata.createcase('TESTACC@testcase.com', ac.id, 'new', false);
        insert cs;
        
        JiraIssue__c ji=Testdata.createjira('test1', 'test1', 10018, '1003', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10018","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        ji.Project__c='DEV';
        insert ji;
        String last5;
        Attachment Attach=new Attachment();
        Attach.ParentId=cs.id;
        last5+='=';
        Blob bl=Blob.valueOf('test body'+ last5);
        Attach.Body=bl;
        Attach.Name='TEST Attachment';
        
        insert Attach;
        list<Attachment> AttachList = new List<Attachment>();
        String last4;
        
        for(Integer i =0;i<1 ;i++){
            Attachment Attach1=new Attachment();
            Attach1.ParentId=cs.id;
            Blob bl1=Blob.valueOf('test body'+ last4);
            Attach1.Body=bl1;
            Attach1.Name='TEST Attachment';
            AttachList.add(Attach1) ;
            last4+='';
        }
        
        insert AttachList;
        
        List<CaseJiraHelper__c> cj=new List<CaseJiraHelper__c>();
        for(Attachment st:AttachList)
        {
            CaseJiraHelper__c cjhelp=new CaseJiraHelper__c();
            cjhelp.Name=st.id ;
            cjhelp.jiraissueid__c=ji.id;
            cj.add(cjhelp);
        } 
        insert cj;
        
        Set<Id> csnew=new Set<ID>();
        csnew.add(cj[0].id);
        //csnew.add(cj[1].id);
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='DEV';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='subtaskkkkkkkkkkkkkkkkkkkkk';
        insert pm;
        
        String data= '{"projects":[{"name":"Development","key":"DEV","issuetypes":[{"subtask":false,"name":"Task","id":"10002","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Task","id":"10002","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}},{"subtask":false,"name":"Story","id":"10001","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Story","id":"10001","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"customfield_10218":{"schema":{"type":"id","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:id"},"required":false,"name":"NEW URL FIELD","key":null,"allowedValues":null},"customfield_10219":{"schema":{"type":"datepicker","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"datetime","key":null,"allowedValues":null},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}}],"id":"10000"}]}}';
            Blob b = blob.valueof(data); //decoded string
        ContentVersion Cv= new ContentVersion();
        cv.VersionData = b;
        cv.Title = +'DEV_Json.txt';
        cv.PathOnClient  =   cv.Title;
        
        upsert cv;
        
        List<ContentVersion > ContentList = [SELECT Id, VersionNumber, ContentBodyId, VersionData, FileExtension, FileType, Title, Description, FirstPublishLocationId FROM ContentVersion];
        List<ContentVersion> contantVersionList=new List<ContentVersion>();
        List<String> contentVersionId=new List<String>();
        for(ContentVersion  attch:ContentList){
            contantVersionList.add(attch);
            contentVersionId.add(attch.id);
        }
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpcommentattach());
        JiraCommentAttachmentService.SendAttachment(attach,ContentList,contentVersionId,ji,csnew);
        Test.StopTest();
        List<Attachment> atList =[Select id FROM Attachment];
        system.assertEquals(atList.size() != 0,true);
    }
    @istest 
    public static void testScenerio1(){
        
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.File_Size__c ='10.00 MB';
        insert setting; 
        JiraSalesforceDetail__c jsd = new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        JiraSalesforceDetail__c jsDetail = new JiraSalesforceDetail__c(Name='File_Size',Value__c='10 MB');
        insert jsDetail;

         JiraSalesforceDetail__c jsd1 = new JiraSalesforceDetail__c();
        jsd1.Name = 'Sync_SF_Comments';
        jsd1.Value__c = 'yes';
        insert jsd1;
        
        JiraSalesforceDetail__c settingPublic =new  JiraSalesforceDetail__c();
        settingPublic.name = 'Auto_SF_Comment_Sync_Type';
        settingPublic.value__c = 'private';
        insert settingPublic;
        
       
        
        Sinergify_Trigger__c st=new Sinergify_Trigger__c();
        st.Name='AddJiraComments';
        st.IsActive__c = true;
        insert st;
        
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
    @istest 
    public static void testData4(){
        
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.File_Size__c ='10.00 MB';
        insert setting; 
        
JiraSalesforceDetail__c jsDetail = new JiraSalesforceDetail__c(Name='File_Size',Value__c='10 MB');
        insert jsDetail;
        
        JiraSalesforceDetail__c jsd = new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        JiraSalesforceDetail__c jsd1 = new JiraSalesforceDetail__c();
        jsd1.Name = 'Sync_SF_Comments';
        jsd1.Value__c = 'yes';
        insert jsd1;
        
        JiraSalesforceDetail__c settingPublic =new  JiraSalesforceDetail__c();
        settingPublic.name = 'Auto_SF_Comment_Sync_Type';
        settingPublic.value__c = 'private';
        insert settingPublic;
        
        Sinergify_Trigger__c st=new Sinergify_Trigger__c();
        st.Name='AddJiraComments';
        st.IsActive__c = true;
        insert st;
        
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
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        SyncCommentsFilesToJira sync=new SyncCommentsFilesToJira(sc); 
        
        for(SyncCommentsFilesToJira.wrapperclass wc:sync.commentWrapperList){ 
            wc.isSelected=true;
        } 
        
        
        sync.SendReqToJIRA();
        
        
        Test.StopTest();
        System.assertEquals(Sync.CommentIdSet.isEmpty(),false); 
        
    }
    
    /*
public Static TestMethod Void TestData2(){

Test.startTest();
Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
// JiraCommentAttachmentService.SendComments(ji,'567','TestBody','121','TestComment');
Test.StopTest();
}

public Static TestMethod Void TestData3(){
Test.startTest();
Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
GenerateJiraLogs.CreateLog('ClassName','HTTP://45.56.67','GET','200','body','201','reqBody','body','4567','ReqForm','Details');
GenerateJiraLogs.CreateLogRealTime('ClassName','HTTP://45.56.67','GET','200','body','201', 'reqBody' ,'body','4567','ReqForm','Details') ; 
Test.StopTest();
}*/
}