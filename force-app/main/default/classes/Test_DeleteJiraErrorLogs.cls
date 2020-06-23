@istest
public class Test_DeleteJiraErrorLogs {
    public static testMethod void testschedule() {
        List<JiraErrorLogs__c> errorlogs = new List<JiraErrorLogs__c>();
        JiraSalesforceDetail__c js = new JiraSalesforceDetail__c(name='JiraErrorLogs_Duration',Value__c='1');
        insert js;
        JiraErrorLogs__c jr = new JiraErrorLogs__c(Name='Test', Other_Details__c='Test', Apex_Class__c='batch');
        insert jr;
        Test.setCreatedDate(jr.Id, Date.today().addDays(-2));
        JiraErrorLogs__c jr1 = new JiraErrorLogs__c(Name='Test1', Other_Details__c='Test1', Apex_Class__c='batch1');
        insert jr1;
        Test.setCreatedDate(jr1.Id, Date.today().addDays(-2));
        Batch_DeleteJiraErrorLogs jiralog = new Batch_DeleteJiraErrorLogs();
        database.executeBatch(jiralog);
        List<JiraErrorLogs__c> jiraErroList = [SELECT id FROM JiraErrorLogs__c];
        System.assertEquals(jiraErroList.size(),2);
    }
    public static testMethod void testschedule1() {
        JiraErrorLogs__c jr = new JiraErrorLogs__c(Name='Test', Other_Details__c='Test', Apex_Class__c='batch');
        insert jr;
        Batch_DeleteJiraErrorLogs jiralog = new Batch_DeleteJiraErrorLogs();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test delete logs', sch, jiralog);
        List<JiraErrorLogs__c> jiraErroList = [SELECT id FROM JiraErrorLogs__c];
        System.assertEquals(jiraErroList.size(),1);
    }
}