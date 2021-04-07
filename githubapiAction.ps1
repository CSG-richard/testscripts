$devName = "charlie"
$OptFeatureFolderName="feature1"
$apiName = "ContractSystemAPI"

if (!($OptFeatureFolderName.length -eq 0)){$OptFeatureFolderName= "\" + $OptFeatureFolderName}

$virtualpath = "github_staging\apis\" + $devName + $OptFeatureFolderName + "\gha" + $apiName

$Testreleasepath = "D:\test_1_soiver8\" + "$virtualpath" + "*"
$releasepath = "D:\test_1_soiver8\" + "$virtualpath" + "-v0"
if (Test-Path $Testreleasepath){    
$measurepath= "D:\test_1_soiver8\github_staging\apis\$devName$OptFeatureFolderName"
$split= $releasepath -split "-v"
$childfolder= Get-ChildItem -Path $measurepath -Directory -Filter *gha*
$latest = 0
$number1=0
$number2=0
$iter=0
foreach($child in $childfolder){
$childFragments= $child -split "-v"

$number1= [int]$childFragments[1]
if($iter -eq 0){
$iter=1
$number2= $number1
}
if ($number2 -gt $number1){
$number2= $number1
}




$version= [int]$childFragments[1]
if ($latest -lt $version){
$latest= $version
}
}
$measure = Get-ChildItem -Path $measurepath -Directory -Filter *gha* | Measure-Object
$count = $measure.count
if ($count -gt 4)      
{
$deletepath= $split[0] + "-v" +$number2
Remove-Item -Path $deletepath -Recurse
}

$latest= [int]$latest+ 1
$releasepath= $split[0] + "-v" + $latest
$releasepath
echo "



New release version v-$latest is assigned

"
}
else{
echo "


This is the first time you are publishing to this folder path
'-v0' is attached to the end of API name in folderpath




"
}