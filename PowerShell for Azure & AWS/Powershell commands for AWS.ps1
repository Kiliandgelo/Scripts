


### Copy File from S3 Bucket to local Storage

Copy-S3Object -bucketname machinchose.machin -key Nomdefichier.exe -LocalFile $HOME\Desktop\Nomdefichier.exe 

# Create Instance 

New-EC2Instance -ImageId ami-3cc4b51 -MinCount 1 -MaxCount 1 -KeyName tutorialkeypair -SecurityGroupId sg-9b4278e3 -InstanceType t1.micro -SubnetId subnet-eb3d658c9

# Stop Instance

Stop-EC2Instance -Instance i-icbf3538

# Setup commands to run by new instance on startup

$userDataString = @" 
<powershell>
New-EventLog -LogName Application -Source "My EC2 Init"
Write-EventLog -LogName Application -Source "My EC2 Init" -EntryType Information -EventID 1
    -Message "Hello World"
</powershell>
"@


New-EC2Instance -ImageId ami-3cc4b51 -MinCount 1 -MaxCount 1 -KeyName tutorialkeypair -SecurityGroupId sg-9b4278e3 -InstanceType t1.micro -SubnetId subnet-eb3d658c9 -EncodeUserData -UserData $userDataString

# Create Tag

New-EC2Tag -Resource i-bc9e7220 -Tag @( @{key="Name"; value="tutorialserver7"})


# Sending Notifications using SNS

Publish-SNSMessage -TopicArn arn:aws:sns:us-east-1:369789454354:AdminAlert -Subject "Hello World" -Message "Here is the message"

# Get number of users currently logged on to the host

$numberofusers = (Get-WmiObject Win32_Process -filter 'name="explorer.exe"' -ComputerName $env:COMPUTERNAME |
                ForEach-Object { $owner = $_.GetOwner(); '{0}\{1}' -f $owner.Domain, $owner.User } |
                Sort-Object |Get-Unique).Count

# Report the metric

$dat = New-Object Amazon.CloudWatch.Model.MetricDatum
$dat.Timestamp = (Get-Date).ToUniversalTime()
$dat.MetricName = "LoggedInUsers"
$dat.Unit = "Count"
$dat.Value = $numberofusers
Write-CWMtricData -Namespace "Usage Metrics" -MetricData $data 

# Get A list of volumes attached to an instance where Backup=True and snapshot them
$volumes - Get-EC2Volume

# For each volume, snapshot
foreach($vol in $volumes)
{
    $instanceId = ""
    if ($vol.Attachment -ne null)
    {
        $instanceId = $vol.Attachment.InstanceId
        $shouldSnapshot = Get-EC2Tag |
            Where-Object -Property "ResourceId" -eq "$instanceId" |
            Where-Object -Property "Key" -eq "Backup" |
             Select-Object -ExpandProperty Value

        if ($shouldSnapshot -eq "True")
        {
            $instanceName = Get-EC2Tag | Where-Object -Property "ResourceId" -eq "$instanceId" |
                Where-Object -Property "Key" -eq "Name" |
                    Select-Object -ExpandProperty Value
            Write-Host ("Taken snapshot of {0} for instance {1}" -f $vol.Attachment.Device, $instanceName)
            New-EC2Snapshot -VolumeId $vol.VolumeId -Description ("{0}-{1}" -f $instanceName.$vol.Attachment.Device)

        }
    
    
    }

}


# For each volume, that is attached to an instance , cleanup old snapshots
foreach($vol in $volumes)
{
    $instanceId = ""
    if ($vol.Attachment -ne null)
    {
        $instanceId = $vol.Attachment.InstanceId
        $shouldSnapshot = Get-EC2Tag |
            Where-Object -Property "ResourceId" -eq "$instanceId" |
            Where-Object -Property "Key" -eq "Backup" |
             Select-Object -ExpandProperty Value

        if ($shouldSnapshot -eq "True")
        {
           # Get all snapshots for this volume
           $filter = New-Object Amazon.EC2.Model.Filter
           $filter.Name = "volume-id"
           $filter.Value.Add($vol.VolumeId)

           # Delete snapshots that are greater than 10 days old
           $daysback = 10
           $snapshots = get-EC2Snapshot -Filter $filter
           for each($snapshot in $snapshots)
           {
                $id = ([DateTime]::Now).AddDays(-$daysBack)
                if ([DateTime]::Compare($d, $Snapshot.StartTime) -get 0)
                {
                    Write-Host "Removed snpashot of " $snapshot.SnapshotId
                    Remove-EC2Snapshot -SnapshotId $s.SnapshotId
                }
           }

        }
    
    
    }

}
