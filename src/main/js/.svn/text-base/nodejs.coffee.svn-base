###
file: comzotoh.node.coffee
###

`(function(genv) {
"use strict";
function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }

if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;

var __domjs__= require('dom-js').DomJS;
var __crypto__ = require('crypto');
var __https__ = require('https');
var __http__ = require('http');
//var __xmljson__ = require('xml2json');

`

##SKIP_GEN_DOC##

class AjaxPipe #{
    agent: (s) -> if 'http' is s then __http__ else __https__

    constructor: () ->

    # args: AjaxArgs
    doAjax: (args) ->
        [urlStr, cpath, hdrs] = @format_url(args )
        me=this
        options= {
            hostname: @get_url_site(args),
            headers: hdrs || {},
            path: cpath,
            url: urlStr,
            method: args.verb
        }
        retryCtx={ opts: options, count: 0}
        @before_send(args, options.headers)
        @do_req(retryCtx,args, urlStr)

    do_req: (retryCtx, args, urlStr) ->
        hc=@agent( @get_url_prefix(args))
        options=retryCtx.opts
        me=this
        if @uteObj.isDbg() then @uteObj.logb( @uteObj.jsonStr(options))
        req=hc.request(options, (res) -> me.filter_response_data(retryCtx, args, res ) )
        req.on('error', (exp) -> me.on_fatal(args, options.url, exp) )
        req.setTimeout( args.timeout_secs * 1000, () -> me.on_error(retryCtx,args,urlStr,'','timeout'))
        if args.data? then req.write(args.data)
        req.end()

    before_send: (args, hdrs) ->
        ctype= args.content_type ? @default_content_type()
        if is_alive(ctype) and ctype.length > 0 then hdrs['content-type'] = ctype
        if args.data?
            hdrs['content-length']= args.dataSize
            hdrs['Expect']= '100-continue'
        @pre_ajax(args, hdrs)

    pre_ajax: ( args, hdrs ) ->
        if @uteObj.vstr(@userAgent) then hdrs['user-agent'] = @userAgent
        args.preAjax?(args, hdrs)

    on_fatal: (args, url, exp) ->
        rc = new ComZotoh.Net.AjaxError(args.action, 'Error', 'Operation Failed')
        if exp.message?
            rc.faultString=exp.message
            msg=exp.message
        else
            msg='???'
        @uteObj.error(['eeeeeeeeee----->',url,'ajax-res-error: '+msg,'eeeeeeeeee<-----'].join('\n'))
        args.callbacks?.error?(rc)

    filter_response_data: (retryCtx, args, res ) ->
        args.serverResponseType=res.statusCode
        me=this
        data=''
        res.setEncoding('utf-8')
        res.on('data', (chunk) -> data += chunk )
        res.on('end', () -> me.on_complete(retryCtx, args, res, data ))

    on_complete: (retryCtx, args, res, data) ->
        if @uteObj.isDbg() then @dbg_response_data(args, res, data)
        ctype= ( res.headers['content-type'] ? '' ).toLowerCase()
        url= retryCtx.opts.url
        rc= res.statusCode
        if rc >= 200 and rc < 300
            @on_success(args, res, ctype, data)
        else if rc >=300 and rc < 400
            @on_redirect(retryCtx,args,url, ctype, res,data)
        else
            @on_error(retryCtx, args, url, ctype, data, 'failed')

    dbg_response_data: (args, res, data) ->
        try
            s=[ 'http-status=(', res.statusCode, ')' ].join('')
            str=[ s, JSON.stringify(res.headers), data ].join('\n')
            @uteObj.debug(str)
        catch e

    on_redirect: (retryCtx,args,url, ctype, res,data) ->
        @uteObj.error('REDIRECT !!!!!!!!!!!!!!!!!!!!')
        if res.headers? then loc=res.headers['location'] else loc=''
        m= @url_matcher(url)
        oldsite = if m? and m.length > 2 then m[2] else ''
        newsite=''
        if @uteObj.vstr(loc)
            m= @url_matcher(loc)
            if m? and m.length > 2 then newsite= m[2]
        else
            tail=data.lastIndexOf('</Endpoint>')
            head=data.lastIndexOf('<Endpoint>')
            if head > 0 then head = head + 10 else head = -1
            newsite = if head > 0 and tail > 0 then data.slice(head,tail) else ''
        if @uteObj.vstr(oldsite) and @uteObj.vstr(newsite)
            @memoize_new_site(oldsite, newsite)
            args.url=''
            @doAjax(args)
        else
            @on_error(retryCtx, args, url, ctype, data, 'failed')

    on_success: (args, res, ctype, data) ->
        done=false
        if 'raw' isnt args.response_type
            if ctype.indexOf('xml') >= 0
                done=true
                new __domjs__().parse(data, (err, dom) -> args.action_handler?(dom) )

        if not done then args.action_handler?(data)

    on_error: ( retryCtx, args, url, ctype, data, error ) ->
        t= args.callbacks?.timeout
        e= args.callbacks?.error
        me=this
        pos= url.indexOf('?')
        if pos > 0 then url= url.slice(0, pos)
        if ('timeout' is error)
            if t? then t( args.action, url )
        else
            if e? then @report_error(retryCtx,args,url,ctype, data, e)

    report_error: (retryCtx, args, url, ctype, data, cb) ->
        me=this
        if ctype.indexOf('xml') >=0
            new __domjs__().parse(data, (e,dom)->me.process_error(retryCtx,args,url,'xml',dom,cb))
        else
            me.process_error(retryCtx,args,url,'text', data,cb)

    process_error: (retryCtx, args, url, ctype, res, cb) ->
        rc = new ComZotoh.Net.AjaxError(args.action, 'Error', 'Operation Failed')
        me=this
        code=args.serverResponseType

        if code is 0
            @on_statuscode_zero(rc, args)
        else if @process_res_error(ctype, rc, res)
            rc
        else if code > 0
            rc= @on_statuscode_bad(args)

        @post_process_error(retryCtx, args, rc, cb)

    process_res_error: (type, errObj, res) -> false

    retry_ajax: (retryCtx, args) ->
        if @uteObj.isDbg()
            @uteObj.debug("Retrying again.  retry count = #{retryCtx.count}")
        @do_req(retryCtx, args, retryCtx.opts.url)

    b64_hmac: (data, key, kind) ->
        t = kind || 'sha256'
        __crypto__.createHmac(t, key).update(data).digest('base64')

#}

##SKIP_GEN_DOC##


`

if (!is_alive(ComZotoh.Net)) { ComZotoh.Net={}; }
if (!is_alive(ComZotoh.Net.AjaxPipe )){ ComZotoh.Net.AjaxPipe=AjaxPipe; }




})(|GLOBAL|);

`





