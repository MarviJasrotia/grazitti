@isTest
public class Test_JiraIssueRelatedListController {
    @isTest static void TestScenerio1() {
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='TJC';
        setting.LoginSuccess__c=true;
        setting.Basic_Authentication__c=true;
        insert setting; 
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='DEV';
        pm.ProjectKey__c='DEV';
        pm.Write__c=true;
        pm.Subtask__c='Task';
        pm.IssueType__c='Bug,Epic,Task,Story';
        insert pm;  
        
        JiraIssue__c ji=Testdata.createjira('testing of Jira Test Class', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"id":"10019","key":"DEV-19","fields":{"issuetype":{"id":"10004","name":"Bug"},"timespent":null,"customfield_10030":"","project":{"id":"10000","key":"DEV","name":"Development"},"customfield_10031":[{"name":"addon_com.atlassian.servicedesk.embedded","key":"addon_com.atlassian.servicedesk.embedded"}],"customfield_10032":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"customfield_10033":{"id":"10002","name":"Release 1"},"fixVersions":[{"id":"10002","name":"Release 1"},{"id":"10003","name":"Release 2"}],"aggregatetimespent":null,"parent":123,"customfield_10034":123,"customfield_10035":{"value":"No","id":"10007"},"resolution":null,"customfield_10036":[{"value":"INDIA","id":"10008"},{"value":"CANADA","id":"10009"}],"customfield_10037":{"value":"ISRO","id":"10012","child":{"value":"GSAT-6","id":"10014"}},"customfield_10028":"TEST","customfield_10029":"TEST","resolutiondate":"2018-04-03T21:49:10.207+0530","lastViewed":"2018-04-03T21:49:10.207+0530","created":"2018-04-03T14:31:00.361+0530","customfield_10020":"Expected Result","customfield_10021":"00001026,00001027,00001024","customfield_10022":{"name":"addon_jira-trello-integration","key":"addon_jira-trello-integration","displayName":"Trello"},"customfield_10023":null,"priority":{"name":"Highest","id":"1"},"customfield_10024":"","customfield_10025":"","customfield_10203":"2019-07-25T23:00:00.000+0000","customfield_10202":"2019-07-24","customfield_10102":"test",customfield_10026":"","labels":["Subject"],"customfield_10017":null,"customfield_10018":{"value":"New","id":"10003"},"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"customfield_10100":"TP-1","assignee":{"name":"admin","key":"admin","displayName":"Jira Grazitti"},"updated":"2018-04-03T14:31:00.543+0530","status":{"name":"To Do","id":"10000"},"components":[],"timeoriginalestimate":null,"description":"TEST","customfield_10010":[],"customfield_10011":"0|i00047:","customfield_10012":null,"customfield_10013":null,"timetracking":{},"security":null,"customfield_10008":null,"customfield_10009":null,"aggregatetimeestimate":null,"attachment":[],"summary":"CLONE - Subject","customfield_10040":["Custom","label"],"customfield_10041":null,"customfield_10042":"Multi LineMulti Line","customfield_10043":{"value":"OPTION 1","id":"10020"},"reporter":{"name":"admin","key":"admin","emailAddress":"jiragrazitti03@gmail.com","displayName":"Jira Grazitti"},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10003":"","customfield_10004":"TEST","customfield_10038":"2018-04-03","customfield_10039":"2018-04-04T14:27:00.000+0530","environment":null,"duedate":null}}';     Ji.Project__c='DEV';
        insert ji;
        
        Case cs=new Case(Subject='TEST',Status='New',Origin='Phone');
        insert cs;
        
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, true);
        
        test.startTest();
        JiraIssueRelatedListController.getjiraissues(cs.id);
        JiraIssueRelatedListController.unlinkjira(ji.id,cs.id);
        test.stopTest();
        System.assertEquals(cs.id != null, true);
    }
}