# Umbraco Permissions Script

The script takes 1 optional argument, which is a folder name, located in the directory defined in the variables portion of the script, ie `.\umbracoPermissions.ps1 "testSite"`

Alternatively, if you provide no arguments, the script will use one of three methods, again defined in the variables portion of the script.

## Options

```
$mode = "1"
$appPoolAccount = ("IIS_IUSRS")
$websitesPath = ("C:\websites\")
$removalMode = $true
```

`$mode` takes either `1`, `2`, or `3`. 
  1. will use the cli input, where you are simply asked to provide the folder name of the website you wish to set permissions on.
  2. will use the powershell grid picker, which offers a gui for picking.
  3. will use another gui for picking.
  
`$appPoolAccount` is the user you wish to set the permissions for on the items in the website folder.

`$websitesPath` is the folder where your IIS websites live, the example above using `C:\websites\`

`$removalMode` is a destructive option, in that it will remove permissions belonging to `$appPoolAccount` before it reapplies them.
