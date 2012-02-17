`
(function(genv) {
"use strict";

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }

var zotoh= require('cloudapi-js').ComZotoh;
var capi= zotoh.CloudAPI;
//zotoh.LogJS.setDebug();
var nodeunit= require('nodeunit');
var events= require('events');
var cred_props= {
    // add your account info here
    accountNumber: 'acct number please',
    accessKey: 'access key please',
    secretKey: 'secret key please'
};

var aws= new zotoh.CloudAPI.AmazonAWS(cred_props);
aws.getContext().setRegionId('us-east-1');
var _dcs= aws.getDataCenterServices();
var _sks= aws.getIdentityServices().getShellKeySupport();
var _fws= aws.getNetworkServices().getFirewallSupport();
var _ips= aws.getNetworkServices().getIpAddressSupport();
var _vos= aws.getComputeServices().getVolumeSupport();
var _sss= aws.getComputeServices().getSnapshotSupport();
var _vms= aws.getComputeServices().getVirtualMachineSupport();
var _ims= aws.getComputeServices().getImageSupport();
var _sts= aws.getComputeServices().getMetricsSupport();
var _sdb= aws.getPlatformServices().getKeyValueDatabaseSupport();
var _sns= aws.getPlatformServices().getPushNotificationSupport();
var _sqs= aws.getPlatformServices().getMessageQueueSupport();
var _ass= aws.getComputeServices().getAutoScalingSupport();
var _lbs= aws.getNetworkServices().getLoadBalancerSupport();
var _s3= aws.getStorageServices().getBlobStoreSupport();
var _rds= aws.getPlatformServices().getRelationalDatabaseSupport();
var _vpc= aws.getNetworkServices().getVlanSupport();
var _vpn= aws.getNetworkServices().getVpnSupport();

var adm= aws.getAdminServices().getPrepaymentSupport();
var P64= zotoh.CloudAPI.Compute.VirtualMachineProduct.entrySet() ['m1.large'];

`

ONN= () ->
    (rc) -> is_alive(rc)

NEA= () ->
    (rc) -> is_alive(rc) and rc.length > 0

EBS= (testObj, cond, msg) ->
    error=(rc) ->
        testObj.ok( true, 'shoud fail')
        testObj.done()
    ok=(rc)->
        testObj.ok( false, 'should not work')
        testObj.done()
    new zotoh.Net.AjaxCBS(ok,error,error)

CBS= (testObj, cond, msg) ->
    msg= msg || 'bad result'
    error=(rc) ->
        zotoh.LogJS.error( JSON.stringify(rc) )
        testObj.done()
    ok=(rc)->
        testObj.ok( cond(rc), msg)
        testObj.done()
    new zotoh.Net.AjaxCBS(ok,error,error)


dc_tcase= {

    'get datacenter' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.getProviderDataCenterId() is 'us-east-1a'
        test.expect(1)
        _dcs.getDataCenter( 'us-east-1a', CBS(test, cond ) )

    'get region' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.getProviderRegionId() is 'us-east-1'
        test.expect(1)
        _dcs.getRegion( 'us-east-1', CBS(test, cond ) )

    'list datacenters' : (test) ->
        test.expect(1)
        _dcs.listDataCenters( 'us-east-1', CBS(test,NEA() ) )

    'list regions' : (test) ->
        test.expect(1)
        _dcs.listRegions( CBS(test,NEA() ) )
}

kp_tcase= {

    'create keypair' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.keyMaterial?.length > 0
        test.expect(1)
        _sks.createKeypair('testtest', CBS(test, cond))

    'get fingerprint' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.result?.length > 0
        test.expect(1)
        _sks.getFingerprint('testtest', CBS(test, cond))

    'list keypairs' : (test) ->
        test.expect(1)
        _sks.list( CBS(test, NEA()))

    'delete keypair' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _sks.deleteKeypair('testtest', CBS(test, cond))

}


sg_tcase ={

    'create sec-group' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.getProviderFirewallId()?.length > 0 and rc.getName() is 'testtest'
        test.expect(1)
        _fws.create('testtest', 'testing', CBS(test,cond))

    'auth sec-group' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _fws.authorize('testtest', '0.0.0.0/0', 'tcp', 22,22, CBS(test,cond))

    'get firewall' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.getName() is 'testtest'
        test.expect(1)
        _fws.getFirewall('testtest', CBS(test,cond))

    'get rules(+)' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.length > 0
        test.expect(1)
        _fws.getRules('testtest', CBS(test,cond))

    'list sec-groups' : (test) ->
        test.expect(1)
        _fws.list( CBS(test,NEA()))

    'revoke sec-group' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _fws.revoke('testtest', '0.0.0.0/0', 'tcp', 22,22, CBS(test,cond))

    'get rules (-)' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.length is 0
        test.expect(1)
        _fws.getRules('testtest', CBS(test,cond))

    'delete sec-group' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _fws.delete('testtest', CBS(test,cond))

}

ip_addr=''
ip_tcase={

    'alloc new eip' : (test) ->
        cond= (rc) ->
            ip_addr= if is_alive(rc) then rc.getProviderIpAddressId() else ''
            (ip_addr || '').length > 0
        test.expect(1)
        _ips.request(capi.Network.AddressType.PUBLIC, CBS(test,cond))

    'get eip' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.getProviderIpAddressId() is ip_addr
        test.expect(1)
        _ips.getIpAddress(ip_addr, CBS(test,cond))

    'list eips' : (test) ->
        test.expect(1)
        _ips.listPublicIpPool(false, CBS(test, NEA()))

    'dealloc eip' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _ips.releaseFromPool(ip_addr, CBS(test,cond))
}

vol_id=''
vol_tcase={

    'list possible dev-ids' : (test) ->
        test.expect(2)
        rc=_vos.listPossibleDeviceIds(capi.Compute.Platform.WINDOWS)
        test.ok(rc.length > 0)
        rc=_vos.listPossibleDeviceIds(capi.Compute.Platform.LINUX)
        test.ok(rc.length > 0)
        test.done()

    'create volume' : (test) ->
        cond = (rc) ->
            vol_id = if is_alive(rc) then rc.getProviderVolumeId() else ''
            (vol_id || '').length > 0
        test.expect(1)
        _vos.create('', 7, 'us-east-1d', CBS(test,cond,'bad object'))

    'get volume' : (test) ->
        cond = (rc) ->
            is_alive(rc) and rc.getProviderVolumeId()?.length > 0
        test.expect(1)
        _vos.getVolume(vol_id, CBS(test, cond))

    'list volumes' : (test) ->
        _vos.listVolumes( CBS(test, NEA()) )

    'delete volume' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _vos.remove(vol_id, CBS(test,cond))

}

snap_id=''
snap_tcase={

    'create volume' : (test) ->
        cond = (rc) ->
            vol_id = if is_alive(rc) then rc.getProviderVolumeId() else ''
            (vol_id || '').length > 0
        test.expect(1)
        _vos.create('', 7, 'us-east-1d', CBS(test,cond))

    'create snapshot' : (test) ->
        cond = (rc) ->
            snap_id = if is_alive(rc) then rc.getProviderSnapshotId() else ''
            (snap_id || '').length > 0
        test.expect(1)
        _sss.create(vol_id, 'test only', CBS(test,cond))

    'delete volume' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _vos.remove(vol_id, CBS(test,cond))

    'get snapshot' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.getProviderSnapshotId()?.length > 0
        test.expect(1)
        _sss.getSnapshot(snap_id, CBS(test, cond))

    'is public (no)' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is false
        test.expect(1)
        _sss.isPublic(snap_id, CBS(test, cond))

    'share public (yes)' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _sss.sharePublic(snap_id, true, CBS(test, cond))

    'is public (yes)' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _sss.isPublic(snap_id, CBS(test, cond))

    'list shares' : (test) ->
        test.expect(1)
        _sss.listShares(snap_id, CBS(test, NEA()))

    'share public (no)' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _sss.sharePublic(snap_id, false, CBS(test, cond))

    'is public (?)' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is false
        test.expect(1)
        _sss.isPublic(snap_id, CBS(test, cond))

    'list snapshots' : (test) ->
        test.expect(1)
        _sss.listSnapshots(CBS(test, NEA()))


    'create volume (from snap)' : (test) ->
        cond = (rc) ->
            vol_id = if is_alive(rc) then rc.getProviderVolumeId() else ''
            (vol_id || '').length > 0
        test.expect(1)
        _vos.create(snap_id, 7, 'us-east-1d', CBS(test,cond,'bad object'))

    'delete snapshot' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _sss.remove(snap_id, CBS(test,cond))

    'delete volume (from snap)' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _vos.remove(vol_id, CBS(test,cond))

}

t_ami='ami-b1a54cd8'
t_ami=null
ami_id='ami-8e1fece7'
im_tcase={

    'get image' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.getTag('isPublic') is true
        test.expect(1)
        _ims.getMachineImage(ami_id, CBS(test, cond))

    'is public' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _ims.isImageSharedWithPublic(ami_id, CBS(test, cond))

    'list own images' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.length >= 0
        test.expect(1)
        _ims.listMachineImages(CBS(test, cond))

    'list images' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.length >= 0
        test.expect(1)
        _ims.listMachineImagesOwnedBy(cred_props.accountNumber, CBS(test, cond))

    'list shares': (test) ->
        if t_ami is null
            test.done()
            return
        cond = (rc) -> is_alive(rc) and rc.length > 0
        test.expect(1)
        _ims.listShares(t_ami, CBS(test, cond))

    'share public (yes)' : (test) ->
        if t_ami is null
            test.done()
            return
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _ims.sharePublic(t_ami, true, CBS(test, cond))

    'share public (no)' : (test) ->
        if t_ami is null
            test.done()
            return
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _ims.sharePublic(t_ami, false, CBS(test, cond))

    'share with (yes)' : (test) ->
        if t_ami is null
            test.done()
            return
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _ims.shareMachineImage(t_ami, cred_props.accountNumber, true, CBS(test, cond))


    'delete image' : (test) ->
        cond= null
        test.expect(1)
        _ims.remove(ami_id, EBS(test, cond))

    'search images' : (test) ->
        test.expect(1)
        _ims.searchMachineImages('Amazon', capi.Compute.Platform.WINDOWS, capi.Compute.Architecture.I64, CBS(test, NEA()))

}

gp_id='testtest'
kp_id='testtest'
vm_id=''
vm_timer=null

cls_timer= () ->
    if vm_timer? then clearInterval(vm_timer)
    vm_timer=null


check_vm_state = (test, target) ->
    vm_err= (rc) ->
        cls_timer()
        test.ok(false, 'failed to check vm state')
        test.done()

    vm_ok = (rc) ->
        if not is_alive(rc)
            test.ok(false, 'fatal error - check vm state(null)')
            test.done()
            return
        s=rc.getCurrentState()
        if target is s
            cls_timer()
            test.ok(true, '')
            test.done()
        else
            console.log('vm state=' + s)

    _vms.getVirtualMachine(vm_id, new zotoh.Net.AjaxCBS(vm_ok,vm_err,vm_err))

vm_tcase={

    'create keypair' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.keyMaterial?.length > 0
        test.expect(1)
        _sks.createKeypair('testtest', CBS(test, cond))

    'create sec-group' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.getProviderFirewallId()?.length > 0 and rc.getName() is 'testtest'
        test.expect(1)
        _fws.create('testtest', 'testing', CBS(test,cond))

    'auth sec-group' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _fws.authorize('testtest', '0.0.0.0/0', 'tcp', 5000,9000, CBS(test,cond))

    'launch vm' : (test) ->
        cond = (rc) ->
            vm_id= if is_alive(rc) then rc.getProviderVirtualMachineId() else ''
            (vm_id || '').length > 0
        test.expect(1)
        cbs=CBS(test, cond)
        _vms.launch(ami_id, P64, 'us-east-1d', kp_id, '', true, [gp_id], null, cbs)

    'wait (after launch)' : (test) ->
        cb = () -> check_vm_state(test,'running')
        vm_timer = setInterval(cb, 10000)

    'get vm' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.getProviderVirtualMachineId() is vm_id
        test.expect(1)
        _vms.getVirtualMachine(vm_id, CBS(test, cond))

    'get Console Output' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result?.length >= 0
        test.expect(1)
        _vms.getConsoleOutput(vm_id, CBS(test,cond))

    'list firewalls' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.result?.length > 0
        test.expect(1)
        _vms.listFirewalls(vm_id, CBS(test,cond))

    'list products' : (test) ->
        test.expect(2)
        rc=_vms.listProducts(capi.Compute.Architecture.I64)
        test.ok(rc.length > 0, 'bad products for 64bits')
        rc=_vms.listProducts(capi.Compute.Architecture.I32)
        test.ok(rc.length > 0, 'bad products for 32bits')
        test.done()

    'list vms' : (test) ->
        test.expect(1)
        _vms.listVirtualMachines(CBS(test, NEA()))

    'reboot vm' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _vms.reboot(vm_id, CBS(test, cond))

    'wait (after reboot)' : (test) ->
        cb = () -> check_vm_state(test,'running')
        vm_timer = setInterval(cb, 10000)

    'pause vm' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _vms.pause(vm_id, CBS(test, cond))

    'wait (after pause)' : (test) ->
        cb = () -> check_vm_state(test,'stopped')
        vm_timer = setInterval(cb, 10000)

    'boot vm' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _vms.boot(vm_id, CBS(test, cond))

    'wait (after boot)' : (test) ->
        cb = () -> check_vm_state(test,'running')
        vm_timer = setInterval(cb, 10000)

    'kill vm' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _vms.terminate(vm_id, CBS(test, cond))

    'wait (after terminate)' : (test) ->
        cb = () -> check_vm_state(test,'terminated')
        vm_timer = setInterval(cb, 10000)

    'wait more (after terminate)' : (test) ->
        cb = () ->
            test.ok(true,'')
            test.done()
        setTimeout(cb, 5000)

    'delete keypair' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _sks.deleteKeypair('testtest', CBS(test, cond))

    'delete sec-group' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _fws.delete('testtest', CBS(test,cond))

}

vm_id='i-70b26412'
vm_id=null

stats_tcase={

    'get vm CPU stats' : (test) ->
        if not vm_id?
            test.done()
            return
        cond = (rc) -> is_alive(rc) and rc.length >= 0
        cbs=CBS(test,cond)
        test.expect(1)
        t=new Date()
        f=new Date( t.getTime() - 60*60*1000)
        _sts.getVMStatistics(vm_id, capi.Compute.MetricType.CPU, f,t,cbs)

    'list metrics' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.length >= 0
        test.expect(1)
        _sts.listMetrics( '', CBS(test, cond))

}

sdb_item1='item1'
sdb_id=''
sdb_tcase={

    'create sdb' : (test) ->
        cond= (rc)->
            sdb_id= if rc? then rc.getProviderDatabaseId() else ''
            (sdb_id || '').length > 0
        test.expect(1)
        _sdb.createDatabase('testtesttesttest', 'testing', CBS(test,cond))

    'add data' : (test) ->
        cond = (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        kvc=capi.Platform.KeyValuePair
        kvs=[new kvc('c1', 'v1'), new kvc('c2', 9.5), new kvc('c3', 75) ]
        _sdb.addKeyValuePairs(sdb_id, sdb_item1, kvs, CBS(test,cond))

    'wait (after data)' : (test) ->
        cb = () ->
            test.ok(true,'')
            test.done()
        setTimeout(cb, 8000)

    'get item count' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result is 1
        test.expect(1)
        _sdb.getItemCount(sdb_id, CBS(test,cond))

    'get item names' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.length is 1
        test.expect(1)
        _sdb.getItemNames(sdb_id, CBS(test,cond))

    'get key count' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result is 3
        test.expect(1)
        _sdb.getKeyCount(sdb_id, sdb_item1, CBS(test,cond))

    'get key values' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.flds?.length is 3
        test.expect(1)
        _sdb.getKeyValuePairs(sdb_id, sdb_item1, true, CBS(test,cond))

    'select ???' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.length is 1
        test.expect(1)
        sql='select * from `'+sdb_id+"` where `c1`='v1'"
        _sdb.query(null, sql, true, CBS(test,cond))

    'replace key values' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.result is true
        kvc=capi.Platform.KeyValuePair
        kvs=[new kvc('c2', 'hi'), new kvc('c3', 7.9) ]
        test.expect(1)
        _sdb.replaceKeyValuePairs(sdb_id, sdb_item1, kvs, CBS(test,cond))

    'remove key values' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result is true
        kvc=capi.Platform.KeyValuePair
        kvs=[new kvc('c2'), new kvc('c3', 7.9) ]
        test.expect(1)
        _sdb.removeKeyValuePairs(sdb_id, sdb_item1, kvs, CBS(test,cond))

    'remove item' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result is true
        test.expect(1)
        _sdb.removeItem(sdb_id, sdb_item1, CBS(test,cond))

    'get db' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.getProviderDatabaseId()?.length > 0
        test.expect(1)
        _sdb.getDatabase(sdb_id, CBS(test,cond))

    'list dbs' : (test) ->
        test.expect(1)
        _sdb.list(null, CBS(test,NEA()))

    'remove db' : (test) ->
        cond= (rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _sdb.removeDatabase(sdb_id, CBS(test,cond))
}

sns_dfmt=capi.DataFormat.TEXT
sns_topic='testtest'
sns_topid=''
sns_subid=''
sns_eptt=capi.Platform.EndpointType.AWS_SQS
sns_ept='arn:aws:sqs:us-east-1:417269015491:com-tibco-cloud-myqueue'
sns_tcase={

    'create topic' : (test) ->
        cond=(rc)->
            sns_topid=if rc? then rc.getProviderTopicId() else ''
            (sns_topid || '').length > 0
        test.expect(1)
        _sns.createTopic(sns_topic, CBS(test,cond))

    'list topics' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.length > 0
        test.expect(1)
        _sns.listTopics(null, CBS(test,cond))

    'subscribe' : (test) ->
        cond=(rc)->
            sns_subid= if rc? then rc.getProviderSubscriptionId() else ''
            (sns_subid || '').length > 0
        test.expect(1)
        _sns.subscribe(sns_topid,sns_eptt,sns_dfmt,sns_ept,CBS(test,cond))

    'list subscriptions (by topic)' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.length > 0
        test.expect(1)
        _sns.listTopicSubscriptions(null, sns_topid, CBS(test,cond))

    'list subscriptions' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.length > 0
        test.expect(1)
        _sns.listSubscriptions(null, CBS(test,cond))

    'publish msg' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.result?.length > 0
        test.expect(1)
        _sns.publish(sns_topid, 'testing', 'hello world', CBS(test, cond))

    'unsubscribe' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result is true
        test.expect(1)
        _sns.unsubscribe(sns_subid, CBS(test, cond))

    'wait (after unsubscribe)' : (test) ->
        cb = () ->
            test.ok(true,'')
            test.done()
        setTimeout(cb, 8000)

    'remove topic' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result is true
        test.expect(1)
        _sns.removeTopic(sns_topid, CBS(test, cond))

}

sqs_msgid=''
sqs_qid='testtest'
sqs_qurl=''

sqs_tcase={

    'create queue' : (test) ->
        cond=(rc)->
            sqs_qurl= if rc? then rc.result else ''
            (sqs_qurl || '').length > 0
        test.expect(1)
        _sqs.createQueue(sqs_qid, 'test', 30, CBS(test, cond))

    'list queues' : (test) ->
        test.expect(1)
        _sqs.list(null, CBS(test, NEA()))

    'get queue' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result?.length > 0
        test.expect(1)
        _sqs.getQueue(sqs_qid, CBS(test, cond))

    'get queue attrs' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.length > 0
        test.expect(1)
        _sqs.getQueueAttributes(sqs_qid, CBS(test, cond))

    'set queue attrs' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _sqs.setQueueAttributes(sqs_qid, 'DelaySeconds', 0, CBS(test, cond))

    'send msg' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.MessageId?.length > 0
        test.expect(1)
        _sqs.sendMessage(sqs_qid, 'hello', CBS(test, cond))

    'wait (after sendmsg)' : (test) ->
        cb = () ->
            test.ok(true,'')
            test.done()
        setTimeout(cb, 8000)

    'recv msg' : (test) ->
        cond=(rc) ->
            sqs_msgid=if rc? and rc.length > 0 then rc[0].ReceiptHandle else ''
            (sqs_msgid || '').length > 0
        test.expect(1)
        _sqs.receiveMessages(sqs_qid, 10, 30, CBS(test,cond))

    'remove msgs' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result is true
        test.expect(1)
        _sqs.removeMessage(sqs_qid, sqs_msgid, CBS(test,cond))


    'remove queue' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result is true
        test.expect(1)
        _sqs.removeQueue(sqs_qid, CBS(test,cond))
}

ass_cfg='testtest'

scale_tcase={

    'create cfg' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result is true
        test.expect(1)
        _ass.createLaunchConfiguration(ass_cfg, ami_id, P64, [], true, CBS(test,cond))

    'create group' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result is true
        test.expect(1)
        _ass.createAutoScalingGroup('testtest', ass_cfg, 2, 4, 3, ['us-east-1d'], CBS(test,cond) )

    'get cfg' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.getProviderImageId() is ami_id
        test.expect(1)
        _ass.getLaunchConfiguration(ass_cfg, CBS(test,cond))

    'get group' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.getProviderLaunchConfigurationId() is ass_cfg
        test.expect(1)
        _ass.getScalingGroup('testtest', CBS(test, cond))

    'set capacity' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _ass.setDesiredCapacity('testtest', 3, CBS(test, cond))

    'list grps' : (test) ->
        test.expect(1)
        _ass.listScalingGroups(null, CBS(test, NEA()))

    'list cfgs' : (test) ->
        test.expect(1)
        _ass.listLaunchConfigurations(null, CBS(test, NEA()))

    'update grp' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _ass.updateAutoScalingGroup('testtest', ass_cfg, 2, 2, 7, ['us-east-1d'], CBS(test, cond))

    'remove group' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.result is true
        test.expect(1)
        _ass.deleteAutoScalingGroup('testtest', true, CBS(test,cond))

    'remove cfg' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _ass.deleteLaunchConfiguration(ass_cfg, CBS(test,cond))

}


ls_ln=new capi.Network.LbListener()
lbs_tcase={

    'create elb' : (test) ->
        cond=(rc)->is_alive(rc) and rc.getAddress()?.length > 0
        test.expect(1)
        _lbs.create('testtest', 'testing', null, ['us-east-1d'], [ls_ln], [], CBS(test, cond))

    'add dcs' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.length is 2
        test.expect(1)
        _lbs.addDataCenters('testtest', ['us-east-1c'], CBS(test,cond))

    'add servers' : (test) ->
        cond=(rc)->is_alive(rc) and rc.length > 0
        test.expect(1)
        test.ok(true,'')
        test.done()
        #_lbs.addServers('testtest', [], CBS())

    'get elb' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.getListeners().length is 1
        test.expect(1)
        _lbs.getLoadBalancer('testtest', CBS(test,cond))

    'list elbs' : (test) ->
        test.expect(1)
        _lbs.listLoadBalancers(CBS(test, NEA()))


    'remove servers' : (test) ->
        cond=(rc)->is_alive(rc) and rc.length > 0
        test.expect(1)
        test.ok(true,'')
        test.done()
        #_lbs.removeServers('testtest', [], CBS())

    'remove dcs' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.length is 1
        test.expect(1)
        _lbs.removeDataCenters('testtest', ['us-east-1c'], CBS(test,cond))


    'remove elb' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _lbs.remove('testtest', CBS(test, cond))










}


s3_dir='comacme-testtesttesttest'
s3_file='file1'

blob_tcase={

    'create dir' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _s3.createDirectory(s3_dir, null, {'x-amz-acl':'bucket-owner-full-control'}, CBS(test,cond))

    'list dirs' : (test) ->
        test.expect(1)
        _s3.listDirectories(CBS(test,NEA()))

    'exists dir' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _s3.existsDirectory(s3_dir, CBS(test, cond))

    'is dir public?' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is false
        test.expect(1)
        _s3.isDirectoryPublic(s3_dir, CBS(test,cond))

    'new file' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        s='hello world'
        blob={data:s,size:s.length}
        _s3.upload(s3_dir, s3_file, 'text/plain', blob, {}, false, null, CBS(test,cond))

    'make dir public': (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _s3.makeDirectoryPublic(s3_dir, true, true, CBS(test,cond))

    'get dir acl' : (test) ->
        cond=(rc)->is_alive(rc)
        test.expect(1)
        _s3.getDirectoryACL(s3_dir,CBS(test,cond))

    'is file public?' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is false
        test.expect(1)
        _s3.isFilePublic(s3_dir,s3_file, CBS(test,cond))

    'make file public': (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _s3.makeFilePublic(s3_dir, s3_file, true, true, CBS(test,cond))

    'get file acl' : (test) ->
        cond=(rc)->is_alive(rc)
        test.expect(1)
        _s3.getFileACL(s3_dir,s3_file,CBS(test,cond))

    'list files' : (test) ->
        test.expect(1)
        _s3.listFiles(null, s3_dir, {}, CBS(test,NEA()))

    'exists file' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _s3.existsFile(s3_dir,s3_file, CBS(test, cond))


    'is dir public now ?' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _s3.isDirectoryPublic(s3_dir, CBS(test,cond))

    'is file public now?' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _s3.isFilePublic(s3_dir,s3_file, CBS(test,cond))

    'get file' : (test) ->
        cond=(rc)-> is_alive(rc)
        test.expect(1)
        _s3.download(s3_dir,s3_file, CBS(test,cond))

    'remove file' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _s3.removeFile(s3_dir, s3_file, {}, CBS(test,cond))

    'remove dir' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _s3.removeDirectory(s3_dir, CBS(test,cond))
}

dbpm= capi.Platform.ConfigurationParameter
dbp=new capi.Platform.DatabaseProduct()
dbp.setStorageInGigabytes(10)
dbp.setEngine('mysql')
dbp.setProductSize('db.m1.small')
dbcfg='testtest'
dbid='tibbrtestdb'
dbid2='tibbrtestdb2'
dbid3='tibbrtestdb3'
dbsnap='testtest'
dbfw='testtest'
#zotoh.LogJS.setDebug()

rds_setup={

    'create cfg' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _rds.createConfiguration(dbcfg,'test', {dbFamily:'MySQL5.1'},CBS(test,cond) )

    'new dbfwall' : (test) ->
        cond=(rc)->is_alive(rc) and rc.getProviderFirewallId()?.length > 0
        test.expect(1)
        _rds.createDBFirewall(dbfw, 'test', CBS(test,cond))

    'create new db' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.getProviderDatabaseId()?.length > 0
        test.expect(1)
        _rds.createFromScratch(dbid, dbp, 'sa','sa123', null, null, CBS(test,cond) )

    'wait (after create db)' : (test) ->
        cb = () ->
            test.ok(true,'')
            test.done()
        setTimeout(cb, 120000)

}

rds_finz={

    'remove db' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _rds.removeDatabase(dbid,null,CBS(test,cond))

    'wait (after remove db)' : (test) ->
        cb = () ->
            test.ok(true,'')
            test.done()
        setTimeout(cb, 150000)

    'remove cfg' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _rds.removeConfiguration(dbcfg,CBS(test,cond))

    'remove snap' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _rds.removeSnapshot(dbsnap, CBS(test,cond))

    'remove dbfwall' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _rds.removeDBFirewall(dbfw, CBS(test,cond))


}

rds_tcase={

    'list db engines' : (test) ->
        test.expect(1)
        _rds.getDatabaseEngines(CBS(test, NEA()))

    'add fw access' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _rds.addAccess(dbfw, { cidr: '0.0.0.0/0'}, CBS(test,cond))

    'get cfg' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.getProviderConfigurationId()?.length > 0
        test.expect(1)
        _rds.getConfiguration(dbcfg, CBS(test,cond))

    'get db' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.getProviderDatabaseId()?.length > 0
        test.expect(1)
        _rds.getDatabase(dbid, CBS(test,cond))

    'update cfg' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        pms= [ new dbpm('max_user_connections', 24),
            new dbpm('max_allowed_packet', 1024) ]
        _rds.updateConfiguration(dbcfg, pms, CBS(test,cond))

    'list cfgs' : (test) ->
        test.expect(1)
        _rds.listConfigurations(null,CBS(test, NEA()))

    'list dbs' : (test) ->
        test.expect(1)
        _rds.listDatabases(CBS(test, NEA()))

    'list db params' : (test) ->
        cond=(rc)->is_alive(rc) and rc.length > 0
        test.expect(1)
        filter=capi.Platform.ConfigurationParameter.SYSTEM
        _rds.listParameters(null,dbcfg, filter, CBS(test,cond))

    'list dbfwalls' : (test) ->
        test.expect(1)
        _rds.listDBFirewalls(null, CBS(test,NEA()))

    'get dbfwall' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.getProviderFirewallId()?.length > 0
        test.expect(1)
        _rds.getDBFirewall(dbfw, CBS(test,cond))

    'take snapshot' : (test) ->
        cond=(rc)-> is_alive(rc) and rc.getProviderSnapshotId()?.length > 0
        test.expect(1)
        _rds.snapshot(dbid, dbsnap, CBS(test, cond))

    'wait (after taking snap)' : (test) ->
        cb = () ->
            test.ok(true,'')
            test.done()
        setTimeout(cb, 90000)

    'reset cfg' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _rds.resetConfiguration(dbcfg,[],CBS(test,cond))

    'list snaps' : (test) ->
        test.expect(1)
        _rds.listSnapshots(null, dbid, CBS(test,NEA()))

    'revoke fw access' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _rds.revokeAccess(dbfw, { cidr: '0.0.0.0/0'}, CBS(test,cond))

    'alter db' : (test) ->
        cond=(rc)->is_alive(rc) and rc.getProviderDatabaseId()?.length > 0
        test.expect(1)
        _rds.alterDatabase(dbid, null, null, [dbfw], 'admin123', {}, true, CBS(test,cond))

    'restart db' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _rds.restart(dbid, false, CBS(test,cond))

    'wait (after restart db)' : (test) ->
        cb = () ->
            test.ok(true,'')
            test.done()
        setTimeout(cb, 60000)

    'get snap' : (test) ->
        cond=(rc)->is_alive(rc) and rc.getProviderSnapshotId()?.length > 0
        test.expect(1)
        _rds.getSnapshot(dbsnap, CBS(test,cond))

}

rds_clones={

    'copy from snap' : (test) ->
        cond=(rc)->is_alive(rc) and rc.getProviderDatabaseId()?.length > 0
        test.expect(1)
        _rds.createFromSnapshot(dbid2, dbsnap, null, null, CBS(test,cond))

    'copy from latest' : (test) ->
        cond=(rc)->is_alive(rc) and rc.getProviderDatabaseId()?.length > 0
        test.expect(1)
        _rds.createFromLatest(dbid3, dbid, null, CBS(test,cond))
}


sub_id=''
vpc_id=''
vlan_tcase={

    'create vlan' : (test) ->
        cond=(rc)->
            vpc_id=if rc? then rc.getProviderVlanId() else ''
            (vpc_id || '').length > 0
        test.expect(1)
        _vpc.createVlan('10.114.0.0/20', {}, CBS(test,cond))

    'create subnet' : (test) ->
        cond=(rc) ->
            sub_id= if rc? then rc.getProviderSubnetId() else ''
            (sub_id || '').length > 0
        test.expect(1)
        _vpc.createSubnet(vpc_id, '10.114.1.0/20', null, {}, CBS(test,cond))

    'get vlan' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.getProviderVlanId()?.length > 0
        test.expect(1)
        _vpc.getVlan(vpc_id, CBS(test,cond))

    'get subnet' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.getProviderSubnetId()?.length > 0
        test.expect(1)
        _vpc.getSubnet(sub_id, CBS(test,cond))

    'list subnets' : (test) ->
        test.expect(1)
        _vpc.listSubnets( vpc_id, CBS(test, NEA()))

    'list vlans' : (test) ->
        test.expect(1)
        _vpc.listVlans( CBS(test, NEA()))

    'list network interfaces' : (test) ->
        test.expect(1)
        _vpc.listNetworkInterfaces( CBS(test, NEA()))

    'remove subnet' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _vpc.removeSubnet(sub_id, CBS(test, cond))

    'remove vlan' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _vpc.removeVlan(vpc_id, CBS(test, cond))
}

gw_vlan=''
gw_inet=''
vpn_id=''
vpn_id='vpn-c213f6ab'
vpc_id='vpc-314d9258'
vpn_tcase={

    'create internet gateway' : (test) ->
        cond=(rc)->
            gw_inet= if rc? then rc.getProviderVpnGatewayId() else ''
            (gw_inet || '').length > 0
        test.expect(1)
        _vpn.createVPNGateway('internet', null,null,null,null,null, CBS(test,cond))

    'create vlan gateway' : (test) ->
        cond=(rc)->
            gw_vlan= if rc? then rc.getProviderVpnGatewayId() else ''
            (gw_vlan || '').length > 0
        test.expect(1)
        _vpn.createVPNGateway('vlan', 'ipsec.1',null,null,null,null, CBS(test,cond))

    'list internet gways' : (test) ->
        test.expect(1)
        _vpn.listVPNGateways('internet', CBS(test, NEA()))

    'list vlan gways' : (test) ->
        test.expect(1)
        _vpn.listVPNGateways('vlan', CBS(test, NEA()))

    'create vpn' : (test) ->
        cond=(rc)->
            vpn_id=if rc? then rc.getProviderVpnId() else ''
            (vpn_id || '').length > 0
        test.expect(1)
        _vpn.createVPN(null, 'ipsec.1', { privateGatewayId:'cgw-ac6782c5', awsGatewayId: gw_vlan }, CBS(test,cond))

    'connect gway to vlan' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _vpn.connectGateway(gw_inet, vpc_id, CBS(test, cond))

    'list vpns' : (test) ->
        test.expect(1)
        _vpn.listVPNs(CBS(test,NEA()))

    'get vpn' : (test) ->
        cond=(rc)->is_alive(rc) and rc.getProviderVpnId()?.length > 0
        test.expect(1)
        _vpn.getVPN(vpn_id, CBS(test, cond))

    'attach vpn to vlan' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _vpn.attachToVLAN(vpn_id, vpc_id, CBS(test,cond))

    'disconnect gway from vlan' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _vpn.disconnectGateway(gw_inet, vpc_id, CBS(test, cond))

    'detach vpn from vlan' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _vpn.detachFromVLAN(vpn_id, vpc_id, CBS(test,cond))

    'delete vpn' : (test) ->
        cond=(rc)->is_alive(rc) and rc.result is true
        test.expect(1)
        _vpn.deleteVPN(vpn_id, CBS(test,cond))

    'remove internet gway' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _vpn.deleteVPNGateway('internet', gw_inet, CBS(test,cond))

    'remove vlan gway' : (test) ->
        cond=(rc) -> is_alive(rc) and rc.result is true
        test.expect(1)
        _vpn.deleteVPNGateway('vlan', gw_vlan, CBS(test,cond))

}

#zotoh.LogJS.setDebug()
dbg_tcase={



}

`

genv['dbg'] = nodeunit.testCase( dbg_tcase ) ;





/*
genv['regions and dcs'] = nodeunit.testCase( dc_tcase ) ;
genv['keypairs'] = nodeunit.testCase( kp_tcase ) ;
genv['firewalls'] = nodeunit.testCase( sg_tcase ) ;
genv['elastic ips'] = nodeunit.testCase( ip_tcase ) ;
genv['volumes'] = nodeunit.testCase( vol_tcase ) ;
genv['snapshots'] = nodeunit.testCase( snap_tcase ) ;
genv['images'] = nodeunit.testCase( im_tcase ) ;
genv['virtual machines'] = nodeunit.testCase( vm_tcase ) ;
genv['metrics'] = nodeunit.testCase( stats_tcase ) ;
genv['keyvalue db'] = nodeunit.testCase( sdb_tcase ) ;
genv['push notify'] = nodeunit.testCase( sns_tcase ) ;
genv['message queues'] = nodeunit.testCase( sqs_tcase ) ;
genv['auto scaling'] = nodeunit.testCase( scale_tcase ) ;
genv['load balancers'] = nodeunit.testCase( lbs_tcase ) ;
genv['blob storage'] = nodeunit.testCase( blob_tcase ) ;
genv['rdbms-init'] = nodeunit.testCase( rds_setup ) ;
genv['rdbms'] = nodeunit.testCase( rds_tcase ) ;
genv['rdbms-clones'] = nodeunit.testCase( rds_clones ) ;
genv['rdbms-finz'] = nodeunit.testCase( rds_finz ) ;
genv['vpn'] = nodeunit.testCase( vpn_tcase ) ;
genv['vlan'] = nodeunit.testCase( vlan_tcase ) ;
*/












})(|GLOBAL|);



`


