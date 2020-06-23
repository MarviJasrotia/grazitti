global with Sharing class OnPackageInstall  implements InstallHandler {
     public boolean init=false;
    global void onInstall(InstallContext context) {
       
        if(context.previousVersion() == null) {
            SendJiraErrorLogsToGrazitti m = new SendJiraErrorLogsToGrazitti();
            String sch = '0 05 0 * * ?';
            String jobID = system.schedule('JIRALOGS', sch, m);
            init=true;
        }
    }
}