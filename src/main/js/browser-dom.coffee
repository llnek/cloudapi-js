###
file: comzotoh.nodedom.coffee
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

var __domp__= new DOMParser();
var __doc__= __domp__.parseFromString(XMLP, 'text/xml');
var __xmlsz__ = new XMLSerializer();



`

##SKIP_GEN_DOC##


find_name=(node, name) -> node.getElementsByTagName(name)[0]

class DomAPI #{
    constructor: () ->

DomAPI.newElement= (name,atts,cs) ->
    rc=__doc__.createElement(name)
    if atts?
        rc.setAttribute(k,v) for own k, v of atts
    nn=cs?.length
    rc.appendChild(cs[n]) for n in [0...nn]
    rc

DomAPI.newText= (data) -> __doc__.createTextNode(data)

DomAPI.clearXmlAttrs= (node) ->
    atts=node?.attributes
    nn=atts?.length
    a=[]
    a.push(atts[n].name) for n in [0...nn]
    nn=a.length
    if node?
        node.removeAttribute(a[n]) for n in [0...nn]

DomAPI.toXml= (node) ->
    __xmlsz__.serializeToString(node)

DomAPI.getTag= (em,tag) ->
    if tag.charAt(0) is '/'
        tag=tag.replace(/^\//, '')
        start=1
    else
        start=0
    ts=tag.split('/')
    ii=ts.length-1
    top=em
    rc=[]

    if ii is 0 and start is 1
        em= find_name(top, ts[0])
        if em? then rc.push(em)
        return rc

    for i in [0...ii]
        top= find_name(top, ts[i])
        if not top? then break
    if top? and ii >= 0
        jj=top.childNodes?.length
        for j in [0...jj]
            if ts[ii] is top.childNodes[j].nodeName then rc.push(top.childNodes[j])
    rc

DomAPI.getCS= (node) -> if node? then node.childNodes else []

DomAPI.getFCN= (node) -> node?.firstChild?.nodeValue

DomAPI.getNode= (parent, nodeName) -> DomAPI.getTag(parent,nodeName)[0]

DomAPI.getNVal= (parent, nodeName) ->
    node = DomAPI.getNode(parent,nodeName)
    if node? and node.firstChild? then node.firstChild.nodeValue else ''

DomAPI.getNName= (node) -> node?.nodeName ? ''

DomAPI.ffcn= (em, tag) ->
    DomAPI.getFCN( DomAPI.getTag(em,tag)[0] )

#}


class BlobSupportDOM extends ComZotoh.CloudAPI.AbstractSupport #{
    constructor: (s3) -> super(s3)

    break_acl: (acl) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items= gt(acl,'Grant')
        ii=items.length
        others=[]
        pub={}
        for i in [0...ii]
            item=items[i]
            p=dom.ffcn(item, 'Permission')
            g=gt(item, 'Grantee')[0]
            u=gt(g, 'URI')[0]
            if S3_PUBLIC_URI is u
                pub[p]=item
            else
                others.push(item)
        [pub, others]

    patch_acl: (acl, others, pub) ->
        cs=acl?.childNodes()
        nn=cs?.length
        a=[]
        a.push(cs[n]) for n in [0...nn]
        nn=a.length
        acl.removeChild(a[n]) for n in [0...nn]
        nn=others.length
        acl.appendChild( others[i]) for n in [0...nn]
        for own k,v of pub
            if is_alive(v) then acl.appendChild(v)


##SKIP_GEN_DOC##




`

if (!is_alive(ComZotoh.DomAPI )){ ComZotoh.DomAPI=DomAPI; }
if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
if (!is_alive(ComZotoh.CloudAPI.Storage)) { ComZotoh.CloudAPI.Storage={}; }
ComZotoh.CloudAPI.Storage.BlobSupportDOM=BlobSupportDOM;








})(|GLOBAL|);

`





