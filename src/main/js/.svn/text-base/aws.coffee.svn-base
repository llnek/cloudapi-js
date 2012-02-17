###
file: comzotoh.aws.coffee
###

`

(function(genv) {
"use strict";
function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }
if ( !is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;

`

##SKIP_GEN_DOC##

class AWSCloudr extends ComZotoh.Net.Ajaxer #{

    constructor: (@target, @apiVersion, @cx) ->
        super()
        @cx.addListener(this)
        @set_nspace()

    ec2Arg: (action, params, handler, cbs) ->
        a= new ComZotoh.Net.AjaxArgs('GET', action, params, cbs)
        a.action_handler=handler
        a

    cfns: () -> [ @ute(), ComZotoh.DomAPI.getFCN, ComZotoh.DomAPI.getTag, ComZotoh.DomAPI ]

    cb_badrequest: (cbs) -> cbs?.error?({ code: 400, status: 'Bad Request' })
    cbok: (cbs) -> cbs?.success?({ code: 200, status: 'OK' })

    cb_result: (r, cbs) -> cbs?.success?({ result: r })
    cb_boolean: (b, cbs) -> @cb_result(b,cbs)
    cb_string: (s, cbs) -> @cb_result(s,cbs)

    cas: (cobj) ->
        if cobj?
            cobj.setProviderOwnerId( @cx.getAccountNumber())
            cobj.setProviderRegionId( @cx.getRegionId() )

    ctx : () -> @cx

    memoize_new_site: (oldsite, newsite) ->
        AWSCloudr.REDIRECT_SITEMAP[oldsite]=newsite

    has_redirect_site: (site) ->
        s=AWSCloudr.REDIRECT_SITEMAP[site]
        @ute().vstr(s)

    get_redirect_site: (site) ->
        AWSCloudr.REDIRECT_SITEMAP[site]

    getFriendlyAWSAccountID: (s) ->
        if s? and s.length is 12
            [ s.slice(0,4), s.slice(4,8), s.slice(8,12) ].join('-')
        else
            s

    testSDBDomainName: (s) -> @test_name(s, /[a-zA-Z0-9][a-z0-9_\.\-]*/)

    testS3BucketName: (bucket) ->
        ok=@test_name(bucket,/[a-z0-9][a-z0-9\.\-]*/)
        if ok
            c= bucket.charAt( bucket.length-1)
            if '-' is c then ok=false
        if ok
            if bucket.indexOf('.-') >= 0 or bucket.indexOf('-.') >= 0 then ok=false
        ok

    testS3ObjName: (s) -> @test_name(s, /[a-zA-Z0-9][a-zA-Z0-9_\.\-]*/)

    testSDBItemName: (s) -> @test_name(s, /[a-zA-Z0-9][a-zA-Z0-9_()\-]*/)

    testEC2Name: (s) -> @test_name(s, /[a-zA-Z][a-zA-Z0-9_\-\.]*/)

    testJSName: (s) -> @test_name(s, /[a-zA-Z][a-zA-Z0-9_]*/)

    test_name: (s, regex) ->
        ok=false
        if @ute().vstr(s)
            r= s.match(regex)
            if r? and r.length > 0 and s is r[0] then ok=true
        ok

    setRegion: (r) -> @setHost( @target + '.' + @getRegion() + '.amazonaws.com')

    getRegion: () -> @cx.getRegionId()

    getNSPResolver: () ->
        me=this
        (pfx) -> me.nspace[pfx] || null

    reset: () -> @cx.setAccessKeys('', '')

    getAPIVersion: () -> @apiVersion

    process_res_error: (type, errObj, res) ->
        switch type
            when 'json' then @prc_json_error(errObj, res)
            when 'xml' then @prc_xml_error(errObj,res)
            else @prc_text_error(errObj,res)

    prc_json_error: (errObj, data) -> false

    prc_xml_error: (errObj, data) -> false

    prc_text_error: (errObj, data) ->
        errObj.faultString= (data ? '').toString()
        true

    pre_format: (args, ver, mtd) ->
        ts= @format_date(new Date(), 'yyyy-MM-ddThh:mm:ssZ')
        sigValues = []
        sigValues.push( [ 'AWSAccessKeyId', @cx.getAccessPublic() ] )
        sigValues.push( [ 'Action', args.action ] )
        sigValues.push( [ 'SignatureVersion', ver ] )
        sigValues.push( [ 'SignatureMethod', mtd ] )
        sigValues.push( [ 'Version', @apiVersion ] )
        sigValues.push( [ 'Timestamp', ts ] )
        #params must be an array of tuples as for sigValues above
        len=args.params?.length || 0
        sigValues.push(args.params[n]) for n in [0...len]
        @sort_params(sigValues)
        sigValues

    sort_params: (arr) ->
        # sort the parameters by their lowercase name
        arr.sort( (x,y) ->
                if x[0] < y[0] then -1
                else if x[0] > y[0] then 1
                else 0
            )

    format_signature: (args) ->
        sigValues= @pre_format(args, '2', 'HmacSHA256')
        ii=sigValues.length
        sig=''
        for i in [0...ii]
            a= sigValues[i]
            a[0]= @ute().urlencode(a[0])
            a[1]= @aws_urlenc( a[1])
            if sig.length > 0 then sig += '&'
            sig += a[0]
            sig += '='
            sig += a[1]
        sig

    aws_urlenc: (c) ->
        @ute().urlencode(c).replace(/'/g, '%27').replace(/\(/g, '%28').replace(/\)/g, '%29').replace(/\*/g, '%2A')

    calc_uripart: (args) -> '/'

    # args: AjaxArgs
    format_url: ( args ) ->
        if not @ute().vstr(args.url)
            qstr= @format_signature(args)
            pfx = @get_url_prefix(args)
            verb= 'GET'
            sig=''
            site = @get_url_site(args)
            uri= @calc_uripart(args)
            s= [ verb , '\n' , site.toLowerCase() , '\n', uri, '\n', qstr ].join('')
            sig = @ute().urlencode( @b64_hmac(s, @cx.getAccessPrivate()))
            url = [ pfx , '://', site, uri, '?' , qstr , '&Signature=' , sig ].join('')
            url = @post_jiggle_url(args, url)
            args.url=url
            if @ute().isDbg()
                @ute().debug([  ['Params (' , qstr , ')'].join('') ,
                        ['StrSig (' , s , ')'].join('') ,
                        ['Sig (',  sig , ')'].join(''),
                        ['URL (', url , ')'].join('') ].join('\n') )
        r= @url_matcher(args.url)
        if r? and r.length is 4
            r = '/' + r[3]
        else
            r=''
        if @ute().isDbg() then @ute().debug('url-path:' + r)
        [ args.url, r, {} ]

    post_jiggle_url : (args, url) -> url

    format_date: (date, fmt) ->
        day = @pad_zero(date.getUTCDate())
        mth = @pad_zero(date.getUTCMonth()+1)
        yr_l = @pad_zero(date.getUTCFullYear())
        yr_s = @pad_zero(date.getUTCFullYear().toString().substring(3,4))
        yr = if fmt.indexOf('yyyy') > -1 then yr_l else yr_s
        hr = @pad_zero(date.getUTCHours())
        min = @pad_zero(date.getUTCMinutes())
        sec = @pad_zero(date.getUTCSeconds())
        ds = fmt.replace(/dd/g, day).replace(/MM/g, mth).replace(/y{1,4}/g, yr)
        ds.replace(/hh/g, hr).replace(/mm/g, min).replace(/ss/g, sec)

    pad_zero: (n) -> (if (n < 10) then '0' else '') + n

    set_nspace: () -> @nspace= { s:'http://schemas.xmlsoap.org/soap/envelope/' }

    pre_ajax: ( args, hdrs ) ->
        if 'GET' is args.verb or 'HEAD' is args.verb
            hdrs['If-Modified-Since'] = 'Tue, 15 Nov 1994 08:12:31 GMT'
        #hdrs['Cache-Control'] =  'no-cache'
        super(args, hdrs)

    on_boolean_reply: (data, root, cbs) ->
        [uu,fcn,gt, dom]= @cfns()
        top= dom.getNode(data, root)
        rc = fcn( gt( top, 'return')[0] )
        @cb_boolean('true' is rc, cbs)

AWSCloudr.REDIRECT_SITEMAP={}
#}


class AWSContext extends ComZotoh.CloudAPI.ProviderContext #{

    constructor: () ->
        super()
        @setProviderName('Amazon')
        @listeners=[]
        @setCloudName('AWS')

    setAccountNumber: (p) ->
        if p? then super(p.replace(/[^0-9]/g, ''))

    setRegionId: (r) ->
        super(r)
        ln.setRegion(r) for ln in @listeners

    setCustomProperties: (props) ->
        super(props)
        @setAccessKeys(props.accessKey, props.secretKey)
        @setAccountNumber(props.accountNumber)

    addListener: (ln) ->
        if ln? then @listeners.push(ln)

    get_url_prefix: (args) -> 'https'

    get_url_site: (args) ->
        if @ute().vstr(args.host) then args.host else @getHost()

#}

class CDNCloudr extends AWSCloudr #{

    constructor: (ctx) ->
        super 'cloudfront', '2010-11-01', ctx
        @ute().mapPut(@nspace, @target, 'http://cloudfront.amazonaws.com/doc/'+ @apiVersion + '/')

    setRegion: (r) ->
        @setHost( @target + '.amazonaws.com')

#}


class SDBCloudr extends AWSCloudr #{

    constructor: (ctx) ->
        super 'sdb', '2009-04-15', ctx
        @ute().mapPut(@nspace, @target, 'http://sdb.amazonaws.com/doc/'+ @apiVersion + '/')

    setRegion: (r) ->
        ind = if 'us-east-1' isnt r then '.' + @getRegion() else ''
        @setHost( @target + ind + '.amazonaws.com')

#}

class XXXCloudr extends AWSCloudr #{

    constructor: (t,v, ctx) ->
        super t, v, ctx

    prc_xml_error: (errObj, data) ->
        [uu,fcn,gt,dom]= @cfns()
        processed=false
        if data?
            top= gt(data, '/ErrorResponse/Error')[0]
            s= fcn( gt(top, 'Message')[0] )
            errObj.faultString = s || ''
            s= fcn( gt(top, 'Code')[0] )
            errObj.faultCode = s || ''
            processed=true
        processed

#}

class AutoScaleCloudr extends XXXCloudr #{

    constructor: (ctx) ->
        super 'autoscaling', '2011-01-01', ctx
        @ute().mapPut(@nspace, @target, 'http://autoscaling.amazonaws.com/doc/' + @apiVersion + '/' )

#}

class RDSCloudr extends XXXCloudr #{

    constructor: (ctx) ->
        super 'rds' , '2011-04-01', ctx
        @ute().mapPut(@nspace, @target, 'http://rds.amazonaws.com/doc/' + @apiVersion + '/' )

#}

class SNSCloudr extends XXXCloudr #{

    constructor: (ctx) ->
        super 'sns' , '2010-03-31', ctx
        @ute().mapPut(@nspace, @target, 'http://sns.amazonaws.com/doc/' + @apiVersion + '/' )

#}

class CWMCloudr extends XXXCloudr #{
    constructor: (ctx) ->
        super 'monitoring', '2010-08-01', ctx
        @ute().mapPut(@nspace, @target, 'http://monitoring.amazonaws.com/doc/' + @apiVersion + '/' )

    get_url_prefix: () -> 'http'

#}

class SQSCloudr extends XXXCloudr #{

    constructor: (ctx) ->
        super 'sqs' , '2011-10-01', ctx
        @ute().mapPut(@nspace, @target, 'http://sqs.amazonaws.com/doc/' + @apiVersion + '/' )

    calc_uripart: (args) ->
        rc= super(args)
        switch args.action
            when 'DeleteQueue', 'SendMessage', 'ReceiveMessage', 'SetQueueAttributes', 'GetQueueAttributes', 'DeleteMessage' then calc=true
            else calc=false
        if calc is true
            owner= @ctx().getAccountNumber()
            queue=args.tags['QueueName']
            rc=[ '/', owner, '/', queue, '/' ].join('')
        rc

#}

class EC2Cloudr extends AWSCloudr #{

    constructor: (ctx) ->
        super 'ec2', '2011-12-15', ctx
        @ute().mapPut(@nspace, @target, 'http://ec2.amazonaws.com/doc/' + @apiVersion + '/' )

    prc_xml_error: (errObj, data) ->
        [uu,fcn,gt,dom]= @cfns()
        processed=false
        if data?
            top= gt(data, '/Response/Errors/Error')[0]
            s= fcn( gt(top, 'Message')[0] )
            errObj.faultString = s || ''
            s= fcn( gt(top, 'Code')[0] )
            errObj.faultCode = s || ''
            processed=true
        processed

class ELBCloudr extends EC2Cloudr #{

    constructor: (ctx) ->
        super(ctx)
        @target='elasticloadbalancing'
        @apiVersion='2011-11-15'
        @ute().mapPut(@nspace, @target, 'http://elasticloadbalancing.amazonaws.com/doc/' + @apiVersion + '/' )

#}


class S3Cloudr extends XXXCloudr #{

    constructor: (ctx) ->
        super 's3' , '2006-03-01' , ctx
        @ute().mapPut(@nspace, @target, 'http://s3.amazonaws.com/doc/'+ @apiVersion + '/')

    ec2Arg: (action, params, handler, cbs) ->
        a= new ComZotoh.Net.AjaxArgs('GET', action, params, cbs)
        a.action_handler=handler
        a.content_type= if @ute().vstr( params.ctype) then params.ctype else ''
        if is_alive(params.body?.data)
            a.dataSize=params.body.size
            a.data=params.body.data
        if @ute().vstr(params.response_type) then a.response_type=params.response_type
        if @ute().vstr(params.verb) then a.verb=params.verb
        if is_obj(params.tags) then @ute().sclone(params.tags, a.tags)
        a

    prc_xml_error: (errObj, data) ->
        [uu,fcn,gt,dom]= @cfns()
        processed=false
        if data?
            top= gt(data, '/Error')[0]
            s1= fcn( gt(top, 'Message')[0] )
            errObj.faultString = s1 || ''
            s2= fcn( gt(top, 'Code')[0] )
            errObj.faultCode = s2 || ''
            processed= uu.vstr(s1) and uu.vstr(s2)
        processed

    setRegion: (r) ->
        ind = if 'us-east-1' isnt r then '.' + @getRegion() else ''
        @setHost( @target + ind + '.amazonaws.com')

    format_signature: (args) ->
        now = new Date().toUTCString()
        subres= args.tags.subres
        xhdrs= args.tags.xhdrs
        [uu,fcn,gt,dom]= @cfns()
        b64=uu.b64()
        ctype= if uu.vstr(args.content_type) then args.content_type else ''

        [ sres, sresStr ] = @do_calc_resource_element(subres)
        [ xamz, xamzStr ] = @do_calc_amz_element(xhdrs)

        switch args.action
            when 'GET Service', 'PUT Bucket'
                [site, path,sig] = @do_xxx_bucket_yyy(args,ctype, now, xamzStr, sresStr)
            when 'GET Bucket location', 'DELETE Bucket'
                [site, path,sig] = @do_aaa_bucket_bbb(args,ctype, now, xamzStr, sresStr)
            when 'GET Bucket location', 'GET Bucket acl', 'GET Object ACL', 'PUT Bucket acl', 'PUT Object acl', 'DELETE Bucket'
                [site, path,sig] = @do_acl_xxx(args,ctype, now, xamzStr, sresStr)
            when 'Head Object'
                [site, path,sig] = @do_peek_item(args,ctype, now, xamzStr, sresStr)
            else
                [site, path,sig] = @do_aaa_bucket_bbb(args,ctype, now, xamzStr, sresStr)

        sig= b64.utf8_encode(sig)
        auth=['AWS ',@cx.getAccessPublic(),':',@b64_hmac(sig, @cx.getAccessPrivate(),'sha1') ].join('')
        [site, path, now, sig, auth, xamz ]

    do_peek_item: (args,ctype, now, xamzStr, sresStr) ->
        [uu,fcn,gt,dom]= @cfns()
        bucket= args.tags.bucket
        file= args.tags.object
        path= '/' + file
        cre= '/' + file
        sig= [ args.verb , '', '', now, '' ].join('\n') + xamzStr + cre
        site= bucket + '.' + @get_url_site(args)
        if @has_redirect_site(site) then site = @get_redirect_site(site)
        [ site, path, sig ]

    do_aaa_bucket_bbb: (args,ctype,now,xamzStr,sresStr) ->
        [uu,fcn,gt,dom]= @cfns()
        bucket= args.tags.bucket
        file= args.tags.object
        qrs= args.tags.query
        path='/'
        cre='/'

        if uu.vstr(file)
            cre += bucket + '/' +  file
            path += file
        else
            cre += bucket + '/'

        path += sresStr
        cre += sresStr

        qs=''
        if is_obj(qrs)
            for own k,v of qrs
                if qs.length > 0 then qs += '&'
                qs += @ute().urlencode(k) + '=' + @ute().urlencode(v)
            if qs.length > 0
                qs = (if path.indexOf('?') >= 0 then '&' else '?') + qs
        if qs.length > 0 then path += qs

        sig= [ args.verb , '', ctype, now, '' ].join('\n') + xamzStr + cre
        site= bucket + '.' + @get_url_site(args)
        if @has_redirect_site(site) then site = @get_redirect_site(site)

        [ site, path, sig ]

    format_url: ( args ) ->
        [site, path, now, sig,auth, amzs ]= @format_signature(args)
        pfx = @get_url_prefix(args)

        if not @ute().vstr(args.url)
            url= [pfx, '://', site, path ].join('')
            args.url=url

        if @ute().isDbg()
            @ute().debug( [ sig,['Auth(',  auth , ')'].join(''), ['URL(', url ,')'].join('') ].join('\n') )

        r= @url_matcher(args.url)
        hdrs={}
        if r? and r.length is 4
            r = '/' + r[3]
        else
            r=''

        if @ute().isDbg() then @ute().debug('content-type:' + args.content_type)
        if @ute().isDbg() then @ute().debug('url-path:' + r)
        if @ute().vstr(args.content_type) then hdrs['content-type']= args.content_type

        hdrs['Authorization'] = auth
        hdrs['Host']= site
        hdrs['Date']= now

        nn=amzs.length
        hdrs[ amzs[n][0] ] = amzs[n][1] for n in [0...nn]

        [ args.url, r, hdrs]

    do_calc_resource_element: (subres) ->
        [uu,fcn,gt,dom]= @cfns()
        sres=''
        aa=[]
        if subres?
            aa.push([ k, v]) for own k,v of subres
        @sort_params(aa)
        nn=aa.length
        for n in [0...nn]
            if sres.length > 0 then sres += '&'
            sres += aa[n][0].replace(/\?/g, '')
            if uu.vstr(aa[n][1]) then sres += '='+aa[n][1]
        if sres.length > 0 then sres = '?' + sres
        [aa, sres]

    do_calc_amz_element: (xhdrs) ->
        [uu,fcn,gt,dom]= @cfns()
        amzs=[]
        xamz=''
        if xhdrs?
            for own k,v of xhdrs
                if k.indexOf('x-amz-') is 0 then amzs.push( [ k, v ])
        @sort_params(amzs)
        nn=amzs.length
        for n in [0...nn]
            if xamz.length > 0 then xamz += '\n'
            xamz += amzs[n][0] + ':' + amzs[n][1]
        if xamz.length > 0 then xamz += '\n'
        [ amzs, xamz ]

    do_acl_xxx: (args,ctype, now, xamzStr, sresStr) ->
        [uu,fcn,gt,dom]= @cfns()
        bucket= args.tags.bucket
        file= args.tags.object
        site= bucket+'.'+ @get_url_site(args)
        if @has_redirect_site(site) then site = @get_redirect_site(site)
        if uu.vstr(file)
            c= '/'+bucket+ '/' + file + sresStr
            path= '/'+ file + sresStr
        else
            c= '/'+bucket+ '/'+sresStr
            path= '/'+ sresStr

        sig = [ args.verb, '', ctype, now, '' ].join('\n') + xamzStr + c
        [ site, path,sig]

    do_xxx_bucket_yyy: (args, ctype, now, xamzStr, sresStr) ->
        [uu,fcn,gt,dom]= @cfns()
        if uu.vstr(args.tags.bucket) 
            c= '/' + args.tags.bucket + sresStr
        else
            c= '/' + sresStr
        sig = [ args.verb, '', ctype, now, '' ].join('\n') + xamzStr + c
        path= c
        site=@get_url_site(args)
        if @has_redirect_site(site) then site = @get_redirect_site(site)
        [ site, path,sig]

#}

##SKIP_GEN_DOC##

class AmazonAWS extends ComZotoh.CloudAPI.CloudProvider #{
    ### Amazon AWS cloud provider ###

    constructor: (props) ->
        ###
        constructs a new AWS Provider</br>
        **props**: object - properties to initialize this provider
        ###
        super( new AWSContext() )
        @ctx.setCustomProperties(props)
        @iniz()

##SKIP_GEN_DOC##

    iniz: () ->
        @scaler=new AutoScaleCloudr(@ctx)
        @sdb=new SDBCloudr(@ctx)
        @ec2=new EC2Cloudr(@ctx)
        @elb=new ELBCloudr(@ctx)
        @sns=new SNSCloudr(@ctx)
        @sqs=new SQSCloudr(@ctx)
        @rds=new RDSCloudr(@ctx)
        @s3=new S3Cloudr(@ctx)
        @cwm=new CWMCloudr(@ctx)
        @admSvcs=new ComZotoh.CloudAPI.Admin.AdminServices(@ec2)
        @idSvcs=new ComZotoh.CloudAPI.Identity.IdentityServices(@ec2)
        @netSvcs=new ComZotoh.CloudAPI.Network.NetworkServices(@ec2, @elb)
        @dcSvcs=new ComZotoh.CloudAPI.Dc.DataCenterServices(@ec2)
        @cmpSvcs=new ComZotoh.CloudAPI.Compute.ComputeServices(@ec2, @scaler,@cwm)
        @plfSvcs=new ComZotoh.CloudAPI.Platform.PlatformServices(@ec2, @sdb, @sns, @sqs, @rds)
        @stoSvcs=new ComZotoh.CloudAPI.Storage.StorageServices(@s3)

##SKIP_GEN_DOC##

#}








`

if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
//ComZotoh.CloudAPI.AWSContext=AWSContext;
ComZotoh.CloudAPI.AmazonAWS=AmazonAWS;


})(|GLOBAL|);




`


