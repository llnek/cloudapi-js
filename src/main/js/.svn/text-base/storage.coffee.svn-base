###
file: comzotoh.cloudapi.storage.coffee
###

`
(function(genv) {
"use strict";

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }

if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;

var S3_PUBLIC_URI= 'http://acs.amazonaws.com/groups/global/AllUsers'
var S3_FULLCTRL='FULL_CONTROL'
var S3_WRITE='WRITE'
var S3_READ='READ'
var XMLP= '<?xml version="1.0" encoding="UTF-8"?>';

`

class CloudStoreDirectory extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores cloud storage directory information ###

    constructor: (name) -> super(name)

    getOwnerName: () -> @ownerName

    setOwnerName: (n) -> @ownerName = n ? ''

#}


class CloudStoreItem extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores cloud storage item information ###

    constructor: (name) -> super(name)

    setSizeInBytes: (n) -> if n? and not isNaN(n) then @sizeBytes = n

    getSizeInBytes: () -> @sizeBytes

    setDirectory: (n) -> @dir = n ? ''

    getDirectory: () -> @dir

    setLastModified: (ts) -> if ts? then @lastMod= ts

    getLastModified: () -> @lastMod

#}

class StorageServices #{
    ### ComZotoh.CloudAPI.Storage.StorageServices interface ###

    constructor: (@s3) ->
        ### internal ###
        @bss= new ComZotoh.CloudAPI.Storage.BlobStoreSupport(@s3)

    getBlobStoreSupport: () -> @bss

    hasBlobStoreSupport: () -> is_alive(bss)

#}

class BlobStoreSupport extends ComZotoh.CloudAPI.Storage.BlobSupportDOM #{
    ### ComZotoh.CloudAPI.Storage.BlobStoreSupport interface ###

    constructor: (s3) ->
        ### internal ###
        super(s3)

    clear: (dirName, cbs) ->
        ###
        Remove all items in this directory.</br>
        NOT YET IMPLEMENTED.</br>
        **returns**: boolean - JSON-Object#result</br>
        **dirName**: string</br>
        **cbs**: AjaxCBS</br>
        ###


    existsDirectory: (dirName, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **dirName**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p={ tags: { bucket: dirName, subres:{ '?location':'' } }}
        me=this
        h=(data)-> me.on_test_dir(data,cbs)
        @awscall('GET Bucket location', p, h, cbs)

    existsFile: (dirName, fileName, cbs) ->
        ###
        **returns**: boolean - JSON-Object:#result</br>
        **dirName**: string</br>
        **fileName**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p={ verb: 'HEAD', tags: { bucket: dirName, object: fileName }}
        me=this
        h=(data)-> me.aws.cb_boolean(true,cbs)
        @awscall('HEAD Object (Exists?)', p, h, cbs)

    isDirectoryPublic: (dirName, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **dirName**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        old=cbs?.success
        me=this
        if cbs?
            cbs.success = (acl)-> me.check_xxx_acl(acl,old,cbs)
        @getDirectoryACL(dirName, cbs)

    isFilePublic: (dirName, fileName, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **dirName**: string</br>
        **fileName**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        old=cbs?.success
        me=this
        if cbs?
            cbs.success = (acl)-> me.check_xxx_acl(acl,old,cbs)
        @getFileACL(dirName, fileName, cbs)

    createDirectory: (name, region, acl, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **region**: string or null</br>
        **acl**: object - optional parameters.</br>
        **cbs**: AjaxCBS</br>
        ###
        # EU | us-west-1 | us-west-2 | ap-southeast-1 | ap-northeast-1 | sa-east-1 | empty string (for the US Classic Region )
        p={ verb: 'PUT', ctype: 'text/plain; charset=utf-8' , body: {} , tags: { bucket: name, xhdrs: {} } }
        [uu,fcn,gt,dom]=@aws.cfns()
        if acl? then uu.sclone(acl, p.tags.xhdrs)
        if uu.vstr(region) and 'us-east-1' isnt region
            s= [ '<CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/', @aws.apiVersion, '/">',
                '<LocationConstraint>', region, '</LocationConstraint>', '</CreateBucketConfiguration>' ].join('')
            p.body.data= s
            p.body.size= s.length
        me=this
        h=(data)-> me.aws.cb_boolean(true,cbs);
        @awscall('PUT Bucket', p, h, cbs)

    listDirectories: (cbs) ->
        ###
        **returns**: [ string, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h=(data)-> cbs?.success?( me.munch_alldirs(data) )
        @awscall('GET Service', {}, h, cbs)

    listFiles: (cursor, dirName, params, cbs) ->
        ###
        **returns**: [ string, ... ] , cursor</br>
        **cursor**: string or null</br>
        **dirName**: string</br>
        **params**: object - optional paramters.</br>
        **cbs**: AjaxCBS</br>
        ###
        [uu,fcn,gt,dom]= @aws.cfns()
        p= { tags: { bucket: dirName, query: {} } }
        uu.sclone(params, p.tags.query)
        if uu.vstr(cursor) then p.tags.query['marker']=cursor
        me=this
        h=(data) ->
            [rc, pfxs, ntk ] = me.on_list_files(data)
            cbs?.success?( rc, pfxs, ntk )
        @awscall('GET Bucket (List Objects)', p, h, cbs)

    download: (dirName, fileName, cbs) ->
        ###
        **returns**:</br>
        **dirName**: string</br>
        **fileName**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= { response_type: 'raw' , tags: { bucket: dirName, object: fileName } }
        me=this
        h=(data) -> cbs?.success?(data)
        @awscall('GET Object', p, h, cbs)

    hasSupport: () -> true

    getMaxFileSizeInMBytes: () -> 5 * 1024 * 1024

    getProviderTermForDirectory: (locale) -> 'Bucket'

    getProviderTermForFile: (locale) -> 'Object'

    makeDirectoryPublic: (dirName, readable, writable, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **dirName**: string</br>
        **readable**: boolean</br>
        **writable**: boolean</br>
        **cbs**: AjaxCBS</br>
        ###
        old=cbs?.success
        me=this
        perms={ read: readable, write: writable }
        if cbs?
            cbs.success = (policy) -> me.make_dir_pub(policy,dirName, perms, old,cbs)
        @getDirectoryACL(dirName,cbs)

    makeFilePublic: (dirName, fileName, readable, writable, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **dirName**: string</br>
        **fileName**: string</br>
        **readable**: boolean</br>
        **writable**: boolean</br>
        **cbs**: AjaxCBS</br>
        ###
        old=cbs?.success
        me=this
        perms={ read: readable, write: writable }
        if cbs?
            cbs.success = (policy) -> me.make_file_pub(policy,dirName, fileName, perms, old,cbs)
        @getFileACL(dirName,fileName,cbs)

    moveFile: (srcDir, srcFile, desDir, params, cbs) ->
        ###
        NOT YET IMPLEMENTED.</br>
        **returns**: boolean - JSON-Object#result</br>
        **srcDir**: string</br>
        **srcFile**: string</br>
        **desDir**: string</br>
        **params**: object - optional parameters.</br>
        **cbs**: AjaxCBS</br>
        ###
        if srcDir is desDir
            @aws.cb_boolean(true, cbs)
            return
        [uu,fcn,gt,dom]=@aws.cfns()
        b64=uu.b64()
        p={ verb: 'PUT', tags: { bucket: desDir, object: srcFile, xhdrs: {} } }
        amz= '/' + uu.urlencode(srcDir) + '/' + uu.urlencode(srcFile)
        if uu.vstr(params?.versionId) then amz += '?versionId='+ uu.urlencode(params.versionId)


        p.tags.xhdrs['x-amz-copy-source-if-modified-since']= 'Tue, 15 Nov 1994 08:12:31 GMT'
        p.tags.xhdrs[ 'x-amz-acl' ] = 'bucket-owner-full-control'
        p.tags.xhdrs[ 'x-amz-copy-source' ] = amz

        me=this
        h=(data) ->
            top=dom.getNode(data,'/CopyObjectResult')
            me.aws.cb_boolean(is_alive(top),cbs)
        @awscall('PUT Object - Copy', p, h, cbs)

    getFileACL: (dirName, fileName, cbs) ->
        ###
        **returns**:</br>
        **dirName**: string</br>
        **fileName**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p={ tags: { bucket: dirName, object: fileName, subres: { '?acl': '' } } }
        me=this
        h=(data) -> cbs?.success?(data)
        @awscall('GET Object ACL', p, h, cbs)

    getDirectoryACL: (dirName, cbs) ->
        ###
        **returns**:</br>
        **dirName**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p={ tags: { bucket: dirName, subres: { '?acl': '' } } }
        me=this
        h=(data) -> cbs?.success?(data)
        @awscall('GET Bucket acl', p, h, cbs)

    removeDirectory: (dirName, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **dirName**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p={ verb: 'DELETE', tags: { bucket: dirName } }
        me=this
        h=(data) -> me.aws.cb_boolean(true, cbs)
        @awscall('DELETE Bucket', p, h, cbs)

    removeFile: (dirName, fileName, params, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **dirName**: string</br>
        **fileName**: string</br>
        **params**: object - optional parameters.</br>
        **cbs**: AjaxCBS</br>
        ###
        p={ verb: 'DELETE' , tags: { bucket: dirName, object: fileName} }
        [uu,fcn,gt,dom]=@aws.cfns()
        if params?
            s=params.versionId
            if uu.vstr(s) then p.subres={ '?versionId' : s}
            if params.mfa?
                s= params.mfa.serialNum + ' ' + params.mfa.authCode
                p.xhdrs= { 'x-amz-mfa': s }
        me=this
        h=(data) -> me.aws.cb_boolean(true,cbs)
        @awscall('DELETE Object', p, h, cbs)

    upload: (dirName, fileName, contentType, blob, params, isMultipart, cursor, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **dirName**: string</br>
        **fileName**: string</br>
        **contentType**: string</br>
        **blob**:</br>
        **params**: object - optional params.</br>
        **isMultipart**: boolean</br>
        **cursor**: string or null</br>
        **cbs**: AjaxCBS</br>
        ###
        [uu,fcn,gt,dom]=@aws.cfns()
        p={ verb: 'PUT',ctype: contentType, tags: {}, body: {} }
        uu.sclone(params,p.tags)
        uu.sclone(blob,p.body)
        p.tags.bucket= dirName
        p.tags.object= fileName
        p.tags.multipart= isMultipart
        p.tags.uploadid= cursor
        me=this
        h=(data)-> me.aws.cb_boolean(true,cbs)
        @awscall('PUT Object', p, h, cbs)

##SKIP_GEN_DOC##
    renameDirectory: (dirName, newName, cbs) ->
    renameFile: (dirName, fileName, newName, cbs) ->

    make_file_pub: (policy, dirName, fileName, perms, old,cbs) ->
        @set_xxx_public(policy,perms)
        [uu,fcn,gt,dom]=@aws.cfns()
        s= XMLP + dom.toXml( policy)
        cbs?.success = old
        p={ verb: 'PUT', ctype:'text/xml', body: { data: s, size: s.length }, tags: { object: fileName, bucket: dirName , subres: { '?acl': ''} } }
        me=this
        h=(data)-> me.aws.cb_boolean(true,cbs)
        @awscall('PUT Object acl', p, h, cbs)

    make_dir_pub: (policy, dirName, perms, old,cbs) ->
        @set_xxx_public(policy,perms)
        [uu,fcn,gt,dom]=@aws.cfns()
        s= XMLP + dom.toXml( policy)
        cbs?.success = old
        p={ verb: 'PUT', ctype:'text/xml', body: { data: s, size: s.length }, tags: { bucket: dirName , subres: { '?acl': ''} } }
        me=this
        h=(data)-> me.aws.cb_boolean(true,cbs)
        @awscall('PUT Bucket acl', p, h, cbs)

    set_xxx_public: (poc, perm) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        acl= gt(poc, '/AccessControlPolicy/AccessControlList')[0]
        [pub,others] = @break_acl(acl)
        if perm.write then @new_acl(pub,S3_WRITE) else @clr_acl(pub,S3_WRITE)
        if perm.read then @new_acl(pub,S3_READ) else @clr_acl(pub,S3_READ)
        @patch_acl(acl,others,pub)

    check_xxx_acl: (policy,old,cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items= gt(policy, '/AccessControlPolicy/AccessControlList/Grant')
        ii=items.length
        rc=false
        for i in [0...ii]
            g=gt(items[i], 'Grantee')[0]
            u=if g? then dom.ffcn(g, 'URI') else ''
            if S3_PUBLIC_URI is u
                rc=true
                break
        cbs?.success=old
        @aws.cb_boolean(rc,cbs)

    on_test_dir: (data,cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        top= gt(data, '/LocationConstraint')[0]
        loc= if top? then fcn(top) else null
        @aws.cb_boolean(is_alive(top), cbs)

    on_list_files: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        top= gt(data, '/ListBucketResult')[0]
        dir= dom.ffcn(top, 'Name')
        dom.ffcn(top, 'Prefix')
        dom.ffcn(top, 'Marker')
        dom.ffcn(top, 'MaxKeys')
        dom.ffcn(top, 'Delimiter')
        dom.ffcn(top, 'IsTruncated')
        ntk= fcn(top, 'NextMarker')
        cpx= gt(data, 'CommonPrefixes')
        rc=[]
        ps=[]
        nn=cpx?.length || 0
        for n in [0...nn]
            ps.push( dom.ffcn(cpx[n], 'Prefix'))
        cts= gt(data, 'Contents')
        nn=cts?.length || 0
        for n in [0...nn]
            a= new ComZotoh.CloudAPI.Storage.CloudStoreItem()
            a.setDirectory(dir)
            x=uu.setISO8601(new Date(), dom.ffcn(cts[n], 'LastModified') )
            a.setLastModified(x)
            a.setName( dom.ffcn(cts[n], 'Key'))
            a.addTag( 'ETag', dom.ffcn(cts[n], 'ETag'))
            a.setSizeInBytes( Number( dom.ffcn(cts[n], 'Size')))
            a.addTag( 'StorageClass', dom.ffcn(cts[n], 'StorageClass'))
            owner=gt(cts[n], 'Owner')[0]
            if owner?
                dom.ffcn(owner, 'DisplayName')
                a.setProviderOwnerId( dom.ffcn( owner, 'ID'))
            rc.push(a)
        [rc, ps, ntk]

    munch_alldirs: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        owner=gt(data,'/ListAllMyBucketsResult/Owner')[0]
        disp=dom.ffcn(owner, 'DisplayName')
        oid= dom.ffcn(owner, 'ID')
        items=gt(data,'/ListAllMyBucketsResult/Buckets/Bucket')
        ii=items.length
        rc=[]
        for i in [0...ii]
            nm=dom.ffcn( items[i], 'Name')
            a= new ComZotoh.CloudAPI.Storage.CloudStoreDirectory(nm)
            a.setProviderOwnerId(oid)
            a.setOwnerName(disp)
            x=uu.setISO8601(new Date(), dom.ffcn(items[i], 'CreationDate') )
            a.setCreationTimestamp(x)
            rc.push(a)
        rc

    new_acl: (pub, perm ) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        if not is_alive(pub[perm])
            em2=dom.newElement('URI', {}, [ dom.newText(S3_PUBLIC_URI) ] )
            cs2=[ em2 ]
            em1=dom.newElement('Grantee', {'xmlns:xsi':'http://www.w3.org/2001/XMLSchema-instance', 'xsi:type' : 'Group'}, cs2)
            em3=dom.newElement('Permission', {}, [dom.newText(perm) ])
            cs0=[ em1, em3 ]
            em0=dom.newElement('Grant', {}, cs0)
            pub[perm]=em0

    clr_acl: (pub, perm) -> pub[perm]= null

##SKIP_GEN_DOC##

#}



`


if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
if (!is_alive(ComZotoh.CloudAPI.Storage)) { ComZotoh.CloudAPI.Storage={}; }
ComZotoh.CloudAPI.Storage.CloudStoreDirectory=CloudStoreDirectory;
ComZotoh.CloudAPI.Storage.CloudStoreItem=CloudStoreItem;
ComZotoh.CloudAPI.Storage.StorageServices=StorageServices;
ComZotoh.CloudAPI.Storage.BlobStoreSupport=BlobStoreSupport;


})(|GLOBAL|);



`


