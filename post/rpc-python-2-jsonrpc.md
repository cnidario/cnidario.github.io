---
title: Remote procedure calls in Python (2) - JSON-RPC
author: cnidario
date: 2022-06-23
publishDate: 2022-06-23
tags:
- distributed computing
- python
categories: 
- programming
draft: true

---

## JSON-RPC

[JSON-RPC](https://en.wikipedia.org/wiki/XML-RPC) is a similar protocol to XML-RPC for remote procedure calling which changes XML for JSON.

I've remade the prior example, calling `os.uname()` from a remote machine and also a simple `echo` procedure.
This program needs the Python `json-rpc` package. For the web server it just uses standard Python `WSGI` and for the client `urllib`.

`server.py`
``` {.python}
from wsgiref.util import setup_testing_defaults
from wsgiref.simple_server import make_server
from jsonrpc import JSONRPCResponseManager, dispatcher
import os

@dispatcher.add_method
def uname():
    return os.uname()

def simple_jsonrpc(environ, start_response):
    dispatcher["echo"] = lambda s: s
    setup_testing_defaults(environ)
    status = '200 OK'
    headers = [('Content-type', 'application/json; charset=utf-8')]
    try:
        req_sz = int(environ.get('CONTENT_LENGTH', 0))
    except ValueError:
        req_sz = 0
    req_body = environ['wsgi.input'].read(req_sz)
    print(f'received body({req_sz} bytes): {req_body}')
    response = JSONRPCResponseManager.handle(req_body, dispatcher)
    print(f'reposne: {response.json}')
    start_response(status, headers)
    return [response.json.encode("utf-8")]

with make_server('', 8000, simple_jsonrpc) as httpd:
    print("Serving on port 8000...")
    httpd.serve_forever()

```
`client.py`
``` {.python}
import urllib.request
import json

def make_jsonrpc_request(name, params, idd):
      payload = {
          'method': name,
          'params': params,
          'jsonrpc': '2.0',
          'id': idd
      }
      data = json.dumps(payload).encode('utf-8')
      print(f'debug: jsonrpc data payload: {data}')
      req = urllib.request.Request('http://prometeo.home:8000/jsonrpc', data=data)
      req.add_header('Content-type', 'application/json')
      return req


  echo_req = make_jsonrpc_request('echo', ['eco ecoooo? estamos solos en esta galaxia?'], 0)
  with urllib.request.urlopen(echo_req) as resp:
      print(resp.read().decode('utf-8'))

  uname_req = make_jsonrpc_request('uname', [], 1)
  with urllib.request.urlopen(uname_req) as resp:
      print(resp.read().decode('utf-8'))

```

Output of `python client.py`
``` {.console}
debug: jsonrpc data payload: b'{"method": "echo", "params": ["eco ecoooo? estamos solos en esta galaxia?"], "jsonrpc": "2.0", "id": 0}'
{"result": "eco ecoooo? estamos solos en esta galaxia?", "id": 0, "jsonrpc": "2.0"}
debug: jsonrpc data payload: b'{"method": "uname", "params": [], "jsonrpc": "2.0", "id": 1}'
{"result": ["Linux", "prometeo", "5.18.5-arch1-1", "#1 SMP PREEMPT_DYNAMIC Thu, 16 Jun 2022 20:40:45 +0000", "x86_64"], "id": 1, "jsonrpc": "2.0"}
```

Output in the server
``` {.console}
Serving on port 8000...
received body(103 bytes): b'{"method": "echo", "params": ["eco ecoooo? estamos solos en esta galaxia?"], "jsonrpc": "2.0",
"id": 0}'
reposne: {"result": "eco ecoooo? estamos solos en esta galaxia?", "id": 0, "jsonrpc": "2.0"}
192.168.1.112 - - [23/Jun/2022 17:17:47] "POST /jsonrpc HTTP/1.1" 200 83
received body(60 bytes): b'{"method": "uname", "params": [], "jsonrpc": "2.0", "id": 1}'
reposne: {"result": ["Linux", "prometeo", "5.18.5-arch1-1", "#1 SMP PREEMPT_DYNAMIC Thu, 16 Jun 2022 20:40:45 +0000", "x86_64"], "id": 1, "jsonrpc": "2.0"}
192.168.1.112 - - [23/Jun/2022 17:17:47] "POST /jsonrpc HTTP/1.1" 200 146
```
