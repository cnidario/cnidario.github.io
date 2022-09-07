---
title: Remote procedure calls in Python (1) - XMLRPC
author: cnidario
date: 2022-06-19
publishDate: 2022-06-19
tags:
- distributed computing
- python
categories: 
- programming
draft: true

---

## XML-RPC

Python comes with an implementation of [XML-RPC](https://en.wikipedia.org/wiki/XML-RPC). XML-RPC is a Remote Procedure Callstandard method wich uses XML via HTTP (and further evolved into SOAP).

Here is a simple example which retrieves machine information through `os.uname()` from a remote machine.

`server.py`
``` {.python}
from xmlrpc.server import SimpleXMLRPCServer
from xmlrpc.server import SimpleXMLRPCRequestHandler
import os

class RequestHandler(SimpleXMLRPCRequestHandler):
    rpc_paths = ('/RPC2',)

with SimpleXMLRPCServer(('0.0.0.0', 8000),
        requestHandler=RequestHandler) as server:
    server.register_introspection_functions()
    print('Exporting function os.uname')
    def uname_wrapper():
        o = os.uname()
        return { 'sysname': o.sysname,
                 'nodename': o.nodename,
                 'release': o.release,
                 'version': o.version,
                 'machine': o.machine }
    server.register_function(uname_wrapper, 'uname')
    print('Starting XML-RPC server at 0.0.0.0:8000...')
    server.serve_forever()

```
`client.py`
``` {.python}
import xmlrpc.client

rpc_server = 'localhost:8000'
print(f'Connecting to {rpc_server}')
server = xmlrpc.client.ServerProxy(f'http://{rpc_server}')
print('Calling server.uname()')
print(server.uname())
print('Calling listMethods')
print(server.system.listMethods())
```

Output of `python client.py`
```{.console}
Connecting to remote-machine:8000
Calling server.uname()
{'sysname': 'Linux', 'nodename': 'prometeo', 'release': '5.18.5-arch1-1', 'version': '#1 SMP PREEMPT_DYNAMIC Thu, 16 Jun 2022 20:40:45 +0000', 'machine': 'x86_64'}
Calling listMethods
['system.listMethods', 'system.methodHelp', 'system.methodSignature', 'uname']
```

Output in the server
```{.console}
Exporting function os.uname
Starting XML-RPC server at 0.0.0.0:8000...
192.168.1.112 - - [19/Jun/2022 10:31:02] "POST /RPC2 HTTP/1.1" 200 -
192.168.1.112 - - [19/Jun/2022 10:31:02] "POST /RPC2 HTTP/1.1" 200 -
```
If we put a man-in-the-middle with socat we can see the actual conversation between the programs
```{.console}
socat -v tcp-listen:9999,fork,reuseaddr tcp:prometeo.home:8000 # pipe man in the middle MITM
```
First change the rpc_server variable in client.py to point to our MITM `localhost:9999`
Ouput
```{.console}
POST /RPC2 HTTP/1.1\r
Host: localhost:9999\r
Accept-Encoding: gzip\r
Content-Type: text/xml\r
User-Agent: Python-xmlrpc/3.10\r
Content-Length: 99\r
\r
<?xml version='1.0'?>
<methodCall>
<methodName>uname</methodName>
<params>
</params>
</methodCall>
< 2022/06/22 13:47:26.000903951  length=717 from=0 to=716
HTTP/1.0 200 OK\r
Server: BaseHTTP/0.6 Python/3.10.5\r
Date: Wed, 22 Jun 2022 11:46:14 GMT\r
Content-type: text/xml\r
Content-length: 580\r

...
```
