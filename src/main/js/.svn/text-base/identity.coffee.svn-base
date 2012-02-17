###
file: comzotoh.cloudapi.identity.coffee
###

`
(function(genv) {
"use strict";

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }

if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;


`

class ShellKeySupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Identity.ShellKeySupport interface ###

    constructor: (ec2) ->
        ### internal ###
        super(ec2)

    list: (cbs) ->
        ###
        **returns**: [JSON-Object, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h= (data) -> cbs?.success?( me.munch_xml(data))
        @awscall( 'DescribeKeyPairs', [], h, cbs)

    createKeypair: (name, cbs) ->
        ###
        **returns**: JSON-Object</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['KeyName', name] ]
        me=this
        h=(data) -> me.on_create(data,cbs)
        @awscall('CreateKeyPair', p, h, cbs)

    deleteKeypair: (name, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['KeyName', name] ]
        me=this
        h=(data) -> me.aws.on_boolean_reply(data,'/DeleteKeyPairResponse',cbs)
        @awscall('DeleteKeyPair', p, h, cbs)

    getFingerprint: (name, cbs) ->
        ###
        **returns**: string - JSON-Object#result</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['KeyName', name] ]
        me=this
        h= (data) ->
            rc=me.aws.ute().getFirst(me.munch_xml(data))
            rc=if rc? then rc.keyFingerprint else ''
            me.aws.cb_string(rc, cbs)
        @awscall('DescribeKeyPairs', p, h, cbs)

    getProviderTermForKeypair: (locale) -> 'Keypair'

##SKIP_GEN_DOC##

    on_create: (data,cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        top= uu.getNode(data, '/CreateKeyPairResponse')
        km = dom.ffcn(top,'keyMaterial')
        fp = dom.ffcn(top,'keyFingerprint')
        kn = dom.ffcn(top,'keyName')
        cbs?.success?( { keyName: kn, keyFingerprint: fp, keyMaterial: km } )

    munch_xml: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data, '/DescribeKeyPairsResponse/keySet/item')
        len= items.length
        lst=[]
        for i in [0...len]
            fp = dom.ffcn(items[i], 'keyFingerprint')
            name = dom.ffcn( items[i], 'keyName')
            lst.push( { keyName: name, keyFingerprint: fp } )
        lst

##SKIP_GEN_DOC##

#}

class IdentityServices #{
    ### ComZotoh.CloudAPI.Identity.IdentityServices interface ###

    constructor: (@ec2) ->
        ### internal ###
        @key=new ComZotoh.CloudAPI.Identity.ShellKeySupport(@ec2)

    getShellKeySupport: () -> @key

    hasShellKeySupport: () -> is_alive(@key)

#}



`


if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
if (!is_alive(ComZotoh.CloudAPI.Identity)) { ComZotoh.CloudAPI.Identity={}; }
ComZotoh.CloudAPI.Identity.ShellKeySupport=ShellKeySupport;
ComZotoh.CloudAPI.Identity.IdentityServices=IdentityServices;


})(|GLOBAL|);



`


