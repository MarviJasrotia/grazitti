public class ProjectWrapper {
    public Jira_Project__c project {
        get;
        set;
    }
    public boolean selected {
        get;
        set;
    }
    public List<SelectOption>IssueSelectList{get;set;}
    public List<String>IssueList{get;set;}
    public List<String>IssueSubList{get;set;}
    public List<String>IssueStdList{get;set;}
    public String SelectedIssues{get;set;}
    public List<String>SelectedIssueList{get;set;}

    public ProjectWrapper() {
       IssueSelectList= new List<SelectOption>();
        IssueList= new list<String>();
        IssueSubList= new list<String>();
        IssueStdList= new list<String>();
        SelectedIssueList=new List<String>();
        project= new Jira_Project__c();
        
    }
}