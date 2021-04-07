Import-Module WebAdministration

$array= Get-ChildItem -Path "D:\test_1_soiver8\github_staging\apis\" -Directory -Filter *gha* -Recurse 
$skipParentArr= @() 
foreach($folderitem in $array){
    
    $folderpath= $folderitem | % { $_.FullName }
	
	$parent= Split-Path -Path $folderpath 
	# $parent



	# $parentName= Split-Path -Path $folderpath | Split-Path -Leaf
	$C1= Split-Path -Path $folderpath -Leaf
	$parentName= $folderpath -split "apis\\"
	$parentName =$parentName[1]
	$parentTitle= $parentName -split "\\"
	$parentTitle= $parentTitle[0]
	$parentName =$parentName -split $C1
	$parentName= $parentName[0]
	if ($parentName -eq ""){
		$parentTitle = "apis"
	}
	# $parentTitle
	# $parentName


	if (!($skipParentArr -contains $parentName)){
	$skipParentArr+= $parentName
	}
	else {
		continue
	}
	
	# Comment => Sites= Default Web Site/github_staging/apis/ <--- end with '/'
	$Sites= "Default Web Site/github_staging/apis/" + $parentName
	# $Sites

	$children= Get-ChildItem -Path $parent -Directory -Filter *gha* 
	# $children

	$version= 0 
	foreach($childfolderitem in $children){
	
	$childfolderpath= $childfolderitem | % { $_.FullName }
	
	# $childfolderpath

    $childfoldername= $childfolderitem.Name
	# $childfoldername
	$pathsplit= $childfoldername -split "-v"
	$versionchecked= [int]$pathsplit[1]
	
	if ($version -lt $versionchecked){
		$version= $versionchecked
		# $version
	}
	}
	
	foreach($childfolderitem in $children){
	
	$childfolderpath= $childfolderitem | % { $_.FullName }
	
	# $childfolderpath

    $childfoldername= $childfolderitem.Name
	# $childfoldername
	$pathsplit= $childfoldername -split "-v"
	$versionchecked= [int]$pathsplit[1]
	
	if ($version -eq $versionchecked){
		# $versionchecked
		$appfoldername= $pathsplit[0]
		
		#------Not used --- Could be Skipped -------------------------
		$stepupfolder= Split-Path -Parent $childfolderpath | Split-Path -Leaf
		
		$appfolderpathshort= $childfolderpath	
		# or
		
		# $appfolderpathshort= "*" + $stepupfolder + "/"+ $appfoldername
		# $appfolderpathshort
		#------Could be Skipped -------------------------	
		
		$appPoolName = $parentName + $appfoldername
		$appPoolName= $appPoolName.replace("\","-")
		# $appPoolName

		if (!(Test-Path "IIS:\AppPools\$appPoolName")){
			New-WebAppPool -Name $appPoolName
			Set-ItemProperty -Path IIS:\AppPools\$appPoolName managedRuntimeVersion ""
		}

		$existingAppName= "github_staging\apis\"+ $parentName + $appfoldername
		$existingAppName=$existingAppName.replace("\","/")
		# $existingAppName

		if(!(Get-WebApplication -Name $existingAppName)){
		New-WebApplication -Site $Sites -Name $appfoldername -PhysicalPath "$childfolderpath" -ApplicationPool $appPoolName 
		Write-Host "New application created"
		}
		

		if(Get-WebApplication -Name $existingAppName){
		$appobj= Get-WebApplication -Name $existingAppName
		foreach ($appObj in $appobj){

		$appPath= $appObj.PhysicalPath
		
		$parentsappPath= Split-Path -Path $appPath
		
		if (($parentsappPath -eq $parent)){

		if(!($appPath -eq $childfolderpath)){
		Remove-WebApplication -Site "Default Web Site" -Name $existingAppName
		New-WebApplication -Site $Sites  -Name $appfoldername -PhysicalPath "$childfolderpath" -ApplicationPool $appPoolName
		}

		}
		}
		}
	}
	}
	
	
	
	
	
}
