Import-Module WebAdministration

$array= Get-ChildItem -Path "D:\github_staging\apis\" -Directory -Filter *gha* -Recurse 

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
	# $parentName


	$Sites= "GithubSites\apis\" + $parentName
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
		
		$appPoolName = $parentTitle +"-"+ $appfoldername
		# $appPoolName

		if (!(Test-Path "IIS:\AppPools\$appPoolName")){
			New-WebAppPool -Name $appPoolName
			Set-ItemProperty -Path IIS:\AppPools\$appPoolName managedRuntimeVersion ""
		}

		$existingAppName= "apis\"+ $parentName + $appfoldername
		$existingAppName=$existingAppName.replace("\","/")
		# $existingAppName

		if(!(Get-WebApplication -Name $existingAppName)){
		New-WebApplication -Site $Sites -Name $appfoldername -PhysicalPath "$childfolderpath" -ApplicationPool $appPoolName 
		}
		

		if(Get-WebApplication -Name $existingAppName){
		$appobj= Get-WebApplication -Name $existingAppName
		foreach ($appObj in $appobj){

		$appPath= $appObj.PhysicalPath
		
		$parentsappPath= Split-Path -Path $appPath
		
		if (($parentsappPath -eq $parent)){

		if(!($appPath -eq $childfolderpath)){
		Write-Host 1
		Remove-WebApplication -Site "GithubSites" -Name $existingAppName
		New-WebApplication -Site $Sites  -Name $appfoldername -PhysicalPath "$childfolderpath" -ApplicationPool $appPoolName
		}

		}
		}
		}
	}
	}
	
	
	
	
	
}







<# foreach($folderitem in $array){
    
    $folderpath= $folderitem | % { $_.FullName }

    $foldername= $folderitem.Name
    
    if (!(Get-WebApplication -Name $foldername)){
        $pathsplit= $foldername -split "-v"
	$mainfolder= $pathsplit[0]
	
	if (Get-WebApplication -Name $mainfolder){
	Remove-WebApplication -Name $mainfolder -Site "GithubSites\apis"
	}
	
	if (!(Test-Path "IIS:\AppPools\$mainfolder)){
        New-WebAppPool -Name $foldername -Force
        Set-ItemProperty -Path IIS:\AppPools\$mainfolder managedRuntimeVersion ""
	}

        New-WebApplication -Name $mainfolder -Site "GithubSites\apis" -PhysicalPath $folderpath -ApplicationPool $foldername
	
    }
} #>


	# if (!(Test-Path "IIS:\AppPools\$mainfolder")){
        # New-WebAppPool -Name $foldername -Force
        # Set-ItemProperty -Path IIS:\AppPools\$mainfolder managedRuntimeVersion ""
	# }


