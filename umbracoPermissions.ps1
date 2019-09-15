# Get Params #---------------
param([string]$folderName)

# Define Variables #---------------
$mode = "1" # Choose 1 (cli), 2 (grid picker), or 3 (full windows picker).
$appPoolAccount = ("IIS_IUSRS")
$websitesPath = ("C:\websites\")
$removalMode = $true

# Check for a path
if (([string]::IsNullOrEmpty($folderName)))
{
    Switch ($mode) { 
        "1"
        { 
            # 1. CLI Free text input
            $folderName = Read-Host -Prompt 'Input website folder name'
        } 
        
        "2"
        {
            # 2. GridView Picker
            $folderName = @(Get-ChildItem $websitesPath | Out-GridView -Title 'Choose a folder' -PassThru) 
            Write-Output $folderName
        } 
        
        "3"
        {
            # 3. GUI Picker
            Add-Type -AssemblyName System.Windows.Forms
            $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{SelectedPath = $websitesPath}
            [void]$FolderBrowser.ShowDialog()
            $FolderBrowser.SelectedPath    
        } 
    }
}

# Build Path #---------------
if (([string]::IsNullOrEmpty($FolderBrowser.SelectedPath)))
{
    $fullPhysicalPath = ($websitesPath + $folderName)
}
else 
{
    $fullPhysicalPath = $FolderBrowser.SelectedPath
}

# Misc ASCII #---------------
$finText = "                                        
                                        
  NEDONE    DONED   DO    NE  NEDONED   
  NEDONED  EDONEDO  DON   NE  NEDONED   
  NE   ED  ED   DO  DONE  NE  NE        
  NE   ED  ED   DO  DO EDONE  NE        
  NE   ED  ED   DO  DO  DONE  NEDONE    
  NE   ED  ED   DO  DO   ONE  NE        
  NE   ED  ED   DO  DO    NE  NE        
  NE  NED  ED  EDO  DO    NE  NE        
  NEDONE    DONED   DO    NE  NEDONED
  
  "

# Set Permissions #---------------
$readExecute = $appPoolAccount, "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow"
$read = $appPoolAccount, "Read", "ContainerInherit, ObjectInherit", "None", "Allow"
$modify = $appPoolAccount, "Modify", "ContainerInherit, ObjectInherit", "None", "Allow"
$fileModify = $appPoolAccount, "Modify", "Allow"
$objects = @{}
$objects["app_browsers"] = $readExecute
$objects["app_code"] = $readExecute
$objects["app_data"] = $modify
$objects["bin"] = $read
$objects["config"] = $modify
$objects["css"] = $modify
$objects["data"] = $modify
$objects["masterpages"] = $modify
$objects["scripts"] = $modify
$objects["umbraco"] = $modify
$objects["usercontrols"] = $read
$objects["web.config"] = $fileModify
$objects["xslt"] = $modify
foreach ($key in $objects.Keys) {
    $path = Join-Path $fullPhysicalPath $key
    if (Test-Path $path) {
        $acl = Get-ACL $path
        if($removalMode) {
            $acl.Access | Where-Object {$_.IdentityReference.Value -match $appPoolAccount} | Foreach-Object {$acl.RemoveAccessRule($_)} > $null
        }
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($objects[$key])
        $acl.AddAccessRule($rule)
        Set-Acl $path $acl
        Get-Acl $path | Format-List
    }
}

Write-Output $finText
