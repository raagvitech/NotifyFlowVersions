global class SchdulerForNotifyFlowVersions implements Schedulable{
    global void execute(SchedulableContext sc){
        NotifyUserFlowVersions.notifyuser();
    }
}