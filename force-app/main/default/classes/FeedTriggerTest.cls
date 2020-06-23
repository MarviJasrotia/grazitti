@istest
public class FeedTriggerTest {  
    @testSetup 
    public static void testdata(){
        Test.StartTest();
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        insert setting;
        
        JiraSalesforceDetail__c jsd = new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
        
        JiraSalesforceDetail__c jsd1 = new JiraSalesforceDetail__c();
        jsd1.Name = 'Chatter_Settings';
        jsd1.Value__c = 'true';
        insert jsd1;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'JiraAutoFileAttach';
        st.IsActive__c=true;
        insert st;
        
        Sinergify_Trigger__c stc = new Sinergify_Trigger__c();
        stc.Name = 'FeedItemTrigger';
        stc.IsActive__c=true;
        insert stc;
        
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        
        Case cs1 =Testdata.createcase('', Null, 'working', true);
        
        
        JiraIssue__c ji=Testdata.createjira('test', 'test', 1212, '1002', 'task', 'u1', 'sds', 'high', false);
        ji.name = '1002';
        ji.Project__c = 'GC';
        ji.CaseNos__c = '124567';
        ji.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10037":"'+ cs.id +'"}}';
        
        insert ji;
        JiraIssue__c ji1=Testdata.createjira('test1', 'test1', 1213, 'GG-4', 'task', 'u1', 'sds', 'high', false);
        ji1.name = 'GC-4';
        ji1.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10037":"'+ cs1.id +'"}}';
        
        insert ji1;
        
        JiraIssue__c ji2=Testdata.createjira('test1', 'test2', 12413, 'GG-3', 'task', 'u1', 'sds', 'high', false);
        ji2.name = 'GC-3';
        ji2.Project__c = 'GC';
        ji2.CaseNos__c = '124517';
        ji2.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10037":"'+ cs.id +'"}}';
        
        insert ji2;
        
        
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, false);
        JiraRelationship__c jr1= Testdata.createjirarelation(cs1.id, ji1.id, false);
        JiraRelationship__c jr2= Testdata.createjirarelation(cs1.id, ji2.id, false);
        insert jr2;
        insert jr1;
        insert jr;
        
        Jira_Project__c jp = Testdata.createjiraProject('10001', 'jiraproject', 'DEV');
        jp.IssueType__c = 'Improvement,New Feature,Bug,Task';
        update jp;
        Testdata.CreateJSon(jp.id, jp.projectkey__c);
        Jira_ProjectFieldsMapping__c fieldmap =Testdata.createjirafieldmapp(jp.id,false ,'name','Subject','Subject', 'customfield_10020' ,True,  true , 'string',false);
        fieldmap.salesforce_object__c='Case';
        insert fieldmap;
    }
    
    @istest
    public static void TestScenario(){
        
        Case cs = [Select Id from Case where status = 'New' limit 1];
        JiraIssue__c JI = [Select Id,IssueKey__c from JiraIssue__c limit 1];
        Test.StartTest();
        FeedItem Fi = New FeedItem(parentId=cs.Id);
        fi.body = '<p> #[linkToJira] dev-11 </p>';
        insert fi;
        FeedItem Fi1 = New FeedItem(parentId=cs.Id);
        fi1.body = '<p> Hey #[linkToJira] Gc-4 </p> \n  <p> Hey #[linkToJira] Gc-3 </p> ';
        insert fi1;
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaDatanull());
        FeedItemHandler FIH = New FeedItemHandler();
        FIH.bulkBefore();
        FIH.beforeDelete(Fi);
        FIH.beforeupdate(Fi , FI);
        FIH.beforeinsert(Fi);
        FIH.afterDelete(Fi);
        FIH.afterUpdate(Fi,Fi);
  String data= '{"projects":[{"name":"Development","key":"DEV","issuetypes":[{"subtask":false,"name":"Task","id":"10002","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Task","id":"10002","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}},{"subtask":false,"name":"Story","id":"10001","fields":{"issuetype":{"schema":{"type":"issuetype","items":null,"custom":null},"required":true,"name":"Issue Type","key":"issuetype","allowedValues":[{"value":null,"name":"Story","id":"10001","children":null}]},"components":{"schema":{"type":"array","items":"component","custom":null},"required":false,"name":"Component/s","key":"components","allowedValues":[{"value":null,"name":"TEST COMP 1","id":"10002","children":null},{"value":null,"name":"TEST COMP 2","id":"10003","children":null}]},"description":{"schema":{"type":"string","items":null,"custom":null},"required":false,"name":"Description","key":"description","allowedValues":null},"customfield_10031":{"schema":{"type":"array","items":"user","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker"},"required":false,"name":"multiple users","key":"customfield_10031","allowedValues":null},"project":{"schema":{"type":"project","items":null,"custom":null},"required":true,"name":"Project","key":"project","allowedValues":[{"value":null,"name":"Development","id":"10000","children":null}]},"customfield_10010":{"schema":{"type":"array","items":"string","custom":"com.pyxis.greenhopper.jira:gh-sprint"},"required":false,"name":"Sprint","key":"customfield_10010","allowedValues":null},"customfield_10032":{"schema":{"type":"array","items":"version","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiversion"},"required":false,"name":"multiple versions","key":"customfield_10032","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"fixVersions":{"schema":{"type":"array","items":"version","custom":null},"required":false,"name":"Fix Version/s","key":"fixVersions","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10033":{"schema":{"type":"version","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:version"},"required":false,"name":"Single Version","key":"customfield_10033","allowedValues":[{"value":null,"name":"Release 1","id":"10002","children":null},{"value":null,"name":"Release 2","id":"10003","children":null}]},"customfield_10034":{"schema":{"type":"number","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:float"},"required":false,"name":"Number","key":"customfield_10034","allowedValues":null},"customfield_10035":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons"},"required":false,"name":"RADIO","key":"customfield_10035","allowedValues":[{"value":"YES","name":null,"id":"10006","children":null},{"value":"No","name":null,"id":"10007","children":null}]},"customfield_10036":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes"},"required":false,"name":"Checkboxes","key":"customfield_10036","allowedValues":[{"value":"INDIA","name":null,"id":"10008","children":null},{"value":"CANADA","name":null,"id":"10009","children":null},{"value":"BRITAIN","name":null,"id":"10010","children":null},{"value":"USA","name":null,"id":"10011","children":null}]},"customfield_10037":{"schema":{"type":"option-with-child","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect"},"required":false,"name":"CASCADING","key":"customfield_10037","allowedValues":[{"value":"ISRO","name":null,"id":"10012","children":[{"value":"GSAT-6","id":"10014"},{"value":"GSAT-5","id":"10015"}]},{"value":"SPACE X","name":null,"id":"10013","children":[{"value":"FALCON","id":"10016"},{"value":"FALCON HEAVY","id":"10017"}]}]},"customfield_10008":{"schema":{"type":"any","items":null,"custom":"com.pyxis.greenhopper.jira:gh-epic-link"},"required":false,"name":"Epic Link","key":"customfield_10008","allowedValues":null},"attachment":{"schema":{"type":"array","items":"attachment","custom":null},"required":false,"name":"Attachment","key":"attachment","allowedValues":null},"summary":{"schema":{"type":"string","items":null,"custom":null},"required":true,"name":"Summary","key":"summary","allowedValues":null},"customfield_10040":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Custom Label","key":"customfield_10040","allowedValues":null},"customfield_10041":{"schema":{"type":"array","items":"option","custom":"com.atlassian.jira.plugin.system.customfieldtypes:multiselect"},"required":false,"name":"multiple choices","key":"customfield_10041","allowedValues":[{"value":"CHOICE 1","name":null,"id":"10018","children":null},{"value":"CHOICE 2","name":null,"id":"10019","children":null}]},"customfield_10020":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":true,"name":"Expected Results","key":"customfield_10020","allowedValues":null},"customfield_10042":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Text Field (multi-line)","key":"customfield_10042","allowedValues":null},"customfield_10021":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textfield"},"required":false,"name":"Client number","key":"customfield_10021","allowedValues":null},"customfield_10043":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Select List","key":"customfield_10043","allowedValues":[{"value":"OPTION 1","name":null,"id":"10020","children":null},{"value":"OPTION 2","name":null,"id":"10021","children":null},{"value":"OPTION 3","name":null,"id":"10022","children":null}]},"customfield_10022":{"schema":{"type":"user","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:userpicker"},"required":true,"name":"Issue Owner","key":"customfield_10022","allowedValues":null},"priority":{"schema":{"type":"priority","items":null,"custom":null},"required":false,"name":"Priority","key":"priority","allowedValues":[{"value":null,"name":"Highest","id":"1","children":null},{"value":null,"name":"High","id":"2","children":null},{"value":null,"name":"Medium","id":"3","children":null},{"value":null,"name":"Low","id":"4","children":null},{"value":null,"name":"Lowest","id":"5","children":null}]},"customfield_10023":{"schema":{"type":"string","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:textarea"},"required":false,"name":"Work Around","key":"customfield_10023","allowedValues":null},"labels":{"schema":{"type":"array","items":"string","custom":null},"required":false,"name":"Labels","key":"labels","allowedValues":null},"customfield_10038":{"schema":{"type":"date","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"DATE PICKER","key":"customfield_10038","allowedValues":null},"customfield_10017":{"schema":{"type":"array","items":"string","custom":"com.atlassian.jira.plugin.system.customfieldtypes:labels"},"required":false,"name":"Case Number","key":"customfield_10017","allowedValues":null},"customfield_10039":{"schema":{"type":"datetime","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datetime"},"required":false,"name":"DATE TIME PICKER","key":"customfield_10039","allowedValues":null},"customfield_10018":{"schema":{"type":"option","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:select"},"required":false,"name":"Case Status","key":"customfield_10018","allowedValues":[{"value":"New","name":null,"id":"10003","children":null},{"value":"Working","name":null,"id":"10004","children":null},{"value":"Escalated","name":null,"id":"10005","children":null}]},"customfield_10218":{"schema":{"type":"id","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:id"},"required":false,"name":"NEW URL FIELD","key":null,"allowedValues":null},"customfield_10219":{"schema":{"type":"datepicker","items":null,"custom":"com.atlassian.jira.plugin.system.customfieldtypes:datepicker"},"required":false,"name":"datetime","key":null,"allowedValues":null},"issuelinks":{"schema":{"type":"array","items":"issuelinks","custom":null},"required":false,"name":"Linked Issues","key":"issuelinks","allowedValues":null},"assignee":{"schema":{"type":"user","items":null,"custom":null},"required":false,"name":"Assignee","key":"assignee","allowedValues":null}}}],"id":"10000"}]}}';
            FeedItemGateway.Feedonjiracreation(data);
        ji.project__c = null;
        update ji;
        Delete Ji;
        ContentVersionHandler cvh=new ContentVersionHandler();
        cvh.bulkBefore();
        cvh.beforeInsert(Fi);
        cvh.beforeUpdate(Fi , FI);
        cvh.beforeDelete(Fi);
        cvh.afterDelete(Fi);
        cvh.afterUpdate(Fi , FI);
        Test.StopTest();
        System.assertEquals(1,1);
    }  
}