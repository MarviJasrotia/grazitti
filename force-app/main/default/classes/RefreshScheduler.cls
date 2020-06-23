global class RefreshScheduler implements Schedulable, Database.AllowsCallouts {
    public boolean Valid =true;
    global void execute(SchedulableContext sc) {
        Valid=false;
        RefreshFieldConfiguration refreshFieldConfg=new RefreshFieldConfiguration();
        refreshFieldConfg.FetchProjects();
    }
}