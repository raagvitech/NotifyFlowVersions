This class sends an email to the owner of the Flow about the total versions of the flow in the org.
Any Flow can have only 50 flow versions. If you reach that limit you cannot create another version of that flow.
If any flow reaches more than 40 flow versions, the owner of that particular flow will be notified about the flow label and the number of flow versions in an email.
A scheduler class which runs at 8:00am everyday will invoke the class which counts the versions and sends email.
Bascially we cannot query the flow object in apex directly, instead we need to make a callout to the same domain and can fetch the flowversions and owner of the flows.
I will be working on deletion of the flow when the owner replies the number of flow versions to be deleted to the same mail which he receives.


Note: Run the following code snippet in anonymous window for scheduling the class

public static string cronexp = '0 0 8 1/1 * ? *';
SchdulerForNotifyFlowVersions s = new SchdulerForNotifyFlowVersions();
String jobId = System.schedule('NotifyUserFlows',cronexp,s);

Thank you.
