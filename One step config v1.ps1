function button ($title, $User, $Name){


[void][System.Reflection.Assembly]::LoadWithPartialName( “System.Windows.Forms”)
[void][System.Reflection.Assembly]::LoadWithPartialName( “Microsoft.VisualBasic”)


$form = New-Object “System.Windows.Forms.Form”;
$form.Width = 400;
$form.Height = 200;
$form.Text = $title;
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;

##############Define User Box
$Userlabel = New-Object “System.Windows.Forms.Label”;
$Userlabel.Left = 25;
$Userlabel.Top = 15;

$Userlabel.Text = $User;

#############Define Computer Name Box

$Namelabel = New-Object “System.Windows.Forms.Label”;
$Namelabel.Left = 25;
$Namelabel.Top = 50;

$Namelabel.Text = $Name;


############Define User name box for input
$Userbox = New-Object “System.Windows.Forms.TextBox”;
$Userbox.Left = 150;
$Userbox.Top = 10;
$Userbox.width = 200;

#############Define Computer Name box for input

$Namebox = New-Object “System.Windows.Forms.TextBox”;
$Namebox.Left = 150;
$Namebox.Top = 50;
$Namebox.width = 200;

#############Define default values for the input box
$defaultValue = “”
$Userbox.Text = $defaultValue;
$namebox.Text = $defaultValue;

#############define OK button
$button = New-Object “System.Windows.Forms.Button”;
$button.Left = 200;
$button.Top = 100;
$button.Width = 100;
$button.Text = “Ok”;


$eventHandler = [System.EventHandler]{
$Userbox.Text;
$Namebox.Text;
$form.Close();};

$button.Add_Click($eventHandler) ;

#############Add controls to all the above objects defined
$form.Controls.Add($button);
$form.Controls.Add($Userlabel);
$form.Controls.Add($Namelabel);
$form.Controls.Add($Userbox);
$form.Controls.Add($Namebox);
$ret = $form.ShowDialog();


#################return values

return $Userbox.Text, $Namebox.text}


$return= button “Help Desk” “User Name” "PC Name"
write-host $return[0];
write-host $return[1];



##Code below moves the files from USB drive and creates source files folder on PC

$mydrive=(GWmi Win32_LogicalDisk | ?{$_.VolumeName -eq 'Configstick'} | %{$_.DeviceID})
$sourcefiles = "c:\source_files"

if(!(test-path -path $sourcefiles)) {new-item $sourcefiles -type directory}

Copy-Item -Path $mydrive\* -Destination $sourcefiles -Recurse -force -verbose

write-host "file move complete"

## Rename Computer to match IT info Sheet

##Rename-Computer "$return[1]"

## Fill in the info for the service desk upload, all put into PCinfo.csv

start-service winrm
get-computerinfo -Property CSname,BIOSSeralnumber,CsModel,CsManufacturer,OsName,CsPhyicallyInstalledMemory|

 foreach-object {
          
        [PSCustomObject][ordered]@{
                              "Workstation Name" = $_.CSName
                               Model = $_.CSModel
                             "Set as Server" = "FALSE"
                             "VM Type" = " "
                             "VM Platform" = " "
                             "Virtual Host" = " "
                             "Asset Tag" = $_.CSName
                            "Serial Number" = $_.BIOSSeralnumber
                             Barcode = " "
                             Vendor = "Safari Micro"
                            "Purchase Cost" = " "
                             Location = " "
                            "Assign to User" = "$return"
                            "Assign to Department" = " "
                             Site = "$location"
                            "Lease Start" = " "
                            "Lease Expiry" = " "
                            "Acquisition Date" = " "
                            "Expiry Date" = " "
                            "Warranty Expiry Date" = " "
                            "Service Tag" = $_.CSName
                             Manufacturer = $_.CsManufacturer
                            "Operating System" = $_.OsName
                             Domain = " "
                             Processor = " "
                            "Processor Clock Speed(in GHz)" = " "
                            "Physical Memory" = $_.CsPhyicallyInstalledMemory
                            "IP Address" =  " "
                            "MAC Address" = " "
                            "HDD Model"= " "
                            "HDD Serial Number" = " "
                            "HDD Capacity In bytes"= " "
                            "Keyboard Type" = " "
                            "Mouse Type" = " "
                            "Retain user's or department's site as Asset site" = "True"
                            "Product Manufacturer" = $_.CsManufacturer
                             }
      }  | select  |
    export-csv -path "$mydrive\pcinfo.csv" -NoTypeInformation
    import-csv -path "$mydrive\pcinfo.csv"
stop-service winrm

## Runs the autopilot hash retriver for auto pilot upload
c:\source_files\Get-WindowsAutoPilotInfo.ps1 -ComputerName localhost -OutputFile $mydrive\MyComputer.csv

import-csv -path "$mydrive\mycomputer.csv"