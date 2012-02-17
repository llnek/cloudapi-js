# About
General js-library for accessing cloud providers.  The API is loosely based on the [Dasein-cloud-api](http://dasein-cloud.sourceforge.net/).  Dasein-cloud defines a set of cloud agnostic API.</br>Current implementation is for Amazon AWS only.

<b>NOTE</b>: This is an independent implementation and is not endorsed or associated with Dasein-cloud.

# Supported Platforms
* NodeJS - 0.6+
* Chrome, FFox, Safari, IE9
* jQuery 1.5+

## Cloud Vendors
* Amazon AWS 

## Supported Features
* EC2
* Auto Scaling
* Simple DB
* RDS
* VPC
* Elastic Load Balancing
* SQS
* SNS
* S3
* Coffeescript code, packaged as javascript for browser or nodejs

# For Browser
Include the scripts in your html and off you go.
<pre>
&lt;html&gt;&lt;head&gt;
&lt;script src="pathto/crypto-2.5.2.min.js" type="text/javascript"&gt;&lt;/script&gt;
&lt;script src="pathto/crypto-sha256-hmac-2.5.2.min.js" type="text/javascript"&gt;&lt;/script&gt;
&lt;script src="pathto/jquery.js" type="text/javascript"&gt;&lt;/script&gt;
&lt;script src="pathto/cloud-api.js" type="text/javascript"&gt;&lt;/script&gt;
&lt;script&gt;
var capi= ComZotoh.CloudAPI;
var cred_props= {
    // add your account info here
    accountNumber: 'acct number please',
    accessKey: 'access key please',
    secretKey: 'secret key please'
};
var aws= new capi.AmazonAWS(cred_props);
aws.getContext().setRegionId('us-east-1');
&lt;/script&gt;
&lt;/head&gt; ... &lt;/html&gt;
</pre>

# For NodeJS
<pre>
// cloudapi-js will pull in other dependencies...
var zotoh= require('cloudapi-js').ComZotoh;
var capi= zotoh.CloudAPI;
var cred_props= {
    // add your account info here
    accountNumber: 'acct number please',
    accessKey: 'access key please',
    secretKey: 'secret key please'
};
var aws= new capi.AmazonAWS(cred_props);
aws.getContext().setRegionId('us-east-1');
</pre>

# Access Services and call APIs
<pre>
var _dcs= aws.getDataCenterServices(); // for regions & availability zones
var _sks= aws.getIdentityServices().getShellKeySupport(); // key pairs
var _fws= aws.getNetworkServices().getFirewallSupport(); // security groups
var _ips= aws.getNetworkServices().getIpAddressSupport(); // Elastic IPs
var _vos= aws.getComputeServices().getVolumeSupport(); // EBS Volumes
var _sss= aws.getComputeServices().getSnapshotSupport();  // Snapshots
var _vms= aws.getComputeServices().getVirtualMachineSupport();  // Instances
var _ims= aws.getComputeServices().getImageSupport(); // AMIs
var _sts= aws.getComputeServices().getMetricsSupport();
var _sdb= aws.getPlatformServices().getKeyValueDatabaseSupport(); // SDB
var _sns= aws.getPlatformServices().getPushNotificationSupport(); // SNS
var _sqs= aws.getPlatformServices().getMessageQueueSupport(); // SQS
var _ass= aws.getComputeServices().getAutoScalingSupport();   
var _lbs= aws.getNetworkServices().getLoadBalancerSupport();
var _s3= aws.getStorageServices().getBlobStoreSupport();  // S3
var _rds= aws.getPlatformServices().getRelationalDatabaseSupport();  // RDS
var _vpc= aws.getNetworkServices().getVlanSupport();  // VPC
var _vpn= aws.getNetworkServices().getVpnSupport();   // VPC
</pre>

# Sample Code (coffeescript)
<pre>
// list all the instances

timeout=(rc) -> zotoh.LogJS.error( JSON.stringify(rc) )
error=(rc) -> zotoh.LogJS.error( JSON.stringify(rc) )
ok=(rc)-> JSON.stringfy(rc[i]) for i in [0...rc.length]
cbs= new zotoh.Net.AjaxCBS(ok,error,timeout)
_vms.listVirtualMachines(cbs)

</pre>

# Latest binary
Download the latest bundle [1.0.0](http://www.zotoh.com/packages/cloudapi-js/stable/1.0.0/cloudapi-js-1.0.0.zip)



