# Puppet Enterprise API Playgroud - Powershell and Curl examples

This repo is just a bunch of files used as examples and playing around with the various Puppet API Endpoints.

Some helpful links to Puppet API docs:
_. <https://puppet.com/docs/puppetdb/latest/api/query/v4/nodes.html>
_. <https://puppet.com/docs/puppetdb/latest/api/query/v4/inventory.html>
_. <https://puppet.com/docs/puppetdb/latest/api/query/v4/reports.html>
_. <https://puppet.com/docs/puppetdb/latest/api/query/v4/resources.html>

_Note:_ For getting Factor fact info for an enpoint, you probably want the Inventory or Nodes endpoints, not the Facts endpoint. See the examples below.

_. <https://puppet.com/docs/pe/2019.8/orchestrator_api_commands_endpoint.html> Orchestraor Endpoint for running Puppet Agent, Tasks & Plans
_. <https://puppet.com/docs/pe/2019.1/rbac_api_v1_token.html> RBAC Token Enpoint

## Powershell Based Examples

### get_token.ps1

This file can be used to get a token using the token endpoint from your Puppet Enterprise infrastructure.
It will create a ./token file, which is used by the rest of the powershell scripts.

### api_query.ps1

This script will allow a query over the Puppet API in a couple different ways (listed below). It either required the `server` and `token` files in the current directory populated with a valid token and server FQDN, or these options can be supplied via command line or manual input when the script is run.

#### Default, No Options

Without options, this script will pull a list of nodes that have a kernel fact of "Linux"
(Note: The default is identical to a PQL with a `-Query 'inventory[certname, facts.kernel] { facts.kernel = "Windows" }'` option)
Sample Command: `./api_query.ps1`
Sample Output:

```
{
    "value":  [
                  {
                      "certname":  "demo-master.classroom.puppet.com",
                      "facts.kernel":  "Linux"
                  },
                  {
                      "certname":  "demo-nix0.classroom.puppet.com",
                      "facts.kernel":  "Linux"
                  },
                  {
                      "certname":  "demo-nix1.classroom.puppet.com",
                      "facts.kernel":  "Linux"
                  },
                  {
                      "certname":  "demo-nix2.classroom.puppet.com",
                      "facts.kernel":  "Linux"
                  }
              ],
    "Count":  4
}
```

#### -Fact and -Value

Using the -Fact and -Value options will pull a list of nodes that match the provided Fact and Value
_Note:_ -Fact and -Value are meant to be used together, if you want to just pull a list of nodes with specific facts, use the `-Query` option with the example below.

Sample Command: `.\api_query.ps1 -Fact "facts.architecture" -Value "x86_64"`
Sample Output:

```
{
    "value":  [
                  {
                      "certname":  "demo-master.classroom.puppet.com",
                      "facts.architecture":  "x86_64"
                  },
                  {
                      "certname":  "demo-nix0.classroom.puppet.com",
                      "facts.architecture":  "x86_64"
                  },
                  {
                      "certname":  "demo-nix1.classroom.puppet.com",
                      "facts.architecture":  "x86_64"
                  },
                  {
                      "certname":  "demo-nix2.classroom.puppet.com",
                      "facts.architecture":  "x86_64"
                  }
              ],
    "Count":  4
}
```

#### -Query

The `-Query` option will allow any ad hoc query to be run against PuppetDB and override the default node list/fact behavior.

##### Example: Pull a list of nodes and show their OS and some additional facts.

Sample Command: `.\api_query.ps1 -Query 'inventory[certname,facts.os.name,facts.architecture,facts.os.release.major] {} '`
Sample Output:

```
{
    "value":  [
                  {
                      "certname":  "demo-master.classroom.puppet.com",
                      "facts.os.name":  "CentOS",
                      "facts.architecture":  "x86_64",
                      "facts.os.release.major":  "7"
                  },
                  {
                      "certname":  "demo-nix0.classroom.puppet.com",
                      "facts.os.name":  "CentOS",
                      "facts.architecture":  "x86_64",
                      "facts.os.release.major":  "7"
                  },
                  {
                      "certname":  "demo-nix1.classroom.puppet.com",
                      "facts.os.name":  "CentOS",
                      "facts.architecture":  "x86_64",
                      "facts.os.release.major":  "7"
                  },
                  {
                      "certname":  "demo-nix2.classroom.puppet.com",
                      "facts.os.name":  "CentOS",
                      "facts.architecture":  "x86_64",
                      "facts.os.release.major":  "7"
                  },
                  {
                      "certname":  "demo-win0.classroom.puppet.com",
                      "facts.os.name":  "windows",
                      "facts.architecture":  "x64",
                      "facts.os.release.major":  "2016"
                  },
                  {
                      "certname":  "demo-win1.classroom.puppet.com",
                      "facts.os.name":  "windows",
                      "facts.architecture":  "x64",
                      "facts.os.release.major":  "2016"
                  },
                  {
                      "certname":  "demo-win2.classroom.puppet.com",
                      "facts.os.name":  "windows",
                      "facts.architecture":  "x64",
                      "facts.os.release.major":  "2016"
                  }
              ],
    "Count":  7
}
```

##### Example: Pull a list of all 'CentOS 7' nodes

Sample Command: `.\api_query.ps1 -Query 'inventory[certname] { facts.os.name = "CentOS" and facts.os.release.major = "7" } '`
Sample Output:

```
{
    "value":  [
                  {
                      "certname":  "demo-master.classroom.puppet.com"
                  },
                  {
                      "certname":  "demo-nix0.classroom.puppet.com"
                  },
                  {
                      "certname":  "demo-nix1.classroom.puppet.com"
                  },
                  {
                      "certname":  "demo-nix2.classroom.puppet.com"
                  }
              ],
    "Count":  4
}
```

##### Example: Show all agent reports with changes (Intentional and Corrective)

The `hash` can then be used to pull the full report details from the reports endpoint.
Reports with `status = "changed"` will have either a correctional or intentional change.
If `corrective_change` is set in the report, it is a corrective vs. intentional change.

Sample Command: `.\api_query.ps1 -Query 'reports[certname,receive_time,corrective_change,hash] { status = "changed" and type = "agent" order by receive_time desc }'`
Sample Output:

```
{
    "value":  [
                  {
                      "certname":  "demo-master.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:57:34.973Z",
                      "corrective_change":  false,
                      "hash":  "54281641682e502384ed162b6366cbab9e7d14c8"
                  },
                  {
                      "certname":  "demo-nix2.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:36:20.756Z",
                      "corrective_change":  false,
                      "hash":  "4b805c0022802f162592cd41a6c38327631a5aa8"
                  },
                  {
                      "certname":  "demo-nix1.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:35:58.868Z",
                      "corrective_change":  false,
                      "hash":  "f0ee7515e4c52a9ab8db807af06b9e2e6c6335c7"
                  },
                  {
                      "certname":  "demo-nix0.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:35:21.401Z",
                      "corrective_change":  false,
                      "hash":  "af657e89e7a25183f92edb0bdaa89e5acd643e80"
                  },
                  {
                      "certname":  "demo-master.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:28:02.114Z",
                      "corrective_change":  true,
                      "hash":  "4f1f9febb90697c03ddb8f24d10e191d0302ab81"
                  },
                  {
                      "certname":  "demo-win2.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:13:06.654Z",
                      "corrective_change":  false,
                      "hash":  "0e37b5abe7887f42d0014946780df5816ef499f9"
                  },
                  {
                      "certname":  "demo-win1.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:11:52.349Z",
                      "corrective_change":  false,
                      "hash":  "3a158929515ab3680ccd1c83201e8c4ab6b56f30"
                  },
                  {
                      "certname":  "demo-win0.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:10:44.445Z",
                      "corrective_change":  false,
                      "hash":  "19d3637956cd27d57fd22152cc84fffafb8dc8fd"
                  },
                  {
                      "certname":  "demo-nix2.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:05:42.618Z",
                      "corrective_change":  false,
                      "hash":  "aca40652765b84eb1135c90a1cb92637d0d2011c"
                  },
                  {
                      "certname":  "demo-nix1.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:05:14.454Z",
                      "corrective_change":  false,
                      "hash":  "782a82f14a61f4004ce19728c02b46aee59b1419"
                  },
                  {
                      "certname":  "demo-nix0.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:04:37.696Z",
                      "corrective_change":  false,
                      "hash":  "a5c1e19abd33fe4f15799191bc53e180696c05ed"
                  },
                  {
                      "certname":  "demo-master.classroom.puppet.com",
                      "receive_time":  "2020-09-02T17:02:24.603Z",
                      "corrective_change":  false,
                      "hash":  "d9f63a31c4fc0bd7a4d926984d25dbaea5230b57"
                  }
              ],
    "Count":  12
}
```

#### -Outfile

This flag will dump the response into a file. This is usful for large returns, like reports.
The example here will use `-Query` to grab the last report for a specific node.
Sample Command: `.\api_query.ps1 -Query 'reports[] { certname = "demo-win1.classroom.puppet.com" limit 1 }' -Outfile lastreport.json`
Sample Output: (way too large to put here)

### get_latest_catalog.ps1

This script uses an AST style query (internal to the script) to get the latest catalog complied for a Puppet Agent Node.
Output will be placed in a file with the same name as the target node, with a `.catalog.json` file extension added.

Sample Command: `.\get_latest_catalog.ps1 -Target demo-win1.classroom.puppet.com`
Sample Output: (way too large to put here)

## Curl Based Examples

### api_ast_test.sh

This is an AST language query based example for a Puppet API call.

```
#!/bin/sh
# Reads API Access token from file, stripping any CR characters (in case the file is dos/windows format)
TOKEN=$(cat ./token | sed -e 's/\r//g')
QUERY='["from", "resources", ["=", "certname", "demo-nix0.classroom.puppet.com"]]'
SERVER='demo-master.classroom.puppet.com'

curl -k -X GET \
  "https://${SERVER}:8081/pdb/query/v4"  \
  -H "X-Authentication:${TOKEN}" \
  --data-urlencode "query=${QUERY}"
```

### api_pql_query.sh

This is a Puppet Query Language (PQL) based Puppet API call example.

```
#!/bin/sh
# Reads API Access token from file, stripping any CR characters (in case the file is dos/windows format)
TOKEN=$(cat ./token | sed -e 's/\r//g')
QUERY='inventory[certname,facts.kernel, facts.architecture] { facts.kernel="windows" }'
SERVER='demo-master.classroom.puppet.com'

curl -k -X GET \
  "https://${SERVER}:8081/pdb/query/v4"  \
  -H "X-Authentication:${TOKEN}" \
  --data-urlencode "query=${QUERY}"
```

## Puppet Query Language (PQL) Examples

See the examples below or this link for additional info on PuppetDB and PQL: <https://puppet.com/docs/puppetdb/latest/api/query/tutorial-pql.html>

### Examples to get a list of all windows nodes

1: `'inventory[certname] { facts.kernel="windows" }'`
2: `'inventory[certname] { facts.os.name="Windows" }'`

## AST (Abstract Syntax Tree) Language Examples

See the examples below or this link for additional info on PuppetDB and AST: <https://puppet.com/docs/puppetdb/latest/api/query/v4/ast.html>

###
