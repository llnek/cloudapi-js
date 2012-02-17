###
file: comzotoh.browser.coffee
###

`

(function(genv) {
"use strict";
function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;


`

##SKIP_GEN_DOC##

class AjaxPipe #{
    constructor: () ->

    doAjax: (args) ->
        [urlStr, cpath, hdrs]= @format_url(args)
        me=this
        retryCtx={ opts: {}, count: 0 }
        retryCtx.opts= {
            contentType: args.content_type ? @default_content_type(),
            dataType: args.response ? @default_response(),
            type: args.verb,
            cache: @cache_pages(),
            processData: false,
            global: true,
            async: true,
            data: args.data,
            url: urlStr,
            timeout: args.timeout_secs * 1000,
            beforeSend: (tx, opts) -> me.before_send(args, opts, hdrs, tx) ,
            dataFilter: (data, type) -> me.filter_response_data(retryCtx,args, data, type) ,
            success: (data, status) -> me.on_success(args, data, status)
        }
        retryCtx.opts.error= (tx, status, e) -> me.on_error(retryCtx, args, urlStr, tx, status, e)
        if @uteObj.isDbg() then @uteObj.logb( @uteObj.jsonStr(retryCtx.opts))
        jQuery.ajax(retryCtx.opts)

    before_send: (args, options, headers, tport) ->
        hdrs= headers || {}
        args.xhr_obj=tport
        if args.data? then hdrs['content-length']= args.dataSize
        @pre_ajax(args, hdrs)
        for own key, value of hdrs
            tport.setRequestHeader(key,value)
        options

    pre_ajax: ( args, hdrs ) ->
        if @uteObj.vstr(@userAgent) then hdrs['user-agent']= @userAgent
        args.preAjax?(args, hdrs)

    filter_response_data: (retryCtx, args, data, type) ->
        args.serverResponseType=type
        data

    on_error: ( retryCtx, args, url, xhr, status, exception) ->
        t= args.callbacks?.timeout
        e= args.callbacks?.error
        try
            ctype= xhr.getResponseHeader('content-type')
        catch e
        pos= url.indexOf('?')
        if pos > 0 then url= url.slice(0, pos)
        if ('timeout' is status)
            if t? then t( args.action, url )
        else
            if e? then @process_error( retryCtx, args.action, url, ctype || '', xhr, e)

    process_error: (retryCtx, action, url, ctype, xhr, cb) ->
        rc = new ComZotoh.Net.AjaxError(action, 'Error', 'Operation Failed')
        code=xhr.statusText
        me=this
        try
            x= xhr.responseXML
        catch e
            x=null
        try
            s= xhr.responseText
        catch e
            s=''

        if not s? then s = ''
        @uteObj.error([ 'ajax-res-error: http-status=(' , code , ')\n' , s ].join('') )

        et= if ctype.indexOf('xml') >=0 then 'xml' else 'text'
        if code is 0
            @on_statuscode_zero(rc, args)
        else if @process_res_error(et, rc, x || s )
            rc
        else if code > 0
            rc= @on_statuscode_bad(args)

        @post_process_error(retryCtx, args, rc, cb)

    process_res_error: (type, errObj, res) -> false

    on_success: (args, data, status) ->
        if @uteObj.isDbg() then @dbg_response_data(args, data, args.serverResponseType, status)
        done=false
        if 'raw' isnt args.response_type
            done=true
            args.action_handler?(data)
        if not done
            args.action_handler?( args.xhr_obj.responseText ? '' )

    dbg_response_data: (args, data, type, status) ->
        try
            t=args.xhr_obj
            s=[ 'ajax-res-type=' , type , ',http-status=(', status, ')' ].join('')
            str=[ s, t.getAllResponseHeaders(), t.responseText ].join('\n')
            @uteObj.debug(str)
        catch e

    retry_ajax: (retryCtx, args) ->
        if @uteObj.isDbg() then @uteObj.debug("Retrying again.  retry count = #{retryCtx.count}")
        jQuery.ajax( retryCtx.opts )


    b64_hmac: (data, key,kind) ->
        t= if 'sha1' is kind then Crypto.SHA1 else Crypto.SHA256
        Crypto.util.bytesToBase64(Crypto.HMAC(t,data, key, {asBytes:true}))


#}


##SKIP_GEN_DOC##


`

if (!is_alive(ComZotoh.Net)) { ComZotoh.Net={}; }
if (!is_alive(ComZotoh.Net.AjaxPipe )){ ComZotoh.Net.AjaxPipe=AjaxPipe; }




})(|GLOBAL|);

`





