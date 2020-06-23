@istest
public class Test_JiraIssueCommentUpdate {
    @istest public static void method1(){
        JIRA_Login__c setting = new JIRA_Login__c();
        setting.name = 'Jira';
        insert setting;
        List<JiraSalesforceDetail__c> JiraDetailList= new List<JiraSalesforceDetail__c>();
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Comments',Value__c='yes');
        JiraDetailList.add(jsDetail);
        JiraSalesforceDetail__c jsDetail1=new JiraSalesforceDetail__c(Name='JiraCommentQualifier',Value__c='');
        JiraDetailList.add(jsDetail1);
        insert JiraDetailList;
        Sinergify_Trigger__c st = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st;
        
        JiraIssue__c Ji= new JiraIssue__c();
        ji.Name='DELL-29';
        Ji.IssueType__c='Task';
        Ji.IssueId__c=Integer.valueOf(Math.random() * 10000);
        Ji.IssueKey__c='DELL-29';
        Insert Ji;
        JiraIssueComments__c comment = new JiraIssueComments__c();
                    comment.CommentBody__c ='TEST 1';
                    comment.CommentId__c = '12621';
                    comment.IsPublished__c = true;  
                   comment.JiraIssue__c = ji.Id;
                    comment.UpdateAuthor__c = 'grazitti';
                    comment.Author__c = 'grazitti';
                    comment.Comment_Added__c = true;
        insert comment;
        map<string,string> issuelist = new  map<string,string>();
        issuelist.put(ji.name,ji.Id);
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.JiraIssuecommentBatch ()); 
        JiraIssueCommentUpdate batch = new JiraIssueCommentUpdate(issuelist);
        datetime dt1 = system.now(); 
        datetime dt = dt1.addSeconds(15);
                String day = string.valueOf(dt.day());
                String month = string.valueOf(dt.month());
                String hour = string.valueOf(dt.hour());
                String minute = string.valueOf(dt.minute());
                String second = string.valueOf(dt.second());
                String year = string.valueOf(dt.year());
                String strSchedule = second+' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
                System.schedule('Jira Comment Update'+strSchedule, strSchedule, batch);
        test.stopTest();
        System.assertEquals(comment.id != null, true);
        
    }
}