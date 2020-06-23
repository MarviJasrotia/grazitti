@isTest
public class Test_JiraService {
   
    public TestMethod Static Void TestData(){
        
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        insert setting; 
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st;
        
        //JiraService js=new JiraService();
        case ac=new case(Subject='Test',Status='New',Origin='Phone');
        insert ac;
       //Set<String> jirakeyset=new Set<string>();
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        Ji.Project__c='DEV';
        
        
        insert ji;
        //jirakeyset.add(ji.name);
         Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='DEV';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='subtaskkkkkkkkkkkkkkkkkkkkk';
        pm.IssueType__c='Bug,Epic,Task,Story';
        insert pm;
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        Testdata.CreateStaticFields(pm.id);
        JiraRelationship__c jr=new JiraRelationship__c(JiraIssue__c=ji.Id,JiraIssueId__c=10019,CaseRelation__c=ac.Id);
       
        insert jr;
        list<Attachment> AttachList = new List<Attachment>();
        String last4;
        for(Integer i =0;i<3 ;i++){
            Attachment Attach1=new Attachment();
            Attach1.ParentId=ac.id;
            Blob bl1=Blob.valueOf('test body'+ last4);
            Attach1.Body=bl1;
            Attach1.Name='TEST Attachment';
            AttachList.add(Attach1) ;
            last4+='==';
        }
        
        insert AttachList;
        
        List<CaseJiraHelper__c> cj=new List<CaseJiraHelper__c>();
        for(Attachment at:AttachList)
        {
            CaseJiraHelper__c cjhelp=new CaseJiraHelper__c();
            cjhelp.Name=at.id ;
            cjhelp.jiraissueid__c=ji.id;
            cj.add(cjhelp);
        } 
        insert cj;
        
        String data= '{"projects":[{"name":"Development","key":"DEV","issuetypes":[{"subtask":false,"name":"Task","id":"10002","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Task","id":"10002","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}},{"subtask":false,"name":"Story","id":"10001","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Story","id":"10001","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"customfield_10218":{"schema":{"type":"id","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:id"},"required":false,"name":"NEW URL FIELD","key":null,"allowedValues":null},"customfield_10219":{"schema":{"type":"datepicker","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"datetime","key":null,"allowedValues":null},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}}],"id":"10000"}]}}';
            Blob b = blob.valueof(data); //decoded string
        ContentVersion Cv= new ContentVersion();
        cv.VersionData = b;
        cv.Title = +'DEV_Json.txt';
        cv.PathOnClient  =   cv.Title;
        
        upsert cv;
        
        List<ContentVersion > ContentList = [SELECT Id, VersionNumber, ContentBodyId, VersionData, FileExtension, FileType, Title, Description, FirstPublishLocationId FROM ContentVersion];
       Map<Id,Set<String>> jirakeymap=new Map<Id,set<string>>();
        JiraIssue__c jira=[Select Issuekey__c from JiraIssue__c Limit 1];
        for(Attachment att:AttachList){
            jirakeymap.put(att.id,new set<string>{jira.Issuekey__c});
        }
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpcommentattach());
        ApexPages.currentPage().getParameters().put('id',ac.id);
        //JiraService jserv=new JiraService();
        JiraService.SendAttachment(AttachList,contentList,jirakeymap);
        JIraIssueListGenericCOntroller jlc=new JIraIssueListGenericCOntroller();
        jlc.unlinkIssues();
        List<JiraRelationship__c> JRel=[Select id from JiraRelationship__c where id =:jr.id];
        System.assertEquals(JRel.size(),1);
        
    }

    public TestMethod Static Void TestData1(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        insert setting; 
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Comments',Value__c='no');
        insert jsDetail;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c(Name='JiraAutoComment',IsActive__c=true);
        insert st;
        case ac=new case(Subject='Test',Status='New',Origin='Phone');
        insert ac;
       JiraSalesforceDetail__c jsDetail1=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',Value__c='yes');
        insert jsDetail1;
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st1;
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10027":"","customfield_10028":"","customfield_10029":"","resolutiondate":null,"lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":null,"customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';
        Ji.Project__c='DEV';
        insert ji;
        Map<String,String> jirakeyset=new Map<string,string>();
         Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='DEV';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='subtaskkkkkkkkkkkkkkkkkkkkk';
        pm.IssueType__c='Bug,Epic,Task,Story';
        insert pm;
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        Testdata.CreateStaticFields(pm.id);
        JiraRelationship__c jr=new JiraRelationship__c(JiraIssue__c=ji.Id,JiraIssueId__c=10019,CaseRelation__c=ac.Id);
       
        insert jr;
        List<CaseComment> comlist=new List<CaseComment>();
        CaseComment com=new CaseComment();
        com.ParentId=ac.id;
        com.CommentBody='newComment';
        com.IsPublished=false;
        comlist.add(com);
        insert comlist;
        Map<Id,Set<String>> jirakeymap=new Map<Id,set<string>>();
        JiraIssue__c jira=[Select name,Issuekey__c,IssueId__c from JiraIssue__c Limit 1];
        jirakeyset.put(ji.Issuekey__c,String.valueof(ji.IssueId__c));
        
        for(CaseComment att:comlist){
            jirakeymap.put(att.id,new set<string>{jira.Issuekey__c});
        }
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpcommentattach());
        JiraService.SendComments(comList,jirakeymap,jirakeyset);
 
    }
}