###
file: comzotoh.cloudapi.admin.coffee
###

`

(function(genv) {
"use strict";

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }

if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;

`

class AdminServices #{
    ### ComZotoh.CloudAPI.Admin.AdminServices interface ###

    constructor: (@ec2) ->
        ### internal ###
        @pps= new ComZotoh.CloudAPI.Admin.PrepaymentSupport(@ec2)

    getPrepaymentSupport: () -> @pps

    hasPrepaymentSupport: () -> is_alive(@pps)

#}

class Prepayment extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Prepayment information ###

    constructor: (@ppId) -> super()

    getSize: () -> @iType

    setSize: (t) -> @iType = t ? ''

    getCurrencyCode: () -> @currency

    getDataCenterId: () -> @zone

    getFixedFee: () -> @fixedFee

    getPeriodInDays: () -> @duration

    getPlatform: () -> @platform

    getSoftware: () -> @software

    getUsageFee: () -> @usageFee

    setCurrencyCode: (c) -> @currency = c ? ''

    setDataCenterId: (z) -> @zone = z ? ''

    setFixedFee: (f) -> if f? and not isNaN(f) then @fixedFee= f

    setPeriodInDays: (d) -> if d? and not isNaN(d) then @duration= d

    setPlatform: (p1) -> if p1? then @platform= p1

    setSoftware: (s) -> @software = s ? ''

    setUsageFee: (f) -> if f? and not isNaN(f) then @usageFee = f

    getCount: () -> @count

    getPeriodStartTimestamp: () -> @tstamp

    getProviderPrepaymentId: () -> @ppId

    setCount: (c) -> if c? and not isNaN(c) then @count = c

    setPeriodStartTimestamp: (ts) -> if ts? then @tstamp= ts

    setPrepaymentId: (id) -> @ppId = id ? ''

#}

class PrepaymentSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Admin.PrepaymentSupport interface ###

    constructor: (ec2) -> 
        ### internal ###
        super(ec2)

    getOffering: (offId, cbs) ->
        ###
        **returns**: Offering</br>
        **offId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [['ReservedInstancesOfferingId.1', offId]]
        me=this
        h= (data) -> cbs?.success?( me.aws.ute().getFirst( me.munch_ofs(data)) )
        @awscall('DescribeReservedInstancesOfferings', p, h, cbs)

    getPrepayment: (ppId, cbs) ->
        ###
        **returns**: Prepayment</br>
        **ppId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [['ReservedInstancesId.1', ppId]]
        me=this
        h= (data) -> cbs?.success?( me.aws.ute().getFirst( me.munch_pps(data)) )
        @awscall( 'DescribeReservedInstances', p, h, cbs)

    getProviderTermForOffering: (locale) -> 'Reserved Instances'

    getProviderTermForPrepayment: (locale) -> 'Reserved Instances'

    listOfferings: (cbs) ->
        ###
        **returns**: [ Offering, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h= (data) -> cbs?.success?( me.munch_ofs(data))
        @awscall( 'DescribeReservedInstancesOfferings', [], h, cbs)

    listPrepayments: (cbs) ->
        ###
        **returns**: [ Prepayment, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h= (data) -> cbs?.success?( me.munch_pps(data))
        @awscall( 'DescribeReservedInstances', [], h, cbs)

    prepay: (offerId, instanceCount, cbs) ->
        ###
        **returns**: Prepayment</br>
        **offerId**: string</br>
        **instanceCount**: int</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['ReservedInstancesOfferingId', offerId] ]
        if instanceCount? and not isNaN(instanceCount)
            p.push(['InstanceCount', instanceCount])
        me=this
        h= (data) -> me.on_prepay(data,cbs)
        @awscall( 'PurchaseReservedInstancesOffering', p, h, cbs)

##SKIP_GEN_DOC##

    on_prepay: (data, cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        top= dom.getNode(data, '/PurchaseReservedInstancesOfferingResponse')
        id= dom.ffcn( top, 'reservedInstancesId' )
        a= new ComZotoh.CloudAPI.Admin.Prepayment(id)
        @aws.cas(a)
        cbs?.success?(a)

    munch_pps: (data) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        items= gt(data, '/DescribeReservedInstances/reservedInstancesSet/item')
        ii=items.length
        rc=[]
        for i in [0...ii]
            id= dom.ffcn( items[i], 'reservedInstancesId')
            a= new ComZotoh.CloudAPI.Admin.Prepayment(id)
            @aws.cas(a)
            a.setCurrentState( dom.ffcn( items[i], 'state') )
            a.setSize( dom.ffcn( items[i], 'instanceType') )
            a.setDataCenterId( dom.ffcn( items[i], 'availabilityZone') )
            num= dom.ffcn( items[i], 'duration')
            a.setPeriodInDays( Number(num) / 86400 )
            num= dom.ffcn( items[i], 'fixedPrice')
            a.setFixedFee( Number(num))
            num= dom.ffcn( items[i], 'usagePrice')
            a.setUsageFee( Number(num))
            num= dom.ffcn( items[i], 'instanceCount')
            a.setCount(Number(num))
            desc= dom.ffcn( items[i], 'productDescription')
            a.setDescription(desc)
            if (desc ? '').toLowerCase().indexOf('windows') >= 0
                a.setPlatform( ComZotoh.CloudAPI.Compute.Platform.WINDOWS)
            else
                a.setPlatform( ComZotoh.CloudAPI.Compute.Platform.LINUX)
            rc.push(a)
        rc

    munch_ofs: (data) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        items= gt(data, '/DescribeReservedInstancesOfferings/reservedInstancesOfferingsSet/item')
        ii=items.length
        rc=[]
        for i in [0...ii]
            id= dom.ffcn( items[i], 'reservedInstancesOfferingId')
            a= new ComZotoh.CloudAPI.Admin.Offering(id)
            @aws.cas(a)
            a.setSize( dom.ffcn( items[i], 'instanceType') )
            a.setDataCenterId( dom.ffcn( items[i], 'availabilityZone') )
            num= dom.ffcn( items[i], 'duration')
            a.setPeriodInDays( Number(num) / 86400 )
            num= dom.ffcn( items[i], 'fixedPrice')
            a.setFixedFee( Number(num))
            num= dom.ffcn( items[i], 'usagePrice')
            a.setUsageFee( Number(num))
            a.addTag('instanceTenancy', dom.ffcn( items[i], 'instanceTenancy') )
            a.setCurrencyCode( dom.ffcn( items[i], 'currencyCode') )
            a.addTag('offeringType',dom.ffcn( items[i], 'offeringType') )
            desc= dom.ffcn( items[i], 'productDescription')
            a.setDescription(desc)
            if (desc ? '').toLowerCase().indexOf('windows') >= 0
                a.setPlatform( ComZotoh.CloudAPI.Compute.Platform.WINDOWS)
            else
                a.setPlatform( ComZotoh.CloudAPI.Compute.Platform.LINUX)
            rc.push(a)
        rc

##SKIP_GEN_DOC##




#}

class Offering extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Offering information ###

    constructor: (@offerId) -> super()

    getSize: () -> @vmSize

    setSize: (z) -> @vmSize= z ? ''

    getCurrencyCode: () -> @currency

    getDataCenterId: () -> @zone

    getFixedFee: () -> @fixedFee

    getProviderOfferingId: () -> @offerId

    getPeriodInDays: () -> @duration

    getPlatform: () -> @platform

    getSoftware: () -> @software

    getUsageFee: () -> @usageFee

    setCurrencyCode: (s) -> @currency = s ? ''

    setDataCenterId: (z) -> @zone = z ? ''

    setFixedFee: (f) -> if f? and not isNaN(f) then @fixedFee= f

    setOfferingId: (id) -> @offerId = id ? ''

    setPeriodInDays: (n) -> if n? and not isNaN(n) then @duration=n

    setPlatform: (p1) -> if p1? then @platform = p1

    setSoftware: (s) -> @software = s ? ''

    setUsageFee: (f) -> if f? and not isNaN(f) then @usageFee= f

#}


`


if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
if (!is_alive( ComZotoh.CloudAPI.Admin)) { ComZotoh.CloudAPI.Admin={}; }
ComZotoh.CloudAPI.Admin.AdminServices=AdminServices;
ComZotoh.CloudAPI.Admin.Prepayment=Prepayment;
ComZotoh.CloudAPI.Admin.PrepaymentSupport=PrepaymentSupport;
ComZotoh.CloudAPI.Admin.Offering=Offering;


})(|GLOBAL|);



`


