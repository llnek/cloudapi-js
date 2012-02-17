###
file: comzotoh.nodedom.coffee
###

`(function(genv) {
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


var __domjs__= require('dom-js');

`

##SKIP_GEN_DOC##

find_name=(node, name) ->
    ii=node.children.length
    rc=null
    for i in [0...ii]
        if name is node.children[i].name
            rc= node.children[i]
            break
    rc


class DomAPI #{
    constructor: () ->

DomAPI.newElement= (name, as, cs) -> new __domjs__.Element(name,as,cs)

DomAPI.newText= (data) -> new __domjs__.Text(data)

DomAPI.toXml= (dom) -> dom.toXml()

DomAPI.clearXmlAttrs= (node) -> 
    node.attributes={}
    node

DomAPI.getTag= (em, tag) ->
    if tag.charAt(0) is '/'
        tag=tag.replace(/^\//, '')
        start=1
    else
        start=0
    ts= tag.split('/')
    ii= ts.length-1
    top=em
    rc=[]

    if ii is 0 and start is 1
        rc.push(em)
        return rc

    for i in [start...ii]
        if ts[i].length > 0
            top= find_name(top, ts[i])
            if not top? then break
    if top? and ii >= 0
        jj=top.children?.length
        for j in [0...jj]
            if ts[ii] is top.children[j].name then rc.push(top.children[j])
    rc

DomAPI.getCS = (node) -> if node? then node.children else []

DomAPI.getFCN= (node) -> ( node?.firstChild()?.text ) ? ''

DomAPI.getNVal= (par, name) -> DomAPI.getFCN(  DomAPI.getNode(par,name))

DomAPI.getNode= (par, name) -> DomAPI.getTag(par,name)[0]

DomAPI.getNName= (node) -> node?.name ? ''

DomAPI.ffcn= (em, tag) -> DomAPI.getFCN( DomAPI.getTag(em,tag)[0])

#}

class BlobSupportDOM extends ComZotoh.CloudAPI.AbstractSupport #{
    constructor: (s3) -> super(s3)

    break_acl: (acl) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        ii=acl?.children?.length
        others=[]
        pub={}
        for i in [0...ii]
            grt=acl.children[i]
            u=fcn( gt(grt, 'Grantee/URI')[0] )
            p=fcn( gt(grt, 'Permission')[0] )
            if S3_PUBLIC_URI is u
                pub[p]=grt
            else
                others.push(grt)
        [pub, others]

    patch_acl: (acl, others, pub) ->
        acl.children.length=0
        ii=others.length
        for i in [0...ii]
            acl.children.push( others[i])
        for own k,v of pub
            if is_alive(v) then acl.children.push(v)


#}

##SKIP_GEN_DOC##

`
if (!is_alive(ComZotoh.DomAPI )){ ComZotoh.DomAPI=DomAPI; }
if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
if (!is_alive(ComZotoh.CloudAPI.Storage)) { ComZotoh.CloudAPI.Storage={}; }
ComZotoh.CloudAPI.Storage.BlobSupportDOM=BlobSupportDOM;




})(|GLOBAL|);

`





